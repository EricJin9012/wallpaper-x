//
//  NewaddedViewController.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/8.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class NewaddedViewController: UIViewController {

    @IBOutlet weak var wallImageCV: UICollectionView!
    
    let segueToFull = "segueNewToFull"
    let reuseIdentifier = "NewCVCell"

    var categoryName: String = ""
    var wallList = [Wallpaper]()
    var wallImageArray = [UIImage?]()
    var tasks = [URLSessionDataTask?]()
    var refWallX: DatabaseReference!

    var wallImages = [String]()
    var selIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.setScreenName("NewaddedView", screenClass: "NewaddedViewController")
        loadWallsFromFirebase()

    }

    @IBAction func onGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToFull {
            let controller = segue.destination as! FullViewController
            controller.wallObject = wallList[self.selIndex]
        }
    }

}

extension NewaddedViewController: UICollectionViewDelegate,
    UICollectionViewDataSourcePrefetching,
    UICollectionViewDataSource {

    // MARK: UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            requestImage(forIndex: indexPath)
        }
    }
    
    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            if let task = tasks[indexPath.row] {
                if task.state != URLSessionTask.State.canceling {
                    task.cancel()
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavouriteCVCell
        if let img = wallImageArray[indexPath.row] {
            cell.wallImageView.image = img
        }
        else {
            requestImage(forIndex: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selIndex = indexPath.row
        performSegue(withIdentifier: segueToFull, sender: self)
    }
}

extension NewaddedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = 2
        let paddingSpace = 25
        let availableWidth: Int = Int(self.view.frame.width)
        let widthPerItem = (availableWidth - paddingSpace * 3) / itemsPerRow
        let heightPerItem = 275 * widthPerItem / 155

        return CGSize(width: widthPerItem, height: heightPerItem)
    }

}

// MARK: Load Data from Firebase

extension NewaddedViewController {
    
    func loadWallsFromFirebase() {
        ProgressHUD.show()
        refWallX = Database.database().reference()
        let query = refWallX.child("wallpaper")
            .queryOrderedByKey()
            .queryLimited(toLast: 10)

        query.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                for walls in snapshot.children.allObjects as! [DataSnapshot] {
                    let wallObject = walls.value as? [String: AnyObject]
                    let aWall = Wallpaper(key: walls.key, dictionary: wallObject!)
                    self.wallList.append(aWall)
                }
                self.wallImageArray = [UIImage?](repeating: nil, count: self.wallList.count)
                self.tasks = [URLSessionDataTask?](repeating: nil, count: self.wallList.count)
            }
            ProgressHUD.dismiss()
            self.wallImageCV.reloadData()
        }
    }

    func urlComponents(index: Int) -> URL {

        let aWall = wallList[index]
        let wallThumb = aWall.thumbnail
        let imgUrl = URL(string: wallThumb)
        return imgUrl!
    }

    func getTask(forIndex: IndexPath) -> URLSessionDataTask {
        let imgURL = urlComponents(index: forIndex.row)
        return URLSession.shared.dataTask(with: imgURL) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {
                let image = UIImage(data: data)!
                self.wallImageArray[forIndex.row] = image
                self.wallImageCV.reloadItems(at: [forIndex])
            }
        }
    }
    
    func requestImage(forIndex: IndexPath) {
        var task: URLSessionDataTask

        if wallImageArray[forIndex.row] != nil {
            // Image is already loaded
            return
        }

        if tasks[forIndex.row] != nil
            && tasks[forIndex.row]!.state == URLSessionTask.State.running {
            // Wait for task to finish
            return
        }

        task = getTask(forIndex: forIndex)
        tasks[forIndex.row] = task
        task.resume()
    }

}

