//
//  incomingEvents.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 02/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class incomingEvents: UICollectionViewController {
    
    var nameProfil : String!
    var eventArray : [(eventID : String, title : String, organizer: String, location: String, price: String, tags: String, date: String, image: UIImage)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false
        self.collectionView?.backgroundColor = UIColor.lightGray
            // Register cell classes
        self.collectionView!.register(PreviewEventCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        
        /// FETCHING EVENT DATA FOR USER
        retrievingData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return eventArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PreviewEventCollectionViewCell {
        
        let cell : PreviewEventCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PreviewEventCollectionViewCell
        
        let indexInEventArray = eventArray[indexPath.row]
        cell.img.image = indexInEventArray.image
        cell.title.text = indexInEventArray.title
        cell.organizer.text = indexInEventArray.organizer
        cell.location.setTitle(indexInEventArray.location, for: .normal)
        cell.price.text = indexInEventArray.price
        cell.tags.text = indexInEventArray.tags
        cell.date.text = indexInEventArray.date
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventOverview = eventPresentation()
        eventOverview.idEvent = eventArray[indexPath.row].eventID
        print (eventArray[indexPath.row].eventID)
        navigationController?.pushViewController(eventOverview, animated: true)
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            
            let indexInEventArray = eventArray[indexPath.row]
            let nameEvent = UILabel(frame : CGRect(x: 10, y: 20, width: 100, height: 20))
            nameEvent.text = indexInEventArray.title
            footerView.addSubview(nameEvent)
            footerView.backgroundColor = UIColor.white
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }*/
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
// MARK - DB FUNCTIONS
    
    ///
    func retrievingData() {
        
        let ref = Database.database().reference(withPath: "events")
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        
        ref.child(nameProfil).observeSingleEvent(of: .value, with: { (snap) in
            let eventValue = snap.value as? NSDictionary
            let listEvent = eventValue!["event"] as! [String:Bool]
            
            // For each event -- /!\ Retravailler la boucle pour qu'elle soit le plus rapide possible donc limiter les requetes dans loop ?
            for eventId in listEvent.keys {
            
            // Retrieve Event
            let singleEventPath = ref.child("event_info").child(eventId)
            singleEventPath.observeSingleEvent(of: .value, with: { (snapshot) in
                     let singleEventValues = snapshot.value as? NSDictionary
                     let nameEvent = singleEventValues!["title"] as! String
                     let organizer = singleEventValues!["userName"] as! String
                     let location = singleEventValues!["adress"] as! String
                     let price: String = singleEventValues!["price"] as! String
                let tags : String = (singleEventValues!["category"] as! NSArray).componentsJoined(by: ", ")
                
                // Create a reference to the file you want to download
                let imgEventData = storageRef.child("event/\(eventId)")
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                imgEventData.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    
                    if error != nil {
                        print (error!)    // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.eventArray.append((eventID : eventId, title : nameEvent, organizer: organizer, location: location, price: price, tags: tags, date: "20 avr.", image : image!))
                        print (self.eventArray)
                        self.collectionView?.reloadData()
                    }
                }
                })
                
            } // End For loop event
            
        })
    }
    
///
}
