//
//  EventPresenterViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 17/04/2018.
//  Copyright © 2018 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class EventPresenterViewController: UIViewController {
    
    var mainContainer : UIScrollView!
    var dataDict : NSDictionary!
    var imageFullEvent : UIImage!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.hidesBackButton = true
        
        // Button Back to previous view
        let backButton : UIButton = UIButton(type: .system) //title: "←", style: .plain, target: self, action: nil)
        backButton.setTitle("←", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsetsMake(9, 12, 9, 12)
        backButton.backgroundColor = .white
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1).cgColor
        backButton.layer.cornerRadius = 4
        backButton.addTarget(self, action: #selector(getBack(sender:)), for: .touchUpInside)
        
        // Button edit mode
        let editButton : UIButton = UIButton(type: .system)
        editButton.layer.cornerRadius = 4
        editButton.setImage(UIImage(named: "crayon_24.png"), for: .normal)
        editButton.contentEdgeInsets = UIEdgeInsetsMake(9, 12, 9, 12)
        editButton.backgroundColor = .white
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1).cgColor
        editButton.tintColor = .black
        editButton.addTarget(self, action: #selector(editEvent(sender:)), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        // Do any additional setup after loading the view.
    }
    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    

    override func loadView() {
        super.loadView()
        
        // Build Template
        
        // Create all views
        
        mainContainer = UIScrollView()
        mainContainer.backgroundColor = .white
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView : UIView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let img : UIImageView = UIImageView()
        img.image = imageFullEvent
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        
        let title : UILabel = UILabel()
        title.text = dataDict["title"] as? String
        title.adjustsFontSizeToFitWidth = true
        title.textColor = .black
        title.font = UIFont.boldSystemFont(ofSize: 24)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let date : UILabel = UILabel()
        let splitDate = (dataDict["start"] as? String)?.components(separatedBy: " ")[0]
        let month = splitDate?.components(separatedBy: "-")[1]
        let day = splitDate?.components(separatedBy: "-")[2]
        date.text = day!+"."+month!
        date.font = UIFont.boldSystemFont(ofSize: 24)
        date.textAlignment = .right
        date.translatesAutoresizingMaskIntoConstraints = false
        
        let tags: UILabel = UILabel()
        tags.text = (dataDict["title"] as? Array)?.joined(separator: ", ")
        tags.numberOfLines = 1
        tags.lineBreakMode = .byClipping
        tags.font = UIFont.italicSystemFont(ofSize: 13)
        tags.textColor = UIColor(red: 106/255, green: 51/255, blue: 231/255, alpha: 1)
        tags.translatesAutoresizingMaskIntoConstraints = false
        
        let byLabel : UILabel = UILabel()
        byLabel.text = "par"
        byLabel.font = UIFont.systemFont(ofSize: 20)
        byLabel.textColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        byLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let organizer : UIButton = UIButton()
        organizer.setTitle(dataDict["userName"] as? String, for: .normal)
        organizer.setTitleColor(.white, for: .normal)
        organizer.addTarget(self, action: #selector(showOrganizerProfil(_:)), for: .touchUpInside)
        organizer.contentEdgeInsets = UIEdgeInsetsMake(3, 9, 3, 9)
        organizer.layer.cornerRadius = 4
        organizer.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        organizer.backgroundColor = UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
        organizer.translatesAutoresizingMaskIntoConstraints = false
        
        let intervalTime : UIButton = UIButton(type: .system)
        intervalTime.setImage(UIImage(named:"time_35.png"), for: .normal)
        intervalTime.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        let startHour = (dataDict["start"] as? String)?.components(separatedBy: " ")[1]
        let endHour = (dataDict["end"] as? String)?.components(separatedBy: " ")[1]
        intervalTime.setTitle(startHour! + " → " + endHour!, for: .normal)
        intervalTime.contentHorizontalAlignment = .left
        intervalTime.tintColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        intervalTime.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        intervalTime.translatesAutoresizingMaskIntoConstraints = false
        
        let price: UIButton = UIButton()
        price.setTitle(dataDict["price"] as? String, for: .normal)
        price.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        price.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        price.setImage(UIImage(named: "ticket_35.png"), for: .normal)
        price.setTitleColor(UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1), for: .normal)
        price.translatesAutoresizingMaskIntoConstraints = false
        
        let location :  UIButton = UIButton()
        location.setTitle(dataDict["adress"] as? String, for: .normal)
        location.setTitleColor(.black, for: .normal)
        location.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        location.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        location.contentHorizontalAlignment = .left
        location.setImage(UIImage(named:"marker_black_35.png"), for: .normal)
        location.translatesAutoresizingMaskIntoConstraints = false
        
        let overview : UILabel = UILabel()
        overview.text = dataDict["description"] as? String
        overview.numberOfLines = 0
        overview.font = UIFont.systemFont(ofSize: 15)
        overview.textColor = UIColor(red: 131/255, green: 131/255, blue: 131/255, alpha: 1)
        overview.translatesAutoresizingMaskIntoConstraints = false
        
        let route : UIButton = UIButton(type: .system)
        route.setTitle("Itineraire → ", for: .normal)
        route.backgroundColor = UIColor(red: 75/255, green: 24/255, blue: 145/255, alpha: 1)
        route.setImage(UIImage(named: "car_32.png"), for: .normal)
        route.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        route.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        route.titleLabel?.adjustsFontSizeToFitWidth = true
        route.contentEdgeInsets = UIEdgeInsetsMake(12, 15, 12, 15)
        route.layer.cornerRadius = 4
        route.tintColor = UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
        route.translatesAutoresizingMaskIntoConstraints = false
        
        let likeCollection : UIButton = UIButton(type: .system)
        likeCollection.setImage(UIImage(named: "heart_35.png"), for: .normal)
        likeCollection.contentEdgeInsets = UIEdgeInsetsMake(12, 15, 12, 15)
        likeCollection.layer.borderWidth = 1
        likeCollection.layer.borderColor = UIColor(red: 75/255, green: 24/255, blue: 145/255, alpha: 1).cgColor
        likeCollection.layer.cornerRadius = 4
        likeCollection.tintColor = UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
        likeCollection.translatesAutoresizingMaskIntoConstraints = false
        
        /// Populate views
        self.view.addSubview(mainContainer)
        mainContainer.addSubview(contentView)
        contentView.addSubview(img)
        contentView.addSubview(title)
        contentView.addSubview(date)
        contentView.addSubview(tags)
        contentView.addSubview(byLabel)
        contentView.addSubview(organizer)
        contentView.addSubview(intervalTime)
        contentView.addSubview(price)
        contentView.addSubview(location)
        contentView.addSubview(overview)
        contentView.addSubview(route)
        contentView.addSubview(likeCollection)
        
        
        /// Constraints building
        
        mainContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        mainContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        mainContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        
        contentView.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: -64).isActive = true /// Maybe change safeArea ?
        contentView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 0).isActive = true
        
            // Img Constraints
        img.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        img.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        img.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
        img.heightAnchor.constraint(equalToConstant: self.view.frame.height/2).isActive = true
        
            // Title Constraints
        title.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 10).isActive = true
        title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        title.heightAnchor.constraint(equalToConstant: (title.text?.heightWithConstrainedWidth(width: 0, font: UIFont.boldSystemFont(ofSize: (title.font?.pointSize)!)))!).isActive = true
        
            // Date Constraints
        date.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 10).isActive = true
        date.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
            // Junction between Title & Date
        title.rightAnchor.constraint(equalTo: date.leftAnchor, constant: -10).isActive = true
        
            // Tags constraints
        tags.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 1).isActive = true
        tags.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        tags.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
            // ByLabel constraints
        byLabel.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 10).isActive = true
        byLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        
            // Organizer constraints
        organizer.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 10).isActive = true
        organizer.leftAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(contentView.leftAnchor, multiplier: 1).isActive = true
        
            // Junction betweenn byLabel & Organizer
        byLabel.rightAnchor.constraint(equalTo: organizer.leftAnchor, constant: -10).isActive = true
        
            // IntervalTime Constraints
        intervalTime.topAnchor.constraint(equalTo: organizer.bottomAnchor, constant: 20).isActive = true
        intervalTime.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        
            // Price Constraints
        price.topAnchor.constraint(equalTo: organizer.bottomAnchor, constant: 20).isActive = true
        price.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
            // Junction between IntervalTime & Price
        intervalTime.rightAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(price.leftAnchor, multiplier: 1).isActive = true
        
            // Location constraints
        location.topAnchor.constraint(equalTo: intervalTime.bottomAnchor, constant: 20).isActive = true
        location.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        location.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
            // Overview constraints
        overview.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 25).isActive = true
        overview.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        overview.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        overview.heightAnchor.constraint(equalToConstant: (overview.text?.heightWithConstrainedWidth(width: self.view.frame.width - 20, font: UIFont.systemFont(ofSize: 15)))!).isActive = true
        
            // Route button constraints
        route.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(overview.bottomAnchor, multiplier: 8).isActive = true
        route.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        route.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
            // LikeCollection constraints
        likeCollection.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(overview.bottomAnchor, multiplier: 8).isActive = true
        likeCollection.leftAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(contentView.leftAnchor, multiplier: 1).isActive = true
        likeCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
            // Junction between Route & LikeCollection
        likeCollection.rightAnchor.constraint(equalTo: route.leftAnchor, constant: -20).isActive = true
        
            // CLOSE MAINCONTAINER CONSTRAINTS
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        getHeightForAllSubviews(view: self.mainContainer)
        mainContainer.frame.size = CGSize(width: 375, height: mainContainer.frame.height)
        
    }
    
    /// EXTRA FUNCTIONS
    
    // Back previous view navigation controller
    func editEvent(sender: UIBarButtonItem){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "addEventVC_id")
        let nc = UINavigationController(rootViewController: modalVC)
        self.present(nc, animated: true, completion: nil)
    }
    
    func showOrganizerProfil(_ sender: UIButton){
        let vc = Profil()
        vc.profilId = dataDict["userId"] as? String
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getBack(sender: UIBarButtonItem){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Get the height of a UIScrollView according to it subviews
    func getHeightForAllSubviews(view : UIScrollView){
        var contentRect = CGRect.zero
        
        for v in view.subviews {
            contentRect = contentRect.union(v.frame)
        }
            view.contentSize = contentRect.size
            view.contentSize.width = 375
            view.layoutIfNeeded()
    }
}
