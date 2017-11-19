

import UIKit

protocol QuickMovieDetailsDelegate: class {
  func quickMovieDidDismiss(_ movieDetailsView: QuickMovieDetailsView)
  func userRating(for movie: Movie, wasChanged toRating: Double)
}

class QuickMovieDetailsView: UIView {

  weak var delegate: QuickMovieDetailsDelegate?

  let movie: Movie
  let point: CGPoint

  // UI
  let yourRating: StarsView
  let starsViewHeight:CGFloat = 25
  let titleLabel = UILabel()
  let containerView = UIView()
  let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

  init(with movie: Movie, touchReceivedAt point: CGPoint) {

    self.movie = movie

    if let actualRating = movie.yourActualRating {
      self.yourRating = StarsView(withRating: actualRating)
    } else {
      self.yourRating = StarsView(withRating: movie.yourPredictedRating)
    }

    self.point = point

    super.init(frame: .zero)

    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .clear

    setViewFrame()

    // Tap gesture recognizer for dismissal
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(close))
    addGestureRecognizer(tapGestureRecognizer)
    addGestureRecognizer(panGestureRecognizer)

    // Containers for stars & blur view
    addSubview(containerView)
    containerView.backgroundColor    = .clear
    containerView.clipsToBounds      = true
    containerView.layer.cornerRadius = 10
    containerView.addSubview(blurView)

    // Ttitle
    titleLabel.text          = movie.title
    titleLabel.font          = UIFont.brownBold(withSize: 16)
    titleLabel.textAlignment = .center
    titleLabel.textColor     = .white
    titleLabel.numberOfLines = 0
    addSubview(titleLabel)

    // Stars View
    if movie.yourActualRating == nil {
      yourRating.grayscale()
    }
    yourRating.ratingDelegate = self
    addSubview(yourRating)

    setupConstraints()
  }

  func close() {
    guard let delegate = self.delegate else { return }
    delegate.quickMovieDidDismiss(self)
  }

}

extension QuickMovieDetailsView: StarsViewDelegate {
  func starsViewRatingDidChange(_ starsView: StarsView, to: Double) {
    guard let delegate = delegate else { return }
    delegate.userRating(for: movie, wasChanged: to)
    // Dismiss after a little bit
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
      self.close()
    })
  }
}
