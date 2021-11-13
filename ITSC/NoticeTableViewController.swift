//
//  NoticeTableViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/4.
//

import UIKit
import SwiftSoup


class NoticeTableViewController: UITableViewController {
    
    var articles = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        var pageNumber = 1
        if let url = URL(string: "https://itsc.nju.edu.cn/tzgg/list.htm"),
           let html = try? String(contentsOf: url),
           let doc = try? SwiftSoup.parse(html) {
            if (try! doc.select(".col_news_con").first()?.child(0).child(0).child(0).child(0)) != nil {
                pageNumber = Int(try! doc.select(".all_pages").text())!
//                print(pageNumber)
            }
        }
        let operationQueue = OperationQueue()
        var operations = [BlockOperation]()
        for page in 1...pageNumber {
            let operation = BlockOperation {
                let urlString = "https://itsc.nju.edu.cn/tzgg/list" + String(page) + ".htm"
                if let url = URL(string: urlString),
                   let html = try? String(contentsOf: url),
                   let doc = try? SwiftSoup.parse(html) {
                    if let articleList = try! doc.select(".col_news_con").first()?.child(0).child(0).child(0).child(0) {
                        for article in articleList.children() {
                            if let a = try! article.select(".news_title").first()?.child(0).getElementsByTag("a") {
                                var articleLink = try! a.attr("href")
                                articleLink = "https://itsc.nju.edu.cn" + articleLink
    //                            print("herf: \(articleLink)")
                                let articleTitle = try! a.attr("title")
    //                            print("title: \(articleTitle)")
                                let articleTime = try! article.select(".news_meta").first()!.text()
    //                            print("time: \(articleTime)")
                                DispatchQueue.main.async {
                                    self.articles.append(Article(title: articleTitle, time: articleTime, link: articleLink))
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
            operations.append(operation)
        }
        for i in operations {
            operationQueue.addOperation(i)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTemplateCell", for: indexPath) as! TemplateTableViewCell

        // Configure the cell...
        
        cell.title.text = articles[indexPath.row].title
        cell.detail.text = articles[indexPath.row].time

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
