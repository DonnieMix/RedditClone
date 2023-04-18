//
//  PostViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 24.02.2023.
//

import UIKit
import SwiftUI

class PostDetailsViewController: UIViewController {

    @IBOutlet private var mainView: UIView!
    @IBOutlet private weak var postView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var postDataLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var postImage: UIImageView!
    
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var likesButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    @IBOutlet private weak var commentListContainerView: UIView!
    
    private var post: PostDetails?
    private var bookmarkLayer: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSaveButton()
        setFields()
        
        let swiftUIListView = CommentListView(comments: loadCommentsForPost(post: post))
        let commentListViewController: UIViewController = UIHostingController(rootView: swiftUIListView)
        let commentListView: UIView = commentListViewController.view
        self.commentListContainerView.addSubview(commentListView)
        
        commentListView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            commentListView.topAnchor.constraint(equalTo: self.commentListContainerView.topAnchor),
            commentListView.bottomAnchor.constraint(equalTo: self.commentListContainerView.bottomAnchor),
            commentListView.trailingAnchor.constraint(equalTo: self.commentListContainerView.trailingAnchor),
            commentListView.leadingAnchor.constraint(equalTo: self.commentListContainerView.leadingAnchor)
        ])
        commentListViewController.didMove(toParent: self)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        postView.addGestureRecognizer(doubleTapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+100)
    }
    
    func loadCommentsForPost(post: PostDetails?) -> [Comment]? {
        guard let permalink = post?.post.permalink else {
            return nil
        }
        let urlString = "https://www.reddit.com\(permalink).json"
        guard let url = URL(string: urlString) else {
                return nil
            }
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _, _) = URLSession.shared.synchronousDataTask(urlrequest: request)
        
        guard let data = data else {
            return nil
        }
        guard let totalJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
              let commentData = try? JSONSerialization.data(withJSONObject: totalJson[1], options: [])
        else {
            return nil
        }
        let commentsStruct = try? JSONDecoder().decode(CommentsStruct.self, from: commentData)
        guard let commentsStruct = commentsStruct else {
            return nil
        }
        return commentsStruct.data.children.map {$0.data}
    }
    
    @objc func handleDoubleTap() {
        if let existingBookmarkLayer = bookmarkLayer {
            existingBookmarkLayer.removeAllAnimations()
            existingBookmarkLayer.removeFromSuperlayer()
            bookmarkLayer = nil
        }
        animateBookmarkIcon()
        if !(post?.isSaved ?? true) {
            onSaveClick(saveButton!)
        }
    }
    
    func animateBookmarkIcon() {
        let width = scrollView.contentSize.width/10
        let height = width + width/4
        let regularBookmarkPath = getBookmarkScaledBezierPath(width: width, height: height)
        
        let smallWidth = width / 10
        let smallHeight = height / 10
        let smallBookmarkPath = getBookmarkScaledBezierPath(width: smallWidth, height: smallHeight)
        
        let popoutWidth = width * 1.2
        let popoutHeight = height * 1.2
        let popoutBookmarkPath = getBookmarkScaledBezierPath(width: popoutWidth, height: popoutHeight)
        
        bookmarkLayer = CAShapeLayer()
        guard let bookmarkLayer = bookmarkLayer else {
            return
        }
        bookmarkLayer.path = regularBookmarkPath.cgPath
        bookmarkLayer.strokeColor = UIColor.white.cgColor
        bookmarkLayer.fillColor = UIColor.white.cgColor
        bookmarkLayer.lineWidth = 2.0
        
        scrollView.layer.addSublayer(bookmarkLayer)
        
        let popoutAnimation = CABasicAnimation(keyPath: "path")
        popoutAnimation.duration = 0.1
        popoutAnimation.fromValue = smallBookmarkPath.cgPath
        popoutAnimation.toValue = popoutBookmarkPath.cgPath
        popoutAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        bookmarkLayer.add(popoutAnimation, forKey: "popoutAnimation")
        
        let toRegularSizeAnimation = CABasicAnimation(keyPath: "path")
        toRegularSizeAnimation.duration = 0.1
        toRegularSizeAnimation.fromValue = popoutBookmarkPath.cgPath
        toRegularSizeAnimation.toValue = regularBookmarkPath.cgPath
        toRegularSizeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        toRegularSizeAnimation.beginTime = CACurrentMediaTime() + 0.1
        
        bookmarkLayer.add(toRegularSizeAnimation, forKey: "toRegularSizeAnimation")
        
        let animationOut = CABasicAnimation(keyPath: "opacity")
        animationOut.duration = 0.1
        animationOut.fromValue = 1
        animationOut.toValue = 0
        animationOut.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animationOut.beginTime = CACurrentMediaTime() + 1.0
        
        bookmarkLayer.add(animationOut, forKey: "opacityAnimationOut")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            bookmarkLayer.removeFromSuperlayer()
        }
    }
    
    func getBookmarkScaledBezierPath(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let bookmarkPath = UIBezierPath()
        let x = scrollView.contentSize.width/2 - width/2
        let y = scrollView.contentSize.height/2 - height/2
        bookmarkPath.move(to: CGPoint(x: x, y: y))
        bookmarkPath.addLine(to: CGPoint(x: x + width, y: y+0))
        bookmarkPath.addLine(to: CGPoint(x: x + width, y: y + height))
        bookmarkPath.addLine(to: CGPoint(x: x + width/2, y: y + height/2 + height/8))
        bookmarkPath.addLine(to: CGPoint(x: x+0, y: y + height))
        bookmarkPath.close()
        return bookmarkPath
    }
    
    func setPost(post: PostDetails) {
        self.post = post
    }
    
    func setFields() {
        guard let post = post else {
            return
        }
        postDataLabel.text = buildPostDataString(for: post.post)
        titleLabel.text = post.post.title
        if let image = post.image {
            postImage.image = image
        } else {
            loadImage(from: URL(string: post.post.url), imageView: postImage)
        }
        likesButton.setTitle(String(post.post.score), for: .normal)
        commentsButton.setTitle(String(post.post.num_comments), for: .normal)
    }
    
    func initSaveButton() {
        guard let post = post else {
            return
        }
        if (!post.isSaved) {
            saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        else {
            saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func loadImage(from url: URL?, imageView: UIImageView) {
        guard let url = url else {
            return
        }
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func buildPostDataString(for post: Post) -> String {
        let author_fullname: String = post.author
        
        let time: String = TimeAgoCalculator.timeAgoSinceDate(Date(timeIntervalSince1970: post.created_utc))
        let domain: String = post.domain
        return author_fullname + " • " + time + " • " + domain
    }
    
    func getPostFromURL(_ url: String) -> Post? {
        guard let url = URL(string: url) else {
                return nil
            }
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _, _) = URLSession.shared.synchronousDataTask(urlrequest: request)
        
        guard let json = data else {
            return nil
        }
        let postStruct = try? JSONDecoder().decode(PostStruct.self, from: json)
        guard let postDataChildren = postStruct?.data.children else {
            return nil
        }
        let posts = postDataChildren.map { $0.data }
        return posts[0]
    }

    @IBAction func onSaveClick(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        guard let post = post else {
            return
        }
        if (post.isSaved) {
            post.isSaved = false
            button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        else {
            post.isSaved = true
            button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    @IBAction func onLikeClick(_ sender: Any) {
    }
    
    @IBAction func onCommentClick(_ sender: Any) {
    }
    
    @IBAction func onShareClick(_ sender: Any) {
        guard let permalink = post?.post.permalink else {
            return
        }
        
        let link = "https://www.reddit.com\(permalink)"
        let activityViewController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        DispatchQueue.main.async {[self] in
            present(activityViewController, animated: true, completion: nil)
        }
        
    }
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}
