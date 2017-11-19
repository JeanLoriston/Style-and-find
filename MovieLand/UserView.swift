

import UIKit

protocol UserViewDelegate: class {
  func userViewSignUpButtonTapped(_ userView: UserView)
}

enum RecommenderSystem: String {
  case ninja
  case pirate
  case viking
  case wizard

  // These descriptions taken in part from MovieLens.org
  func recommenderDescription() -> String {
    switch self {
    case .ninja:
      return "It works by finding the similarities and differences among all movies in the system based on all users' ratings."
    case .pirate:
      return "It is not personalized to your ratings, but instead recommends the top-rated content."
    case .viking:
      return "It works by turning all users' ratings data into a small set of factors that capture the essential preference aspects of a movie or a user."
    case .wizard:
      return "It is best for new MovieLand users. It uses your movie group selection to determine which movies to recommend."
    }
  }
}

class UserView: UIView {

  // DATA
  var numberRated: Int {
    didSet {
      updateRatingData()
    }
  }
  var user: User? {
    didSet {
      updateUserData()
    }
  }

  var showsSignUp: Bool {
    didSet {
      signUpButton.alpha = showsSignUp ? 1 : 0
    }
  }

  var recommender: RecommenderSystem = RecommenderSystem.ninja

  weak var delegate: UserViewDelegate?

  // UI
  let nameLabel         = UILabel()
  let ratingDescription = UILabel()
  let userMessage       = UILabel()
  let signUpButton      = UIButton()

  init(with user: User?, numberRated: Int) {
    self.user        = user
    self.numberRated = numberRated
    self.showsSignUp = false
    super.init(frame: .zero)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {

    // Tap gesture recognizer for swithing recommender systems
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(switchRecommender))
    addGestureRecognizer(tapGestureRecognizer)

    addNameLabel()
    addDescription()
    addUserRatingsData()
    addSignUpButton()

    setupConstraints()
  }

  func switchRecommender() {
    switch recommender {
    case .ninja:
      recommender = .pirate
    case .pirate:
      recommender = .viking
    case .viking:
      recommender = .wizard
    case .wizard:
      recommender = .ninja
    }

    updateRatingData()
  }

  private func updateUserData() {
    guard let userName = user?.name else { return }
    nameLabel.text = "Hello, \(userName)!"
  }

  private func addNameLabel() {
    updateUserData()
    nameLabel.font = UIFont.brownBold(withSize: 20)
    addSubview(nameLabel)
  }

  private func addDescription() {
    ratingDescription.text = "MovieLand Settings:"
    ratingDescription.font = UIFont.brownBold(withSize: 18)
    ratingDescription.numberOfLines = 0
    ratingDescription.textAlignment = .left
    addSubview(ratingDescription)
  }

  private func addUserRatingsData() {
    updateRatingData()
    userMessage.numberOfLines = 0
    addSubview(userMessage)
  }

  private func updateRatingData() {
    let recSystem = recommender.rawValue.uppercased()
    let string = "You've rated \(numberRated) movies.\nYou're using the \(recSystem) recommender. 🔄\n\n\(recommender.recommenderDescription())"
    let userAttributedString = NSMutableAttributedString(string: string)
    let userAttributedRange = NSRange.init(location: 0, length: string.characters.count)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left

    userAttributedString.addAttributes([NSFontAttributeName : UIFont.brown(withSize: 14), NSParagraphStyleAttributeName : paragraphStyle],
                                       range: userAttributedRange)

    userAttributedString.addAttribute(NSFontAttributeName,
                                      value: UIFont.brownBold(withSize: 16),
                                      range: NSRange(location: 12, length: 8+String(numberRated).characters.count))

    let recommenderStart = string.range(of: recSystem)?.lowerBound
    let recommenderIndex: Int = string.distance(from: string.startIndex, to: recommenderStart!)

    userAttributedString.addAttribute(NSFontAttributeName,
                                      value: UIFont.brownBold(withSize: 16),
                                      range: NSRange(location: recommenderIndex, length: recSystem.characters.count))

    userMessage.attributedText = userAttributedString
  }

  private func addSignUpButton() {
    signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    signUpButton.setTitle("SIGN UP", for: .normal)
    signUpButton.setTitle("SIGN UP", for: .selected)
    signUpButton.titleLabel?.font  = UIFont.brownBold(withSize: 18)
    signUpButton.setTitleColor(.black, for: .normal)
    signUpButton.setTitleColor(.black, for: .selected)
    signUpButton.backgroundColor   = UIColor.white.withAlphaComponent(0.5)
    signUpButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    signUpButton.layer.borderColor = UIColor.black.cgColor
    signUpButton.layer.borderWidth = 2
    signUpButton.alpha             = 0
    addSubview(signUpButton)
  }

  func signUp() {
    guard let delegate = delegate else { return }
    delegate.userViewSignUpButtonTapped(self)
  }
}

//MARK: Layout
extension UserView {
  func setupConstraints() {
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    let nameCenterX = NSLayoutConstraint(
      item: nameLabel,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let nameTop = NSLayoutConstraint(
      item: nameLabel,
      attribute: .top,
      relatedBy: .equal,
      toItem: self,
      attribute: .top,
      multiplier: 1.0,
      constant: 10.0)

    addConstraints([
      nameCenterX,
      nameTop]
    )

    ratingDescription.translatesAutoresizingMaskIntoConstraints = false

    let ratingCenterX = NSLayoutConstraint(
      item: ratingDescription,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let ratingTop = NSLayoutConstraint(
      item: ratingDescription,
      attribute: .top,
      relatedBy: .equal,
      toItem: nameLabel,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 10.0)

    let ratingWidth = NSLayoutConstraint(
      item: ratingDescription,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 0.9,
      constant: 0.0)

    addConstraints([
      ratingCenterX,
      ratingTop,
      ratingWidth,
      ]
    )

    userMessage.translatesAutoresizingMaskIntoConstraints = false

    let userCenterX = NSLayoutConstraint(
      item: userMessage,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: ratingDescription,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let userTop = NSLayoutConstraint(
      item: userMessage,
      attribute: .top,
      relatedBy: .equal,
      toItem: ratingDescription,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 15.0)

    let userWidth = NSLayoutConstraint(
      item: userMessage,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 0.9,
      constant: 0.0)


    addConstraints([
      userCenterX,
      userTop,
      userWidth]
    )

    signUpButton.translatesAutoresizingMaskIntoConstraints = false

    let signUpCenterX = NSLayoutConstraint(
      item: signUpButton,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: userMessage,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let signUpTop = NSLayoutConstraint(
      item: signUpButton,
      attribute: .top,
      relatedBy: .equal,
      toItem: userMessage,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 15.0)
    
    addConstraints([
      signUpCenterX,
      signUpTop]
    )
  }
}
