//
//  Post.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 24.02.2023.
//

import Foundation
import UIKit

struct PostStruct : Codable {
    let data: PostData
}

struct PostData: Codable {
    let after: String?
    let children: [PostDataChild]
}

struct PostDataChild: Codable {
    let data: Post
}

struct Post: Codable {
    let author: String
    let domain: String
    let title: String
    let url: String
    let score: Int
    let num_comments: Int
    let created_utc: TimeInterval
    let permalink: String
}

class PostDetails {
    let post: Post
    var isSaved: Bool
    var image: UIImage?
    
    init(post: Post, isSaved: Bool) {
        self.post = post
        self.isSaved = isSaved
        DispatchQueue.main.async {
            self.image = self.loadImage(from: URL(string: post.url)!)
        }
    }
    
    init(post: PostDetailsForSaving) {
        self.post = post.post
        self.isSaved = post.isSaved
        if  let string = post.imageUrlString,
            let data = Data(base64Encoded: string),
            let image = UIImage(data: data)
        {
            self.image = image
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func loadImage(from url: URL) -> UIImage? {
        var image: UIImage?
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                image = UIImage(data: data)
            }
        }
        return image
    }
}

struct PostDetailsForSaving: Codable {
    let post: Post
    let isSaved: Bool
    let imageUrlString: String?
    
    init(post: PostDetails) {
        self.post = post.post
        self.isSaved = post.isSaved
        self.imageUrlString = post.image?.jpegData(compressionQuality: 1)?.base64EncodedString()
        print(imageUrlString)
    }
}
