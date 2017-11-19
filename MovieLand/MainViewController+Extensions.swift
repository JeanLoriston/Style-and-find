

import UIKit
import AudioToolbox

//MARK: Search controller delegate
extension MainViewController: FiltersViewDelegate {

  func filtersViewSearch(_: FiltersView, didChangeWith searchQuery: String?) {
    if searchQuery != nil && searchQuery != "" {
      mode = .search
    } else {
      mode = .defaultMode
    }

    movieSections = mode.movieData(for: allMovies, with: searchQuery, for: filterGenres)
    tableView.reloadData()
  }

  func filtersView(_: FiltersView, didSelect genre: Genre) {

    mode = .genreSearch
    filterGenres.append(genre)

    movieSections = mode.movieData(for: allMovies, with: nil, for: filterGenres)

    tableView.reloadData()
  }

  func filtersView(_: FiltersView, didDeselect genre: Genre) {
    let index = filterGenres.index(of: genre)
    filterGenres.remove(at: index!)
    if filterGenres.count > 0 {
      mode = .genreSearch
    } else {
      mode = .defaultMode
    }

    movieSections = mode.movieData(for: allMovies, with: nil, for: filterGenres)
    tableView.reloadData()
  }
}

//MARK: QuickMovieDetails Delegate
extension MainViewController: QuickMovieDetailsDelegate, MovieDetailsDelegate {

  func quickMovieDidDismiss(_ movieDetailsView: QuickMovieDetailsView) {
    fadeOutQuickMovieDetails()
  }

  func fadeOutQuickMovieDetails() {
    if isPresenting {

      UIView.animate(withDuration: 0.2, animations: {
        self.quickMovieDetails?.alpha = 0
      }) { (completion) in
        self.isPresenting = false
        self.quickMovieDetails?.removeFromSuperview()
      }
    }
  }

  func userRating(for movie: Movie, wasChanged toRating: Double) {
    // Increase number of movies user has rated
    user.numberRated += 1

    // Step learnToRate (3)
    if user.onboardingProgress == .learnToRate {
      user.onboardingSteps += 1
    }
    // Step rateFive (4)
    if user.onboardingProgress == .rateFive {
      if user.numberRated > 4 {
        user.onboardingSteps += 1
      }
    }

    update(movie, to: toRating)
  }

  func movieRating(updatedFor movie: Movie, to rating: Double) {
    update(movie, to: rating)
  }

  private func update(_ movie: Movie, to rating: Double) {
    let movieIndex = allMovies.index(of: movie)

    allMovies[movieIndex!].yourActualRating = rating
    allMovies[movieIndex!].movieSection = .alreadyRated

    movieSections = mode.movieData(for: allMovies, with: nil, for: filterGenres)
    if let alreadyRatedCount = movieSections[MovieSection.alreadyRated]?.count {
      user.numberRated = alreadyRatedCount
      userView.numberRated = alreadyRatedCount
    }
    tableView.reloadData()
  }
}

//MARK: MovieCollectionCell Delegate
extension MainViewController: MovieCollectionCellDelegate {

  func movieCell(wasSelected movieCell: MovieCell) {
    guard let movie = movieCell.movie, !isPresenting else {
      fadeOutQuickMovieDetails()
      return
    }
    let detailVC = MovieDetailViewController(with: movie, user: user)
    detailVC.delegate = self
    detailVC.modalPresentationStyle = .overCurrentContext
    present(detailVC, animated: true, completion: nil)
  }

  func movieCell(receivedTouchOn movieCell: MovieCell, at point: CGPoint) {
    guard let movie = movieCell.movie, !isPresenting else { return }
    quickMovieDetails = QuickMovieDetailsView(with: movie, touchReceivedAt: point)
    quickMovieDetails!.delegate = self
    isPresenting = true
    view.addSubview(quickMovieDetails!)
  }

  func movieCollectionCellDidScroll(_ movieCollectionCell: MovieCollectionCell) {
    if isPresenting {
      fadeOutQuickMovieDetails()
    }
  }
}

//MARK: User Delegate
extension MainViewController: UserViewDelegate {
  func userViewSignUpButtonTapped(_ userView: UserView) {
    askForSignUp()
  }
}

//MARK: User Delegate
extension MainViewController: UserOnboardingDelegate {

  func userProgressed(to step: Int) {

    /// <-------**** Code added in Demo2\Starter
    switch self.user.onboardingProgress {
    // Step showSignUp (10)
    case .showSignUp:
      self.userView.showsSignUp = true
    // Step sayGoodbye (11)
    case .sayGoodbye:
      self.filtersView(shouldExpand: false, with: 0)
    default:
      break
    }
    /// End Code added in Demo2\Starter **** --------->

    animateOnboardingRow()
  }

  func animateOnboardingRow() {
    let indexPaths = [IndexPath(item: 0, section: 0)]

    var shouldAlert: Bool
    switch user.onboardingProgress {
    case .afterScrolling, .toSettings:
      shouldAlert = true
    default:
      shouldAlert = false
    }

    // If iPhone 7 should use taptic feedback
    if shouldAlert {
      if UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int == 2 {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
      } else {
        let systemSoundID: SystemSoundID = 1104
        AudioServicesPlaySystemSound (systemSoundID)
      }
    }

    tableView.reloadRows(at: indexPaths, with: .fade)
  }
}
