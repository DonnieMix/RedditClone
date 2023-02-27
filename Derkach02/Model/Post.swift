//
//  Post.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 24.02.2023.
//

import Foundation
import UIKit

struct PostStruct : Codable{
    let data: PostData
}

struct PostData: Codable {
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
}
