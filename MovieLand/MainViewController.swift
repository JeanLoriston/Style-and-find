
import UIKit

class MainViewController: UIViewController {

  let tableTopOffset:CGFloat = 40

  // Content view - table view + offset
  var containerView: UIView = UIView()

  // Each table view cell contains a collection view
  var tableView: UITableView = UITableView()
  var tableTopConstraint     = NSLayoutConstraint()

  // Filter View
  var filterView: FiltersView        = FiltersView()
  var filtersOpen                    = false
  static let filtersViewCompactSize:CGFloat = 180
  static let filtersViewExpandedSize:CGFloat = 380

  // User View - initialize with empty user & sync back when signed in
  let userView: UserView = UserView(with: nil, numberRated: 0)

  // Presentation
  var isPresenting: Bool = false
  var quickMovieDetails: QuickMovieDetailsView?

  // SearchController
  var searchController = UISearchController(searchResultsController: nil)

  // Filtering - when user has filters selected
  var filterGenres: [Genre] = []

  enum DisplayMode: String {
    case defaultMode
    case search
    case genreSearch

    func movieData(for movies: [Movie], with searchQuery: String?, for genres: [Genre]) -> [MovieSection: [Movie]] {
      switch self {
      case .defaultMode:
        return MovieStore.moviesBySection(movies: movies)
      case .search:
        if let query = searchQuery {
          return MovieStore.searchResults(on: movies, for: query.lowercased())
        } else {
          return MovieStore.moviesBySection(movies: movies)
        }
      case .genreSearch:
        return MovieStore.genreResults(on: movies, for: genres)
      }
    }
  }

  // Displaying Content:
  enum Sections: Int {
    case onboarding
    case movies

    static var count: Int { return Sections.movies.rawValue + 1}
  }

  // Data
  var mode: DisplayMode = .defaultMode

  var allMovies:[Movie] = []
  var movieSections: [MovieSection: [Movie]] = [:]

  var user: User = User(with: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self

    allMovies = (UIApplication.shared.delegate as! AppDelegate).movies
    movieSections = mode.movieData(for: allMovies, with: nil, for: [])

    setupViews()

    user.delegate = self
  }

  override var prefersStatusBarHidden: Bool {
    return false
  }

  //MARK: View SetUp

  func setupViews() {

    view.backgroundColor = .yellow

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fadeOutQuickMovieDetails))
    tapGestureRecognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGestureRecognizer)

    // Table View
    tableView.register(MovieCollectionCell.self, forCellReuseIdentifier: MovieCollectionCell.identifier)
    tableView.separatorStyle = .none
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .white

    view.addSubview(tableView)

    // Filter View
    filterView.backgroundColor = .yellow
    filterView.filtersViewDelegate = self
    view.addSubview(filterView)

    // User View
    userView.delegate = self
    view.addSubview(userView)

    setupConstraints()
  }

  //MARK: Bounce
  func bounceFilters(withConstant constant: CGFloat) {
    // Scroll to top
    tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentInset.top - tableTopOffset) , animated: true)
    view.layoutIfNeeded()

    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 8, options: .curveEaseInOut, animations: {
      self.tableTopConstraint.constant = constant
      self.view.layoutIfNeeded()
    }) { (completed) in
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 8, options: .curveEaseInOut, animations: {
        self.tableTopConstraint.constant = 0
        self.view.layoutIfNeeded()
      }, completion: { (completion) in
        // nothing for now
      })
    }
  }
}

//MARK: Table View Delegate + Data Source
extension MainViewController: UITableViewDataSource, UITableViewDelegate {

  //MARK: Table View:

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let currentSection = Sections(rawValue: indexPath.section)!

    switch currentSection {
    case .onboarding:
      let cell = UITableViewCell()

      var textToDisplay = ""
      if user.onboardingSteps <= OnboardingProgress.count {
        textToDisplay = user.onboardingProgress.message()
      }

      if user.onboardingProgress == .rateFive {
        textToDisplay = textToDisplay + "\n\nMovies rated: \(user.numberRated)/5"
      }

      configure(onboardingCell: cell, withText: textToDisplay)

      return cell
    case .movies:
      if let moviesCell = movieTableViewCell(forIndexPath: indexPath) {
        return moviesCell
      }
    }

    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currentSection = Sections(rawValue: indexPath.section)!

    if currentSection == .onboarding {

      /// <-------**** Code replaced from Demo1\Final
      //user.onboardingSteps += 1
      //tableView.reloadData()
      /// End Code replaced from Demo1\Final **** --------->

      /// <-------**** Code added in Demo2\Starter
      // Step greet (1)
      // Step explain (2)
      // Step toSettings (9)
      // Step sayGoodbye (11)
      switch user.onboardingProgress {
      case .greet, .explain, .toSettings, .sayGoodbye:
        user.onboardingSteps += 1
      default:
        return
      }
      /// End Code added in Demo2\Starter **** --------->
    }
  }

  private func configure(onboardingCell cell: UITableViewCell, withText text: String) {
    cell.selectionStyle = .none
    cell.textLabel?.font = UIFont.brown(withSize: 18)
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.textAlignment = .center
    cell.textLabel?.text = text
  }

  private func movieTableViewCell(forIndexPath: IndexPath) -> MovieCollectionCell? {
    let identifier = MovieCollectionCell.identifier

    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: forIndexPath) as? MovieCollectionCell else { return nil }

    var collectionName: String = ""
    var collectionData: [Movie] = []

    let sortedSections = Array(movieSections.keys).sorted{ $0.rawValue < $1.rawValue }
    let cellSection = sortedSections[forIndexPath.row]

    if let cellData = movieSections[cellSection] {
      switch cellSection {
      case .alreadyRated:
        cell.backgroundColor = UIColor(colorLiteralRed: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        collectionData = cellData
      case .topPicks:
        cell.backgroundColor = .yellow
        // Shuffle for demo purposes, so that it appears like the curation algorithms are doing their job
        collectionData = cellData.shuffled()
      case .rate, .recent:
        collectionData = cellData
        cell.backgroundColor = .white
      }

      collectionName = cellSection.sectionName()
    }

    cell.collectionName = collectionName
    cell.collectionData = collectionData
    cell.movieCollectionCellDelegate = self

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let currentSection = Sections(rawValue: section)!

    switch currentSection {
    case .onboarding:
      return 1
    case .movies:
      return movieSections.keys.count
    }
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return Sections.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let currentSection = Sections(rawValue: indexPath.section)!

    switch currentSection {
    case .onboarding:
      return user.onboardingSteps == OnboardingProgress.count ? 0 : 150
    case .movies:
      return 300
    }
  }

  //MARK: ScrollView:

  func scrollViewDidScroll(_ scrollView: UIScrollView) {

    if scrollView.contentOffset.y > 0 && filtersOpen {
      filtersView(shouldExpand: false, with: 0)
    }

    // Remove Movie Details View on Scroll
    if isPresenting {
      fadeOutQuickMovieDetails()
    }
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    if -scrollView.contentOffset.y > filterView.bounds.height/2 {

      if !filtersOpen {
        filtersView(shouldExpand: true, with: MainViewController.filtersViewCompactSize + tableTopOffset)
      } else {
        filtersView(shouldExpand: true, with: MainViewController.filtersViewExpandedSize + tableTopOffset)
      }
    }

    /// <-------**** Code added in Demo2\Starter
    updateOnboardingForScrolling(withScrollView: scrollView)
    /// End Code added in Demo2\Starter **** --------->
  }

  /// <-------**** Code added in Demo2\Starter
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    updateOnboardingForScrolling(withScrollView: scrollView)
  }

  private func updateOnboardingForScrolling(withScrollView scrollView:UIScrollView) {
    let height = scrollView.frame.size.height
    let contentOffsetY = scrollView.contentOffset.y
    let distanceFromBottom = scrollView.contentSize.height
      - contentOffsetY

    // Step scrollToBottom (5)
    if distanceFromBottom == height {
      if user.onboardingProgress == .scrollToBottom {
        user.onboardingSteps += 1
      }
    }
  }
  /// End Code added in Demo2\Starter **** --------->

  func filtersView(shouldExpand: Bool, with tableTopConstant: CGFloat) {
    view.layoutIfNeeded()
    let filtersViewExpandedSize = tableTopOffset + MainViewController.filtersViewCompactSize
    let settingsViewExpandedSize = tableTopOffset + MainViewController.filtersViewExpandedSize

    UIView.animate(withDuration: 0.3, animations: {

      self.tableTopConstraint.constant = tableTopConstant
      self.view.layoutIfNeeded()
      self.filtersOpen = shouldExpand

      // Step afterScrolling (6)
      if self.user.onboardingProgress == .afterScrolling &&
        tableTopConstant == filtersViewExpandedSize {
        self.user.onboardingSteps += 1
      }

      // Step settingsPrompt (8)
      if self.user.onboardingProgress == .settingsPrompt &&
        tableTopConstant == settingsViewExpandedSize {
        self.user.onboardingSteps += 1
      }
    })
  }
}

// MARK: Sign Up
extension MainViewController {
  func askForSignUp() {
    // Show alert to Sign Up/Log In
    let alertController = UIAlertController(title: "Sign Up/Login", message:
      "Hello! Sign Up or Login to use MovieLand!", preferredStyle: .alert)

    alertController.addTextField { (textField) in
      textField.placeholder = "Username"
      textField.clearButtonMode = .whileEditing
      textField.borderStyle = .roundedRect
    }

    alertController.addTextField { (textField) in
      textField.placeholder = "Password"
      textField.clearButtonMode = .whileEditing
      textField.borderStyle = .roundedRect
      textField.isSecureTextEntry = true
    }

    let signUp = UIAlertAction(title: "Sign Up", style: .default) { (action) in
      guard let username = alertController.textFields?[0].text else { return }
      self.signUp(with: username, and: "Password")
    }

    let login = UIAlertAction(title: "Login", style: .default) { (action) in
      guard let username = alertController.textFields?[0].text else { return }
      self.signUp(with: username, and: "Password")
    }

    alertController.addAction(signUp)
    alertController.addAction(login)

    present(alertController, animated: true, completion: nil)
  }
  
  func signUp(with username: String, and password: String) {
    user.name = username
    userView.user = user
    userView.showsSignUp = false
    
    //Step showSignUp (10)
    user.onboardingSteps += 1
    tableView.reloadData()
  }
}
