//
//  ZoomViewController.swift
//  Tumblr
//
//  Created by Joey Dafforn on 1/16/18.
//  Copyright © 2018 Joey Dafforn. All rights reserved.
//

import UIKit

class ZoomViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pictureToBeZoomed: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        pictureToBeZoomed.image = image
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var scrollView: UIScrollView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pictureToBeZoomed
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
