//
//  PostListCell.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 03.03.2023.
//

import UIKit

class PostListCell : UITableViewCell {
    @IBOutlet weak var postView: UIView!
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var postDataLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commsButton: UIButton!
    
    private var post: PostDetails?
    
    func config(post: PostDetails) {
        self.post = post
        let controller = PostDetailsViewController()
        if let image = post.image {
            postImageView.image = image
        }
        postDataLabel.text = controller.buildPostDataString(for: post.post)
        postTitleLabel.text = post.post.title
        if Reachability.isConnectedToNetwork() {
            controller.loadImage(from: URL(string: post.post.url)!, imageView: postImageView)
        }
        post.isSaved ? saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal) : saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        likesButton.setTitle(String(post.post.score), for: .normal)
        commsButton.setTitle(String(post.post.num_comments), for: .normal)
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
}
