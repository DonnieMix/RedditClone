//
//  Comment.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 09.04.2023.
//

import Foundation

struct CommentsStruct: Codable {
    let data: CommentsData
}

struct CommentsData: Codable {
    let children: [CommentsDataChild]
}

struct CommentsDataChild: Codable {
    let data: Comment
}

struct Comment: Codable, Identifiable {
    let id: String
    let author: String
    let created_utc: TimeInterval
    let body: String
    let score: Int
    let replies: RepliesStruct?
    let permalink: String
    
    init(id: String, author: String, created_utc: TimeInterval, title: String, score: Int, replies: RepliesStruct?, permalink: String) {
        self.id = id
        self.author = author
        self.created_utc = created_utc
        self.body = title
        self.score = score
        self.replies = replies
        self.permalink = permalink
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            author = try container.decode(String.self, forKey: .author)
            created_utc = try container.decode(TimeInterval.self, forKey: .created_utc)
            body = try container.decode(String.self, forKey: .body)
            score = try container.decode(Int.self, forKey: .score)
            
            if let repliesJSONString = try? container.decode(String.self, forKey: .replies),
               let data = repliesJSONString.data(using: .utf8),
               let repliesJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let repliesData = try? JSONSerialization.data(withJSONObject: repliesJSON["data"] as Any, options: []),
               let replies = try? JSONDecoder().decode(RepliesStruct.self, from: repliesData) {
                self.replies = replies
            } else {
                self.replies = nil
            }
            
            permalink = try container.decode(String.self, forKey: .permalink)
        }
}

struct RepliesStruct: Codable {
    let data: Replies
}

struct Replies: Codable {
    let children: [CommentsDataChild]?
}
