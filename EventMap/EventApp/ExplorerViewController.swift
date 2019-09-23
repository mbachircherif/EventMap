//
//  ExplorerViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 21/04/2018.
//  Copyright © 2018 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Segmentio
import Firebase

private let reuseIdentifier = "Cell"

class ExplorerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    var fakeData : [(img: UIImage, organizer: String, gender: String, location: String)] = [(img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE"), (img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE"), (img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE"), (img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE"), (img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE"), (img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE"), (img: UIImage(named: "vogue.png")!, organizer: "Vogue Paris", gender: "Mode, Fashion, Tourisme", location: "Lyon, FRANCE")]
    
    lazy var searchBar : UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
    lazy var segmentioView = Segmentio(frame : CGRect.zero)
    
    lazy var organizerCollection: UICollectionViewController? = {
        
        // Implement uicollectionviewFLOWlayout instead of uicollectionviewlayout
        // You need to set the item sizes properly with uicollectionviewFLOWlayout
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6)
        layout.itemSize = CGSize(width: self.view.frame.width - 12, height: 125)
        let organizerCollectionViewController = UICollectionViewController(collectionViewLayout : layout)
        return organizerCollectionViewController
        
    }()
    
    override func loadView() {
        super.loadView()
        
        let mainContainer : UIView = UIView()
        
        let content:[SegmentioItem] = [SegmentioItem(title: "Nearby", image: UIImage(named: "cat_food")),
                                       SegmentioItem(title: "Worldwide", image: UIImage(named: "cat_concert")),
                                       SegmentioItem(title: "Business", image: UIImage(named: "cat_concert")),
                                       SegmentioItem(title: "Mode", image: UIImage(named: "cat_concert")),
                                       SegmentioItem(title: "Home", image: UIImage(named: "cat_concert"))]
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
        
        mainContainer.translatesAutoresizingMaskIntoConstraints =  false
        organizerCollection?.view.translatesAutoresizingMaskIntoConstraints = false
                segmentioView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(mainContainer)
        mainContainer.addSubview((organizerCollection?.view)!)
        mainContainer.addSubview(segmentioView)
        
        mainContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        mainContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        mainContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        segmentioView.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        segmentioView.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        segmentioView.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        segmentioView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        organizerCollection?.view.topAnchor.constraint(equalTo: segmentioView.bottomAnchor, constant: 0).isActive = true
        organizerCollection?.view.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        organizerCollection?.view.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        organizerCollection?.view.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 0).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        navigationController?.navigationBar.isTranslucent = false
        
        organizerCollection?.collectionView?.delegate = self
        organizerCollection?.collectionView?.dataSource = self
        organizerCollection?.collectionView?.backgroundColor = UIColor.lightGray
        organizerCollection?.collectionView?.register(ExplorerCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //segmentioView.valueDidChange = { [weak self] _, segmentIndex in self?.switchTab(segmentIndex)}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ExplorerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExplorerCollectionViewCell
        
        let indexFakeDataArray = fakeData[indexPath.row]
        print (indexFakeDataArray)
        cell.organizer.text = indexFakeDataArray.organizer
        cell.gender.text = indexFakeDataArray.gender
        cell.location.text = indexFakeDataArray.location
        cell.img.image = indexFakeDataArray.img
        
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // Delegate Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        fakeData.removeAll()
        if searchText.count != 0 {
            fetchSearchUser(value: searchText)
        } else {
            self.organizerCollection?.collectionView?.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    // Database request
    func fetchSearchUser(value : String) {
        
        let ref = Database.database().reference(withPath: "events/username_id/fullname/")
        //let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com")
       
        ref.queryOrderedByKey().queryStarting(atValue: value).queryEnding(atValue: value+"~").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot, self.fakeData.count)
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let key = snap.key
                    let value = snap.value
                    self.fakeData.append((img: UIImage(named: "cults")!, organizer: key, gender: "Design, Interior, Home", location: "Genève, SUISSE"))
                }
                self.organizerCollection?.collectionView?.reloadData()
        })
    }
    
    // Retrieve Data from Database event

}

class ExplorerCollectionViewCell: UICollectionViewCell {
    
    let img : UIImageView = UIImageView()
    let organizer : UILabel = UILabel()
    let gender : UILabel = UILabel()
    let location : UILabel = UILabel()
    let followerNbr : UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.layer.zPosition = 1
        
        followerNbr.setImage(UIImage(named: "add_user_35.png"), for: .normal)
        followerNbr.setTitle("217k", for: .normal)
        followerNbr.setTitleColor(.lightGray, for: .normal)
        followerNbr.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        followerNbr.contentMode = .left
        
        let mainContainer : UIView = UIView()
        
        let leftBandeau : UIView = UIView()
        leftBandeau.backgroundColor = .white
        leftBandeau.layer.zPosition = 2
        
        let separator : UIView = UIView()
        separator.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
        
        organizer.font = UIFont.boldSystemFont(ofSize: 14)
        
        gender.textColor = UIColor.lightGray
        gender.font = UIFont.italicSystemFont(ofSize: 12)
        
        location.font = UIFont.boldSystemFont(ofSize: 13)
        
        self.addSubview(mainContainer)
        mainContainer.addSubview(img)
        mainContainer.addSubview(organizer)
        mainContainer.addSubview(gender)
        mainContainer.addSubview(location)
        mainContainer.addSubview(separator)
        mainContainer.addSubview(followerNbr)
        mainContainer.addSubview(leftBandeau)
        
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        img.translatesAutoresizingMaskIntoConstraints = false
        organizer.translatesAutoresizingMaskIntoConstraints = false
        gender.translatesAutoresizingMaskIntoConstraints = false
        location.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        followerNbr.translatesAutoresizingMaskIntoConstraints = false
        leftBandeau.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        mainContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        mainContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        img.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        img.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        img.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 0).isActive = true
        img.widthAnchor.constraint(equalTo: mainContainer.widthAnchor, multiplier: 0.5).isActive = true
        
        organizer.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 10).isActive = true
        organizer.leftAnchor.constraint(equalTo: img.rightAnchor, constant: 10).isActive = true
        organizer.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        
        gender.topAnchor.constraint(equalTo: organizer.bottomAnchor, constant: 3).isActive = true
        gender.leftAnchor.constraint(equalTo: img.rightAnchor, constant: 10).isActive = true
        gender.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        
        location.topAnchor.constraint(equalTo: gender.bottomAnchor, constant: 7).isActive = true
        location.leftAnchor.constraint(equalTo: img.rightAnchor, constant: 10).isActive = true
        location.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        
        separator.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(location.bottomAnchor, multiplier: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: img.rightAnchor, constant: 0).isActive = true
        separator.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: 0).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        followerNbr.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 5).isActive = true
        followerNbr.leftAnchor.constraint(equalTo: img.rightAnchor, constant: 10).isActive = true
        followerNbr.rightAnchor.constraint(equalTo: mainContainer.rightAnchor, constant: -10).isActive = true
        followerNbr.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -5).isActive = true
        
        // Left Bandeau
        leftBandeau.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        leftBandeau.leftAnchor.constraint(equalTo: mainContainer.leftAnchor, constant: 0).isActive = true
        leftBandeau.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 0).isActive = true
        leftBandeau.widthAnchor.constraint(equalTo: mainContainer.widthAnchor, multiplier: 0.08).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //https://stackoverflow.com/questions/44341768/when-calling-prepareforreuse-in-customtableviewcell-swift-uitableviewcells-be
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

