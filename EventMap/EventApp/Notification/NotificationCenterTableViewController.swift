//
//  NotificationCenterTableViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 30/06/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Firebase
import AttributedTextView

public var uid : String!

class NotificationCenterTableViewController: UITableViewController {

    var data : [Int : NotificationApp] = [:]
    var index : [Int] = []
    var handle : AnyObject?
    
    ///// END VARIABLES //////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 60
        
        ///////////// A METTRE DANS WILL APPEAR /////////
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                uid = user.uid
                self.retrievingData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let getIndex = index[indexPath.row]
        /// GET Notification Class
        let notification = self.data[getIndex] as! NotificationApp
        
        /// BACKGROUND COLOR READ-UNREAD CELL
        if notification.state == "unread" {
            cell.contentView.backgroundColor = .lightGray
        } else {
            cell.contentView.backgroundColor = .white
        }
        
        /// ADD CUSTOM LABEL
        let label = AttributedTextView()
        label.attributer = notification.senderName!.makeInteract { _ in
                    let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "Profil") as! profile
                    vc.nameProfil = notification.senderName!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                .append(" ")
                .append(notification.typeNotification).black
                .all.font(UIFont(name: "HelveticaNeue", size: 13))
                .setLinkColor(UIColor.blue)
        
        label.sizeToFit()
        let labelBounds = label.bounds
        cell.contentView.addSubview(label)
       
        /// ADDING IMAGE
        let image = UIImageView(frame : CGRect(x : 0, y: 0, width: 40, height: 40))
        image.clipsToBounds = true
        image.image = UIImage(named: "bread.png")
        image.layer.cornerRadius = 40 / 2
        cell.contentView.addSubview(image)
        
        /// ACCESSORY VIEW AS UIBUTTON
        let buttonNotification = notification.buttonNotification
        buttonNotification.tag = getIndex
        if notification.type == "follow" {
            buttonNotification.addTarget(self, action: #selector(followAction), for: .touchUpInside)
        }
        else {
            buttonNotification.addTarget(self, action: #selector(pushToEvent), for: .touchUpInside)
        }
        cell.accessoryView = buttonNotification
        
        /// AUTO-LAYOUT
        let viewsDict = ["label" : label, "image": image, "accessory" : cell.accessoryView]
        label.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        let descHorizontal = "H:|-25-[image(40)]-10-[label(\(labelBounds.width))]"
        let verticalLabel = "V:|-10-[label(\(labelBounds.height))]"
        let verticalImage = "V:|-7-[image(40)]"
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: descHorizontal,
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: viewsDict)
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: verticalLabel,
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: viewsDict)
        let verticalConstraintsImage = NSLayoutConstraint.constraints(withVisualFormat: verticalImage,
                                                                 options: NSLayoutFormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: viewsDict)
        
        cell.contentView.addConstraints(horizontalConstraints)
        cell.contentView.addConstraints(verticalConstraintsImage)
        cell.contentView.addConstraints(verticalConstraints)
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    /// DID SELECT CELL
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let getIndex = self.index[indexPath.row]
        let notification = self.data[getIndex] as! NotificationApp
        if notification.type == "follow" {
            let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "Profil") as! profile
            vc.nameProfil = notification.senderName!
            self.navigationController?.pushViewController(vc, animated: true)
            self.updateNotificationState(row: getIndex)
        } else {
            let eventOverview = eventPresentation()
            eventOverview.idEvent = notification.eventId!
            navigationController?.pushViewController(eventOverview, animated: true)
            self.updateNotificationState(row: getIndex)
        }
    }
    
    @IBAction func dismissNotificationCenter(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // RETRIEVE DATAS
    
    func retrievingData() {
        let ref = Database.database().reference()
        
        // Path notification
        let notificationPath = ref.child("notifications")
        
        // Event path
        let userPathNotification = ref.child("events").child(uid).child("notification")
        // Retrieve Data from Database event
        userPathNotification.observeSingleEvent(of: .value, with: { (snapshot) in
            var notificationIds : [NSNumber] = []
            
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let key = snap.key as String
                let notificationId : NSNumber = NSNumber(value: Int(key)!)
                notificationIds.append(notificationId)
            }

            /// ADD LISTENER ONLY FOR STATUS UNREAD NOTIF ?
             notificationPath.child(notificationIds[0].stringValue).observe(.value, with: { (snap) in
                let notificationStruct = snap.value as? NSDictionary
                let notification : NotificationApp = NotificationApp(id : notificationIds[0].stringValue,
                                                               eventId : notificationStruct?["eventId"] as! String,
                                                               senderName: notificationStruct?["senderName"] as! String ,
                                                               message: notificationStruct?["message"] as! String,
                                                               type: notificationStruct?["type"] as! String,
                                                               state: notificationStruct?["state"] as! String,
                                                               date: notificationStruct?["date"] as! String
                )
                // Check if notification is in the data dict
                if self.data[notificationIds[0].intValue] == nil {
                    self.data[notificationIds[0].intValue] = notification
                    self.index.append(notificationIds[0].intValue)
                } else {
                    self.data.updateValue(notification, forKey: notificationIds[0].intValue)
                }
                self.tableView.reloadData()
            }) /// END OF OBSERVE
            
        })
    }
    
    /// Update notification state
    func updateNotificationState(row : Int){
        let notification = self.data[row] as! NotificationApp
        let ref = Database.database().reference()

        let childUpdates : [String : Any] = ["/notifications/\((notification.id)!)/state": "read",
                                             "events/\(uid!)/notification/\(notification.id!)" : "read"]
        
        ref.updateChildValues(childUpdates){ (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    
    /// IMAGE PUSH TO EVENT PAGE
    func pushToEvent(sender: notificationButton){
        let eventOverview = eventPresentation()
        eventOverview.idEvent = sender.eventId!
        navigationController?.pushViewController(eventOverview, animated: true)
    }
    
    ///// FOLLOW BUTTON IN CELL FUNCTION
    func followAction(sender: UIButton){
    
        let ref = Database.database().reference(withPath: "events")
        let notificationClass = self.data[sender.tag] as! NotificationApp
        
        if sender.titleLabel?.text == "Suivi" {
                ref.child(uid).updateChildValues(["following" : ""]) { (error, ref) in
                    if error != nil {
                        print("error \(String(describing: error))")
                    }
                }
            }
        
        if sender.titleLabel?.text == "Suivre" {
            ref.child(uid).updateChildValues(["following" : notificationClass.senderName]){ (error, ref) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
        }
    }
    
////////////
}

class notificationButton: UIButton {
    var eventId: String?
    
    convenience init(eventId: String) {
        self.init(frame:.zero)
        self.eventId = eventId
    }}

class NotificationApp: NSObject {
    
    private let ref = Database.database().reference(withPath: "events").child(uid).child("following")
    private let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
    
    let id : String?
    let senderName : String?
    let eventId : String?
    let message : String?
    let type : String?
    
    var typeNotification : String {
        switch type {
        case "follow"?: return "vous a suivi"
        case "newEvent"?: return "a soumi un événement"
        default: return "Unknown"
        }
    }
    
    var buttonNotification : UIButton {
        let dummyButton = notificationButton(eventId : eventId!)
        
        switch type {
        case "follow"?:
            dummyButton.setTitle("...", for: UIControlState.normal)
            dummyButton.layer.cornerRadius = 4
            dummyButton.setTitleColor(UIColor.black, for: .normal)
            dummyButton.layer.borderColor = UIColor.blue.cgColor
            dummyButton.layer.borderWidth = 1
            dummyButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 13)
            dummyButton.sizeToFit()
            self.addListenerToFollowButton(sender: dummyButton)
        case "newEvent"?:
            dummyButton.frame = CGRect(x : 0, y: 0, width: 50, height: 50)
            dummyButton.clipsToBounds = true
            dummyButton.layer.cornerRadius = 4
            self.retrieveImgEvent(eventIdentification: eventId!){(image: UIImage?) -> Void in
                dummyButton.setImage(image, for: .normal)
            }
        default:
            return dummyButton
        }
        return dummyButton
    }
    
    let state : String?
    let date : String?
    
    init(id : String, eventId: String, senderName: String, message: String, type: String, state: String, date: String) {
        self.id = id
        self.eventId = eventId
        self.senderName = senderName
        self.type = type
        self.message = message
        self.state = state
        self.date = date
    }
    
    /// ADD LISTENER TO UIBUTTON
    func addListenerToFollowButton(sender : UIButton){
        ref.observe(.value, with: { (snap) in
            if let eventValue = snap.value as? String {
                if eventValue == "Ninkazi" {
                    sender.setTitle("Suivi", for: UIControlState.normal)
                }
                else {sender.setTitle("Suivre", for: UIControlState.normal)}
            }
            else {sender.setTitle("Suivre", for: UIControlState.normal)}
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /// RETRIEVE IMAGE EVENT
    func retrieveImgEvent(eventIdentification : String, result: @escaping (_ image: UIImage?) -> Void){
    var image : UIImage?
    storageRef.child("event/\(eventIdentification)").getData(maxSize: 1 * 1024 * 1024) { data , error -> Void in
        if error != nil {
            print (error!)    // Uh-oh, an error occurred!
        }   else {
            image = UIImage(data: data!)
            result(image)
            }
        }
    }
    
/////////////////////
}

//// END NOTIFICATION

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
