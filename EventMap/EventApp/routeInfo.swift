//
//  routeInfo.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 03/12/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class routeInfo: UIViewController {

    var buttonSpace : UIButton!
    var userAdress : String?
    var destinationAdress : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Update button space point string
        let pointString = "."
        let pointStringSize = pointString.size(attributes: [NSFontAttributeName: buttonSpace.titleLabel?.font])
        let repeatPointString : String = String(repeating: pointString, count: Int(buttonSpace.frame.width / pointStringSize.width))
        print (buttonSpace.frame, pointStringSize.width)
        buttonSpace.setTitle(repeatPointString, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func loadView() {
        super.loadView()
        
        // Button User Location
        let buttonLocation = UIButton()
        // create button
        buttonLocation.titleLabel!.numberOfLines = 0
        //buttonLocation.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonLocation.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        buttonLocation.backgroundColor = UIColor.black
        buttonLocation.layer.cornerRadius = 3
        buttonLocation.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        buttonLocation.setTitleColor(UIColor.white, for: .normal)
        buttonLocation.contentEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        buttonLocation.setTitle(userAdress,for: .normal)
        
        // Button Space Arrow
        buttonSpace = UIButton()
        buttonSpace.titleLabel?.numberOfLines = 0
        buttonSpace.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonSpace.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        buttonSpace.backgroundColor = UIColor.white
        buttonSpace.layer.cornerRadius = 3
        buttonSpace.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        buttonSpace.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        // Button Destination Location
        let buttonDestination = UIButton()
        // create button
        buttonDestination.titleLabel!.numberOfLines = 0
        //buttonDestination.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonDestination.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        buttonDestination.backgroundColor = UIColor.black
        buttonDestination.layer.cornerRadius = 3
        buttonDestination.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        buttonDestination.setTitleColor(UIColor.white, for: .normal)
        buttonDestination.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        buttonDestination.setTitle(destinationAdress,for: .normal)
        
        // Button Car/Walk Moving
        let buttonTypeOfTravel = UIButton()
        // create button
        buttonTypeOfTravel.backgroundColor = UIColor.white
        buttonTypeOfTravel.layer.cornerRadius = 3
        buttonTypeOfTravel.layer.borderWidth = 1
        buttonTypeOfTravel.layer.borderColor = UIColor.black.cgColor
        buttonTypeOfTravel.contentEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 15)
        buttonTypeOfTravel.setImage(UIImage(named: "car_32.png"), for: .normal)
        
        // To Distance
        let toLabel = UILabel()
        toLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        toLabel.textColor = .black
        toLabel.text = "To :"
        
        // From Distance
        let fromLabel = UILabel()
        fromLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        fromLabel.textColor = .black
        fromLabel.text = "From :"
        
        // Label Distance
        let distanceLabel = UILabel()
        distanceLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        distanceLabel.textColor = .black
        distanceLabel.text = "24 Km"
        
        // Label Duration
        let durationLabel = UILabel()
        durationLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        durationLabel.textColor = .black
        durationLabel.text = "36 Min"
        
        // Cancel Button
        let cancelButton = UIButton()
        // create button
        cancelButton.backgroundColor = UIColor.red
        cancelButton.layer.cornerRadius = 3
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 15)
        cancelButton.setImage(UIImage(named: "cross_32.png"), for: .normal)
        
        
        // ADD Subview to Superview
        
        view.addSubview(toLabel)
        view.addSubview(fromLabel)
        view.addSubview(buttonLocation)
        //view.addSubview(buttonSpace!)
        view.addSubview(buttonDestination)
        //view.addSubview(buttonTypeOfTravel)
        //view.addSubview(distanceLabel)
        //view.addSubview(durationLabel)
        //view.addSubview(cancelButton)
        
        // AUTOLAYOUT CONSTRAINTS
        
        let viewsDict = ["buttonLocation" : buttonLocation, "buttonSpace": buttonSpace, "buttonDestination" : buttonDestination,
                         "buttonTypeOfTravel": buttonTypeOfTravel, "distanceLabel": distanceLabel, "durationLabel" : durationLabel, "cancelButton" : cancelButton, "toLabel" : toLabel, "fromLabel": fromLabel]
        
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonDestination.translatesAutoresizingMaskIntoConstraints = false
        buttonLocation.translatesAutoresizingMaskIntoConstraints = false
        buttonSpace.translatesAutoresizingMaskIntoConstraints = false
        buttonTypeOfTravel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        /*let buttonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[buttonLocation(<=\(frame.width/3))]-10-[buttonSpace]-10-[buttonDestination(<=\(frame.width/3))]-10-|", options: NSLayoutFormatOptions.alignAllLastBaseline,
                                                                metrics: nil,
                                                                views: viewsDict)
    
        
        let extraInfoConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[buttonTypeOfTravel(50)]-20-[distanceLabel]-10-[durationLabel]-(>=1)-[cancelButton(50)]-10-|", options: NSLayoutFormatOptions.alignAllLastBaseline,
                                                                  metrics: nil,
                                                                  views: viewsDict)*/
        
        let fromLabelWithAdress = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fromLabel]-20-[buttonLocation]", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: viewsDict)
        
        let toLabelWithAdress = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[toLabel]-20-[buttonDestination]", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: viewsDict)
        
        let verticalBetweenLabelsToandFrom = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[toLabel]-(>=1)-[fromLabel]-10-|", options: NSLayoutFormatOptions(rawValue : 0),
                                                                              metrics: nil,
                                                                              views: viewsDict)
        
        view.addConstraints(fromLabelWithAdress)
        view.addConstraints(toLabelWithAdress)
        view.addConstraints(verticalBetweenLabelsToandFrom)
        
        /// VERY IMPORTANT  TO GET THE NEW SIZE OF EACH SUBVIEWS
        view.layoutIfNeeded()
    }

}
