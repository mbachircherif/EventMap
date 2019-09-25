//
//  LikeListTableViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 06/12/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Firebase
import AttributedTextView

private let reuseIdentifier = "Cell"

class LikeListTableViewController: UITableViewController {

    var peopleData : [(uid : String, name: String, image: UIImage)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 60
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        retrievePeopleLike()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peopleData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let currentPeopleData = peopleData[indexPath.row]
        /// ADD CUSTOM LABEL
        let label = AttributedTextView()
        label.attributer = currentPeopleData.name.makeInteract { _ in
            let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "Profil") as! profile
            vc.nameProfil = currentPeopleData.uid
            self.navigationController?.pushViewController(vc, animated: true)
            }
            .all.font(UIFont(name: "HelveticaNeue", size: 14))
            .setLinkColor(UIColor.blue)
        
        label.sizeToFit()
        let labelBounds = label.bounds
        cell.contentView.addSubview(label)
        
        /// ADDING IMAGE
        let image = UIImageView(frame : CGRect(x : 0, y: 0, width: 40, height: 40))
        image.clipsToBounds = true
        image.image = currentPeopleData.image
        image.layer.cornerRadius = 40 / 2
        cell.contentView.addSubview(image)
        
        /// AUTO-LAYOUT
        let viewsDict = ["label" : label, "image": image]
        label.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let descHorizontal = "H:|-25-[image(40)]-10-[label(\(labelBounds.width))]"
        let descVerticalImage = "V:|-[image]-|"
        let descVerticalLabel = "V:|-[label]-|"
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: descHorizontal,
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: viewsDict)
        
        let verticalConstraintImage = NSLayoutConstraint.constraints(withVisualFormat: descVerticalImage,
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: viewsDict)
        
        let verticalConstraintLabel = NSLayoutConstraint.constraints(withVisualFormat: descVerticalLabel,
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: viewsDict)
        
        cell.contentView.addConstraints(horizontalConstraints)
        cell.contentView.addConstraints(verticalConstraintImage)
        cell.contentView.addConstraints(verticalConstraintLabel)
        
        return cell
    }

   /*
    */
    
    func retrievePeopleLike(){

        let ref = Database.database().reference(withPath: "events")
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        
        ref.child(userData.uID!).observeSingleEvent(of: .value, with: { (snap) in
            
            let eventValue = snap.value as? NSDictionary
            let listPeople = eventValue!["following"] as! [String:Any]
            // Retrieve Event
            for people in listPeople.keys{
                
                let peopleDataPath = ref.child(people)
                
                peopleDataPath.observeSingleEvent(of: .value, with: { (snapshot) in
                    let peopleDataValues = snapshot.value as? NSDictionary
                    let namePeople = peopleDataValues!["fullname"] as! String
                    
                    /// RETRIEVE IMAGE PROFIL
                    let imgEventData = storageRef.child("img_profil/\(people).jpg")
                    self.retrieveImageFormDB(ref : imgEventData){(image: UIImage?) -> Void in
                        self.peopleData.append((people, namePeople, image!))
                        self.tableView.reloadData()
                    }
                    
                })
            }
        })
    }
    
    func retrieveImageFormDB(ref: StorageReference, result: @escaping (_ image: UIImage?) -> Void){
        var image : UIImage?
        
        ref.getData(maxSize: 1 * 1024 * 1024) { data , error -> Void in
            if error != nil {
                print (error!)    // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                image = UIImage(data: data!)
                result(image)
            }
        }
    }
}
