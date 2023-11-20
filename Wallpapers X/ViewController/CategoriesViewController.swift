//
//  CategoriesViewController.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/8.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class CategoriesViewController: UIViewController {

    @IBOutlet weak var categoryTableView: UITableView!
    
    let segueToOne = "segueCategoriesToOne"

    let reuseIdentifier = "CategoryTVCell"

    var categoryList = [Category]()
    var catCoverArray = [UIImage?]()
    var tasks = [URLSessionDataTask?]()

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.setScreenName("CategoriesView", screenClass: "CategoriesViewController")
        self.loadCategoryFromFirebase()
    }
    
// MARK: - Navigation

    @IBAction func onGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToOne {
            if let indexPath = self.categoryTableView.indexPathForSelectedRow {
                let controller = segue.destination as! OneCategoryViewController
                controller.categoryName = categoryList[indexPath.row].name
            }
        }
    }

}

extension CategoriesViewController: UITableViewDataSource,
    UITableViewDataSourcePrefetching, UITableViewDelegate {

// MARK: UITableViewDataSourcePrefetching

    /// - Tag: Prefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            requestImage(forIndex: indexPath)
        }
    }
    
    /// - Tag: CancelPrefetching
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            if let task = tasks[indexPath.row] {
                if task.state != URLSessionTask.State.canceling {
                    task.cancel()
                }
            }
        }
    }

// MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catCoverArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CategoryTVCell
        if let img = catCoverArray[indexPath.row] {
          cell.coverImageView.image = img
          cell.coverImageView.layer.shadowColor = UIColor.darkGray.cgColor
          cell.coverImageView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
          cell.coverImageView.layer.shadowRadius = 25.0
          cell.coverImageView.layer.shadowOpacity = 0.9
            cell.categoryNameNabel.text = categoryList[indexPath.row].name
        }
        else {
            requestImage(forIndex: indexPath)
        }
        return cell
    }
    
// MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueToOne, sender: self)
    }
}

// MARK: Load Data from Firebase
extension CategoriesViewController {
    func loadCategoryFromFirebase() {
        ProgressHUD.show()
        self.catCoverArray = [UIImage?](repeating: nil, count: self.categoryList.count)
        self.tasks = [URLSessionDataTask?](repeating: nil, count: self.categoryList.count)
        ProgressHUD.dismiss()
        self.categoryTableView.reloadData()
    }

    func urlComponents(index: Int) -> URL {

        let aCategory = categoryList[index]
        let catCover = aCategory.cover
        let imgUrl = URL(string: catCover)
        return imgUrl!
    }

    func getTask(forIndex: IndexPath) -> URLSessionDataTask {
        let imgURL = urlComponents(index: forIndex.row)
        return URLSession.shared.dataTask(with: imgURL) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {
                let image = UIImage(data: data)!
                self.catCoverArray[forIndex.row] = image
                self.categoryTableView.reloadRows(at: [forIndex], with: .middle)
            }
        }
    }
    
    func requestImage(forIndex: IndexPath) {
        var task: URLSessionDataTask

        if catCoverArray[forIndex.row] != nil {
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
