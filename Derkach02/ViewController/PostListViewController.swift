//
//  PostListViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 03.03.2023.
//

import UIKit

class PostListViewController : UIViewController {
    
    private var cellAmount: Int = 0

    private var loadedPosts: [PostDetails] = []
    private var filteredPosts: [PostDetails] = []
    private var after: String? = nil
    
    private let group: DispatchGroup = DispatchGroup()
    private var processing: Bool = false
    private var toUpdate: Bool = false
    private var isFilterPressed: Bool = false
    
    
    struct Const {
        static let cellReuseIdentifier = "Post List Cell"
        static let showPost = "showPost"
    }
    
    
    @IBOutlet weak var filterSavedButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet private var postListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postListView.delegate = self
        self.searchField.delegate = self
        if Reachability.isConnectedToNetwork() {
            loadNextPosts(amount: 20)
            filteredPosts = loadedPosts
            postListView.reloadData()
            savePostsToJson()
            for index in 0..<postListView.visibleCells.count {
                configureCell(postListView.visibleCells[index] as! PostListCell, index: index)
                
            }
        } else {
            loadedPosts = loadPostsFromJson()
            filteredPosts = loadedPosts
            for row in 0..<postListView.numberOfRows(inSection: 0) {
                postListView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
            }
        }
    }
    
    func configureCell(_ cell: PostListCell, index: Int) {
       
        cell.config(post: loadedPosts[index])
    }
    
    @IBAction func onFilterSavedButtonClick(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        if isFilterPressed {
            button.setImage(UIImage(systemName: "bookmark.circle"), for: .normal)
            isFilterPressed = false
            filteredPosts = loadedPosts
            cellAmount = filteredPosts.count
            postListView.reloadData()
            
            self.searchField.isHidden = true
        } else {
            button.setImage(UIImage(systemName: "bookmark.circle.fill"), for: .normal)
            isFilterPressed = true
            filteredPosts = loadedPosts.filter({$0.isSaved})
            cellAmount = filteredPosts.count
            postListView.reloadData()
            
            searchField.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.searchField.center.x -= self.view.bounds.width * (self.searchField.isHidden ? 1 : -1)
            }
        }
    }
    
    func loadNextPosts(amount: Int) {
        cellAmount += amount
        
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
        if Reachability.isConnectedToNetwork() {
            for post in loadedPosts {
                post.image = loadImage(from: URL(string: post.post.url)!)
            }
        }
        filteredPosts = loadedPosts
        savePostsToJson()
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
                print("Written to: \(fileURL)")
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
                let postToOpen = filteredPosts[index]
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
        self.cellAmount
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        print("indexpath row \(indexPath.row), loadedPosts.count \(loadedPosts.count)")
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostListCell
        if Reachability.isConnectedToNetwork() {
            // if user is close to last loaded post and new portion isn't being loaded, start loading new portion
            if indexPath.row >= loadedPosts.count - 5 && !processing {
                processing = true
                group.enter()
                DispatchQueue.global(qos: .default).async {[self] in
                    loadNextPosts(amount: 20)
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
                        toUpdate = true
                        group.leave()
                    }
                    group.wait()
                }
                group.wait()
                processing = false
            }
        }
        cell.config(post: filteredPosts[indexPath.row])
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

extension PostListViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filteredPosts = searchText.isEmpty ?
            (isFilterPressed ?
                loadedPosts.filter({$0.isSaved}) :
                loadedPosts)
            : loadedPosts.filter({$0.isSaved}).filter { $0.post.title.range(of: searchText, options: .caseInsensitive) != nil }
        self.cellAmount = filteredPosts.count
            postListView.reloadData()
            return true
        }
}
    
