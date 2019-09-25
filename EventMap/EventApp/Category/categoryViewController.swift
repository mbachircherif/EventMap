//
//  categoryViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 06/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class categoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var categoryArray : [(nom : String, image: UIImage)] = [("Food", UIImage(named: "food")!), ("Movie", UIImage(named: "movie")!), ("Concert", UIImage(named: "party")!), ("Food", UIImage(named: "food")!), ("Movie", UIImage(named: "movie")!), ("Concert", UIImage(named: "party")!)]
    
    weak var delegate: categoryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.cyan
    }

    override func loadView() {
        super.loadView()
        let layout = UICollectionViewFlowLayout()
        //layout.headerReferenceSize = CGSize(width: frame.width - 10, height: 55)
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.estimatedItemSize = CGSize(width: 110, height: 100)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 70, width: frame.width, height: 300), collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 6
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let img = UIImageView()
        img.contentMode = .center
        img.frame = cell.bounds
        img.image = categoryArray[indexPath.row].image
        cell.addSubview(img)
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categoryArray[indexPath.row].nom
        delegate?.changeCategoryEvent(category)
        dismiss(animated: true, completion: nil)
    }
    
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            headerView.backgroundColor = UIColor.gray
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }*/

}

protocol categoryViewControllerDelegate : class {
    func changeCategoryEvent(_ category: String)
}
