//
//  PostViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 24.02.2023.
//

import UIKit

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
    
    private var post: PostDetails?
    private var bookmarkLayer: CAShapeLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSaveButton()
        setFields()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        tapGesture.numberOfTapsRequired = 2
        postView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
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
        postImage.image = post.image
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
    
    func loadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func buildPostDataString(for post: Post) -> String {
        let author_fullname: String = post.author
        
        let time: String = timeAgoSinceDate(Date(timeIntervalSince1970: post.created_utc))
        let domain: String = post.domain
        return author_fullname + " • " + time + " • " + domain
    }
    
    func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        if let year = components.year, year >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: date)
        }
        if let month = components.month, month >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: date)
        }
        if let weekOfYear = components.weekOfYear, weekOfYear >= 1 {
            return "\(weekOfYear)w"
        }
        if let day = components.day, day >= 1 {
            return "\(day)d"
        }
        if let hour = components.hour, hour >= 1 {
            return "\(hour)h"
        }
        if let minute = components.minute, minute >= 1 {
            return "\(minute)m"
        }
        if let second = components.second, second >= 3 {
            return "\(second)s"
        }
        return "just now"
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
