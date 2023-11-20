//
//  FullViewController.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/10.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import SwiftyStoreKit

class FullViewController: UIViewController {
    
    @IBOutlet weak var wallImageView: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var wallObject: Wallpaper = Wallpaper()
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var refWallX: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.setScreenName("FullView", screenClass: "FullViewController")
        
        refWallX = Database.database().reference()
        let wallPath = wallObject.origin
        let imgUrl = URL(string: wallPath)
        let data = try? Data(contentsOf: imgUrl!)
        if let imageData = data {
            wallImageView.image = UIImage(data: imageData)
        }
        bannerView.adUnitID = "ca-app-pub-4914322139360972/8752206308"
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.backgroundColor = .darkText
        bannerView.load(GADRequest())
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFavorite(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        let favorites = defaults.bool(forKey: "\(wallObject.key)")
        if favorites == true {
            defaults.set(false, forKey: "\(wallObject.key)")
            wallObject.favorites -= 1
            favoriteButton.setImage(UIImage(named: "unfavorite_icon"), for: .normal)
        } else {
            defaults.set(true, forKey: "\(wallObject.key)")
            wallObject.favorites += 1
            favoriteButton.setImage(UIImage(named: "favourite_icon"), for: .normal)
        }
        refWallX.child("wallpaper").child(wallObject.key).setValue(wallObject.getDictionary()) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be favorited: \(error).")
            } else {
                print("Data favorited successfully!")
                Analytics.logEvent("favorite a wall", parameters: [
                    "key": self.wallObject.key as String,
                    "favorites": self.wallObject.favorites as Int
                ])
            }
        }
    }
    
    @IBAction func onDownload(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "isUserSubbed") {
            ProgressHUD.show()
            UIImageWriteToSavedPhotosAlbum(wallImageView.image!, self, #selector(imageX(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            
        }
    }
    
    @objc func imageX(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        ProgressHUD.dismiss()
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            // write downloads to firebase database
            wallObject.downloads += 1
            refWallX.child("wallpaper").child(wallObject.key).setValue(wallObject.getDictionary()) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Data saved successfully!")
                    Analytics.logEvent("download a wall", parameters: [
                        "key": self.wallObject.key as String,
                        "downloads": self.wallObject.downloads as Int
                    ])
                    self.downloadButton.setImage(UIImage(named: "check_icon"), for: .disabled)
                    let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

