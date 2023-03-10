//
//  PostListViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 03.03.2023.
//

import UIKit

class PostListViewController : UIViewController {
    
    private var cellAmount: [Int] = Array(0..<1000)

    private var loadedPosts: [PostDetails] = []
    private var after: String? = nil
    
    private let group: DispatchGroup = DispatchGroup()
    private var processing: Bool = false
    private var toUpdate: Bool = false
    
    struct Const {
        static let cellReuseIdentifier = "Post List Cell"
        static let showPost = "showPost"
    }
    
    @IBOutlet private var postListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postListView.delegate = self
        if Reachability.isConnectedToNetwork() {
            loadNextPosts(amount: 20)
            postListView.reloadData()
            savePostsToJson()
            for index in 0..<postListView.visibleCells.count {
                configureCell(postListView.visibleCells[index] as! PostListCell, index: index)
                
            }
        } else {
            loadedPosts = loadPostsFromJson()
            for row in 0..<postListView.numberOfRows(inSection: 0) {
                postListView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
            }
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
        loadedPosts.append(contentsOf: (posts.map { PostDetails(post: $0, isSaved: Bool.random()) }))
        savePostsToJson()
        
        print(loadPostsFromJson())
    }
    
    func savePostsToJson() {
        let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            var postDetailsForSaving = [PostDetailsForSaving]()
            for post in loadedPosts.filter({$0.isSaved}) {
                let postDetails = PostDetailsForSaving(post: post)
                postDetailsForSaving.append(postDetails)
            }
            
            do {
                let data = try encoder.encode(postDetailsForSaving)
                
                let fileManager = FileManager.default
                let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = documentsDirectory.appendingPathComponent("posts.json")
                
                try data.write(to: fileURL)
                print("Writed to: \(fileURL)")
            } catch {
                print("Error encoding or saving posts: \(error)")
            }
    }
    
    func loadPostsFromJson() -> [PostDetails] {
        var loadedPosts: [PostDetails] = []
            do {
                let fileManager = FileManager.default
                let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = directory.appendingPathComponent("posts.json")
                    let data = try Data(contentsOf: fileURL)
                    let postsForSaving = try JSONDecoder().decode([PostDetailsForSaving].self, from: data)
                    loadedPosts = postsForSaving.map { PostDetails(post: $0) }
            } catch {
                print("Error loading or decoding posts: \(error)")
            }
            return loadedPosts
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
        switch segue.identifier {
            case Const.showPost:
                guard
                    let nextVC = segue.destination as? PostDetailsViewController,
                    let index = postListView.indexPathForSelectedRow?.row
                else {
                    return
                }
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
        //self.cellAmount.count
            self.loadedPosts.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        print("indexpath row \(indexPath.row), loadedPosts.count \(loadedPosts.count)")
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostListCell
        if Reachability.isConnectedToNetwork() {
            print("Internet connected")
            // if user is close to last loaded post and new portion isn't being loaded, start loading new portion
            if indexPath.row >= loadedPosts.count - 5 && !processing {
                processing = true
                group.enter()
                DispatchQueue.global(qos: .default).async {[self] in
                    loadNextPosts(amount: 20)
                    print("in <= 5")
                    toUpdate = true
                    group.leave()
                }
            }
            
            // wait if user goes further than loaded posts
            if(indexPath.row >= loadedPosts.count-1) {
                // if user jumped far from current post, load all posts until we are at user's post
                while(indexPath.row >= loadedPosts.count-1) {
                    group.enter()
                    DispatchQueue.global(qos: .default).async {[self] in
                        loadNextPosts(amount: 20)
                        print("in while")
                        toUpdate = true
                        group.leave()
                    }
                    group.wait()
                }
                group.wait()
                processing = false
            }
        }
        cell.config(post: loadedPosts[indexPath.row])
        if toUpdate {
            postListView.reloadData()
            toUpdate = false
        }
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
    
