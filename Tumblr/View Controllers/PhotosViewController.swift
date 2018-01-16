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
    
    var selectedIndex : NSInteger! = -1 //Declare this globally
    var i = 1 // Used to make sure try again alert only shows once
    var userQueryFormatted: String = "humansofnewyork"
    @IBOutlet weak var searchBar: UISearchBar!
    
    let alertController = UIAlertController(title: "Cannot get feed", message: "The internet connection appears to be offline", preferredStyle: .alert)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == selectedIndex{
            selectedIndex = -1
        }else{
            selectedIndex = indexPath.section
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == selectedIndex
        {
            return 226
        }else{
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        let profileView = UIImageView(frame: CGRect(x: 10, y: 0, width: 27.5, height: 27.5))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        let label = UILabel(frame: CGRect(x: 50, y: 0, width: 300, height: 30))
        label.clipsToBounds = true
        label.layer.cornerRadius = 15;
        let post = posts[section]
        let timestamp = (post["timestamp"]!)
        let date = NSDate(timeIntervalSince1970: timestamp as! TimeInterval)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd, YYYY, hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        label.text = "\(dateString)"
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/" + userQueryFormatted + ".tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        headerView.addSubview(label)
        return headerView
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.section] // Now uses section number instead of row
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
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkText.withAlphaComponent(0.8)
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
        userQueryFormatted = "humansofnewyork"
        if !(userQuery?.isEmpty)! {
            userQueryFormatted = (userQuery?.replacingOccurrences(of: " ", with: ""))! // If something was searched, get the query and remove spaces
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
        let url = URL(string: totalUrl)!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { (action) in
                    self.fetchFeed(temp)
                }
                if self.i == 1 {
                    // add the try again action to the alert controller
                    self.alertController.addAction(tryAgainAction)
                    self.i = self.i + 1
                }
                self.present(self.alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
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
    ////////////////////////////////////////////////
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! PhotoDetailsViewController
        let cell = sender as! PhotoCell
        let indexPath = photosTableView.indexPath(for: cell)!
        let post = posts[indexPath.row]
        
        destinationViewController.image = cell.pictureView.image
//        if let photos = post["photos"] as? [[String: Any]] {
//            // photos is NOT nil, we can use it!
//            // 1.
//            let photo = photos[0]
//            // 2.
//            let originalSize = photo["original_size"] as! [String: Any]
//            // 3.
//            let urlString = originalSize["url"] as! String
//            // 4.
//            let url = URL(string: urlString)
//
//            destinationViewController.detailViewPicture.af_setImage(withURL: url!) // Results in segfault
//        }
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor.darkText.withAlphaComponent(0.8)
//        cell.selectedBackgroundView = backgroundView
        
        //return cell
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
