//
//  ViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 24.02.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var mainView: UIView!
    @IBOutlet private weak var postView: UIView!
    
    @IBOutlet private weak var postDataLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var postImage: UIImageView!
    
    private var saved: Bool = Bool.random()
    
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var likesButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSaveButton()
        
        guard let post = getPostFromURL("https://www.reddit.com/r/ios/top.json?limit=1") else {
            return
        }
        
        postDataLabel.text = buildPostDataString(for: post)
        titleLabel.text = post.title
        loadImage(url: post.url)
        likesButton.setTitle(String(post.score), for: .normal)
        commentsButton.setTitle(String(post.num_comments), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    func initSaveButton() {
        if (!saved) {
            saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        else {
            saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    func loadImage(url: String) {
        let url = URL(string: url)

        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                self.postImage.image = UIImage(data: data)
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
        if (saved) {
            saved = false
            button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        else {
            saved = true
            button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    @IBAction func onLikeClick(_ sender: Any) {
    }
    
    @IBAction func onCommentClick(_ sender: Any) {
    }
    
    @IBAction func onShareClick(_ sender: Any) {
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
