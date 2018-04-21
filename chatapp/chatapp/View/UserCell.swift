//
//  UserCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/23/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class UserCell:UITableViewCell{
    
    var message: Message? {
        didSet{
            setupNameAndProfileImage()
            
            if let seconds = message?.timeStamp?.doubleValue{
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "dd/MM/yyyy"
                let timeFormat = DateFormatter()
                timeFormat.dateFormat = "hh:mm:ss"
                
                let curTimeStamp: NSNumber? = NSDate().timeIntervalSince1970 as NSNumber
                let curTimeStampDate = NSDate(timeIntervalSince1970: (curTimeStamp?.doubleValue)!)
                
                if dateFormat.string(from: timeStampDate as Date) == dateFormat.string(from: curTimeStampDate as Date){
                    dateLabel.text = "Today"
                }else{
                     dateLabel.text = dateFormat.string(from: timeStampDate as Date)
                }
                
                timeLabel.text = timeFormat.string(from: timeStampDate as Date)
            }
            
        }
    }
    
    private func setupNameAndProfileImage(){
             
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            })
        }
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        self.detailTextLabel?.textColor = UIColor.darkGray
        self.detailTextLabel?.text = message?.text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let dateLabel :UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.darkGray
        
        return dateLabel
    }()
    
    let timeLabel :UILabel = {
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.darkGray
        
        return timeLabel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(dateLabel)
        addSubview(timeLabel)
        
        // add constrains x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //dateLabel constrains
        dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        dateLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
        //timeLabel constrains
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant : -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("inint has not been implemented")
    }
}