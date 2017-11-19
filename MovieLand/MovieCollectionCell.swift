

import UIKit

protocol MovieCollectionCellDelegate: class {

  func movieCell(wasSelected movieCell: MovieCell)
  func movieCell(receivedTouchOn movieCell: MovieCell, at point: CGPoint)
  func movieCollectionCellDidScroll(_ movieCollectionCell: MovieCollectionCell)
}

class MovieCollectionCell: UITableViewCell {

  static let identifier = "MovieCollectionCell"

  weak var movieCollectionCellDelegate: MovieCollectionCellDelegate?

  var collectionData: [Movie] {
    didSet {
      movieCollectionView.reloadData()
    }
  }

  var collectionName: String {
    didSet {
      titleLabel.text = collectionName
    }
  }

  let titleLabel         = UILabel()
  let titleUnderlineView = UIView()
  let containerView      = UIView()
  let movieCollectionView: UICollectionView

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

    let flowLayout                     = UICollectionViewFlowLayout()
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing      = 0
    flowLayout.scrollDirection         = .horizontal
    movieCollectionView                = UICollectionView(frame: CGRect.zero, collectionViewLayout:flowLayout)

    self.collectionName = "Collection"
    self.collectionData = []

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //MARK: Setup
  private func setupViews() {

    contentView.addSubview(containerView)
    selectionStyle = .none

    if collectionData.count > 0 {
      if collectionData[0].movieSection == .alreadyRated {
        backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
      }
    }

    // Title Label
    containerView.addSubview(titleLabel)
    titleLabel.text          = "RECOMMENDED"
    titleLabel.textAlignment = .left
    titleLabel.font = UIFont.brownBold(withSize: 22)

    // Title Underline
    containerView.addSubview(titleUnderlineView)
    titleUnderlineView.backgroundColor = .yellow

    // Movie Collection View
    containerView.addSubview(movieCollectionView)
    movieCollectionView.dataSource = self
    movieCollectionView.delegate   = self
    movieCollectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
    movieCollectionView.backgroundColor = .clear
    movieCollectionView.showsHorizontalScrollIndicator = false

    setupConstraints()
  }
}

//MARK: MovieCellDelegate
extension MovieCollectionCell: MovieCellDelegate {

  func movieCell(receivedTouchIn movieCell: MovieCell, at point: CGPoint) {
    guard let delegate = movieCollectionCellDelegate else { return }
    delegate.movieCell(receivedTouchOn: movieCell, at: point)
  }
}

//MARK: UICollectionViewDelegate
extension MovieCollectionCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    guard let cell = collectionView.cellForItem(at: indexPath) as? MovieCell,
      let delegate = movieCollectionCellDelegate else { return }

    delegate.movieCell(wasSelected: cell)
  }
}

//MARK: UICollectionViewDelegate
extension MovieCollectionCell: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return collectionData.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let identifier = MovieCell.identifier
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MovieCell {
      cell.movie = collectionData[indexPath.section]
      cell.touchDelegate = self
      return cell
    }

    return UICollectionViewCell()
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension MovieCollectionCell: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    return CGSize(width: 140, height: 230)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

    return UIEdgeInsetsMake(0, 5, 0, 5)
  }
}

//MARK: UIScrollView
extension MovieCollectionCell: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let delegate = movieCollectionCellDelegate else { return }
    delegate.movieCollectionCellDidScroll(self)
  }
}
