//
//  MovieSearchResultTableViewCell.swift
//  MovieSearch
//
//  Created by Srinath Giri on 9/16/19.
//  Copyright © 2019 Example. All rights reserved.
//

import UIKit

class MovieSearchResultTableViewCell: UITableViewCell {
  
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var releaseDateLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UITextView!
  
  var movie: Movie?
  weak var viewControler: MovieSearchViewController?

  
  func updateUi(posterImage: UIImage? = nil) {
    
    if let movie = movie {
      self.titleLabel.text = movie.title
      self.releaseDateLabel.text = movie.release_date
      self.posterImageView.image = posterImage
      self.updateDescription()
    }
    
  }
  
  
  func updateDescription() {
    
    if let overview = movie?.overview {
      
      var dotCount = 0
      
      let indexOfThirdPeriod = overview.firstIndex() { ch in
        if ch == "." {
          dotCount = dotCount + 1
          return dotCount == 3
        }
        return false
      }
      
      if let indexOfThirdPeriod = indexOfThirdPeriod, overview.index(after: indexOfThirdPeriod) != overview.endIndex {
        self.descriptionLabel.text = String(overview.prefix(through: indexOfThirdPeriod)) + "..."
      } else {
        self.descriptionLabel.text = overview
      }
    }
  }


  func isShowingFullDescription() -> Bool {
    return self.descriptionLabel.text.count == (movie?.overview?.count ?? 0)
  }

}
