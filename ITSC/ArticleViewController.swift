//
//  ArticleViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/14.
//

import UIKit
import SwiftSoup

class ArticleViewController: UIViewController {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var textTextView: UITextView!
    var article: Article?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLable.text! = article!.title
        if let url = URL(string: article!.link),
           let html = try? String(contentsOf: url),
           let doc = try? SwiftSoup.parse(html) {
            print("来了")
            textTextView.text! = ""
            if let content = try? doc.select(".wp_articlecontent").first() {
                for i in content.children() {
                    if try! i.text().isEmpty {
                        continue
                    }
//                    textTextView.text! += "        "
                    textTextView.text! += try! i.text()
                    textTextView.text! += "\n"
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
