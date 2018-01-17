//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Joey Dafforn on 1/15/18.
//  Copyright © 2018 Joey Dafforn. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var detailViewPicture: UIImageView!
    var image: UIImage!
    
    
    @IBAction func zoomGestureRecognizer(_ sender: UITapGestureRecognizer) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailViewPicture.image = image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        
        // Optionally set the number of required taps, e.g., 2 for a double click
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        detailViewPicture.isUserInteractionEnabled = true
        detailViewPicture.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @objc func didTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        // User tapped at the point above. Do something with that if you want.

        performSegue(withIdentifier: "zoomSegue", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! ZoomViewController
        destinationViewController.image = image
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
