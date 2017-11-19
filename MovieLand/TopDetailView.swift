
import UIKit

class TopDetailView: UIView {

  weak var movieDelegate: MovieDetailsDelegate?

  var movie: Movie

  // UI
  let overallLabel     = UILabel()
  let overallRatingView: StarsView
  let titleLabel       = UILabel()
  let factsView: MovieFactsView
  let predictionLabel  = UILabel()
  let predictionRating = UIView()
  let yourRating: StarsView

  init(with movie: Movie) {
    self.movie = movie
    self.factsView = MovieFactsView(with: movie, fontSize: 14.0)
    self.overallRatingView = StarsView(withRating: movie.rating)

    if let actualRating = movie.yourActualRating {
      self.yourRating = StarsView(withRating: actualRating)
    } else {
      self.yourRating = StarsView(withRating: movie.yourPredictedRating)
    }

    super.init(frame: .zero)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {

    overallLabel.text = "OVERALL: "
    titleLabel.text = movie.title

    var predictionText = "PREDICTED RATING: "
    if movie.yourActualRating != nil {
      predictionText = "YOUR RATING: "
    } else {
      yourRating.grayscale()
    }
    predictionLabel.text = predictionText

    // OVERALL:
    overallLabel.font          = UIFont.brownBold(withSize: 14)
    overallLabel.textColor     = .white
    overallLabel.numberOfLines = 0
    overallLabel.textAlignment = .center
    addSubview(overallLabel)

    // OVERALL RATING:
    overallRatingView.isUserInteractionEnabled = false
    addSubview(overallRatingView)

    // TITLE:
    titleLabel.font          = UIFont.brownBold(withSize: 24)
    titleLabel.textColor     = .white
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    addSubview(titleLabel)

    // MOVIE FACTS: Year, Admission Rating, Length
    addSubview(factsView)

    // PREDICTION:
    predictionLabel.font          = UIFont.brownBold(withSize: 18)
    predictionLabel.textColor     = .white
    predictionLabel.numberOfLines = 0
    addSubview(predictionLabel)

    // YOUR RATING:
    yourRating.ratingDelegate = self
    addSubview(yourRating)

    setupConstraints()
  }
}

extension TopDetailView: StarsViewDelegate {
  func starsViewRatingDidChange(_ starsView: StarsView, to: Double) {
    guard let delegate = movieDelegate else { return }
    delegate.movieRating(updatedFor: movie, to: to)
    predictionLabel.text = "YOUR RATING: "
  }
}
