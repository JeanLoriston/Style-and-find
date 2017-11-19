

import UIKit

protocol FiltersViewDelegate: class {
  func filtersViewSearch(_: FiltersView, didChangeWith searchQuery: String?)
  func filtersView(_: FiltersView, didSelect genre: Genre)
  func filtersView(_: FiltersView, didDeselect genre: Genre)
}

class FiltersView: UIView {
  weak var filtersViewDelegate: FiltersViewDelegate?

  let allFilters: [GenreFilter] = Filters.genres()
  var allSelected: [GenreFilter] = []
  var allDeselected: [GenreFilter] = []

  enum FilterSection: Int {
    case deselected
    case selected
    static var count: Int { return FilterSection.selected.rawValue + 1}
  }

  // Search Controller
  let searchController: UISearchController = UISearchController(searchResultsController: nil)

  // Genres
  let genresLabel:UILabel = UILabel()
  let genreCollectionView: UICollectionView
  let selectedGenreCollectionView: UICollectionView

  override init(frame: CGRect) {

    let topGenreLayout                        = UICollectionViewFlowLayout()
    topGenreLayout.minimumInteritemSpacing    = 0
    topGenreLayout.minimumLineSpacing         = 0
    topGenreLayout.scrollDirection            = .horizontal
    genreCollectionView                       = UICollectionView(frame: CGRect.zero, collectionViewLayout:topGenreLayout)

    let bottomGenreLayout                     = UICollectionViewFlowLayout()
    bottomGenreLayout.minimumInteritemSpacing = 0
    bottomGenreLayout.minimumLineSpacing      = 0
    bottomGenreLayout.scrollDirection         = .horizontal
    selectedGenreCollectionView               = UICollectionView(frame: CGRect.zero, collectionViewLayout:bottomGenreLayout)

    // Initialize all deselected filters with all filters
    allDeselected = allFilters.sorted{ $0.name < $1.name }
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupViews() {

    setupSearchController()

    // Genres
    addSubview(genresLabel)
    genresLabel.text = "GENRES:"
    genresLabel.font = UIFont.brownBold(withSize: 18)

    setupDeselectedGenres()
    setupSelectedGenres()

    setupConstraints()
  }

  private func setupSearchController() {

    searchController.searchResultsUpdater             = self
    searchController.dimsBackgroundDuringPresentation = true
    searchController.searchBar.placeholder            = "Search here..."
    searchController.searchBar.delegate               = self
    searchController.searchBar.barTintColor           = .yellow
    searchController.searchBar.searchBarStyle         = .prominent
    // To get rid of the gray borders
    searchController.searchBar.layer.borderColor      = UIColor.yellow.cgColor
    searchController.searchBar.layer.borderWidth      = 1

    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)

    addSubview(searchController.searchBar)
  }

  private func setupDeselectedGenres() {

    addSubview(genreCollectionView)
    genreCollectionView.dataSource                     = self
    genreCollectionView.delegate                       = self
    genreCollectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.identifier)
    genreCollectionView.backgroundColor                = .clear
    genreCollectionView.showsHorizontalScrollIndicator = false
  }

  private func setupSelectedGenres() {

    addSubview(selectedGenreCollectionView)
    selectedGenreCollectionView.dataSource                     = self
    selectedGenreCollectionView.delegate                       = self
    selectedGenreCollectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.identifier)
    selectedGenreCollectionView.backgroundColor                = .clear
    selectedGenreCollectionView.showsHorizontalScrollIndicator = false
  }
}

//MARK: UISearchResultsUpdating
extension FiltersView: UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {

    let searchQuery = searchController.searchBar.text

    if let delegate = filtersViewDelegate,
      let query = searchQuery {
      delegate.filtersViewSearch(self, didChangeWith: query)
    }
  }
}

//MARK: UISearchBarDelegate
extension FiltersView: UISearchBarDelegate {
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    if let delegate = filtersViewDelegate,
      let query = searchBar.text {
      delegate.filtersViewSearch(self, didChangeWith: query)
      searchController.dismiss(animated: true, completion: nil)
    }
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    if let delegate = filtersViewDelegate {
      delegate.filtersViewSearch(self, didChangeWith: nil)
    }
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchController.dismiss(animated: true, completion: nil)
  }
}

//MARK: UICollectionViewDataSource
extension FiltersView: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView == genreCollectionView {
      return allDeselected.count
    } else {
      return allSelected.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let identifier = GenreCell.identifier
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? GenreCell

    var genreFilter: GenreFilter

    if collectionView == genreCollectionView {
      genreFilter = allDeselected[indexPath.section]
    } else {
      genreFilter = allSelected[indexPath.section]
    }

    cell?.name = genreFilter.name
    cell?.added = genreFilter.added

    return cell ?? UICollectionViewCell()
  }
}

//MARK: UICollectionViewDelegate
extension FiltersView: UICollectionViewDelegate {
  //MARK: Collection View Delegate:
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    if collectionView == genreCollectionView {
      // Remove item from Deselected array
      let genreFilter = allDeselected.remove(at: indexPath.section)
      // Flip added flag
      genreFilter.added = !genreFilter.added
      // Add to Selected array
      allSelected.append(genreFilter)

      if let delegate = filtersViewDelegate {
        delegate.filtersView(self, didSelect: Genre(rawValue: genreFilter.name)!)
      }
    }

    if collectionView == selectedGenreCollectionView {
      // Remove item from Selected array
      let genreFilter = allSelected.remove(at: indexPath.section)
      // Flip added flag
      genreFilter.added = !genreFilter.added
      // Add to Deselected array
      allDeselected.append(genreFilter)
      // Sort alphabetically
      allDeselected = allDeselected.sorted{ $0.name < $1.name }

      if let delegate = filtersViewDelegate {
        delegate.filtersView(self, didDeselect: Genre(rawValue: genreFilter.name)!)
      }
    }

    selectedGenreCollectionView.reloadData()
    genreCollectionView.reloadData()
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension FiltersView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    var originalString: String = allDeselected[indexPath.section].name

    if collectionView == selectedGenreCollectionView {
      originalString = allSelected[indexPath.section].name
    }

    let myString: NSString = originalString as NSString
    let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)])

    let sizeForItem = CGSize(width: size.width + 23, height: size.height + 10)

    return sizeForItem
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

    return UIEdgeInsetsMake(0, 3, 0, 3)
  }
}
