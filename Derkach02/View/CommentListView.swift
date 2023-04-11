//
//  CommentListView.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 07.04.2023.
//

import SwiftUI

struct CommentListView: View {
    var comments: [Comment]
    
    var body: some View {
        NavigationView {
            List(comments) { comment in
                NavigationLink {
                    CommentDetailView(comment: comment)
                } label: {
                    CommentCellView(comment: comment, showShare: false)
                }
            }
        }
        .navigationTitle("Comments")
    }
}

struct CommentListView_Previews: PreviewProvider {
    static var previews: some View {
        CommentListView(comments: [Comment(id: "1",
                    author: "Author",
                    created_utc: 123,
               title: "Title", score: 2, replies: RepliesStruct(data:
                Replies(children:[
                CommentsDataChild(data:
                Comment(id: "3", author: "another", created_utc: 123, title: "Another title", score: 5, replies: RepliesStruct(data:
                                                                                                                                Replies(children:[
                                                                                                                                CommentsDataChild(data:
                                                                                                                                Comment(id: "5", author: "another", created_utc: 123, title: "Answer on that", score: 5, replies: nil, permalink: "123")
                                                                                                                                                 )
                                                                  ]
                                                                                                                                       )
                                                                                                                                                                               ), permalink: "123")
                                 ),CommentsDataChild(data:
                                                        Comment(id: "3", author: "another", created_utc: 123, title: "Another title", score: 5, replies: RepliesStruct(data:
                                                                                                                                                                        Replies(children:[
                                                                                                                                                                        CommentsDataChild(data:
                                                                                                                                                                        Comment(id: "5", author: "another", created_utc: 123, title: "Answer on that", score: 5, replies: nil, permalink: "123")
                                                                                                                                                                                         )
                                                                                                          ]
                                                                                                                                                                               )
                                                                                                                                                                                                                       ), permalink: "123")
                                                                         )
                                ]
                       )
                                                               ), permalink: "123")])
    }
}
