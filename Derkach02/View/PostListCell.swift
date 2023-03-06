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
    
    func config(post: Post?) {
        guard let post = post else {
            return
        }
        let controller = PostViewController()
        postDataLabel.text = controller.buildPostDataString(for: post)
        postTitleLabel.text = post.title
        controller.loadImage(from: URL(string: post.url)!, imageView: postImageView)
        likesButton.setTitle(String(post.score), for: .normal)
        commsButton.setTitle(String(post.num_comments), for: .normal)
    }
}
