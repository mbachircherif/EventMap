//
//  detailPlaceViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 23/06/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Firebase

class detailPlaceViewController: UIViewController, SemiModalPresentable {

    var handle : AnyObject?
    var coordinate : CLLocationCoordinate2D?
    var uid : String!
    var idEvent = String()
    var dataDict : NSDictionary!
    var imageFullSizeEvent : UIImage!
    
    /// Variables correspondant aux différentes vues de detailPlaceViewController
    var img : UIImageView!
    var titleLabel : UILabel!
    var tags: UILabel!
    var organizerImg : UIImageView!
    var organizer : UILabel!
    var intervalTime : UIButton!
    var distance : UIButton!
    var price : UIButton!
    var likeButton : UIButton!

    weak var delegate:DetailPlaceViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 1, alpha: 0)
        // Nagitation bar options
        //navigationController?.navigationBar.isTranslucent = false
        //searchController?.hidesNavigationBarDuringPresentation = false
        
        // This makes the view area include the nav bar even though it is opaque.
        // Adjust the view placement down.
        //self.extendedLayoutIncludesOpaqueBars = true
        //self.edgesForExtendedLayout = .bottom
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrievingData()

        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                self.uid = user.uid
                // Check if the user follow costumer
                self.checkFollowing()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
    }
   
    @IBAction func showProfil(_ sender: UIButton) {
        let nameProfil = sender.titleLabel?.text
        delegate?.passingNameProfil(string: nameProfil!)
        canceledPresentationEvent(sender: self)
    }
    
    @objc func presentedFullScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.passingIdEvent(dataDict: dataDict, imageFullSizeEvent: imageFullSizeEvent)
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        let ref = Database.database().reference(withPath: "events")
        
        if sender.titleLabel?.text == "Désabonner" {
            print("Désabonner")
            sender.setTitle("Suivre", for: UIControlState.normal)
            ref.child(uid).child("following").removeValue { (error, ref) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
            
        }
            
         if sender.titleLabel?.text == "Suivre" {
            sender.setTitle("Désabonner", for: UIControlState.normal)
            ref.child(uid).setValue(["following" : 1]){ (error, ref) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
        }
    }

    override func loadView() {
        super.loadView()
        
            // Create Views
        
        let mainContainer : UIView = UIView()
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundContainer : UIView = UIView()
        backgroundContainer.backgroundColor = .white
        backgroundContainer.layer.cornerRadius = 8
        backgroundContainer.layer.zPosition = 1
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let containt : UIView = UIView()
        containt.layer.zPosition = 2
        containt.translatesAutoresizingMaskIntoConstraints = false
        
        img = UIImageView()
        img.layer.cornerRadius = 8
        img.backgroundColor = .lightGray
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel = UILabel()
        titleLabel.text = "For Honor Apollyon’s Legacy"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tags = UILabel()
        tags.text = "Rap, Dance, Showcase, night, Gallery, Artiste"
        tags.font = UIFont.systemFont(ofSize: 13)
        tags.textColor = UIColor(red: 151/255, green: 102/255, blue: 255/255, alpha: 1)
        tags.translatesAutoresizingMaskIntoConstraints = false
        
        organizerImg = UIImageView()
        organizerImg.image = UIImage(named: "logo_company.png")
        organizerImg.layer.cornerRadius = 18
        organizerImg.backgroundColor = .black
        organizerImg.contentMode = .scaleAspectFill
        organizerImg.clipsToBounds = true
        organizerImg.translatesAutoresizingMaskIntoConstraints = false
        
        organizer = UILabel()
        organizer.text = "Organisé par Natchdog"
        organizer.font = UIFont.systemFont(ofSize: 14)
        organizer.textColor = UIColor(red: 126/255, green: 126/255, blue: 126/255, alpha: 1)
        organizer.translatesAutoresizingMaskIntoConstraints = false
        
        intervalTime = UIButton(type: .system)
        intervalTime.setImage(UIImage(named:"time_35.png"), for: .normal)
        intervalTime.titleLabel?.adjustsFontSizeToFitWidth = true
        intervalTime.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        intervalTime.setTitle("19.23 → 01.00", for: .normal)
        intervalTime.tintColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        intervalTime.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        intervalTime.translatesAutoresizingMaskIntoConstraints = false
        
        distance = UIButton()
        distance.setTitle("2.4 Km", for: .normal)
        distance.contentMode = .center
        distance.titleLabel?.adjustsFontSizeToFitWidth = true
        distance.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        distance.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        distance.setImage(UIImage(named: "car_32.png"), for: .normal)
        distance.setTitleColor(UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1), for: .normal)
        distance.translatesAutoresizingMaskIntoConstraints = false
        
        price = UIButton()
        price.setTitle("50-60€", for: .normal)
        price.titleLabel?.adjustsFontSizeToFitWidth = true
        price.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        price.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        price.setImage(UIImage(named: "ticket_35.png"), for: .normal)
        price.setTitleColor(UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1), for: .normal)
        price.translatesAutoresizingMaskIntoConstraints = false
        
        likeButton = UIButton(type: .system)
        likeButton.setImage(UIImage(named: "heart_35.png"), for: .normal)
        likeButton.contentEdgeInsets = UIEdgeInsetsMake(9, 12, 9, 12)
        likeButton.layer.borderWidth = 1
        likeButton.layer.borderColor = UIColor(red: 151/255, green: 102/255, blue: 255/255, alpha: 1).cgColor
        likeButton.layer.cornerRadius = 4
        likeButton.tintColor = UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let showDetails : UIButton = UIButton()
        showDetails.setTitle("Know More →", for: .normal)
        showDetails.setTitleColor(.white, for: .normal)
        showDetails.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        showDetails.contentEdgeInsets = UIEdgeInsetsMake(9, 12, 9, 12)
        showDetails.layer.cornerRadius = 4
        showDetails.backgroundColor = UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
        showDetails.addTarget(self, action: #selector(presentedFullScreen(_:)), for: .touchUpInside)
        showDetails.translatesAutoresizingMaskIntoConstraints = false
        
            // Populate views
        
        view.addSubview(mainContainer)
        mainContainer.addSubview(backgroundContainer)
        mainContainer.addSubview(containt)
        containt.addSubview(img)
        containt.addSubview(titleLabel)
        containt.addSubview(tags)
        containt.addSubview(organizerImg)
        containt.addSubview(organizer)
        containt.addSubview(intervalTime)
        containt.addSubview(distance)
        containt.addSubview(price)
        containt.addSubview(likeButton)
        containt.addSubview(showDetails)
        
            /// Build off constraints -- Start
        
        mainContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mainContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mainContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        backgroundContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 70).isActive = true
        backgroundContainer.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 10).isActive = true
        backgroundContainer.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        backgroundContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -10).isActive = true
        
        containt.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        containt.leftAnchor.constraint(equalTo: backgroundContainer.leftAnchor, constant: 13).isActive = true
        containt.rightAnchor.constraint(equalTo: backgroundContainer.rightAnchor, constant: -13).isActive = true
        containt.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor, constant: -10).isActive = true
        
        img.topAnchor.constraint(equalTo: containt.topAnchor, constant: 0).isActive = true
        img.leftAnchor.constraint(equalTo: containt.leftAnchor, constant: 0).isActive = true
        img.rightAnchor.constraint(equalTo: containt.rightAnchor, constant: 0).isActive = true
        img.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: containt.leftAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: containt.rightAnchor, constant: 0).isActive = true
        
        tags.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        tags.leftAnchor.constraint(equalTo: containt.leftAnchor, constant: 0).isActive = true
        tags.rightAnchor.constraint(equalTo: containt.rightAnchor, constant: 0).isActive = true
        
        organizerImg.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 10).isActive = true
        organizerImg.heightAnchor.constraint(equalToConstant: 36).isActive = true
        organizerImg.widthAnchor.constraint(equalToConstant: 36).isActive = true
        organizerImg.leftAnchor.constraint(equalTo: containt.leftAnchor, constant: 0).isActive = true
        
        organizer.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 10).isActive = true
        organizer.leftAnchor.constraint(equalTo: organizerImg.rightAnchor, constant: 10).isActive = true
        organizer.rightAnchor.constraint(equalTo: containt.rightAnchor, constant: 0).isActive = true
        
        intervalTime.topAnchor.constraint(equalTo: organizerImg.bottomAnchor, constant: 13).isActive = true
        intervalTime.leftAnchor.constraint(equalTo: containt.leftAnchor, constant: 0).isActive = true
        
        distance.topAnchor.constraint(equalTo: organizerImg.bottomAnchor, constant: 13).isActive = true
        
        price.topAnchor.constraint(equalTo: organizerImg.bottomAnchor, constant: 13).isActive = true
        price.rightAnchor.constraint(equalTo: containt.rightAnchor, constant: 0).isActive = true
        
            /// JUNCTIONS betweens informations like Time, Price and Distance -- Start
        distance.leftAnchor.constraintLessThanOrEqualToSystemSpacingAfter(intervalTime.rightAnchor, multiplier: 1).isActive = true
        distance.rightAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(price.leftAnchor, multiplier: 1).isActive = true
            /// JUNCTIONS betweens informations like Time, Price and Distance -- end
        
        likeButton.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(intervalTime.bottomAnchor, multiplier: 1).isActive = true
        likeButton.leftAnchor.constraint(equalTo: containt.leftAnchor, constant: 0).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: containt.bottomAnchor, constant: 0).isActive = true
        
        showDetails.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(intervalTime.bottomAnchor, multiplier: 1).isActive = true
        showDetails.rightAnchor.constraint(equalTo: containt.rightAnchor, constant: 0).isActive = true
        showDetails.bottomAnchor.constraint(equalTo: containt.bottomAnchor, constant: 0).isActive = true
        
            /// JUNCTION bewteen like & showDetail Buttons
        likeButton.rightAnchor.constraintLessThanOrEqualToSystemSpacingAfter(showDetails.leftAnchor, multiplier: 1).isActive = true
        
        
            /// Build off constraints -- Stop
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func canceledPresentationEvent(_ sender: Any) {
        if let delegate = navigationController?.transitioningDelegate as? SemiModalTransitionDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func retrievingData() {
        
        let ref = Database.database().reference(withPath: "events/event_info/")
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        
        // Event path
        let eventPath = ref.child(idEvent)
            
        eventPath.observeSingleEvent(of: .value, with: { (snap) in
            let eventValue = snap.value as! NSDictionary
            self.dataDict = eventValue
            
            self.titleLabel.text = eventValue["title"] as? String
            self.tags.text = (eventValue["category"] as! NSArray).componentsJoined(by: ", ")
            self.organizer.text = "Organisé par " + (eventValue["userName"] as! String)
            let startHour = (eventValue["start"] as! String).components(separatedBy: " ")[1]
            let endHour = (eventValue["end"] as! String).components(separatedBy: " ")[1]
            
            self.intervalTime.setTitle(startHour + " → " + endHour, for: .normal)
            self.price.setTitle(eventValue["price"] as? String, for: .normal)
            
            
            
            // Update description
            //self.descriptionEventLabel.text = descriptionEvent
            
            // Create a reference to the file you want to download
            let imgEventData = storageRef.child("event/\(self.idEvent)")
            
            // Download in memory with a maximum allowed size of 2MB (1 * 1024 * 1024 bytes)
            imgEventData.getData(maxSize: 2 * 1024 * 1024) { data, error in
                
                if error != nil {
                print (error!)    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    self.imageFullSizeEvent = image
                    self.img?.image = image
                }
            }
            
        })

}
    
    func checkFollowing(){
        let ref = Database.database().reference(withPath: "events")
        
        // Retrieve Data from Database event
        ref.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

        let value = snapshot.value as? NSDictionary
            let following = value?["following"] as? String
            
            if following == "Gcym6pSoaef7rygaenydSrrrPvY2"{
                //self.followButton.setTitle("Désabonner", for: UIControlState.normal)
            }
            
        })

    }
    
}

// Following and unfollowed state of FollowButton


//https://useyourloaf.com/blog/quick-guide-to-swift-delegates/
protocol DetailPlaceViewControllerDelegate: class {
    func passingNameProfil(string: String)
    func passingIdEvent(dataDict: NSDictionary, imageFullSizeEvent: UIImage)
}

