# iw03 ITSC客户端

> 191180164 杨茂琛

## 简述

为[ITSC](https://itsc.nju.edu.cn)开发iOS客户端

[演示DEMO](https://www.bilibili.com/video/BV1RL4y1v7Vo)已发布

### 需求

`tab bar`将程序分为5个子页面，分别展示新闻动态、通知公告、信息化动态、安全公告的新闻和关于ITSC的信息，点击某条新闻可跳转显示详细图文内容

## 开发环境

- Swift 5
- [SwiftSoup](https://github.com/scinfu/SwiftSoup) 2.3.3

## 工作流程

1. 创建各个`tableView`视图的`controller`类
2. 定义`Article`结构：

```swift
struct Article {
    var title : String
    var time : String
    var link : String
}
```

3. 定义`tableViewCell`类：

```swift
class TemplateTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    var link: String!
}
```

并把每个`tableView`视图里的`cell`的`label`对应地connect

4. 4个新闻页面的`viewDidLoad()`方法中，在主线程请求总页数，对每一页开启新线程请求内容，每当解析出新内容，将其添加到类中的`articles : [Article]()`并对`articles`按时间倒序排序并刷新视图；关于页的处理类似，直接请求网页并解析显示
5. 实现`ArticleViewController`中对新闻页面的请求、解析、显示：

```swift
class ArticleViewController: UIViewController {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var textTextView: UITextView!
    var article: Article?
    //func viewDidLoad()
}
```

## 技术细节

### 网页请求、HTML解析

以新闻动态页面的请求页面数量为例：

```swift
var pageNumber = 1
if let url = URL(string: "https://itsc.nju.edu.cn/xwdt/list.htm"),
   let html = try? String(contentsOf: url),
   let doc = try? SwiftSoup.parse(html) {
    if (try! doc.select(".col_news_con").first()?.child(0).child(0).child(0).child(0)) != nil {
        pageNumber = Int(try! doc.select(".all_pages").text())!
    }
}
```

`select`方法为CSS选择器

`first`方法为选择器找到的第1个结果

`child(0)`方法为取第0个子元素

### 网络图片请求与`UITextView`图文混排

请求图片资源相比于请求网页再解析HTML轻松很多：

```swift
let imgData = try! Data(contentsOf: URL(string: "https://itsc.nju.edu.cn" + imgURL)!)
let image = UIImage(data: imgData)
```

此时就拿到了`image : UIImage`，这个就是我们想要的图片

将图片调整到合适屏幕的大小，并转为`NSAttributedString`的附件类型`NSTextAttachment`：

```swift
let attach = NSTextAttachment(image: image!)
let imageWidth = textTextView.frame.width - 20 // 预留与Safe Area的边界
let imageHeight = image!.size.height / image!.size.width * imageWidth
attach.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
```

要想实现图文混排，需要使用的是`NSAttributedString`富文本字符串

请求到图片后，我们需要把图片接续到原先的内容上：

```swift
let imgString = NSAttributedString(attachment: attach)
let mutableString = NSMutableAttributedString(attributedString: textTextView.attributedText!)
mutableString.append(imgString)
```

`NSMutableAttributedString`可以想象成一个`NSAttributedString`的数组，我们用`append`方法实现拼接

最后，设置`UITextView`：

```swift
textTextView.attributedText = mutableString
```

### 多线程请求页面

```swift
let operationQueue = OperationQueue()
var operations = [BlockOperation]()
for page in 1...pageNumber {
    // ...
    operations.append(operation)
}
for i in operations {
    operationQueue.addOperation(i)
}
```

`OperationQueue`的方法`addOperation`不需要显式地手动启动线程，只需加入即可被系统调度运行

### `tableView`增加搜索栏

1. 先在Storyboard中添加`Search Bar`
2. 在`ViewController`中关联`Outlet`

```swift
@IBOutlet weak var searchBar: UISearchBar!
```

3. 增加一个`Bool`变量表示搜索状态，增加一个`[Article]()`数组存放搜索结果：

```swift
var searching : Bool = false
var searchedArticles = [Article]()
```

4. 修改`numberOfRowsInSection`和`cellForRowAt`方法：

```swift
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return searching ? searchedArticles.count : articles.count
}

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTemplateCell", for: indexPath) as! TemplateTableViewCell

    // Configure the cell...

    if searching {
        cell.title.text = searchedArticles[indexPath.row].title
        cell.detail.text = searchedArticles[indexPath.row].time
    } else {
        cell.title.text = articles[indexPath.row].title
        cell.detail.text = articles[indexPath.row].time
    }
    return cell
}
```

根据当前的搜索状态来决定显示内容

5. 为`ViewController`扩展一个`UISearchBar`的委托并添加必需的方法：

```swift
extension NewsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searching = false
        } else {
            searching = true
            searchedArticles = articles.filter { $0.title.contains(searchText)}
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text! = ""
        tableView.reloadData()
    }
}
```

`textDidChange`方法会在搜索框内文字变动时自动调用

### 文章标题`title`过长时，显示文章发布时间的`detail`被遮挡

产生这个问题的原因是，左边的`label`在自动地`sizeToFit()`后宽度太长使得右边的`label`宽度不够

我的解决方案为，既然左边`label`太宽，那就想办法根据右边`label`宽度来限制它

在`TemplateTableViewCell`中重写方法：

```swift
override func layoutSubviews() {
    super.layoutSubviews()
    self.title.sizeToFit()
    self.detail.sizeToFit()
    if self.frame.size.width > self.title.frame.size.width + self.detail.frame.size.width + 30 {
        return
    }
    if let detail = self.detail {
        detail.sizeToFit()
        let rightMargin: CGFloat = 16
        let detailWidth = rightMargin + detail.frame.size.width
        detail.frame.origin.x = self.frame.size.width - detailWidth
        detail.textAlignment = .left
        if let text = self.title {
            if text.frame.origin.x + text.frame.size.width > self.frame.width - detailWidth {
                text.frame.size.width = self.frame.width - detailWidth - text.frame.origin.x
            }
        }
    }
}
```

第1个`if`语句判断是否足够显示，够的话就不进行调整了：

```swift
if self.frame.size.width > self.title.frame.size.width + self.detail.frame.size.width + 30 {
    return
}
```

常数`30`是用于`label`与`SafeArea`保持边界

如果没有`return`离开方法，那么就会进入调整：

1. `detail`根据自身内容调整至合适宽度（发布时间）
2. 通过调整`x`的位置确定`detail`的位置
3. 把`detail`改为左对齐。因为宽度正好合适，看起来的效果和右对齐无异
4. 修改`title`的宽度

