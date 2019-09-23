//
//  FollowedTableViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 15/07/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Firebase

class FollowedTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var following : [(uid: String, nameUser : String, occupationUser : String)] = []
    var filteredFollowing : [(uid: String, nameUser : String, occupationUser : String)] = []
    var uid : String?
    var handle : AnyObject?
    let followButton = UIButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        followButton.setTitle("Désabonner", for: UIControlState.normal)
        
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.brown.cgColor
        followButton.layer.cornerRadius = 2
        followButton.setTitleColor(.blue, for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
        
        followButton.sizeToFit()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.uid = user.uid
                self.retrieveAllFollowing()
            } else {
                
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredFollowing.count
        }
        return following.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let followingArray : (uid: String, nameUser : String, occupationUser : String)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            followingArray = filteredFollowing[indexPath.row]
        } else {
            followingArray = following[indexPath.row]
        }
        cell.textLabel?.text = followingArray.nameUser
        cell.detailTextLabel?.text = followingArray.occupationUser
        cell.accessoryView = followButton
        return cell
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredFollowing = following.filter { following in
            return following.nameUser.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func retrieveAllFollowing(){
        let ref = Database.database().reference(withPath: "events")
        
        // Retrieve Data from Database event
        ref.child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let followingList = value?["followed"] as? String
            
            //for follow in followingList!{
            ref.child(followingList!).observeSingleEvent(of: .value, with: { (snap) in
                let followValue = snap.value as? NSDictionary
                let nameUserFollow = followValue?["nameUser"] as! String
                let occupationUserFollow = followValue?["occupationUser"] as! String
                self.following.append((uid: followingList!, nameUser : nameUserFollow, occupationUser : occupationUserFollow))
                self.tableView.reloadData()
            })
            
            //}
            
            
        })
        
    }
    
    func followAction(sender : UIButton!){
        
        // START
        if let cell = sender.superview as? UITableViewCell {
            
            let indexPath = tableView.indexPath(for: cell)
            
            let uidFollowingUser : String?
            
            if searchController.isActive && searchController.searchBar.text != "" {
                uidFollowingUser = self.filteredFollowing[(indexPath?.row)!].uid
            }
                
            else {
                uidFollowingUser = self.following[(indexPath?.row)!].uid
            }
            
            // Check if UIButton is in a follow state or unfollow state
            let ref = Database.database().reference(withPath: "events")
            
            if sender.titleLabel?.text == "Désabonner" {
                sender.setTitle("Suivre", for: UIControlState.normal)
                ref.child(uid!).child("followed").removeValue { (error, ref) in
                    if error != nil {
                        print("error \(String(describing: error))")
                    }
                }
                
            }
                
            else if sender.titleLabel?.text == "Suivre" {
                sender.setTitle("Désabonner", for: UIControlState.normal)
                ref.child(uid!).updateChildValues(["followed" : uidFollowingUser! ]){ (error, ref) in
                    if error != nil {
                        print("error \(String(describing: error))")
                    }
                }
            }
            
        }
        
    }
    // END
    
}

extension FollowedTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
