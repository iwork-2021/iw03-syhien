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
            textTextView.attributedText = NSAttributedString(string: "")
            if let content = try? doc.select(".wp_articlecontent").first() {
                for i in content.children() {
                    if let img = try? i.getElementsByTag("img") {
                        if let imgURL = try? img.attr("src") {
                            if imgURL != "" {
                                let imgData = try! Data(contentsOf: URL(string: "https://itsc.nju.edu.cn" + imgURL)!)
                                let image = UIImage(data: imgData)
                                let attach = NSTextAttachment(image: image!)
                                let imageWidth = textTextView.frame.width - 20
                                let imageHeight = image!.size.height / image!.size.width * imageWidth
                                attach.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
                                let imgString = NSAttributedString(attachment: attach)
                                let mutableString = NSMutableAttributedString(attributedString: textTextView.attributedText!)
                                mutableString.append(imgString)
                                textTextView.attributedText = mutableString
                            }
                        }
                        
                    }
                    if try! i.text().isEmpty {
                        continue
                    }
                    let mutableString = NSMutableAttributedString(attributedString: textTextView.attributedText!)
                    mutableString.append(NSAttributedString(string: try! i.text() + "\n"))
                    textTextView.attributedText = mutableString
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
