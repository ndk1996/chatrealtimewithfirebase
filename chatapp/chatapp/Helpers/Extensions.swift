//
//  Extensions.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithUrlString(urlString:String) {
        self.image = nil
        
        //check cache for image first
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cacheImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}

extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
    
}
extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 40
        return sizeThatFits
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIView {
    func shake(count: Float = 4, for duration: TimeInterval = 0.5, withTranslation translation: Float = 5){
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: CGFloat(-translation), y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: CGFloat(translation), y: self.center.y))
        layer.add(animation, forKey: "shake")
        
    }
    
    
    func slideInFromLeft(duration: TimeInterval = 1.0) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.moveIn
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func slideIOutFromRight(duration: TimeInterval = 1.0) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.reveal
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromRightTransition")
    }
    
    
}

extension UILabel {
    func underline(){
        if let textString = self.text {
            let atributedString = NSMutableAttributedString(string: textString)
            atributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: atributedString.length - 1) )
            attributedText = atributedString
        }
    }
    
    
}

extension String{
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: 1)]
    }
    
    var isReallyEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

extension UICollectionView {
    func isIndexPathAvailable(_ indexPath: IndexPath) -> Bool {
        guard dataSource != nil,
            indexPath.section < numberOfSections,
            indexPath.item < numberOfItems(inSection: indexPath.section) else {
                return false
        }
        
        return true
    }
    
    func scrollToItemIfAvailable(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard isIndexPathAvailable(indexPath) else { return }
        
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToItemOrThrow(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) throws {
        guard isIndexPathAvailable(indexPath) else {
            throw Error.invalidIndexPath(indexPath: indexPath, lastIndexPath: lastIndexPath)
        }
        
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    var lastIndexPath: IndexPath {
        let lastSection = numberOfSections - 1
        return IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                         section: lastSection)
    }
}

extension UICollectionView {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidIndexPath(indexPath: IndexPath, lastIndexPath: IndexPath)
        
        var description: String {
            switch self {
            case let .invalidIndexPath(indexPath, lastIndexPath):
                return "IndexPath \(indexPath) is not available. The last available IndexPath is \(lastIndexPath)"
            }
        }
    }
}
