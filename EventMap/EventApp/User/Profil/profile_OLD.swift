//
//  profile.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 29/09/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Segmentio
import Firebase

class profile: UIViewController {
    
    var nameProfil : String!
    var handle : AnyObject?
    var uid : String!
    
    enum TabIndex : Int {
        case firstChildTab = 0
        case secondChildTab = 1
    }

    @IBOutlet weak var mainContainer: UIView!
    // removing weak https://stackoverflow.com/questions/26924791/swift-fatal-error-unexpectedly-found-nil-while-unwrapping-an-optional-value
    @IBOutlet var contentSegment: UIView!
    @IBOutlet weak var butFollower: UIButton!
    @IBOutlet weak var butFollowing: UIButton!
    @IBOutlet weak var proFollow: UIButton!
    @IBOutlet weak var proImg: UIImageView!
    @IBOutlet weak var proBio: UILabel!

    var segmentioView = Segmentio(frame : CGRect.zero)
    
    // Define the current view in ContainerView
    var currentViewController: UICollectionViewController?
    
    // Instantiate the views Controller to switch between
    lazy var firstChildTabVC: UICollectionViewController? = {
        
        // Implement uicollectionviewFLOWlayout instead of uicollectionviewlayout
        // You need to set the item sizes properly with uicollectionviewFLOWlayout

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.estimatedItemSize = CGSize(width: frame.width, height: 100)
        layout.footerReferenceSize = CGSize(width : frame.width, height: 50)
        let incomEvents = incomingEvents(collectionViewLayout : layout)
        incomEvents.nameProfil = self.nameProfil
        return incomEvents
        
    }()
    
    lazy var secondChildTabVC : UICollectionViewController? = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.estimatedItemSize = CGSize(width: frame.width, height: 100)
        layout.footerReferenceSize = CGSize(width : frame.width, height: 50)
        let incomEvents = incomingEvents(collectionViewLayout : layout)
        incomEvents.nameProfil = self.nameProfil
        return incomEvents
    }()
    
// MARK - DISPLAY TAB FUNCTIONS
    
    // Display the appropriate viewController depending of the tab selected
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            
            // Appellé automatiquement quand on add ou remove une view
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.mainContainer.bounds
            self.mainContainer.addSubview(vc.view)
            self.currentViewController = vc
        }
    }

    // Called when the user tap segmented Control
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UICollectionViewController? {
        var vc: UICollectionViewController?
        switch index {
        case TabIndex.firstChildTab.rawValue :
            vc = firstChildTabVC
        case TabIndex.secondChildTab.rawValue :
            vc = secondChildTabVC
        default:
            return nil
        }
        
        return vc
    }
    
    func switchTab(_ indexTab : Int) {
        
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(indexTab)
    }
    
// MARK - COMMON FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MODIFICATION OF USER IMAGE PROFIL
        proImg.layer.cornerRadius = proImg.layer.frame.height / 2
        proImg.clipsToBounds = true
        
        contentSegment.addSubview(segmentioView)
        segmentioView.selectedSegmentioIndex = TabIndex.firstChildTab.rawValue
        displayCurrentTab(TabIndex.firstChildTab.rawValue)
        
        // https://stackoverflow.com/questions/37244576/calling-a-function-that-has-a-typealias-as-a-parameter
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in self?.switchTab(segmentIndex)}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
            /// Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                self.uid = user.uid
                self.retrieveFirebaseDataProfil()
                // CHECK IS FOLLOWED OR NOT
                self.checkFollowStatus(ref: Database.database().reference(withPath: "events").child(self.uid).child("following"))
                // Check if the user follow costumer
            }
        }
        
    }
    
    override func loadView() {
        super.loadView()
        
        // Initialize https://github.com/Yalantis/Segmentio
        let content:[SegmentioItem] = [SegmentioItem(title: "Events", image: UIImage(named: "cat_food")),
                                       SegmentioItem(title: "Collections", image: UIImage(named: "cat_concert")),
                                       SegmentioItem(title: "Collections suivies", image: UIImage(named: "cat_concert")),
                                       SegmentioItem(title: "Concert", image: UIImage(named: "cat_concert"))]
        
        //segmentioView.autoresizingMask = .flexibleWidth
        segmentioView.frame = CGRect(x: 0, y: 0, width : frame.width, height: contentSegment.frame.height)
        segmentioView.sizeToFit()
        segmentioView.isUserInteractionEnabled = true
        
        segmentioView.setup(
            content: content,
            style: SegmentioStyle.onlyLabel,
            options: SegmentioOptions(backgroundColor: .white, maxVisibleItems: 4, scrollEnabled: true, indicatorOptions: SegmentioIndicatorOptions(
                type: .bottom,
                ratio: 0.7,
                height: 2,
                color: UIColor(red : 6/255, green: 57/255, blue: 208/255, alpha: 1.0)
                ), horizontalSeparatorOptions: nil, verticalSeparatorOptions: nil, imageContentMode: .scaleAspectFit, labelTextAlignment: .center, labelTextNumberOfLines: 1, segmentStates: SegmentioStates(
                    defaultState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                        titleTextColor: .black
                    ),
                    selectedState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                        titleTextColor: UIColor(red : 6/255, green: 57/255, blue: 208/255, alpha: 1.0)
                    ),
                    highlightedState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                        titleTextColor: .white
                    )
            ), animationDuration: 0.2)
        )
        
        /// CUSTOMIZE FOLLOW BUTTON
        proFollow.layer.borderWidth = 1
        proFollow.layer.borderColor = UIColor.black.cgColor
        proFollow.layer.cornerRadius = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// MARK - DATABASE FUNCTIONS SET
    
    @IBAction func followAction(_ sender: UIButton) {
        let ref = Database.database().reference(withPath: "events")
        
        if sender.titleLabel?.text == "Suivie" {
            ref.child(uid).updateChildValues(["following" : ""]) { (error, ref) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
            
        }
        
        if sender.titleLabel?.text == "Suivre" {
            ref.child(uid).updateChildValues(["following" : nameProfil]){ (error, ref) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
        }
        
        ///
    }
    
    /// MARK - RETRIEVE PROFIL DATA
    
    func retrieveFirebaseDataProfil(){
        
        let ref = Database.database().reference(withPath: "events")
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        
        // Retrieve Data from Database event
        ref.child(nameProfil).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let bioUser = value?["bioUser"] as? String
            self.proBio.text = bioUser

            /// RETRIEVE IMAGE PROFIL
            let imgUser = value?["img_profil"] as! String
            let imgEventData = storageRef.child("img_profil/\(imgUser)")
            self.retrieveImageFormDB(ref : imgEventData){(image: UIImage?) -> Void in
                self.proImg.image = image
            }
            
        })
        
    }
    
    /// Verifie si l'utilisateur follow le personne visité
    /// Si oui, alors il retourne True
    /// Si non, retourne False
    func checkFollowStatus(ref: DatabaseReference){
        ref.observe(.value, with: { (snap) in
            if let eventValue = snap.value as? String {
                if eventValue == "Ninkazi" {
                     self.proFollow.setTitle("Suivie", for: UIControlState.normal)
                }
                else {self.proFollow.setTitle("Suivre", for: UIControlState.normal)}
            }
            else {self.proFollow.setTitle("Suivre", for: UIControlState.normal)}
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /// https://stackoverflow.com/questions/31794542/ios-swift-function-that-returns-asynchronously-retrieved-value
    ///
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
    
    

////
}
