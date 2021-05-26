//
//  RocketTableViewController.swift
//  RocketReserver
//
//  Created by Aleksander Kulikov on 15.05.2021.
//

import UIKit
import SDWebImage
import Apollo

class RocketTableViewController: UITableViewController {
    
    var launches = [LaunchListQuery.Data.Launch.Launch]()
    private var lastConnection: LaunchListQuery.Data.Launch?
    private var activeRequest: Cancellable?
    
    
    enum ListSection: Int, CaseIterable {
      case launches
      case loading
    }
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      self.loadMoreLaunchesIfTheyExist()
    }
    
    
    
    private func loadMoreLaunchesIfTheyExist() {
      guard let connection = self.lastConnection else {
        // We don't have stored launch details, load from scratch
        self.loadMoreLaunches(from: nil)
        return
      }
        
      guard connection.hasMore else {
        // No more launches to fetch
        return
      }
        
      self.loadMoreLaunches(from: connection.cursor)
    }
    
    private func loadMoreLaunches(from cursor: String?) {
        
      self.activeRequest = Network.shared.apollo.fetch(query: LaunchListQuery(cursor: cursor)) { [weak self] result in
        guard let self = self else {
          return
        }
        self.activeRequest = nil
        defer {
          self.tableView.reloadData()
        }
        switch result {
        case .success(let graphQLResult):
          if let launchConnection = graphQLResult.data?.launches {
            self.lastConnection = launchConnection
            self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
          }
          if let errors = graphQLResult.errors {
            let message = errors
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
            self.showErrorAlert(title: "GraphQL Error(s)",
                                message: message)
        }
        case .failure(let error):
          self.showErrorAlert(title: "Network Error",
                              message: error.localizedDescription)
        }
      }
    }
  
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return ListSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      guard let listSection = ListSection(rawValue: section) else {
        assertionFailure("Invalid section")
        return 0
      }
            
      switch listSection {
      case .launches:
        return self.launches.count
      case .loading:
        if self.lastConnection?.hasMore == false {
          return 0
        } else {
          return 1
        }
      }
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        cell.imageView?.image = nil
//        cell.textLabel?.text = nil
//        cell.detailTextLabel?.text = nil

      guard let listSection = ListSection(rawValue: indexPath.section) else {
        assertionFailure("Invalid section")
        return cell
      }
        
        switch listSection {
        case .launches:
          let launch = self.launches[indexPath.row]
          cell.textLabel?.text = launch.mission?.name
          cell.detailTextLabel?.text = launch.site
            
         // let placeholder = UIImage(named: "placeholder")!
          
          if let missionPatch = launch.mission?.missionPatch {
            cell.imageView?.sd_setImage(with: URL(string: missionPatch)!, placeholderImage: UIImage(named: "missionPatch"))
          } else {
            cell.imageView?.image = UIImage(named: "missionPatch")
          }
   
        case .loading:
          if self.activeRequest == nil {
            cell.textLabel?.text = "Tap to load more"
          } else {
            cell.textLabel?.text = "Loading..."
          }
        }
        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//      guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else {
//        // Nothing is selected, nothing to do
//        return
//      }
//
//      guard let listSection = ListSection(rawValue: selectedIndexPath.section) else {
//        assertionFailure("Invalid section")
//        return
//      }
//
//      switch listSection {
//      case .launches:
//        guard
//          let destination = segue.destination as? UINavigationController,
//          let detail = destination.topViewController as? DetailViewController else {
//            assertionFailure("Wrong kind of destination")
//            return
//        }
//
//        let launch = self.launches[selectedIndexPath.row]
//        detail.launchID = launch.id
//        self.detailViewController = detail
//      case .loading:
//        assertionFailure("Shouldn't have gotten here!")
//      }
//    }
    

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
      guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else {
        return false
      }
              
      guard let listSection = ListSection(rawValue: selectedIndexPath.section) else {
        assertionFailure("Invalid section")
        return false
      }
            
    switch listSection {
      case .launches:
        return true
      case .loading:
        self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        assertionFailure("Shouldn't have gotten here!")
        

        if self.activeRequest == nil {
          self.loadMoreLaunchesIfTheyExist()
        } // else, let the active request finish loading

        self.tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        
        // In either case, don't perform the segue
        return false
      }
    }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func showErrorAlert(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alert, animated: true)
    }
 
}
