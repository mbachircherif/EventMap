//
//  addEventVC.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 29/04/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Photos
import Eureka

class addEventVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var previewImg: UIImageView!
    @IBOutlet weak var photoPicker: UICollectionView!
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    let header_ri = "photoPicker_header"
    let screenSize: CGRect = UIScreen.main.bounds
    let retinaMultiplier: CGFloat = UIScreen.main.scale
    var photoLibrary = [UIImage]()
    var currentCell = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup constraints
        previewImg.translatesAutoresizingMaskIntoConstraints = false
        photoPicker.translatesAutoresizingMaskIntoConstraints = false
        
            // Visual Format
        let hScreenSize = screenSize.width
        let viewsDict = ["photoPicker": photoPicker, "previewImg" : previewImg, "hScreenSize" : hScreenSize] as [String : Any]
        
        /*view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewImg]-1-[photoPicker]-|",
                                                                  options: .directionLeadingToTrailing,
                                                                  metrics: nil,
                                                                  views: viewsDict))
        
            // Horizontal Format are set on the storyboard
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[photoPicker(hScreenSize)]-|",
                                                                 options: .alignAllBottom,
                                                                 metrics: nil,
                                                                 views: viewsDict))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[previewImg(hScreenSize)]-|",
                                                          options: .alignAllBottom,
                                                          metrics: nil,
                                                          views: viewsDict))
 */
        
        // Left Done Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView) )
        
        // Right Suivant Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Suivant", style: .plain, target: self, action: #selector(nextPage))
        
        // Delegate and datatsource to the collecitonview photoPicker
        photoPicker.delegate = self
        photoPicker.dataSource = self
        
        // Height of header of collectionview
        let layout = photoPicker.collectionViewLayout as! UICollectionViewFlowLayout
        //layout.headerReferenceSize = CGSize(width: screenSize.width, height: screenSize.height/2)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        grabPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func nextPage(){
        let formView = info_addEvent()
        formView.eventImg = previewImg.image!
        self.navigationController?.pushViewController(formView,animated: true)
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "info_addEvent"{
            if segue.destination is info_addEventTable{
        
            }
        }*/
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoLibrary.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (screenSize.width/4) - 1, height : (screenSize.width/4) - 1)
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = photoLibrary[indexPath.row]
       
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        //let cellImg = photoPicker.cellForItem(at: indexPath)?.viewWithTag(1) as! UIImageView
        if indexPath.row != currentCell{
            grabHDPhoto(_index: indexPath.row)
            currentCell = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: header_ri, for: indexPath)
        return headerView
    }
    
    // Grab Photos
    
    func grabPhoto(){
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .opportunistic
        requestOptions.resizeMode = .none
        requestOptions.isSynchronous = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset , targetSize: CGSize (width: retinaMultiplier * (screenSize.width/4) - 1, height : retinaMultiplier * (screenSize.width/4) - 1), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: {
                        (result: UIImage?, info) -> Void in
                        
                        if self.photoLibrary.indices.contains(i){
                            self.photoLibrary[i] = (result!)
                            self.photoPicker.reloadData()
                        }
                        else {
                            self.photoLibrary.append(result!)
                    }

                    })
                }
            }
            else{
                print("You got no photos !")
            }
        }
    }
    
    // GRAB PHOTO HD
    
    func grabHDPhoto(_index: Int){
 
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        
        requestOptions.deliveryMode = .opportunistic
        requestOptions.isSynchronous = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            
            if fetchResult.count > 0 {
                imgManager.requestImage(for: fetchResult.object(at: _index) as PHAsset , targetSize: CGSize( width: retinaMultiplier * previewImg.frame.width, height: retinaMultiplier * previewImg.frame.height), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: {
                    (result: UIImage?, info) -> Void in
                    
                        self.previewImg.image = result

                })
            }
        }
        
    }
    
// END CLASS
}

    
