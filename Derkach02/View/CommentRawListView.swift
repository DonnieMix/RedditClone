//
//  CommentRawListView.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 09.04.2023.
//

import SwiftUI

struct CommentRawListView: View {
    var comments: [Comment]
    
    func getReplies(comment: Comment) -> [Comment]? {
        guard let children = comment.replies?.data.children else {
            return nil
        }
        return children.map { $0.data }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(comments, id: \.id) { comment in
                CommentCellView(comment: comment)
                if let replies = getReplies(comment: comment) {
                    HStack(alignment:.top) {
                        Spacer()
                        Divider().frame(alignment:.leading)
                        CommentRawListView(comments: replies).frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                           
                    }
                    .frame(alignment: .leading)
                    .padding(.leading, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CommentRawListView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}
