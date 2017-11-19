

import UIKit
import CoreLocation

protocol MovieDetailsDelegate: class {
  func movieRating(updatedFor movie: Movie, to rating: Double)
}

class MovieDetailViewController: UIViewController {

  weak var delegate: MovieDetailsDelegate?
  let locationManager: CLLocationManager

  // Data
  var movie: Movie
  var user: User

  // UI
  let imageView = UIImageView()
  let topDetailView: TopDetailView
  let bottomDetailView: BottomDetailView

  init(with movie: Movie, user: User) {

    self.movie            = movie
    self.user             = user
    self.topDetailView    = TopDetailView(with: movie)
    let locationEnabled   = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    self.locationManager  = CLLocationManager()
    self.bottomDetailView = BottomDetailView(with: movie, locationEnabled: locationEnabled)

    super.init(nibName: nil, bundle: nil)
    modalTransitionStyle = .crossDissolve

    self.topDetailView.movieDelegate = self
    self.bottomDetailView.delegate   = self
    self.locationManager.delegate    = self
    self.locationManager.startUpdatingLocation()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if user.locationOnboardingSteps < LocationOnboardingProgress.count {
      bottomDetailView.showOnboarding(with: user.locationProgress.message(withUsername: user.name, locationEnabled: false))
    }

    setupView()
  }

  func askForLocationAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }

  private func setupView() {

    setupGestures()

    // Image View
    imageView.image         = movie.image
    imageView.clipsToBounds = true
    view.addSubview(imageView)

    let blurEffect                  = UIBlurEffect(style: .regular)
    let blurEffectView              = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame            = view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(blurEffectView)

    // Top Detail View
    view.addSubview(topDetailView)

    // Bottom Detail View
    view.addSubview(bottomDetailView)

    setupConstraints()
  }

  private func setupGestures() {

    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(close))
    swipeDown.direction = .down
    view.addGestureRecognizer(swipeDown)
  }

  @objc private func close() {

    modalTransitionStyle = .coverVertical
    dismiss(animated: true) {
      if self.user.locationProgress == .howToClose {
        self.user.locationOnboardingSteps += 1
      }
    }
  }
}

//MARK: BottomDetailDelegate
extension MovieDetailViewController: BottomDetailDelegate {
  func bottomDetailViewSelected(_ bottomDetailView: BottomDetailView, for theatre: TheatreView?) {

    // If there's still on-boarding to do
    if user.locationOnboardingSteps < LocationOnboardingProgress.count {
      progressWithOnboarding()
    } else {
      // Show alert to buy ticket (if location enabled)
      guard let theatre = theatre else { return }
      showAlertToBuyTicket(at: theatre.title, for: movie.title)
    }
  }

  func progressWithOnboarding() {
    let locationEnabled = CLLocationManager.authorizationStatus() == .authorizedWhenInUse

    switch user.locationProgress {
    case .howToClose, .explainSection:
      user.locationOnboardingSteps += 1
    case .explainLocationNeed:
      askForLocationAuthorization()
    case .askForLocation:

      if !locationEnabled {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
          UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
      }

      user.locationOnboardingSteps += 1
    }

    bottomDetailView.locationEnabled = locationEnabled
    bottomDetailView.showOnboarding(with: user.locationProgress.message(withUsername: user.name, locationEnabled: locationEnabled))
  }

  func showAlertToBuyTicket(at theatre: String, for movie: String) {
    let alertController = UIAlertController(title: "Ahoy Movie Buff!", message:
      "So, you're trying to see \(movie) at the wonderful \(theatre) theatre?", preferredStyle: UIAlertControllerStyle.actionSheet)

    let buyAction = UIAlertAction(title: "Buy Ticket", style: .default) { (action) in
      //Show alert ticket was bought successfully
      let buyAlert = UIAlertController(title: "Success!", message:
        "A ticket for \(movie) at the \(theatre) has been sent to your email. Enjoy the show!", preferredStyle: .alert)

      let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
      buyAlert.addAction(dismissAction)
      
      self.present(buyAlert, animated: true, completion: nil)
    }

    alertController.addAction(buyAction)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

    present(alertController, animated: true, completion: nil)
  }
}

//MARK: MovieDetailsDelegate
extension MovieDetailViewController: MovieDetailsDelegate {
  func movieRating(updatedFor movie: Movie, to rating: Double) {
    guard let delegate = delegate else { return }
    delegate.movieRating(updatedFor: movie, to: rating)
  }
}

//MARK: CLLocationManagerDelegate
extension MovieDetailViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    let locationEnabled = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    if user.locationProgress == .explainLocationNeed {
      user.locationOnboardingSteps += 1
      bottomDetailView.showOnboarding(with: user.locationProgress.message(withUsername: user.name, locationEnabled: locationEnabled))
    }
  }
}

