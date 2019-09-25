//
//  info_addEvent.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 13/05/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//
// https://github.com/xmartlabs/Eureka/blob/master/Example/Example/ViewController.swift

import Eureka
import Firebase
import FirebaseStorage
import CoreLocation
import GooglePlaces

class info_addEvent: FormViewController {
    
    var ref: DatabaseReference!
    var eventImg = UIImage()
    
    // GET UID OF USER FIREBASE
    var handle : AnyObject?
    var uid : String!
    var dataCoordinates : [String: Any] = [:]

    // 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // To prevent the inset between navigation bar and form view when the user get back from the LocationRow
        //https://stackoverflow.com/questions/46318022/uisearchbar-increases-navigation-bar-height-in-ios-11
        print (navigationController?.navigationBar.frame.height)
        self.extendedLayoutIncludesOpaqueBars = true
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                self.uid = user.uid
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
        NotificationCenter.default.removeObserver(self, name: .eventAdded, object: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Right Suivant Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publier", style: .plain, target: self, action: #selector(done))
        
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
        self.tableView?.backgroundColor = UIColor.white
        
        TextAreaRow.defaultCellUpdate = { cell, row in
            cell.textView.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
            cell.placeholderLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        }
        
        form +++ Section("Informations")
            
            <<< TextRow("Title"){ row in
                row.title = "Event Name"
                row.placeholder = "Enter text here"
                //row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }
                /*.cellUpdate { cell, row in
                    if  row.section?.form?.validate().count != 0 {
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        print(row.section?.form?.validate().count)
                    } else {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true                    }
            }*/
           
            <<< TextAreaRow("Description") {
                $0.placeholder = "Description"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
            }
            
            <<< MultipleSelectorRow<String>("Diciplines") {
                $0.title = "Diciplines"
                $0.options = ["Showcase", "Rap", "Nightclub", "Danse", "Concert", "Night"]
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            +++ Section("Dates Event")
            
            <<< SwitchRow("privateRow") {
                $0.title = "Public"
                $0.value = false
            }.onChange { row in
                row.title = (row.value ?? false) ? "Private" : "Public"
                row.updateCell()
            }
    
    
            <<< LabelRow(){
    
                $0.hidden = Condition.function(["privateRow"], { form in
                    return !((form.rowBy(tag: "privateRow") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Invite"
            }
            
            <<< DateTimeInlineRow("Starts") {
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*24)
                }
                .onChange { [weak self] row in
                    let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                    
                    // Check if the start date is < to the actual Date
                    
                    if row.value?.compare(Date()) == .orderedAscending {
                        row.cell!.backgroundColor = .red
                        row.updateCell()
                    }
                    else {
                        row.cell!.backgroundColor = .white
                        row.updateCell()
                    }
                    
            }
        
            <<< DateTimeInlineRow("Ends"){
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*25)
                }.onChange { [weak self] row in
                    let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    if row.value?.compare(startRow.value!) == .orderedAscending {
                        row.cell!.backgroundColor = .red
                    }
                    else{
                        row.cell!.backgroundColor = .white
                    }
                    row.updateCell()
            }
    
            <<< LocationRow("LocationCoordinates"){
                $0.title = "Location"
                //$0.value = ""
            }.cellUpdate { cell, row in
            }

            
        +++ Section("Informations complémentaires")
            
            <<< IntRow("Price") {
                $0.title = "Price"
                $0.placeholder = "price"
                }.onCellSelection { cell, row in
                    row.title = (row.title ?? "")
                    row.reload() // or row.updateCell()
        }
        
            <<< IntRow("NumberPlace") {
                $0.title = "Number Places"
                $0.placeholder = "place number"
                }
    
        +++ Section("Contact")
            <<< URLRow("ContactUrl") {
                $0.title = "Web Site"
                $0.placeholder = "And web site url"
                //$0.add(rule: RuleURL())
            }
            
            <<< EmailRow("ContactMail") {
                $0.title = "Email"
                $0.placeholder = "contact@mail.com"
                $0.add(rule: RuleEmail())
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if  row.section?.form?.validate().count != 0 {
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        print(row.section?.form?.validate().count)
                        
                    } else {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
            }

            <<< PhoneRow("ContactPhone"){
                $0.title = "Phone Number"
                $0.placeholder = "+33 0 00 00 00 00"
                }
        
//////////////
    }
    
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func done(){
        
        /// https://firebase.google.com/docs/database/ios/read-and-write#update_specific_fields
        /// CAN DO SIMULTANEOUS UPDATE
        
        ref = Database.database().reference(withPath: "events")
        //let docRef = Firestore.firestore().collection("locations")
        
        let newKey = ref.child("event").childByAutoId().key
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let title: TextRow? = form.rowBy(tag: "Title")
        let category: MultipleSelectorRow<String>? = form.rowBy(tag: "Diciplines")
        let locationCoordinates: LocationRow? = form.rowBy(tag: "LocationCoordinates")
        let description: TextAreaRow? = form.rowBy(tag: "Description")
        let privateEvent: SwitchRow? = form.rowBy(tag: "privateRow")
        let start: DateTimeInlineRow? = form.rowBy(tag: "Starts")
        let end: DateTimeInlineRow? = form.rowBy(tag: "Ends")
        let price: IntRow? = form.rowBy(tag: "Price")
        let nbrPlace: IntRow? = form.rowBy(tag: "NumberPlace")
        let url: URLRow? = form.rowBy(tag: "ContactUrl")
        let mail: EmailRow? = form.rowBy(tag: "ContactMail")
        let phone: PhoneRow? = form.rowBy(tag: "ContactPhone")
        var adressEvent: String = "Nil"

        //Get adress
        retrieveAdress(coord: (locationCoordinates?.value?.coordinate)!){ (adress: String?) -> Void in
            adressEvent = adress!
        
        // Create a Geopoint to store location coordinates
        let latitude = NSNumber(value: (locationCoordinates?.value?.coordinate.latitude)!).doubleValue
        let longitude = NSNumber(value: (locationCoordinates?.value?.coordinate.longitude)!).doubleValue
        
        let geohash = Geohash.encode(latitude: latitude, longitude: longitude, length: 10)
            self.dataCoordinates["coordinates"] = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.dataCoordinates["zoom"] = 14
        
        let structData : [String: Any?] = ["title" : title?.value,
                                           "id": newKey,
                                           "userId" : self.uid,
                                           "userName": userData.uName,
                                           "adress" : adressEvent,
                                           "latitude" : latitude,
                                           "longitude" : longitude,
                                           "category" : Array((category?.value)!),
                                           "description" : description?.value,
                                           "private" : privateEvent?.value,
                                           "start" : formatter.string(from: (start?.value)!),
                                           "end" : formatter.string(from: (end?.value)!),
                                           "price" : price?.value,
                                           "place" : nbrPlace?.value,
                                           "url" : url?.value?.absoluteString,
                                           "mail" : mail?.value,
                                           "phone" : phone?.value,
                                           "image" : self.imageUpload(_name: String(describing: newKey))] ///////
        
            let childUpdates : [String : Any] = ["/\(self.uid!)/event/" : [newKey: true],
                                                 "/event_location/geohashdata/\(self.prefixQuery(string: geohash))/\(geohash)/final/": structData,
                                                 "/event_info/\(newKey)/": structData ]
            self.ref.updateChildValues(childUpdates)
        }
    }
    
    func imageUpload(_name : String) -> String{
        
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        var downloadURL = "None"
        var data = NSData()
        
        data = UIImageJPEGRepresentation(eventImg, 1)! as NSData
        
            // Img Preview 70x70 wgich is the double size of marker icon map because of retina display
        let thumbnailMapImage : Data = UIImageJPEGRepresentation(eventImg.scaled(to: CGSize(width: 70, height: 70), scalingMode: .aspectFill)!, 1)!
        
        // set upload path
        let filePath = "event/" + _name
        let filePathThumbnails = "event/thumbnails/" + _name
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let metaDataThumbnails = StorageMetadata()
        metaDataThumbnails.contentType = "image/jpg"
        
        storageRef.child(filePath).putData(data as Data, metadata: metaData, completion: {(metaData,error) in
        
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            } else{
                //store downloadURL
                downloadURL = metaData!.downloadURL()!.absoluteString
                
                ///* Special Note : Trouver une solution pour synchroniser les upload des infos et des images pour que les infos
                ///  sois utilisable pour lorsque la carte zoom sur l'évnement
                
                // Move To Location Event on the root Map
                NotificationCenter.default.post(name: .eventAdded, object: self.dataCoordinates, userInfo: nil)
                self.dismiss(animated: true, completion: nil)
            }

        })
        
        /// Uploading Thumbnail image to find it on the root map
        storageRef.child(filePathThumbnails).putData(thumbnailMapImage as Data, metadata: metaDataThumbnails, completion: {(metaDataThumbnails, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            } else{
                //store downloadURL
                downloadURL = metaDataThumbnails!.downloadURL()!.absoluteString
            }
            
        })
        
        return _name
        
    }
    
    func retrieveAdress(coord: CLLocationCoordinate2D, result: @escaping (_ adress: String?) -> Void){
        var adress : String?
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coord) { response, error in
            if error != nil {
                adress = "Adresse non trouvé"
                result(adress)
            }
            if let location = response?.firstResult() {
                let lines = location.lines! as [String] // ["14 Chaussée Yves Kerguélen", "38090 Villefontaine"]
                adress = lines.joined(separator: ", ")
                result(adress)
            }
        }
    }
    
    func prefixQuery(string : String) -> String{
        
        let prefix_nbr_car = 3
        
        var multiple = 1
        var startIndex = string.index(string.startIndex, offsetBy: 0)
        var endIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car)
        var prefix = string.substring(with: Range(startIndex..<endIndex))

        repeat {
            startIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car * multiple)
            endIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car * (multiple + 1))
            prefix += "/"+string.substring(with: Range(startIndex..<endIndex))
            multiple += 1

        } while prefix_nbr_car * multiple < string.count - prefix_nbr_car

        return prefix
    }
}

extension Notification.Name {
    static let eventAdded = Notification.Name("eventAdded")
}
