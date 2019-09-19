//
//  MovieDescriptionViewController.swift
//  MovieSearch
//
//  Created by Srinath Giri on 9/19/19.
//  Copyright © 2019 Example. All rights reserved.
//

import UIKit

class MovieDescriptionViewController: UIViewController {

  var movie: Movie?
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.updateUi()
  }
  
  
  func updateUi() {
    descriptionTextView.text = movie?.overview
  }

  @IBAction func donePressed(_ sender: Any) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}
