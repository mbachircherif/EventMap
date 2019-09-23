//
//  selfProfil.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 29/09/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Segmentio
import Firebase

class Profil: UIViewController {
    
    var handle : AnyObject?
    var colViewContainer : UIView!
    var profilId : String!
    
    enum TabIndex : Int {
        case firstChildTab = 0
        case secondChildTab = 1
    }
    
    /// OUTLETS
    
    
    // removing weak https://stackoverflow.com/questions/26924791/swift-fatal-error-unexpectedly-found-nil-while-unwrapping-an-optional-value
    var segmentioView = Segmentio(frame : CGRect.zero)
    
    // Define the current view in ContainerView
    var currentViewController: UICollectionViewController?
    
    // Instantiate the views Controller to switch between
    lazy var firstChildTabVC: UICollectionViewController? = {
        
        // Implement uicollectionviewFLOWlayout instead of uicollectionviewlayout
        // You need to set the item sizes properly with uicollectionviewFLOWlayout
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6)
        layout.itemSize = CGSize(width: 176, height: 270)
        //layout.footerReferenceSize = CGSize(width : frame.width, height: 50)
        let incomEvents = incomingEvents(collectionViewLayout : layout)
        incomEvents.nameProfil = userData.uID
        return incomEvents
        
    }()
    
    lazy var secondChildTabVC : UICollectionViewController? = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.estimatedItemSize = CGSize(width: frame.width, height: 100)
        layout.footerReferenceSize = CGSize(width : frame.width, height: 50)
        let collectionEvent = collectionUser(collectionViewLayout : layout)
        collectionEvent.nameProfil = userData.uID
        return collectionEvent
    }()
    
    // MARK - DISPLAY TAB FUNCTIONS
    
    /// BON EXEMPLE DE VARIABLE FONCTION
    // Display the appropriate viewController depending of the tab selected
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            
            // Appellé automatiquement quand on add ou remove une view
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.colViewContainer.bounds
            print(self.colViewContainer.bounds)
            self.colViewContainer.addSubview(vc.view)
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
        
        let leftItem : UIButton = UIButton(type: .system)
        
        if profilId == nil || profilId == userData.uID{
            
            leftItem.setImage(UIImage(named: "option_35.png"), for: .normal)
            leftItem.tintColor = .lightGray
            
        } else {
                // Add following button
            leftItem.setImage(UIImage(named: "add_user_35.png"), for: .normal)
            leftItem.tintColor = .white
            leftItem.backgroundColor = UIColor(red: 50/255, green: 88/255, blue: 251/255, alpha: 1)
            leftItem.contentEdgeInsets = UIEdgeInsetsMake(8, 11, 8, 11)
            leftItem.layer.cornerRadius = 4
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView:leftItem)
        retrieveFirebaseDataProfil()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        displayCurrentTab(TabIndex.firstChildTab.rawValue)
        // https://stackoverflow.com/questions/37244576/calling-a-function-that-has-a-typealias-as-a-parameter
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in self?.switchTab(segmentIndex)}
        //segmentioView.selectedSegmentioIndex = TabIndex.firstChildTab.rawValue
    }
    
    /// BUILD DESIGN PAGE ///
    
    override func loadView(){
        super.loadView()
        
        navigationController?.navigationBar.isTranslucent = false
        
        let mainContainer : UIView = UIView()
        mainContainer.backgroundColor = .white
        self.view.addSubview(mainContainer)
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Initialize https://github.com/Yalantis/Segmentio
        let content:[SegmentioItem] = [SegmentioItem(title: "Upcoming", image: UIImage(named: "cat_food")),
                                       SegmentioItem(title: "Events", image: UIImage(named: "cat_concert"))]
        
        segmentioView.translatesAutoresizingMaskIntoConstraints = false
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
        
        mainContainer.addSubview(segmentioView)
        
        let profilContainer : UIView = UIView()
        profilContainer.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(profilContainer)
        
        let profilPhoto : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        profilPhoto.image = UIImage(named: "moi.png")
        profilPhoto.layer.cornerRadius = profilPhoto.frame.height/2
        profilPhoto.clipsToBounds = true
        
        let name : UILabel = UILabel()
        name.text = "Paul Kalkbrenner"
        name.font = UIFont.boldSystemFont(ofSize: 18)
        name.textColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        name.translatesAutoresizingMaskIntoConstraints = false
        
        let occupation : UILabel = UILabel()
        occupation.text = "Dj Set @ Mama Shelter"
        occupation.font = UIFont.systemFont(ofSize: 14)
        occupation.textColor = UIColor(red: 54/255, green: 16/255, blue: 107/255, alpha: 1)
        occupation.translatesAutoresizingMaskIntoConstraints = false
        
        let followStats : UIButton = UIButton(type: .system)
        followStats.setImage(UIImage(named: "like_35.png"), for: .normal)
        followStats.setTitle("145", for: .normal)
        followStats.tintColor = .lightGray
        followStats.setTitleColor(UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1), for: .normal)
        followStats.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        followStats.translatesAutoresizingMaskIntoConstraints = false
        
        let visitStats : UIButton = UIButton(type: .system)
        visitStats.setImage(UIImage(named: "visible_35.png"), for: .normal)
        visitStats.tintColor = .lightGray
        visitStats.setTitle("145", for: .normal)
        visitStats.setTitleColor(UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1), for: .normal)
        visitStats.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        visitStats.translatesAutoresizingMaskIntoConstraints = false
        
        /*let followButton : UIButton = UIButton(type: .system)
        followButton.backgroundColor = UIColor(red: 54/255, green: 16/255, blue: 107/255, alpha: 1)
        followButton.setImage(UIImage(named: "add_user_35.png"), for: .normal)
        followButton.contentEdgeInsets = UIEdgeInsetsMake(9, 10, 9, 8)
        followButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0)
        followButton.layer.cornerRadius = 4
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        followButton.setTitle("Suivre", for: .normal)
        followButton.setTitleColor(UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1), for: .normal)
        followButton.translatesAutoresizingMaskIntoConstraints = false*/
        
            // Collecttion View Container
        colViewContainer = UIView()
        mainContainer.addSubview(colViewContainer)
        colViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let rightContainer : UIView = UIView()
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        let leftContainer: UIView = UIView()
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Containers to superview
        profilContainer.addSubview(rightContainer)
        profilContainer.addSubview(leftContainer)
        
        // Add items to leftContainer
        leftContainer.addSubview(profilPhoto)
        
        // Add items to rightContainer
        rightContainer.addSubview(name)
        rightContainer.addSubview(occupation)
        rightContainer.addSubview(followStats)
        rightContainer.addSubview(visitStats)
        //rightContainer.addSubview(followButton)
        
        /// BUILD CONSTRAINTS ///
        
            // Extra Variable
        let sizeNameLabelText : CGSize = name.text!.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13.0)])
        
            // Main Container
        mainContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        mainContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        mainContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
            // ProfilContainer Container
        profilContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        profilContainer.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        profilContainer.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        profilContainer.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
            /// Left Container
        leftContainer.topAnchor.constraint(equalTo: profilContainer.topAnchor, constant: 10) .isActive = true
        leftContainer.leftAnchor.constraint(equalTo: profilContainer.leftAnchor, constant: 20).isActive = true
        
            /// Right Container
        rightContainer.topAnchor.constraint(equalTo: profilContainer.topAnchor, constant: 10).isActive = true
        rightContainer.rightAnchor.constraint(equalTo: profilContainer.rightAnchor, constant: 0).isActive = true
        
            /// Junction between container left & right
        leftContainer.rightAnchor.constraint(equalTo: rightContainer.leftAnchor, constant: -10).isActive = true

            /// Left Container Subviews Constraint
        
        profilPhoto.topAnchor.constraint(equalTo: leftContainer.topAnchor, constant: 0).isActive = true
        profilPhoto.leftAnchor.constraint(equalTo: leftContainer.leftAnchor, constant: 0).isActive = true
        profilPhoto.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor, constant: 0).isActive = true
        profilPhoto.rightAnchor.constraint(equalTo: leftContainer.rightAnchor, constant: 0).isActive = true
        
        
            /// Right Container Subviews
            // Name Label // No need to specify height with label when using constraint
        name.topAnchor.constraint(equalTo: rightContainer.topAnchor, constant: 0).isActive = true
        name.leftAnchor.constraint(equalTo: (name.superview?.leftAnchor)!, constant: 0).isActive = true
        name.rightAnchor.constraint(equalTo: (name.superview?.rightAnchor)!, constant: 0).isActive = true
        
            // Ocupation Label
        occupation.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 3).isActive = true
        occupation.leftAnchor.constraint(equalTo: (occupation.superview?.leftAnchor)!, constant: 0).isActive = true
        occupation.rightAnchor.constraint(equalTo: (occupation.superview?.rightAnchor)!, constant: 0).isActive = true

        
            // followStats Label
        followStats.leftAnchor.constraint(equalTo: (followStats.superview?.leftAnchor)!, constant: 0).isActive = true
        followStats.topAnchor.constraint(equalTo: occupation.bottomAnchor, constant: 3).isActive = true
        
            // VisitStats Label
        visitStats.topAnchor.constraint(equalTo: occupation.bottomAnchor, constant: 3).isActive = true
        visitStats.leftAnchor.constraint(equalTo: followStats.rightAnchor, constant: 5).isActive = true

        
            // Follow Button
        //followButton.leftAnchor.constraint(equalTo: (followButton.superview?.leftAnchor)!, constant: 0).isActive = true
        //followButton.topAnchor.constraint(equalTo: likeStats.bottomAnchor, constant: 5).isActive = true
        
            // Close Right Content
        rightContainer.bottomAnchor.constraint(equalTo: followStats.bottomAnchor, constant: 0).isActive = true
        
            // Close ProfilContainer
        
            /// SEGMENT IO CONSTRAINT               //profilContainer.bottomAnchor --> Ne marche pas puisque n'est pas la superview de contentSegment
        segmentioView.topAnchor.constraint(equalTo: profilContainer.bottomAnchor, constant: 0).isActive = true
        segmentioView.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        segmentioView.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        segmentioView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
            /// COLLECTION VIEW CONTAINER CONSTRAINTS
        colViewContainer.topAnchor.constraint(equalTo: segmentioView.bottomAnchor, constant: 0).isActive = true
        colViewContainer.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        colViewContainer.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        colViewContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 0).isActive = true
        colViewContainer.backgroundColor = .gray
        
        /// END BUILDING CONSTRAINTS ///
        
        // Once constraints are builed up we resize the segmentIO
        //segmentioView.sizeToFit()
        
    }
    
    /// END BUILDING PAGE ////
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
            /// Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.proBio.text = userData.uBio
        //self.proOccupation.text = userData.uOccupation
        //self.proName.text = userData.uName
        
    }
    
    /*override func loadView() {
        super.loadView()
        
        /// Profile Label
        let profilLabel = UILabel()
        profilLabel.text = "PROFIL"
        profilLabel.sizeToFit()
        
        /// SET NAVIGATION BAR OPAQUE
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = profilLabel
        let modifyProfilBarButtonItem = UIBarButtonItem(image: UIImage(named:"settings_32.png"), style: .done, target: self, action: #selector(presentModifProfilPage))
        modifyProfilBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = modifyProfilBarButtonItem
        
        // Initialize https://github.com/Yalantis/Segmentio
        let content:[SegmentioItem] = [SegmentioItem(title: "♥", image: UIImage(named: "cat_food")),
                                       SegmentioItem(title: "Collections", image: UIImage(named: "cat_concert"))]
        
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
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPeopleLikeList(_ sender: Any) {
        let vc = LikeListTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// SHOW SETTINGS MODIFICATION PAGE
    func presentModifProfilPage(){
        let vc = modifyProfil()
        vc.uid = userData.uID
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    /// MARK - RETRIEVE PROFIL DATA
    
    func retrieveFirebaseDataProfil(){
        
        let ref = Database.database().reference(withPath: "events")
        let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
        
        // Retrieve Data from Database event
        ref.child(userData.uID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            /// RETRIEVE IMAGE PROFIL
            let imgUser = value?["img_profil"] as! String
            let imgEventData = storageRef.child("img_profil/\(imgUser)")
            self.retrieveImageFormDB(ref : imgEventData){(image: UIImage?) -> Void in
                //self.proImg.image = image
            }
            
        })
        
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


