
import UIKit

extension QuickMovieDetailsView {

  func setViewFrame() {
    // Set frame based on sent center point + edges
    let oldFrame = frame
    let width:CGFloat = 200
    let height:CGFloat = 90

    // X
    let widthBounds = UIScreen.main.bounds.size.width
    var x:CGFloat = 0
    // If center x is too close to left edge
    if point.x < width/2 {
      x = 10 + width/2
      // If center point it too close to the right edge
    } else if point.x > widthBounds - width/2 {
      x = widthBounds - (10 + width/2)
      // Otherwise keep center x
    } else {
      x = point.x
    }

    // Y
    var y:CGFloat = 0

    // If center y is too close to top
    if point.y < height + starsViewHeight {
      y = point.y + (2 * starsViewHeight) + 20
      // Otherwise keep center y
    } else  {
      y = point.y - (2 * starsViewHeight)
    }

    let newCenter = CGPoint(x: x, y: y)
    let newFrame = CGRect(origin: oldFrame.origin, size: CGSize(width: width, height: height))
    frame = newFrame
    center = newCenter
  }

  func setupConstraints() {
    yourRating.translatesAutoresizingMaskIntoConstraints = false

    let yourRatingCenterX = NSLayoutConstraint(
      item: yourRating,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1,
      constant: 0)

    let yourRatingBottom = NSLayoutConstraint(
      item: yourRating,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerY,
      multiplier: 1,
      constant: 0)

    let yourRatingHeight = NSLayoutConstraint(
      item: yourRating,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: starsViewHeight)

    addConstraints([
      yourRatingCenterX,
      yourRatingHeight,
      yourRatingBottom]
    )

    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let titleLeading = NSLayoutConstraint(
      item: titleLabel,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: yourRating,
      attribute: .top,
      multiplier: 1.0,
      constant: -10)

    let titleCenterX = NSLayoutConstraint(
      item: titleLabel,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: yourRating,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let titleWidth = NSLayoutConstraint(
      item: titleLabel,
      attribute: .width,
      relatedBy: .equal,
      toItem: yourRating,
      attribute: .width,
      multiplier: 1.0,
      constant: 0.0)

    addConstraints([
      titleLeading,
      titleCenterX,
      titleWidth]
    )

    containerView.translatesAutoresizingMaskIntoConstraints = false

    let containerCenterX = NSLayoutConstraint(
      item: containerView,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: yourRating,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let containerTop = NSLayoutConstraint(
      item: containerView,
      attribute: .top,
      relatedBy: .equal,
      toItem: titleLabel,
      attribute: .top,
      multiplier: 1.0,
      constant: -10.0)

    let containerBottom = NSLayoutConstraint(
      item: containerView,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: yourRating,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 10.0)

    let containerWidth = NSLayoutConstraint(
      item: containerView,
      attribute: .width,
      relatedBy: .equal,
      toItem: yourRating,
      attribute: .width,
      multiplier: 1.0,
      constant: 20.0)

    addConstraints([
      containerCenterX,
      containerTop,
      containerBottom,
      containerWidth]
    )

    blurView.translatesAutoresizingMaskIntoConstraints = false

    let blurCenterX = NSLayoutConstraint(
      item: blurView,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: containerView,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let blurCenterY = NSLayoutConstraint(
      item: blurView,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: containerView,
      attribute: .centerY,
      multiplier: 1.0,
      constant: 0.0)

    let blurHeight = NSLayoutConstraint(
      item: blurView,
      attribute: .height,
      relatedBy: .equal,
      toItem: containerView,
      attribute: .height,
      multiplier: 1.0,
      constant: 20.0)

    let blurWidth = NSLayoutConstraint(
      item: blurView,
      attribute: .width,
      relatedBy: .equal,
      toItem: containerView,
      attribute: .width,
      multiplier: 1.0,
      constant: 20.0)

    containerView.addConstraints([
      blurCenterX,
      blurCenterY,
      blurHeight,
      blurWidth]
    )
  }
}

