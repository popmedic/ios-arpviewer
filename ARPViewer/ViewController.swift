//
//  TableViewController.swift
//  ARPViewer
//
//  Created by Kevin Scardina on 3/29/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    var contents:[Any]? = [Any]()
    let NUMBER_OF_SECTIONS = 1
    var myIPAddr = ""
    var defaultGateway = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return NUMBER_OF_SECTIONS
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default:
            return contents?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            
            if let cell = cell as? TableViewCell {
                if let contents = self.contents {
                    if let ip = contents[indexPath.row] as? IP {
                        cell.addrLabel.text = ip.addr
                        cell.macLabel.text = ip.mac
                        if ip.addr == self.defaultGateway {
                            cell.addrLabel.text = String(format: "%@ (Default Gateway)", ip.addr)
                        } else if ip.addr == self.myIPAddr {
                            cell.addrLabel.text = String(format: "%@ (Me)", ip.addr)
                        }
                    }
                }
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        default:
            return 72
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        self.refresh()
    }
    
    func refresh() {
        self.contents =  Utils.allIPs()
        self.defaultGateway = Utils.getDefaultGateway()
        self.myIPAddr = Utils.getIPAddress()
        self.tableView.reloadData()
    }
}
