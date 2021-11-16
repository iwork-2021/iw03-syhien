//
//  AboutViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/13.
//

import UIKit
import SwiftSoup

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true

        // Do any additional setup after loading the view.
        aboutText.text! = ""
        if let url = URL(string: "https://itsc.nju.edu.cn/aqtg/list.htm"),
           let html = try? String(contentsOf: url),
           let doc = try? SwiftSoup.parse(html) {
            let details = try! doc.select(".foot-center").first()?.child(0).child(1).child(0).child(0).children()
            for detail in details! {
                aboutText.text! += try! detail.child(0).child(0).child(0).getElementsByTag("a").text() + "\n"
                aboutText.text! += try! detail.child(0).child(1).text() + "\n"
                aboutText.text! += try! detail.child(0).child(2).text() + "\n"
                aboutText.text! += "\n"
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
