//
//  PreviewEventCollectionViewCell.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 15/04/2018.
//  Copyright © 2018 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class PreviewEventCollectionViewCell: UICollectionViewCell {
    
    let img : UIImageView = UIImageView()
    let title : UILabel = UILabel()
    let organizer : UILabel = UILabel()
    let location : UIButton = UIButton(type: .system)
    let price : UILabel = UILabel()
    let tags : UILabel = UILabel() // Est-ce qu'on initialise ici les variables ?
    let date: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let mainContainer : UIView = UIView()
        
        // Stylisation
        
        title.font = UIFont.boldSystemFont(ofSize: 13)
        title.textColor = UIColor(red: 76/255, green: 76/255, blue: 76/255, alpha: 1)
        
        organizer.font = UIFont(name:"Helvetica-Light", size: 12.0)
        organizer.textColor = UIColor(red: 81/255, green: 77/255, blue: 71/255, alpha: 1)
        
        location.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        location.setTitleColor(UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1) , for: .normal)
        location.setImage(UIImage(named: "marker_black_35.png"), for: .normal)
        
        price.font = UIFont.boldSystemFont(ofSize: 14)
        price.textColor = UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
        
        tags.font = UIFont.italicSystemFont(ofSize: 12)
        tags.textColor = UIColor(red: 112/255, green: 13/255, blue: 164/255, alpha: 1)
        
        date.font = UIFont(name:"HelveticaNeue-Medium", size: 13.0)
        date.textColor = UIColor(red: 76/255, green: 76/255, blue: 76/255, alpha: 1)
        date.textAlignment = .right
        
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        price.textAlignment = .right
        
        self.addSubview(mainContainer)
        mainContainer.addSubview(img)
        mainContainer.addSubview(title)
        mainContainer.addSubview(organizer)
        mainContainer.addSubview(location)
        mainContainer.addSubview(price)
        mainContainer.addSubview(tags)
        mainContainer.addSubview(date)
        
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        self.img.translatesAutoresizingMaskIntoConstraints = false
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.organizer.translatesAutoresizingMaskIntoConstraints = false
        self.location.translatesAutoresizingMaskIntoConstraints = false
        self.price.translatesAutoresizingMaskIntoConstraints = false
        self.tags.translatesAutoresizingMaskIntoConstraints = false
        self.date.translatesAutoresizingMaskIntoConstraints = false
        
        // Building constraints -- START
        
        mainContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        mainContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        mainContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
            // img constraints
        
        img.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        img.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        img.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        img.heightAnchor.constraint(equalToConstant: self.frame.height/2 + 25).isActive = true
        
            // title constraints
        title.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 5).isActive = true
        title.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 10).isActive = true
        
            // Price constraints
        price.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 5).isActive = true
        price.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        
            // Junction between price & title
        title.rightAnchor.constraint(equalTo: price.leftAnchor, constant: 0).isActive = true
        
            // Organizer constraints
        organizer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 1).isActive = true
        organizer.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 10).isActive = true
        organizer.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        
            // Location constraints
        location.topAnchor.constraint(equalTo: organizer.bottomAnchor, constant: 10).isActive = true
        location.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 5).isActive = true
        location.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        
            // Tags constraints
        //tags.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 10).isActive = true
        tags.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(location.bottomAnchor, multiplier: 1).isActive = true
        tags.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 10).isActive = true
        tags.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -10).isActive = true
        
            // Date constraints
        date.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(location.bottomAnchor, multiplier: 1).isActive = true
        //date.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 10).isActive = true
        date.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        date.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -10).isActive = true
        
            // Junction Tags & Date
        tags.rightAnchor.constraint(equalTo: date.leftAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //https://stackoverflow.com/questions/44341768/when-calling-prepareforreuse-in-customtableviewcell-swift-uitableviewcells-be
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
