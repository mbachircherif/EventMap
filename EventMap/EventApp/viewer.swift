//
//  viewer.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 02/04/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class viewer: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Auto-set the UITableViewCells height (requires iOS8+)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let contentHeader = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let titleHeader = UILabel()
        contentHeader.addSubview(titleHeader)
        titleHeader.text = "Nike Club Kits"
        titleHeader.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        titleHeader.sizeToFit()
        
        let competencesUser = UILabel()
        contentHeader.addSubview(competencesUser)
        competencesUser.text = "Directeur artistique du Mama Shelter"
        competencesUser.font = UIFont(name: "HelveticaNeue", size: 12)
        competencesUser.textColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
        competencesUser.sizeToFit()
        
        // Constraint Title Header with contentHeader - Top
        let topTitleTopConstraint = NSLayoutConstraint(item: titleHeader, attribute:
            .top, relatedBy: .equal, toItem: contentHeader,
                            attribute: .top, multiplier: 1.0,
                            constant: 40)
        
        // Constraint CompetencesUser with titleHeader - Top
        let topCompetencesTopConstraint = NSLayoutConstraint(item: competencesUser, attribute:
            .top, relatedBy: .equal, toItem: titleHeader,
                  attribute: .top, multiplier: 1.0,
                  constant: 25)
        
        //when using autolayout we an a view, MUST ALWAYS SET setTranslatesAutoresizingMaskIntoConstraints
        //to false.
        titleHeader.translatesAutoresizingMaskIntoConstraints = false
        competencesUser.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([topTitleTopConstraint, topCompetencesTopConstraint])
        
        self.tableView.tableHeaderView = contentHeader
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 25
        default:
            return 25
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! plainImage
        print (indexPath)

        switch indexPath[0] {
        case 0:
            if indexPath[1] == 0 {
                
                cell.textLabel?.text = "Expected Intention From Love. This Gallery Will Show You Several Works Realised This Year With Collaborations:  Peter Jaworowski & Dav Hill"
                cell.textLabel?.font = UIFont(name: "Baskerville", size : 18)
                cell.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            
            }
            if indexPath[1] == 1 {cell.img.image = UIImage(named: "hbo.jpg")}
            if indexPath[1] == 2 {cell.img.image = UIImage(named: "dark_flower.jpg")}
            if indexPath[1] == 3 {cell.img.image = UIImage(named: "orangina.jpg")}
            if indexPath[1] == 4 {cell.img.image = UIImage(named: "bread.jpg")}
            if indexPath[1] == 6 {
                cell.textLabel?.text = "Voici un commentaire"
                cell.imageView?.image = UIImage(named: "profil.png")
            }
        default:
            cell.textLabel?.text = "Bonjour"
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
