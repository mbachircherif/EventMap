//
//  eventPresentation.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 17/05/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

let cellIdentifier = "Cell"

class eventPresentation: UITableViewController, UITextFieldDelegate {
    
    var editOnOff: Bool = false
    var idEvent = String()
    var uid : String = "dwIHSBYsjbci0SkNrKqMYSziAVk2"
    var coordinate : CLLocationCoordinate2D!
    
    var data:[String:Any] = ["imgEvent" : UIImage(),
        "mapImagePreviewEvent" : UIImage(),
        "titleEvent" : String(),
        "categoryEvent" : NSArray(),
        "managedByEvent" : String(),
        "adressEvent" : String(),
        "descriptionEvent" : String(),
        "startDateEvent" : "20.00",
        "endDateEvent" : "01.00"
    ]

    var price = String()
    weak var delegate:eventPresentationDelegate?
    
    var statusEventButton = UIButton(frame: CGRect(x : 0, y: 0, width : 100, height : 25))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Edit button
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.tappedEdit(_:)))
        editButton.title = "..."
        navigationItem.rightBarButtonItem = editButton
        
        // Need to register a class for a cell in Swift 3.0
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryAndDateEventCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "adressEventCell")
        self.tableView.register(EventEditablePresentationCell.self, forCellReuseIdentifier: "titleEventCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "description_title")
        self.tableView.register(EventEditablePresentationCell.self, forCellReuseIdentifier: "descriptionEventCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "imgEventCell")
        self.tableView.register(UITableViewCell.self.self, forCellReuseIdentifier: "duration_title")
        self.tableView.register(UITableViewCell.self.self, forCellReuseIdentifier: "durationEventCell")
        self.tableView.register(EventEditablePresentationCell.self, forCellReuseIdentifier: "route")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "information_title")
        self.tableView.register(EventEditablePresentationCell.self, forCellReuseIdentifier: "titleEventCell")
        
        self.tableView.estimatedRowHeight = 500
        //self.tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        /// CUSTOMIZE STATUS BUTTON
        statusEventButton.layer.cornerRadius = 4
        statusEventButton.backgroundColor = .white
        statusEventButton.titleLabel?.minimumScaleFactor = 0.5
        statusEventButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        /// ADD STATUS BUTTON TO NAVIGATION
        let statusEventButtonBarItem = UIBarButtonItem(customView: statusEventButton)
        self.navigationItem.rightBarButtonItem = statusEventButtonBarItem
        
        ///
        retrievingData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame = tableView.frame
        // Have to use constraint to replace x,y absolute positions
        let button = UIButton(frame: CGRect(x:frame.size.width - 90, y: (55-30)/2, width:80, height:30))
            // create button
            button.titleLabel!.numberOfLines = 0
            button.titleLabel!.adjustsFontSizeToFitWidth = true
            button.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
            button.backgroundColor = .clear
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.setTitleColor(UIColor(red: 23/255, green: 31/255, blue: 211/255, alpha: 1), for: .normal)
            button.layer.borderColor = UIColor(red: 23/255, green: 31/255, blue: 211/255, alpha: 1).cgColor
        
            button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        //  Check if this event is view by his owner or not
        /////////////////////////////////////////
        if userData.uEvent![idEvent]! {
            button.setTitle("...",for: .normal)
            button.addTarget(self, action: #selector(editMode(_:)), for: .touchUpInside)
        } else{
            button.setTitle("Follow",for: .normal)
        }
        /////////////////////////////////////////
        
        let userButton = UIButton(frame: CGRect(x:10, y: (55-30)/2, width:120, height:30))
            userButton.titleLabel!.adjustsFontSizeToFitWidth = true
            userButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: -20,bottom: 0,right: 0)
            userButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
            userButton.setTitle("Ninkazi", for: .normal)
            userButton.setTitleColor(UIColor(red: 23/255, green: 31/255, blue: 211/255, alpha: 1), for: .normal)
            userButton.setImage(UIImage(named: "ticket_35.png"), for: .normal)
            userButton.addTarget(self, action: #selector(goToProfil), for: .touchUpInside)
        
        let headerView = UIView(frame: CGRect(x:0, y:0, width:frame.size.width, height:frame.size.height))
            headerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
            headerView.addSubview(button)   // add the button to the view
            headerView.addSubview(userButton)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let frame = tableView.frame
        
        // Create Footer View
        let footerView = UIView(frame: CGRect(x:0, y:0, width:frame.size.width, height: 55))
        footerView.backgroundColor = .white
        
        let buttonTicket = UIButton(frame: CGRect(x:0, y: 0, width:180, height: footerView.bounds.height))
        // create button
        buttonTicket.titleLabel!.numberOfLines = 0
        buttonTicket.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonTicket.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        buttonTicket.backgroundColor = UIColor(red: 35/255, green: 56/255, blue: 246/255, alpha: 1)
        buttonTicket.layer.cornerRadius = 3
        buttonTicket.layer.borderWidth = 1
        buttonTicket.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        buttonTicket.setTitleColor(UIColor.white, for: .normal)
        buttonTicket.layer.borderColor = UIColor(red: 35/255, green: 56/255, blue: 246/255, alpha: 1).cgColor
        buttonTicket.addTarget(self, action: #selector(buyTickets), for: .touchUpInside)
        buttonTicket.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        buttonTicket.setTitle("GET TICKETS",for: .normal)
        
        let addToCollectionButton = UIButton(frame: CGRect(x:225, y: 0, width:55, height: footerView.bounds.height))
        // create button
        addToCollectionButton.titleLabel!.numberOfLines = 0
        addToCollectionButton.titleLabel!.adjustsFontSizeToFitWidth = true
        addToCollectionButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        addToCollectionButton.backgroundColor = .clear
        addToCollectionButton.layer.cornerRadius = 3
        addToCollectionButton.layer.borderWidth = 1
        addToCollectionButton.setTitleColor(UIColor.black, for: .normal)
        addToCollectionButton.layer.borderColor = UIColor.black.cgColor
        addToCollectionButton.addTarget(self, action: #selector(addToCollection), for: .touchUpInside)
        
        //addToCollectionButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        addToCollectionButton.setTitle("+",for: .normal)
        
        let showRouteButton = UIButton(frame: CGRect(x:305, y: 0, width:55, height: footerView.bounds.height))
        // create button
        showRouteButton.titleLabel!.numberOfLines = 0
        showRouteButton.titleLabel!.adjustsFontSizeToFitWidth = true
        showRouteButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        showRouteButton.backgroundColor = .clear
        showRouteButton.layer.cornerRadius = 3
        showRouteButton.layer.borderWidth = 1
        showRouteButton.setImage(UIImage(named: "run_32.png"), for: .normal)
        showRouteButton.setTitleColor(UIColor.black, for: .normal)
        showRouteButton.layer.borderColor = UIColor.black.cgColor
        showRouteButton.addTarget(self, action: #selector(bridgeFuncDrawPath), for: .touchUpInside)
        
        //addToCollectionButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        footerView.addSubview(addToCollectionButton)
        footerView.addSubview(buttonTicket)
        footerView.addSubview(showRouteButton)
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(55)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(55)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        //let cell = tableView.dequeueReusableCell(withIdentifier: "categoryAndDateEventCell", for: indexPath as IndexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.row == 0  {

            let cell = EventEditablePresentationCell(style: UITableViewCellStyle.default, reuseIdentifier: "titleEventCell")
            cell.label.text = self.data["titleEvent"] as? String
            cell.tagData = "titleEvent" // Position of titleEvent in self.data
            return cell
            
        }
        
        else if indexPath.row == 1  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "categoryAndDateEventCell")
            let dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            dateLabel.text = "27.10"
            dateLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            dateLabel.sizeToFit()
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Italic", size: 12)
            cell.textLabel?.text = (self.data["categoryEvent"] as? NSArray)?.componentsJoined(by: ", ").uppercased()
            cell.accessoryView = dateLabel as UILabel
            return cell
        }
        
        else if indexPath.row == 2  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "imgEventCell")
            let imageViewCell = UIImageView(frame : CGRect(x: 0, y: 0, width: cell.frame.width, height: 300))
            imageViewCell.clipsToBounds = true
            imageViewCell.contentMode = .scaleAspectFill
            imageViewCell.image = self.data["imgEvent"] as? UIImage
            cell.contentView.addSubview(imageViewCell)
            
            let viewsDict = ["img": imageViewCell]
            imageViewCell.translatesAutoresizingMaskIntoConstraints = false
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[img(200)]-|",
                                                                     options: NSLayoutFormatOptions(rawValue: 0),
                                                                     metrics: nil,
                                                                     views: viewsDict)
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[img]-(20)-|",
                                                                     options: NSLayoutFormatOptions(rawValue: 0),
                                                                     metrics: nil,
                                                                     views: viewsDict)
            cell.contentView.addConstraints(verticalConstraints)
            cell.contentView.addConstraints(horizontalConstraints)
            
            return cell
        }
            
        else if indexPath.row == 3  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "adressEventCell")
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = self.data["adressEvent"] as? String
            
            return cell
        }
           
        else if indexPath.row == 4  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "description_title")
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Italic", size: 13)
            cell.textLabel?.text = "OVERVIEW"
            
            return cell
        }
            
        else if indexPath.row == 5  {
            
            let cell = EventEditablePresentationCell(style: UITableViewCellStyle.default, reuseIdentifier: "descriptionEventCell")
            cell.label.font = UIFont(name: "HelveticaNeue-Italic", size: 13)
            cell.label.text = self.data["descriptionEvent"] as? String
            cell.tagData = "descriptionEvent"
            return cell
        }
            
        else if indexPath.row == 6  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "duration_title")
            
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "DURATION"
    
            return cell
        }
            
        else if indexPath.row == 7  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "durationEventCell")
            
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = self.data["startDateEvent"] as? String
            
            return cell
        }
            
        else if indexPath.row == 8  {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "information_title")
            cell.textLabel?.text = "INFORMATIONS"
            return cell
        }
            
        else if indexPath.row == 9  {
            
            let cell = EventEditablePresentationCell(style: UITableViewCellStyle.default, reuseIdentifier: "route")
            cell.label.text = "http://www.soudcloud.fr"
            cell.label.delegate = self
            cell.label.tag = indexPath.row
            return cell
        }
            
        else {
            // cell = tableView.dequeueReusableCell( withIdentifier: "cell", for: indexPath)
            //set the data here
            return cell!
        }
        
    }
    
    /// TEXTFIELD DELEGATE -- EDITABLE MODE
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !editOnOff {
            return false
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let superclass = textField.superclass as? EventEditablePresentationCell! {
            self.data.updateValue(description, forKey: superclass.tagData)
            print ("IT WORK, IT DOES")
        } else { print ("WHAT THE FUCK ?") }
        
        return true
    }
    
    /// FUNCTIONS
    @objc func tappedEdit(_ sender: UIBarButtonItem){}
    func editMode(_ sender: UIButton) {
        switch editOnOff {
        case true:
            editOnOff = false
            sender.titleLabel?.text = "..."
            sender.addTarget(self, action: #selector(editMode(_:)), for: .touchUpInside)
        case false:
            editOnOff = true
            sender.titleLabel?.text = "save"
            sender.addTarget(self, action: #selector(saveForm(_:)), for: .touchUpInside)
        default:
            editOnOff = false
        }
    }
    
    func saveForm(_ sender: UIButton){
    }
    
    func retrievingData() {
        let ref = Database.database().reference(withPath: "events/event_info/")
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        
        // Retrieve Snapshot Map
        // getMapSnapshot()
        
        // Retrieve Data from Database event
        ref.child(idEvent).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let description : String =  value?["description"] as! String
            let title : String =  value?["title"] as! String
            let category : NSArray = value?["category"] as! NSArray
            let startDate : Date =  self.stringToDate(stringDate: value?["start"] as! String)
            let location : String = value?["adress"] as! String
            let endDate : Date = self.stringToDate(stringDate: value?["end"] as! String)
            
            self.data.updateValue(description, forKey: "descriptionEvent")
            self.data.updateValue(title, forKey: "titleEvent")
            self.data.updateValue(category, forKey: "categoryEvent")
            self.data.updateValue(location, forKey: "adressEvent")
            
            /// Actualise the status event
            let currentDate = Date()
            if currentDate > startDate && currentDate < endDate {
                self.statusEventButton.backgroundColor = UIColor.green
                self.statusEventButton.setTitle("Open", for: .normal)
            } else {
                self.statusEventButton.backgroundColor = UIColor.red
                self.statusEventButton.setTitle("Close", for: .normal)
            }
            
            // Create a reference to the file you want to download
            let imgEventData = storageRef.child("event/\(self.idEvent)")
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            imgEventData.getData(maxSize: 1 * 1024 * 1024) { data, error in
                
                if error != nil {
                    print (error!)    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    self.data.updateValue(image!, forKey: "imgEvent")
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    
    func goToProfil(sender: UIButton){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "Profil") as! profile
        vc.nameProfil = sender.titleLabel?.text
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getMapSnapshot(){
        
        let coords = CLLocationCoordinate2D(latitude: 45.750000, longitude: 4.850000)
        let distanceInMeters: Double = 500
        let size = CGSize(width: 375, height: 136)
        
        let options = MKMapSnapshotOptions()
        options.region = MKCoordinateRegionMakeWithDistance(coords, distanceInMeters, distanceInMeters)
        options.size = size
        
        let snapShotter = MKMapSnapshotter(options: options)
        let bgQueue = DispatchQueue.global(qos: .default)
        // this might be run in foregourd but we want to have responsive UI
        // which helped a lot being a UITableViewCell which lagged a lot
        snapShotter.start(with: bgQueue) { [weak self] (snapShot, error) in
            guard error == nil else {
                return
            }

            /*if let snapShotImage = snapShot?.image, let coordinatePoint = snapShot?.point(for: coords), let pinImage = UIImage(named: "pinImage") {*/

                UIGraphicsBeginImageContextWithOptions(options.size, true, 0)
                snapShot?.image.draw(at: .zero)
                // need to fix the point position to match the anchor point of pin which is in middle bottom of the frame
                //let fixedPinPoint = CGPoint(x: coordinatePoint.x - pinImage.size.width / 2, y: coordinatePoint.y - pinImage.size.height)
                //pinImage.draw(at: fixedPinPoint)
                let mapImagePreview = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self?.data.updateValue(mapImagePreview!, forKey: "mapImagePreviewEvent")
            
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    //self?.tableView.layoutSubviews()
                }
        }
        
    }
    
    /// FUNCTION ADD TO COLLECTION
    func addToCollection(){
        print (self.idEvent, uid)
        let ref = Database.database().reference(withPath: "events").child(uid).child("collection").child(self.idEvent)
        ref.setValue(true, withCompletionBlock: {(error, ref) in
            if error != nil{ print("error \(String(describing: error))") }
            })
    }
    
    /// FUNCTION THAT CONVERT STRING TO DATE
    func stringToDate(stringDate : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: stringDate)
        return date!
    }
   
    func bridgeFuncDrawPath(sender: UIButton){
        delegate?.drawPath(destinationWithCoordinates: coordinate, destinationWithString: self.data["adressEvent"] as! String )
        navigationController?.popToRootViewController(animated: true)
    }
    
    /// GO TO EXTERNAL WEB SITE TO BUY TICKETS
    func buyTickets(){
        let externalWebSite = externWebsite()
        externalWebSite.requestUrl = URLRequest(url: URL(string: "https://www.spotify.com/fr/")!)
        navigationController?.pushViewController(externalWebSite, animated: true)
    }
///
}

protocol eventPresentationDelegate: class {
    func drawPath(destinationWithCoordinates: CLLocationCoordinate2D, destinationWithString: String )
}
