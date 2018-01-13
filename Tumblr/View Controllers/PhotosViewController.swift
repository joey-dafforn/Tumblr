//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Joey Dafforn on 1/10/18.
//  Copyright © 2018 Joey Dafforn. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var selectedIndex : NSInteger! = -1 //Delecre this global
    var i = 1 // Used to make sure try again alert only shows once
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let alertController = UIAlertController(title: "Cannot get feed", message: "The internet connection appears to be offline", preferredStyle: .alert)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == selectedIndex{
            selectedIndex = -1
        }else{
            selectedIndex = indexPath.row
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedIndex
        {
            return 226
        }else{
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]] {
            // photos is NOT nil, we can use it!
            // 1.
            let photo = photos[0]
            // 2.
            let originalSize = photo["original_size"] as! [String: Any]
            // 3.
            let urlString = originalSize["url"] as! String
            // 4.
            let url = URL(string: urlString)
            cell.pictureView.af_setImage(withURL: url!)
        }
        //cell.pictureView.tintColor = UIColor.red
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkText.withAlphaComponent(0.8)
        //cell.pictureView.frame = CGRect(x:0.0,y:0.0,width:365.0,height:216.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.photosTableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    @IBOutlet weak var photosTableView: UITableView!
    var posts: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        photosTableView.insertSubview(refreshControl, at: 0)
        photosTableView.delegate = self
        photosTableView.dataSource = self
        searchBar.delegate = self
        fetchFeed("")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let userQuery = searchBar.text
        var userQueryFormatted = "humansofnewyork"
        if !(userQuery?.isEmpty)! {
            userQueryFormatted = (userQuery?.replacingOccurrences(of: " ", with: ""))! // If something was searched, get the query
            userQueryFormatted = userQueryFormatted.lowercased() // Cast the string to lowercase to comply with API parameters
        }
        fetchFeed(userQueryFormatted)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.resignFirstResponder()
        
    }
    
    func fetchFeed(_ urlString: String) {
        var temp = urlString
        if urlString.isEmpty {
            temp = "humansofnewyork"
        }
        let totalUrl = "https://api.tumblr.com/v2/blog/" + temp + ".tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        print(totalUrl)
        let url = URL(string: totalUrl)!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { (action) in
                    self.fetchFeed(temp)
                }
                if self.i == 1 {
                    // add the try agian action to the alert controller
                    self.alertController.addAction(tryAgainAction)
                    self.i = self.i + 1
                }
                self.present(self.alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                //print(dataDictionary)
                
                // TODO: Get the posts and store in posts property
                // Get the dictionary from the response key
                if dataDictionary["response"] as? [String: Any] == nil {
                    //do nothing
                }
                else {
                    let responseDictionary = dataDictionary["response"] as! [String: Any]
                    self.posts = responseDictionary["posts"] as! [[String: Any]]
                }
                // Store the returned array of dictionaries in our posts property
                
                // TODO: Reload the table view
                self.photosTableView.reloadData()
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
