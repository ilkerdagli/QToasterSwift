//
//  QToasterView.swift
//  QToasterSwift
//
//  Created by Ahmad Athaullah on 7/3/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

class QToasterView: UIButton {
    
    /**
     Define toaster to use variable and function on QToasterSwift.
     */
    var toaster = QToasterSwift()
    /**
     Define area view to toaster.
    */
    var viewArea = UIView()

    /**
     Minimum height for toaster in CGFloat.
     - returns: Height of status bar + 40 on **QToasterConfig**.
     */
    var minHeight:CGFloat{
        return QToasterConfig.statusBarHeight + 40
    }
    /**
     Your toaster text size in CGSize. 
     This is defined again to distinguish if there is a badge.
     - returns: Toaster text size consist of toaster text, font and maximum width
    */
    var textSize:CGSize{
        if toaster.iconImage == nil && (toaster.iconURL == nil || toaster.iconURL == "") {
            return QToasterConfig.textSize(toaster.text, font: toaster.textFont, maxWidth: QToasterConfig.screenWidth)
        }else{
            return QToasterConfig.textSize(toaster.text, font: toaster.textFont, maxWidth: QToasterConfig.screenWidth - toaster.iconSquareSize - 25)
        }
    }
    /**
     Your toaster title size in CGSize.
     - returns: If toaster title text is nil and blank then toaster text size consist of toaster text, font and maximum width. Otherwise, set CGSizeMake(0, 0)
    */
    var titleSize:CGSize{
        if toaster.titleText != nil && toaster.titleText != ""{
            if toaster.iconImage == nil && (toaster.iconURL == nil || toaster.iconURL == "") {
                return QToasterConfig.textSize(toaster.titleText!, font: toaster.textFont, maxWidth: QToasterConfig.screenWidth - 20)
            }else{
                return QToasterConfig.textSize(toaster.titleText!, font: toaster.textFont, maxWidth: QToasterConfig.screenWidth -  toaster.iconSquareSize - 25)
            }
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // The storyboard loader uses this at runtime.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /**
     Function will be called on override. 
     It is called whenever creating objects.
     */
    func commonInit(){
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tag = 1313
        self.layer.zPosition = 9999
    }
    
    /**
     To configure toaster view
     - parameter toaster: QToasterSwift.
    */
    func setupToasterView(_ toaster: QToasterSwift){
        self.toaster = toaster
        
        var textAreaWidth =  QToasterConfig.screenWidth - 20
        var imageToasterHeight:CGFloat = 0
        var textXPos:CGFloat = 10
        
        if toaster.iconImage != nil || (toaster.iconURL != nil && toaster.iconURL != ""){
            imageToasterHeight = toaster.iconSquareSize + QToasterConfig.statusBarHeight + 20
            textAreaWidth -= (toaster.iconSquareSize + 5)
            toaster.textAlignment = NSTextAlignment.left
            textXPos += toaster.iconSquareSize + 5
        }
        
        var toasterHeight = self.textSize.height + self.titleSize.height + QToasterConfig.statusBarHeight + 20
        if self.titleSize.height > 0 {
            toasterHeight += 3
        }
        if toasterHeight < self.minHeight {
            toasterHeight = self.minHeight
        }
        
        if toasterHeight < imageToasterHeight{
            toasterHeight = imageToasterHeight
        }
        
        
        var yPos:CGFloat = QToasterConfig.statusBarHeight + 10
        
        let toasterViewFrame = CGRect(x: 0,y: 0 - toasterHeight, width: QToasterConfig.screenWidth,height: toasterHeight)
        
        viewArea.frame = toasterViewFrame
        viewArea.isUserInteractionEnabled = false
        viewArea.backgroundColor = toaster.backgroundColor
        
        if toaster.iconImage != nil || (toaster.iconURL != nil && toaster.iconURL != ""){
            let iconView = UIImageView(frame: CGRect(x: 10, y: yPos, width: toaster.iconSquareSize, height: toaster.iconSquareSize))
            iconView.backgroundColor = toaster.iconBackgroundColor
            iconView.layer.cornerRadius = toaster.iconCornerRadius
            iconView.clipsToBounds = true
            
            if toaster.iconImage != nil {
                iconView.image = toaster.iconImage
            }
            if toaster.iconURL != nil && toaster.iconURL != "" {
                QToasterConfig.imageForUrl(toaster.iconURL!, completionHandler:{(image: UIImage?, url: String) in
                    iconView.image = image
                })
            }
            viewArea.addSubview(iconView)
        }
        
        if toaster.titleText != nil && toaster.titleText != "" {
            let titleLabel = UILabel(frame: CGRect(x: textXPos, y: yPos, width: textAreaWidth, height: self.titleSize.height))
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = toaster.textAlignment
            titleLabel.text = toaster.titleText
            titleLabel.textColor = toaster.textColor
            titleLabel.font = toaster.titleFont
            viewArea.addSubview(titleLabel)
            yPos += 3 + self.titleSize.height
        }else{
            yPos = ((toasterHeight - self.textSize.height) / 2) + 10
        }
        
        let textLabel = UILabel(frame: CGRect(x: textXPos, y: yPos, width: textAreaWidth, height: self.textSize.height))
        textLabel.text = toaster.text
        textLabel.textAlignment = toaster.textAlignment
        textLabel.textColor = toaster.textColor
        textLabel.numberOfLines = 0
        textLabel.font = toaster.textFont
        viewArea.addSubview(textLabel)
        
        self.frame = CGRect(x: 0, y: 0, width: QToasterConfig.screenWidth, height: toasterHeight)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.addTarget(self, action: #selector(QToasterView.touchAction), for: UIControlEvents.touchUpInside)
        self.addSubview(viewArea)
    }
    func touchAction(){
        self.toaster.touchAction()
    }
    /**
     To show toaster
    */
    func show(){
        UIView.animate(withDuration: self.toaster.animateDuration, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            let showFrame = CGRect(x: 0,y: 0,width: QToasterConfig.screenWidth,height: self.frame.height)
            self.viewArea.frame = showFrame
            }, completion: { _ in
                self.hide()
            }
        )
        
    }
    
    /**
     To hide toaster
      - parameter completion: **()->Void** as hide for your toaster.
     */
    func hide(_ completion: @escaping () -> Void = ({})){
        UIView.animate(withDuration: self.toaster.animateDuration, delay: self.toaster.delayDuration, options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                let hideFrame = CGRect(x: 0,y: 0 - self.frame.height,width: QToasterConfig.screenWidth,height: self.frame.height)
                self.viewArea.frame = hideFrame
            },
            completion: { _ in
                self.isHidden = true
                self.removeFromSuperview()
                completion()
            }
        )
    }
}
