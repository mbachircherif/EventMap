//
//  scheduleViewController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 05/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import FSCalendar


class scheduleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    fileprivate weak var schedule: FSCalendar!
    weak var delegate: scheduleViewControllerDelegate?
    var choosenDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        
        let sizeView = CGRect(x: 0, y: 0, width: frame.width, height: frame.height/2 + 2)
        /// Create the schedule
        let schedule = FSCalendar(frame: sizeView)
        schedule.select(choosenDate!)
        schedule.appearance.headerMinimumDissolvedAlpha = 0.0
        schedule.dataSource = self
        schedule.delegate = self
        view.addSubview(schedule)
        self.schedule = schedule
    }
    
    /// MARK - Select Date

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.changeDateEvent(date)
        dismiss(animated: true, completion: nil)
    }

}

protocol scheduleViewControllerDelegate : class {
    func changeDateEvent(_ date: Date)
}
