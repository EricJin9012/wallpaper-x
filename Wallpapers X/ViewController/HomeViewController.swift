//
//  HomeViewController.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/1.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class PopularThumbnailCVCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
}

class CategoryThumbnailCVCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
}

class NewaddedThumbnailCVCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
}

class ShuffledThumbnailCVCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
}

class HomeViewController: UIViewController {

    @IBOutlet weak var popularCV: UICollectionView!
    @IBOutlet weak var categoryCV: UICollectionView!
    @IBOutlet weak var newaddedCV: UICollectionView!
    @IBOutlet weak var shuffledCV: UICollectionView!
    
    let segueToPolular    = "segueHomeToPopular"
    let segueToCategories = "segueHomeToCategories"
    let segueToNewAdded   = "segueHomeToNew"
    let segueToShuffled   = "segueHomeToShuffled"
    let segueToFull       = "segueHomeToFull"
    let segueToOne        = "segueHomeToOne"


    let polularCellID  = "PopularThumbnailCVCell"
    let categoryCellID = "CategoryThumbnailCVCell"
    let newaddedCellID = "NewaddedThumbnailCVCell"
    let shuffledCellID = "ShuffledThumbnailCVCell"

    var popularList = [Wallpaper]()
    var popularImageArray = [UIImage?]()
    var popularTasks = [URLSessionDataTask?]()

    var newaddedList = [Wallpaper]()
    var newaddedImageArray = [UIImage?]()
    var newaddedTasks = [URLSessionDataTask?]()

    var shuffledList = [Wallpaper]()
    var shuffledImageArray = [UIImage?]()
    var shuffledTasks = [URLSessionDataTask?]()

    var categoryList = [Category]()
    var catCoverArray = [UIImage?]()
    var catTasks = [URLSessionDataTask?]()

    var refWallX: DatabaseReference!

    var selCV = 0
    var selIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.setScreenName("HomeView", screenClass: "HomeViewController")

        loadCategoryFromFirebase()
        loadPopularFromFirebase()
        loadNewaddedFromFirebase()
        loadShuffledFromFirebase()

    }
    
    @IBAction func onSearch(_ sender: UIButton) {
    }
    
    @IBAction func onShowMenu(_ sender: UIButton) {
        if slideMenuController()?.isLeftOpen() == true {
            self.slideMenuController()?.closeLeft()
        } else {
            self.slideMenuController()?.openLeft()
        }
    }
    
// MARK: - Navigation

    @IBAction func onShowPopularNow(_ sender: UIButton) {
        performSegue(withIdentifier: segueToPolular, sender: self)
    }
    
    @IBAction func onShowCategories(_ sender: UIButton) {
        performSegue(withIdentifier: segueToCategories, sender: self)
    }
    
    @IBAction func onShowNewadded(_ sender: UIButton) {
        performSegue(withIdentifier: segueToNewAdded, sender: self)
    }
    
    @IBAction func onShowShuffled(_ sender: UIButton) {
        performSegue(withIdentifier: segueToShuffled, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToFull {
            let controller = segue.destination as! FullViewController
            
            switch self.selCV {
            case 1: // popularCV
                controller.wallObject = popularList[self.selIndex]
                break
                
            case 2: // newaddedCV
                controller.wallObject = newaddedList[self.selIndex]
                break

            case 3: // shuffledCV
                controller.wallObject = shuffledList[self.selIndex]
                break

            default: // 0
                controller.wallObject = popularList[self.selIndex]
            }
        } else if segue.identifier == segueToOne {
            let controller = segue.destination as! OneCategoryViewController
            controller.categoryName = categoryList[self.selIndex].name
        } else if segue.identifier == segueToCategories {
            let controller = segue.destination as! CategoriesViewController
            controller.categoryList = self.categoryList
        }
    }

}

extension HomeViewController: UICollectionViewDataSource,
    UICollectionViewDataSourcePrefetching,
    UICollectionViewDelegate {
    
// MARK: UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            switch collectionView {
            case categoryCV:
                requestCategoryImage(forIndex: indexPath)
                break
            default:
                requestWallImage(collectionView: collectionView, forIndex: indexPath)
            }
        }
    }
    
    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            switch collectionView {
            case popularCV:
                if let task = popularTasks[indexPath.row] {
                    if task.state != URLSessionTask.State.canceling {
                        task.cancel()
                    }
                }
                break
                
            case newaddedCV:
                if let task = newaddedTasks[indexPath.row] {
                    if task.state != URLSessionTask.State.canceling {
                        task.cancel()
                    }
                }
                break
                
            case shuffledCV:
                if let task = shuffledTasks[indexPath.row] {
                    if task.state != URLSessionTask.State.canceling {
                        task.cancel()
                    }
                }
                break
                
            default: // categoryCV
                if let task = catTasks[indexPath.row] {
                    if task.state != URLSessionTask.State.canceling {
                        task.cancel()
                    }
                }
            }
        }
    }

// MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case popularCV:
            return popularImageArray.count

        case categoryCV:
            return catCoverArray.count

        case newaddedCV:
            return newaddedImageArray.count

        case shuffledCV:
            return shuffledImageArray.count

        default:
            return catCoverArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case popularCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: polularCellID, for: indexPath) as! PopularThumbnailCVCell
            if let img = popularImageArray[indexPath.row] {
                cell.thumbnailImageView.image = img
            }
            else {
                requestWallImage(collectionView: collectionView, forIndex: indexPath)
            }
            return cell

        case categoryCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellID, for: indexPath) as! CategoryThumbnailCVCell
            
            if let img = catCoverArray[indexPath.row] {
                cell.thumbnailImageView.image = img
                let aCategory = categoryList[indexPath.row]
                let catName = aCategory.name
                cell.categoryNameLabel.text = catName
                cell.thumbnailImageView.layer.shadowColor = UIColor.darkGray.cgColor
                cell.thumbnailImageView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
                cell.thumbnailImageView.layer.shadowRadius = 25.0
                cell.thumbnailImageView.layer.shadowOpacity = 0.9
            }
            else {
                requestCategoryImage(forIndex: indexPath)
            }
            return cell

        case newaddedCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newaddedCellID, for: indexPath) as! NewaddedThumbnailCVCell
            if let img = newaddedImageArray[indexPath.row] {
                cell.thumbnailImageView.image = img
            }
            else {
                requestWallImage(collectionView: collectionView, forIndex: indexPath)
            }
            return cell

        case shuffledCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shuffledCellID, for: indexPath) as! ShuffledThumbnailCVCell
            if let img = shuffledImageArray[indexPath.row] {
                cell.thumbnailImageView.image = img
            }
            else {
                requestWallImage(collectionView: collectionView, forIndex: indexPath)
            }
            return cell

        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellID, for: indexPath) as! CategoryThumbnailCVCell
            if let img = catCoverArray[indexPath.row] {
                cell.thumbnailImageView.image = img
                let aCategory = categoryList[indexPath.row]
                let catName = aCategory.name
                cell.categoryNameLabel.text = catName
            }
            else {
                requestCategoryImage(forIndex: indexPath)
            }
            return cell
        }

    }
    
// MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selIndex = indexPath.row
        switch collectionView {
        case popularCV:
            self.selCV = 1
            performSegue(withIdentifier: segueToFull, sender: self)
            break
            
        case newaddedCV:
            self.selCV = 2
            performSegue(withIdentifier: segueToFull, sender: self)
            break

        case shuffledCV:
            self.selCV = 3
            performSegue(withIdentifier: segueToFull, sender: self)
            break

        default: // categoryCV
            self.selCV = 4
            performSegue(withIdentifier: segueToOne, sender: self)
        }
    }

}

// MARK: Load Data from Firebase

extension HomeViewController {

    func urlCategoryComponents(index: Int) -> URL {

        let aCategory = categoryList[index]
        let catCover = aCategory.cover
        let imgUrl = URL(string: catCover)
        return imgUrl!
//        var baseUrlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
//        baseUrlComponents?.path = "/\(screenSize.width)x\(screenSize.height * 0.3)"
//        baseUrlComponents?.query = "text=food \(index)"
//        return (baseUrlComponents?.url)!
    }

    func getCategoryTask(forIndex: IndexPath) -> URLSessionDataTask {
        let imgURL = urlCategoryComponents(index: forIndex.row)
        return URLSession.shared.dataTask(with: imgURL) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {
                let image = UIImage(data: data)!
                self.catCoverArray[forIndex.row] = image
                self.categoryCV.reloadItems(at: [forIndex])
            }
        }
    }
    
    func requestCategoryImage(forIndex: IndexPath) {
        var task: URLSessionDataTask

        if catCoverArray[forIndex.row] != nil {
            // Image is already loaded
            return
        }

        if catTasks[forIndex.row] != nil
            && catTasks[forIndex.row]!.state == URLSessionTask.State.running {
            // Wait for task to finish
            return
        }

        task = getCategoryTask(forIndex: forIndex)
        catTasks[forIndex.row] = task
        task.resume()
    }
    
    func loadCategoryFromFirebase() {
        ProgressHUD.show()
        refWallX = Database.database().reference()
        refWallX.child("categories").queryOrderedByKey().observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                for categories in snapshot.children.allObjects as! [DataSnapshot] {
                    let categoriesObject = categories.value as? [String: AnyObject]
                    let aCategory = Category(dictionary: categoriesObject!)
                    self.categoryList.append(aCategory)
                }
                self.catCoverArray = [UIImage?](repeating: nil, count: self.categoryList.count)
                self.catTasks = [URLSessionDataTask?](repeating: nil, count: self.categoryList.count)
            }
            ProgressHUD.dismiss()
            self.categoryCV.reloadData()
        }
    }

    func loadPopularFromFirebase() {
        ProgressHUD.show()
        refWallX = Database.database().reference()
        refWallX.child("wallpaper").queryOrdered(byChild: "downloads").queryLimited(toLast: 10).observe(.value) { (snapshot) in
            print("child count: ", snapshot.childrenCount)
            if snapshot.childrenCount > 0 {
                for walls in snapshot.children.allObjects as! [DataSnapshot] {
                    let wallObject = walls.value as? [String: AnyObject]
                    let aWall = Wallpaper(key: walls.key, dictionary: wallObject!)
                    self.popularList.append(aWall)
                }
                self.popularList.reverse()
                self.popularImageArray = [UIImage?](repeating: nil, count: self.popularList.count)
                self.popularTasks = [URLSessionDataTask?](repeating: nil, count: self.popularList.count)
            }
            ProgressHUD.dismiss()
            self.popularCV.reloadData()
        }

    }

    func loadNewaddedFromFirebase() {
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
                    self.newaddedList.append(aWall)
                }
                self.newaddedImageArray = [UIImage?](repeating: nil, count: self.newaddedList.count)
                self.newaddedTasks = [URLSessionDataTask?](repeating: nil, count: self.newaddedList.count)
            }
            ProgressHUD.dismiss()
            self.newaddedCV.reloadData()
        }

    }

    func loadShuffledFromFirebase() {
        ProgressHUD.show()
        refWallX = Database.database().reference()
        refWallX.child("wallpaper")
            .observe(.value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                let wallCount = snapshots.count
                print("wall count: ", wallCount)
                let randNums = (1...1).map( {_ in Int.random(in: 1...wallCount-10)} )
                print(randNums)
                self.refWallX.child("wallpaper").queryOrdered(byChild: "id").queryStarting(atValue: randNums[0]).queryEnding(atValue: randNums[0]+10).observe(.value) { (snapshot) in
                    print("child count: ", snapshot.childrenCount)
                    if snapshot.childrenCount > 0 {
                        for walls in snapshot.children.allObjects as! [DataSnapshot] {
                            let wallObject = walls.value as? [String: AnyObject]
                            let aWall = Wallpaper(key: walls.key, dictionary: wallObject!)
                            self.shuffledList.append(aWall)
                        }
                        self.shuffledImageArray = [UIImage?](repeating: nil, count: self.shuffledList.count)
                        self.shuffledTasks = [URLSessionDataTask?](repeating: nil, count: self.shuffledList.count)
                    }
                    ProgressHUD.dismiss()
                    self.shuffledCV.reloadData()
                }
            }
        }

    }
    
    func urlWallComponents(collectionView: UICollectionView, index: Int) -> URL {

        var aWall = Wallpaper()
        switch collectionView {
        case popularCV:
            aWall = popularList[index]
            break
        
        case newaddedCV:
            aWall = newaddedList[index]
            break
            
        case shuffledCV:
            aWall = shuffledList[index]
            break

        default:
            aWall = popularList[index]
        }
        let wallThumb = aWall.thumbnail
        let imgUrl = URL(string: wallThumb)
        return imgUrl!
    }

    func getWallTask(collectionView: UICollectionView, forIndex: IndexPath) -> URLSessionDataTask {
        let imgURL = urlWallComponents(collectionView: collectionView, index: forIndex.row)
        return URLSession.shared.dataTask(with: imgURL) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {
                let image = UIImage(data: data)!
                switch collectionView {
                case self.popularCV:
                    self.popularImageArray[forIndex.row] = image
                    self.popularCV.reloadItems(at: [forIndex])
                    break
                
                case self.newaddedCV:
                    self.newaddedImageArray[forIndex.row] = image
                    self.newaddedCV.reloadItems(at: [forIndex])
                    break
                    
                case self.shuffledCV:
                    self.shuffledImageArray[forIndex.row] = image
                    self.shuffledCV.reloadItems(at: [forIndex])
                    break

                default:
                    self.popularImageArray[forIndex.row] = image
                    self.popularCV.reloadItems(at: [forIndex])
                }
            }
        }
    }
        
    func requestWallImage(collectionView: UICollectionView, forIndex: IndexPath) {
            var task: URLSessionDataTask

        switch collectionView {
        case popularCV:
            if popularImageArray[forIndex.row] != nil {
                // Image is already loaded
                return
            }
            if popularTasks[forIndex.row] != nil
                && popularTasks[forIndex.row]!.state == URLSessionTask.State.running {
                // Wait for task to finish
                return
            }

            task = getWallTask(collectionView: collectionView, forIndex: forIndex)
            popularTasks[forIndex.row] = task
            break
            
        case newaddedCV:
            if newaddedImageArray[forIndex.row] != nil {
                // Image is already loaded
                return
            }
            if newaddedTasks[forIndex.row] != nil
                && newaddedTasks[forIndex.row]!.state == URLSessionTask.State.running {
                // Wait for task to finish
                return
            }

            task = getWallTask(collectionView: collectionView, forIndex: forIndex)
            newaddedTasks[forIndex.row] = task
            break

        case shuffledCV:
            if shuffledImageArray[forIndex.row] != nil {
                // Image is already loaded
                return
            }
            if shuffledTasks[forIndex.row] != nil
                && shuffledTasks[forIndex.row]!.state == URLSessionTask.State.running {
                // Wait for task to finish
                return
            }

            task = getWallTask(collectionView: collectionView, forIndex: forIndex)
            shuffledTasks[forIndex.row] = task
            break

        default:
            if popularImageArray[forIndex.row] != nil {
                // Image is already loaded
                return
            }
            if popularTasks[forIndex.row] != nil
                && popularTasks[forIndex.row]!.state == URLSessionTask.State.running {
                // Wait for task to finish
                return
            }

            task = getWallTask(collectionView: collectionView, forIndex: forIndex)
            popularTasks[forIndex.row] = task
        }

        task.resume()
    }
}
