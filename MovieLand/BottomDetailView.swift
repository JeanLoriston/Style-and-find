

import UIKit
import CoreLocation

protocol BottomDetailDelegate: class {
  func bottomDetailViewSelected(_ bottomDetailView:BottomDetailView, for theatre: TheatreView?)
}

class BottomDetailView: UIView {

  weak var delegate: BottomDetailDelegate?

  // Data
  private let movie: Movie
  var locationEnabled: Bool {
    didSet {
      locationDisabledLabel.isHidden = locationEnabled
      updateTheatreView(with: locationEnabled)
    }
  }

  // UI
  let contentView         = UIView()
  let genreLabel          = UILabel()
  let languagesLabel      = UILabel()
  let buyLabel            = UILabel()
  let theatreView         = UIView()

  // Used for onboarding purposes as well
  let locationDisabledLabel = UILabel()

  init(with movie: Movie, locationEnabled: Bool) {
    self.movie = movie
    self.locationEnabled = locationEnabled
    super.init(frame: .zero)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func showOnboarding(with text: String) {
    locationDisabledLabel.text = text
    locationDisabledLabel.textColor = .black
  }

  private func setupData() {
    // Bottom View:
    buyLabel.text = "BUY TICKETS FROM:"
  }

  private func setupViews() {

    setupData()

    backgroundColor = UIColor.white.withAlphaComponent(0.7)
    setupGenresLabel()
    setupLanguagesLabel()

    // BUY TICKETS FROM:
    buyLabel.font          = UIFont.brownBold(withSize: 22)
    buyLabel.textColor     = .black
    buyLabel.textAlignment = .center
    addSubview(buyLabel)

    // THEATRE VIEW:
    setupTheatreView(with: locationEnabled)
    addSubview(theatreView)

    // LOCATION DISABLED/ONBOARDING LABEL:
    locationDisabledLabel.text = "Location Services are disabled. \n\nTAP to Go to General > Settings \nto adjut your settings."
    locationDisabledLabel.textAlignment = .center
    locationDisabledLabel.textColor     = .red
    locationDisabledLabel.font          = UIFont.brown(withSize: 18)
    locationDisabledLabel.numberOfLines = 0

    // For sending user to settings if location services aren't enabled
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
    addGestureRecognizer(tapGestureRecognizer)

    setupConstraints()
  }

  @objc private func didTapOnView() {
    if !locationEnabled {
      guard let delegate = delegate else { return }
      delegate.bottomDetailViewSelected(self, for: nil)
    }
  }

  private func setupGenresLabel() {
    let genre = "GENRE: "
    let genreRange = NSRange.init(location: 0,
                                  length: genre.characters.count)
    let genreText = NSMutableAttributedString(string: genre)
    genreText.addAttributes(
      [NSFontAttributeName : UIFont.brownBold(withSize: 14)],
      range: genreRange)

    let genreDetails = movie.genres.map { $0.rawValue }.joined(separator: ", ")
    let genreDetailsRange = NSRange.init(location: 0,
                                         length: genreDetails.characters.count)
    let genreDetailsText = NSMutableAttributedString(string: genreDetails)
    genreDetailsText.addAttributes(
      [NSFontAttributeName : UIFont.brown(withSize: 14)],
      range: genreDetailsRange)

    let genreAttributedString: NSMutableAttributedString = genreText
    genreAttributedString.append(genreDetailsText)
    genreLabel.attributedText = genreAttributedString
    genreLabel.textColor = .black
    genreLabel.numberOfLines = 0
    addSubview(genreLabel)
  }

  private func setupLanguagesLabel() {
    let language = "LANGUAGES: "
    let languageRange = NSRange.init(location: 0,
                                     length: language.characters.count)
    let languageText = NSMutableAttributedString(string: language)
    languageText.addAttributes(
      [NSFontAttributeName : UIFont.brownBold(withSize: 14)],
      range: languageRange)

    let languageDetails = movie.languages.joined(separator: ", ")
    let languageDetailsRange = NSRange.init(location: 0,
                                            length: languageDetails.characters.count)
    let languageDetailsText = NSMutableAttributedString(string: languageDetails)
    languageDetailsText.addAttributes(
      [NSFontAttributeName : UIFont.brown(withSize: 14)],
      range: languageDetailsRange)

    let languageAttributedString: NSMutableAttributedString = languageText
    languageAttributedString.append(languageDetailsText)
    languagesLabel.attributedText = languageAttributedString
    languagesLabel.textColor = .black
    languagesLabel.numberOfLines = 0
    addSubview(languagesLabel)
  }

  func updateTheatreView(with locationEnabled: Bool) {
    setupTheatreView(with: locationEnabled)
    setupConstraints()
  }
}

//MARK: TheatreViewDelegate
extension BottomDetailView: TheatreViewDelegate {
  func theatreViewSelected(_ theatreView: TheatreView) {
    guard let delegate = delegate else { return }
    delegate.bottomDetailViewSelected(self, for: theatreView)
  }
}

