//
//  modifyProfil.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 24/11/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class modifyProfil: FormViewController {
    
    var uid : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Personal Informations")
            
            <<< TextRow("fullname"){ row in
                row.title = "Full name"
                row.placeholder = "Enter text here"
                //row.validationOptions = .validatesOnChange
            }
            
            <<< TextRow("occupation"){ row in
                row.title = "Occupation"
                row.placeholder = "Enter text here"
                row.value = "DJ Set @ Mama Shelter"
                //row.validationOptions = .validatesOnChange
            }
            
            <<< TextAreaRow("biographie") {
                $0.placeholder = "Biographie"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 200)
                $0.value = "Berlin’s Paul Kalkbrenner is a unique international talent. In fact, with seven studio albums and more than 2.4 million Facebook fans, he is one of techno’s biggest superstars.In July 2016 he became the first techno artist to grace long-running European institution Tomorrowland’s main stage and will play the main stage in 2017 as well."
        }
        
        form +++ Section("")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Se déconnecter"
                }
                .onCellSelection { [weak self] (cell, row) in
                    if Auth.auth().currentUser != nil {
                        do {
                            ///  /!\ /!\ /!\ REMOVE OBSERVER FOR PATH USER FIREBASE /!\ /!\ /!\ /!\ /!\
                            try Auth.auth().signOut()
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScreen")
                            self?.present(vc, animated: true, completion: nil)
                            
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
            }
        
    }
    
    override func loadView() {
        super.loadView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.updateData))
    }
    
    func updateData(){
        
        let ref = Database.database().reference(withPath: "events").child(uid)
        
        let fullname: TextRow? = form.rowBy(tag: "fullname")
        let occupation: TextRow? = form.rowBy(tag: "occupation")
        let biographie: TextAreaRow? = form.rowBy(tag: "biographie")
        
        let childUpdates = ["/fullname/": fullname?.value,
                            "/occupation/" : occupation?.value,
                            "/bioUser/" : biographie?.value]
        
        ref.updateChildValues(childUpdates)
    }
    
    func dismissView() {
        dismiss(animated: true)
    }
}
