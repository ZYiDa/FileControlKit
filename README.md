# FileControlKit~~~~
本地沙盒文件浏览和管理
示例图
![-w720](https://github.com/ZYiDa/FileControlKit/blob/main/IMG/IMG_1.PNG)
![-w720](https://github.com/ZYiDa/FileControlKit/blob/main/IMG/IMG_2.PNG)
![-w720](https://github.com/ZYiDa/FileControlKit/blob/main/IMG/IMG_3.PNG)
##### 使用方法
###### block

```
let fileControlKit = FileControlKit()
fileControlKit.fileControlKitDidSelected { file in
    
}
self.present(FileControlKit(), animated: true, completion: nil)
```
###### delegate

```
let fileControlKit = FileControlKit()
fileControlKit.fileDelegate = self
self.present(FileControlKit(), animated: true, completion: nil)
```

```
/// - FileControlKitDeledate
func fileControlKitDidSelectedFile(with file: FileItemModel) {
        
}
```