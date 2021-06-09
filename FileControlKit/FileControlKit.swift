//
//  FileControlKit.swift
//  FileControlKit
//
//  Created by zhoucz on 2021/06/08.
//

import UIKit
import WebKit
import PDFKit

//MARK: - 文件类型
enum FileType:String {
    case pdf    = "icon_file_pdf"
    case word   = "icon_file_word"
    case excel  = "icon_file_excel"
    case ppt    = "icon_file_ppt"
    case wps    = "icon_file_wps"
    case txt    = "icon_file_txt"
    case rtf    = "icon_file_rtf"
    case image  = "icon_file_image"
    case unknow = "icon_file_unknow"
}

//MARK: - 文件对象属性信息
class FileItemModel: NSObject {
    
    //MARK: - 是否为文件夹
    var isDirectory:Bool = false
    //MARK: - 文件路径
    var filePath:String = ""
    //MARK: - 文件名
    var fileName:String = ""
    //MARK: - 扩展名
    var fileExtension:String = ""
    //MARK: - 文件类型
    var fileType:FileType = .unknow
    //MARK: - 子文件数量
    var fileCount:Int = 0
    //MARK: - 创建时间
    var fileCreateTime:String = ""
    //MARK: - 最后修改时间
    var fileModificationDate:String = ""
    //MARK: - 文件大小
    var fileSize:String = "0B"
    //MARK: - 是否可读
    var readable:Bool = false
    //MARK: - 是否可写入
    var writable:Bool = false
    //MARK: - 是否可删除
    var deletable:Bool = false
}

//MARK: - Block
typealias FileControlKitSelectedBlock = (_ file:FileItemModel)->Void

//MARK: - Protocol
@objc
protocol FileControlKitDeledate:NSObjectProtocol {
    @objc func fileControlKitDidSelectedFile(with file:FileItemModel)
}

//MARK: - FileControlKit
class FileControlKit: UINavigationController {
    
    //MARK: - delegate
    public weak var fileDelegate:FileControlKitDeledate? = nil
    
    //MARK: - block
    public var fileDidSelectedBlock:FileControlKitSelectedBlock? = nil
    
    //MARK: - block function
    public func fileControlKitDidSelected(withResult result:@escaping FileControlKitSelectedBlock){
        self.fileDidSelectedBlock = result
    }
    
    //MARK: - 关闭按钮
    private lazy var closeItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(named: "icon_close"),
            style: .plain,
            target: self,
            action: #selector(fileControlKitCloseAction))
        item.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return item
    }()
    
    //MARK: - 返回按钮
    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(named: "icon_back"),
            style: .plain,
            target: self,
            action: #selector(fileContolKitBackAction))
        item.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return item
    }()
    
    convenience init() {
        self.init(rootViewController: FileController())
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialization(){
        
        self.navigationBar.tintColor = .black
        
        weak var WeakSelf = self
        WeakSelf?.delegate = self
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
}

//MARK: - UINavigationControllerDelegate
extension FileControlKit:UINavigationControllerDelegate{
        
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.hidesBackButton = true
        if viewControllers.count <= 1 {
            viewController.navigationItem.leftBarButtonItem = closeItem
        }else{
            viewController.navigationItem.leftBarButtonItem = backItem
        }
    }
}

//MARK: - Actions
@objc
extension FileControlKit{
    
    private func fileControlKitCloseAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func fileContolKitBackAction(){
        self.popViewController(animated: true)
    }
}

//MARK: - FileController
fileprivate class FileController: UIViewController {
    
    
    
    private let identifier = "UITableViewCell"
    
    //MARK: - FileManager
    private var fileManager:FileManager = {
        let m = FileManager.default
        m.shouldGroupAccessibilityChildren = true
        return m
    }()
    
    private lazy var fileList: UITableView = {
        let list = UITableView(frame: self.view.frame, style: .plain)
        list.rowHeight = 84
        list.separatorInset = .zero
        list.delegate = self
        list.dataSource = self
        return list
    }()
    
    private var currentDirectory:String = NSHomeDirectory()
    
    private var currentFileDataSource:[FileItemModel] = []
    
    private func configUI(){
        self.view.addSubview(self.fileList)
        self.view.backgroundColor = .white
        if self.currentDirectory == NSHomeDirectory() {
            self.navigationItem.title = "文件管理器"
        }
    }
    
    private func initData(){
        
        currentFileDataSource.removeAll()
        
        DispatchQueue.global(qos: .default).async {[weak self] in
            if let currentPath = self?.currentDirectory, let children = try? self?.fileManager.contentsOfDirectory(atPath: currentPath){
                for item in children {
                    let childItem = FileItemModel()
                    let filePath = currentPath + "/" + item
                    childItem.filePath = filePath
                    childItem.fileName = item
                    childItem.fileCount = self?.getChildrenFileCount(withPath: filePath) ?? 0
                    childItem.fileType = self?.getFileType(withPath: filePath) ?? FileType.unknow
                    childItem.isDirectory = self?.isDirectory(withPath: filePath) ?? false
                    childItem.readable = self?.isReadable(withPath: filePath) ?? false
                    childItem.writable = self?.isWritable(withPath: filePath) ?? false
                    childItem.fileCreateTime = self?.getFileCreateTime(withPath: filePath) ?? ""
                    childItem.fileModificationDate = self?.getModificationDate(withPath: filePath) ?? ""
                    childItem.fileExtension = self?.getFileExtension(withPath: filePath) ?? ""
                    childItem.deletable = self?.isDetelable(withPath: filePath) ?? false
                    
                    print(filePath)
                    self?.currentFileDataSource.append(childItem)
                }
                
                DispatchQueue.main.async {
                    self?.fileList.reloadData()
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        initData()
    }
    
}

extension FileController{
    
    //MARK: - 是否为文件夹
    private func isDirectory(withPath path:String)->Bool?{
        var isDirectory = ObjCBool(false)
        self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    //MARK: - 是否可读
    private func isReadable(withPath path:String)->Bool{
        return self.fileManager.isReadableFile(atPath: path)
    }
    
    //MARK: - 是否可读
    private func isDetelable(withPath path:String)->Bool{
        return self.fileManager.isDeletableFile(atPath: path)
    }
    
    //MARK: - 是否可写入
    private func isWritable(withPath path:String)->Bool{
        return self.fileManager.isWritableFile(atPath: path)
    }
    
    //MARK: - 文件扩展名
    private func getFileExtension(withPath path:String)->String?{
        return path.components(separatedBy: ".").last
    }
    
    //MARK: - 创建时间
    private func getFileCreateTime(withPath path:String)->String?{
        
        if let attribute = (try? self.fileManager.attributesOfItem(atPath: path) as [FileAttributeKey:Any]){
            if let createTime:Date = attribute[FileAttributeKey.creationDate] as? Date {
                return createTime.toString()
            }
            return nil
        }
        return nil
    }
    
    //MARK: - 子文件数量
    private func getChildrenFileCount(withPath path:String)->Int?{
        if let attribute = (try? self.fileManager.attributesOfItem(atPath: path) as [FileAttributeKey:Any]){
            if let count:Int = attribute[FileAttributeKey.referenceCount] as? Int {
                return count
            }
            return nil
        }
        return nil
    }
    
    //MARK: - 最后修改时间
    private func getModificationDate(withPath path:String)->String?{
        if let attribute = (try? self.fileManager.attributesOfItem(atPath: path) as [FileAttributeKey:Any]){
            if let createTime:Date = attribute[FileAttributeKey.modificationDate] as? Date {
                return createTime.toString()
            }
            return nil
        }
        return nil
    }
    
    //MARK: - 获取文件大小
    private func getFileSize(withPath path:String)->String?{
        if let attribute = (try? self.fileManager.attributesOfItem(atPath: path) as [FileAttributeKey:Any]){
            if let size:UInt64 = attribute[FileAttributeKey.size]  as? UInt64{
                return size.toString()
            }
            return nil
        }
        return nil
    }
    
    //MARK: - 文件类型
    private func getFileType(withPath path:String)->FileType{
        
        let fileExtension = path.components(separatedBy: ".").last
        switch fileExtension {
        case "PDF","pdf":
            return .pdf
        case "xls","xlsx":
            return .excel
        case "doc","docx":
            return .word
        case "rtf","RTF":
            return .rtf
        case "txt","TXT":
            return .txt
        case "wps","WPS":
            return .wps
        case "ppt","pptx":
            return .ppt
        case "jpeg","JPEG","jpg","JPG","png","PNG","BMP","bmp","tiff","GIF","gif","heif","heic":
            return .image
        default:
            return .unknow
        }

    }
    
    private func ShowErrorAlert(withMessage msg:String){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: .none))
        self.present(alert, animated: true, completion: .none)
    }
    
}

extension FileController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.currentFileDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        
        let model = self.currentFileDataSource[indexPath.row]
        
        cell?.textLabel?.numberOfLines = 3
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        cell?.detailTextLabel?.textColor = UIColor.lightGray
        cell?.detailTextLabel?.numberOfLines = 3
        
        config(withCell: cell, model: model)
        
        return cell!
    }
    
    private func config(withCell cell:UITableViewCell?,model:FileItemModel){
        
        cell?.accessoryType = model.isDirectory ? .disclosureIndicator:.none
        cell?.textLabel?.text = model.fileName
        
        if model.isDirectory{
            cell?.imageView?.image = UIImage(named: "icon_directory")
        }else{
            cell?.imageView?.image = UIImage(named: model.readable ? model.fileType.rawValue:"icon_file_unreadable")
        }
        
        let readable = model.readable
        let writeable = model.writable
        var fileInfo:String = "\(readable ? "可读":"不可读")" + " | " + "\(writeable ? "可写入":"不可写入")" + " | " + "\(model.fileCount)"
        fileInfo += "\n" + "\(model.fileSize)"
        fileInfo += " | " + "\(model.fileModificationDate)"
        
        cell?.detailTextLabel?.text = fileInfo
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
        let model = self.currentFileDataSource[indexPath.row]
        
        let readable = model.readable

        if readable {///可读，就打开
            let isDirectory = model.isDirectory
            if isDirectory{///文件夹
                let nextFolder = FileController()
                nextFolder.currentDirectory = model.filePath
                nextFolder.navigationItem.title = model.fileName
                self.navigationController?.pushViewController(nextFolder, animated: true)
            }else{///文件
                
                if model.fileType == .unknow {
                    ShowErrorAlert(withMessage: "当前文件为不支持类型")
                }else if model.fileType == .pdf{
                    let pdfviewer = PDFPreviewController()
                    pdfviewer.navigationItem.title = model.fileName
                    pdfviewer.localFilePath = model.filePath
                    self.navigationController?.pushViewController(pdfviewer, animated: true)
                }else{
                    let previewer = FilePreviewControler()
                    previewer.localFilePath = model.filePath
                    previewer.navigationItem.title = model.fileName
                    self.navigationController?.pushViewController(previewer, animated: true)
                }
            }
        }else{/// 不可读，就提示
            ShowErrorAlert(withMessage: "当前文件(夹)没有读写权限，无法查看、编辑或分享")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let model = self.currentFileDataSource[indexPath.row]
        let readable = model.readable
        let isDirectory = model.isDirectory
        
        //MARK: - 添加文件
        let addAction = UIContextualAction(style: .normal, title: "选择") {( action, v, result) in
            //MARK: - block
            if let navigation = self.navigationController as? FileControlKit,
               let handler = navigation.fileDidSelectedBlock{
                handler(model)
            }
            //MARK: - delegate
            if let navigation = self.navigationController as? FileControlKit,
               let delegate = navigation.fileDelegate,
               delegate.responds(to: #selector(delegate.fileControlKitDidSelectedFile(with:))) {
                delegate.fileControlKitDidSelectedFile(with: model)
            }
            
            if let navigationController = self.navigationController{
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
        
        var actions:[UIContextualAction] = []
        
        if readable && !isDirectory {
            actions.append(addAction)
        }

        //MARK: - 删除文件
        let canDelete =  model.deletable

        let deleteAction = UIContextualAction(style: .destructive, title: "删除") {( action, v, result) in

            try? self.fileManager.removeItem(atPath: model.filePath)
            self.currentFileDataSource.removeAll { t in
                t === model
            }

            self.initData()
        }

        if canDelete && !isDirectory {
            actions.append(deleteAction)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
}

//MARK: - PDFPreviewer
class PDFPreviewController:UIViewController{
    
    public var localFilePath:String? = nil
    
    
    lazy var pdfView: PDFView = {
        let pdffView = PDFView()
        pdffView.frame = self.view.frame
        pdffView.autoScales = true
        pdffView.backgroundColor = .darkGray
        return pdffView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.pdfView)
        
        if let fileUrl = self.localFilePath{
            let url = URL(fileURLWithPath: fileUrl)
            let document = PDFDocument(url: url)
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.backgroundColor = .lightGray
        }
    }
}

//MARK: - FilePreviewer
class FilePreviewControler:UIViewController{
    
    public var localFilePath:String? = nil

    lazy var wkWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        var webview = WKWebView.init(frame: .zero, configuration: config)
        webview.frame = self.view.frame
        return webview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(wkWebView)
        
        
        if let fileUrl = localFilePath {
            let url = URL(fileURLWithPath: fileUrl)
            wkWebView.loadFileURL(url, allowingReadAccessTo: url)
        }
        
    }
}

extension UInt64{
    public func toString() -> String {
        var convertedValue: Double = Double(self)
        var multiplyFactor = 0
        let tokens = ["B", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}

extension Date{
    
    public func toString()->String{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: self)
    }
    
}
