//
//  CommentDetailView.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 09.04.2023.
//

import SwiftUI

struct CommentDetailView: View {
    var comment: Comment
    
    var replies: [Comment]? {
        guard let children = comment.replies?.data.children else {
            return nil
        }
        return children.map { $0.data }
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("\(comment.author) • \(TimeAgoCalculator.timeAgoSinceDate(Date(timeIntervalSince1970: comment.created_utc)))")
                        .bold()
                        .font(.system(size: 20))
                        .padding(.bottom, 1)
                    Text("\(comment.body)")
                        .font(.system(size: 24))
                        .padding(.bottom, 1)
                    Button(action: {}){
                        HStack {
                            Image(systemName: "arrow.up")
                            Text("\(comment.score)")
                        }
                    }
                    .font(.system(size:22))
                }
                .frame(alignment:.leading)
                .padding(.leading)
                Button(action: {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let url = URL(string: "https://www.reddit.com\(comment.permalink)") else {
                        return
                    }
                    let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    windowScene.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                }) {
                    HStack {
                        Spacer()
                        Text("Share")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        Spacer()
                    }
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                if let replies = replies {
                    HStack(alignment:.top) {
                        Divider()
                        CommentRawListView(comments: replies)
                            .frame(maxWidth: .infinity, alignment:.leading)
                        Spacer()
                        
                    }
                    .padding(.leading)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CommentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommentDetailView(comment: Comment(id: "1",
                    author: "Author",
                    created_utc: 123,
                    title: "Title", score: 2, replies: nil, permalink: "123"))
    }
}
