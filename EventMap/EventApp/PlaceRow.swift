//
//  PlaceRow.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 15/01/2018.
//  Copyright © 2018 BACHIR-CHERIF Mohamed. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import Eureka

public final class PlaceRow: OptionsRow<PushSelectorCell<GMSPlace>>, PresenterRowType, RowType {
    
    public typealias PresenterRow = SearchPlaceController
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return SearchPlaceController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        self.displayValueFor = nil
        
        /*displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
            return  "\(latitude), \(longitude)"
        }*/
    }
    
    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

public class SearchPlaceController: UIViewController, TypedRowControllerType, UINavigationControllerDelegate {
    
    public var row: RowOf<GMSPlace>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Keep the navigation bar visible.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    @objc func tappedDone(){
        //let target = mapView.projection.coordinate(for: ellipsisLayer.position)
        //row.value = CLLocation(latitude: target.latitude, longitude: target.longitude)
        print ("OK")
        onDismissCallback?(self)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        resultsViewController?.dismiss(animated: true, completion: nil)
    }
    
}

// Handle the user's selection.
extension SearchPlaceController: GMSAutocompleteResultsViewControllerDelegate {
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        row.value = place
    }

    
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    public func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    public func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}
