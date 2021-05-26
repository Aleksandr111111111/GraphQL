//
//  DetailViewController.swift
//  RocketReserver
//
//  Created by Aleksander Kulikov on 17.05.2021.
//

import UIKit
import Apollo
import SDWebImage

class DetailViewController: UIViewController {
   
    private var launch: LaunchDetailsQuery.Data.Launch? {
      didSet {
        self.configureView()
        
      }
    }

    @IBOutlet private var missionPatchImageView: UIImageView!
    @IBOutlet private var missionNameLabel: UILabel!
    @IBOutlet private var rocketNameLabel: UILabel!
    @IBOutlet private var launchSiteLabel: UILabel!
    @IBOutlet private var bookCancelButton: UIBarButtonItem!

    var launchID: GraphQLID? {
      didSet {
        self.loadLaunchDetails()
      }
    }


    override func viewDidLoad() {
      super.viewDidLoad()
        
        self.loadLaunchDetails()
        self.configureView()
    }

    func configureView() {
        guard
          self.missionNameLabel != nil,
          let launch = self.launch else {
            return
        }

        self.missionNameLabel.text = launch.mission?.name
        self.title = launch.mission?.name

        //let placeholder = UIImage(named: "placeholder")!

        if let missionPatch = launch.mission?.missionPatch {
            self.missionPatchImageView.sd_setImage(with: URL(string: missionPatch)!, placeholderImage: UIImage(named: "missionPatch"))
        } else {
          self.missionPatchImageView.image = UIImage(named: "missionPatch")
        }

        if let site = launch.site {
          self.launchSiteLabel.text = "Launching from \(site)"
        } else {
          self.launchSiteLabel.text = nil
        }

        if
          let rocketName = launch.rocket?.name ,
          let rocketType = launch.rocket?.type {
            self.rocketNameLabel.text = "🚀 \(rocketName) (\(rocketType))"
        } else {
          self.rocketNameLabel.text = nil
        }

        if launch.isBooked {
          self.bookCancelButton.title = "Cancel trip"
          self.bookCancelButton.tintColor = .red
        } else {
          self.bookCancelButton.title = "Book now!"
          self.bookCancelButton.tintColor = self.view.tintColor
        }
    }




    private func loadLaunchDetails() {
      guard
        let launchID = self.launchID,
        launchID != self.launch?.id else {
          // This is the launch we're already displaying, or the ID is nil.
          return
      }

      Network.shared.apollo.fetch(query: LaunchDetailsQuery(id: launchID)) { [weak self] result in
        guard let self = self else {
          return
        }

        switch result {
        case .failure(let error):
          print("NETWORK ERROR: \(error)")
        case .success(let graphQLResult):
          if let launch = graphQLResult.data?.launch {
            self.launch = launch
          }

          if let errors = graphQLResult.errors {
            print("GRAPHQL ERRORS: \(errors)")
          }
        }
      }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
