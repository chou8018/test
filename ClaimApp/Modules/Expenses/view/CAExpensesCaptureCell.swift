//
//  CAExpensesCaptureCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/28.
//

import UIKit

class CAExpensesCaptureCell: UITableViewCell ,InitializableFromNib {
    
    static var nibName: String = "CAExpensesCaptureCell"
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var data: PhotoFormFieldData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTaped)))
    }
    
    
    override var frame: CGRect{
        
        didSet {
            var newFrame = frame
            newFrame.origin.y += 8
            newFrame.size.height -= 16
            super.frame = newFrame
        }
    }
    
    @objc func imageTaped(_ sender: UITapGestureRecognizer) {
        
        guard let usedData = self.data else { return }
        
        guard let file = usedData.images.first as? LNUploadImage, let url = URL(string: file.url) else { return }
        
        let vc = WebViewController(withTitle: "Receipt", url: url)
        vc.hidesBottomBarWhenPushed = true
        self.getCurrentVC?.show(vc, sender: self)
    }
}

extension CAExpensesCaptureCell: FormFieldDataUI {
    
    func bind(data: FormFieldData) {
        if let photo = data as? PhotoFormFieldData {
            self.data = photo
            if let fileName = photo.images.first as? String {
                DispatchQueue.global().async {
                    //转换尝试判断，有可能返回的数据丢失"=="，如果丢失，swift校验不通过
                    var imageData = Data(base64Encoded: fileName, options: .ignoreUnknownCharacters)
                    if imageData == nil {
                        imageData = Data(base64Encoded: fileName + "==", options: .ignoreUnknownCharacters) //如果数据不正确，添加"=="重试
                    }
                    if let imageData = imageData, let image = UIImage(data: imageData) {
                        DispatchQueue.main.async { [self] in
                            self.photo.image = image
                        }
                    }
                }
            }else if let file = photo.images.first as? LNUploadImage {
                if file.mime_type.contains("pdf") {
                    self.photo.image = UIImage(named: "detail_file_placeholder")
                }else if let url = URL(string: file.url) {
                    self.photo.af_setImage(withURL: url)
                }
            }
        }
    }
}
