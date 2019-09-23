//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Eureka

public final class LocationRow: OptionsRow<PushSelectorCell<CLLocation>>, PresenterRowType, RowType {
    
    public typealias PresenterRow = MapViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return MapViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
            return  "\(latitude), \(longitude)"
        }
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

public class MapViewController : UIViewController, TypedRowControllerType, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    public var row: RowOf<CLLocation>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var placeCLL: CLLocation?
    var currentAdress: String?
    
    lazy var button : UIBarButtonItem = { [weak self] in
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MapViewController.tappedDone(_:)))
        b.title = "Done"
        return b
    }()
    
    
    lazy var locationUser: CLLocationManager = { [unowned self] in
        let l = CLLocationManager()
        return l
    }()
    
    lazy var mapView : GMSMapView = { [unowned self] in
        let v = GMSMapView(frame: self.view.bounds)
        v.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        return v
        }()
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = UIImage(named: "map_pin", in: Bundle(for: MapViewController.self), compatibleWith: nil)
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()
    
    let width: CGFloat = 10.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        return ellipse
        }()
    
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        layer.path = self.ellipse.cgPath
        layer.fillColor = UIColor.gray.cgColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.gray.cgColor
        return layer
        }()
    
    
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
        
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        
        // Define a new area to fit the searchViewController --> searchBar size height incrased in iOs 11
        var newSafeArea = UIEdgeInsets()
        newSafeArea.top += ((searchController?.searchBar.frame.height)! - 44) // 44 refer to original height size of searchBar
        resultsViewController?.additionalSafeAreaInsets = newSafeArea
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        navigationItem.rightBarButtonItem = button
        
        if let value = row.value {
            let camera = GMSCameraPosition.camera(withLatitude: 45.75, longitude: 4.85, zoom: 13.5)
            mapView.camera = camera
        }
        else{
            mapView.isMyLocationEnabled = true
            //Location Manager code to fetch current location
            locationUser.delegate = self
            locationUser.startUpdatingLocation()
            let camera = GMSCameraPosition.camera(withLatitude: (locationUser.location?.coordinate.latitude)!, longitude: (locationUser.location?.coordinate.longitude)!, zoom: 13.5)
            mapView.camera = camera
        }
        placeCLL = CLLocation(latitude: (locationUser.location?.coordinate.latitude)! , longitude: (locationUser.location?.coordinate.longitude)!)
        updateTitle()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // This makes the view area include the nav bar even though it is opaque.
        // Adjust the view placement down.
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.isTranslucent = false
        searchController?.hidesNavigationBarDuringPresentation = false
        
        let mapCenter = mapView.center
        let center = mapView.convert(mapCenter, to: pinView)
        
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        row.value = placeCLL
        locationUser.stopUpdatingLocation()
    }
    
    @objc func tappedDone(_ sender: UIBarButtonItem){
        row.value = placeCLL
        locationUser.stopUpdatingLocation()
        onDismissCallback?(self)
    }
    
    func updateTitle(){

        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate((placeCLL?.coordinate)!) { response, error in
            self.searchController?.searchBar.placeholder = "Chargement..."
            self.searchController?.searchBar.isUserInteractionEnabled = true
            if error != nil {
                fatalError("Unable to find adress by coordinate \((self.placeCLL?.coordinate)!)")
                self.searchController?.searchBar.placeholder = "Aucune adresse trouvée"
                self.searchController?.searchBar.isUserInteractionEnabled = true
            }
            
            if let location = response?.firstResult() {
                let lines = location.lines! as [String] // ["14 Chaussée Yves Kerguélen", "38090 Villefontaine"]
                let adress = lines[0]
                // If current adress is used for the first time
                self.currentAdress = adress+", "+location.locality!
                self.searchController?.searchBar.placeholder = adress
                self.searchController?.searchBar.isUserInteractionEnabled = true
            }
        }
    }
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
        })
    }
    
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
        })
        placeCLL = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        updateTitle()
    }
    
}

public final class ImageCheckRow<T: Equatable>: Row<ImageCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ImageCheckCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Image for selected state
    lazy public var trueImage: UIImage = {
        return UIImage(named: "selected")!
    }()
    
    /// Image for unselected state
    lazy public var falseImage: UIImage = {
        return UIImage(named: "unselected")!
    }()
    
    public override func update() {
        super.update()
        checkImageView?.image = row.value != nil ? trueImage : falseImage
        checkImageView?.sizeToFit()
    }
    
    /// Image view to render images. If `accessoryType` is set to `checkmark`
    /// will create a new `UIImageView` and set it as `accessoryView`.
    /// Otherwise returns `self.imageView`.
    open var checkImageView: UIImageView? {
        guard accessoryType == .checkmark else {
            return self.imageView
        }
        
        guard let accessoryView = accessoryView else {
            let imageView = UIImageView()
            self.accessoryView = imageView
            return imageView
        }
        
        return accessoryView as? UIImageView
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .none
    }
    
    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }
    
}

// Handle the user's selection.
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                                  didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        placeCLL = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        currentAdress = place.formattedAddress
        
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
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
    
    public func didRequestAutocompletePredictionsForResultsController(forResultsController resultsController: GMSAutocompleteResultsViewController){
    }
    
    public func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.placeholder = ""
        return true
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.placeholder == "" {searchBar.placeholder = currentAdress}
        return true
    }
    
    public func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.hidesBackButton = false
    }
    
    public func didDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem = button
    }
    
}
