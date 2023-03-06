//
//  PostListViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 03.03.2023.
//

import UIKit

class PostListViewController : UIViewController {
    
    private var cellAmount: [Int] = Array(0..<1000)

    private var loadedPosts: [Post] = []
    private var after: String? = nil
    
    private let group: DispatchGroup = DispatchGroup()
    private var processing: Bool = false
    
    struct Const {
        static let cellReuseIdentifier = "Post List Cell"
        static let showPost = "showPost"
    }
    
    @IBOutlet private var postListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postListView.delegate = self
        loadNextPosts(amount: 20)
        for index in 0..<postListView.visibleCells.count {
            configureCell(postListView.visibleCells[index] as! PostListCell, index: index)
        }
    }
    
    func configureCell(_ cell: PostListCell, index: Int) {
       
        cell.config(post: loadedPosts[index])
    }
    
    func loadNextPosts(amount: Int) {
        cellAmount.append(contentsOf: Array(cellAmount.count..<cellAmount.count+20))
        
        let endOfURL = (after != nil) ? "&after=\(after!)" : ""
        guard let url = URL(string: "https://www.reddit.com/r/ios/top.json?limit=\(amount)\(endOfURL)") else {
                return
            }
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _, _) = URLSession.shared.synchronousDataTask(urlrequest: request)
        
        guard let json = data else {
            return
        }
        let postStruct = try? JSONDecoder().decode(PostStruct.self, from: json)
        guard let postDataChildren = postStruct?.data.children else {
            return
        }
        let posts = postDataChildren.map { $0.data }
        after = postStruct?.data.after
        loadedPosts.append(contentsOf: posts)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            switch segue.identifier
            {
            case Const.showPost:
                let nextVC = segue.destination as! PostViewController
                let index = postListView.indexPathForSelectedRow!.row
                let postToOpen = loadedPosts[index]
                nextVC.setPost(post: postToOpen)
            default:
                break
            }
        }
    
}

extension PostListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        self.cellAmount.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        print("indexpath row \(indexPath.row), loadedPosts.count \(loadedPosts.count)")
        
        // if user is close to last loaded post and new portion isn't being loaded, start loading new portion
        if indexPath.row >= loadedPosts.count - 5 && !processing {
            processing = true
            group.enter()
            DispatchQueue.global(qos: .default).async {[self] in
                loadNextPosts(amount: 20)
                group.leave()
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostListCell
        // wait if user goes further than loaded posts
        if(indexPath.row >= loadedPosts.count) {
            // if user jumped far from current post, load all posts until we are at user's post
            while(indexPath.row >= loadedPosts.count) {
                group.enter()
                DispatchQueue.global(qos: .default).async {[self] in
                    loadNextPosts(amount: 20)
                    group.leave()
                }
                group.wait()
            }
            group.wait()
            processing = false
        }
        cell.config(post: loadedPosts[indexPath.row])
        
        return cell
    }
    
    
}

extension PostListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        self.performSegue(
            withIdentifier: Const.showPost,
            sender: nil)
    }
}
    
