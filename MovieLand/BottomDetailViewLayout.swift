
import UIKit

extension BottomDetailView {

  func setupTheatreView(with locationEnabled: Bool) {
    theatreView.translatesAutoresizingMaskIntoConstraints = false

    if (locationEnabled) {

      let amcTheatre = TheatreView(with: "AMC Loews", distance: 0.8, imageName: "amcTheatre")
      amcTheatre.delegate = self
      theatreView.addSubview(amcTheatre)

      let villageTheatre = TheatreView(with: "Village East", distance: 1.4, imageName: "villageTheatre")
      villageTheatre.delegate = self
      theatreView.addSubview(villageTheatre)

      let lincolnTheatre = TheatreView(with: "Lincoln Plaza", distance: 5.7, imageName: "lincolnTheatre")
      lincolnTheatre.delegate = self
      theatreView.addSubview(lincolnTheatre)

      villageTheatre.translatesAutoresizingMaskIntoConstraints = false

      let villageTop = NSLayoutConstraint(
        item: villageTheatre,
        attribute: .top,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0)

      let villageCenterX = NSLayoutConstraint(
        item: villageTheatre,
        attribute: .centerX,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .centerX,
        multiplier: 1.0,
        constant: 0.0)

      let villageBottom = NSLayoutConstraint(
        item: amcTheatre,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .bottom,
        multiplier: 1.0,
        constant: 0.0)

      theatreView.addConstraints([
        villageTop,
        villageCenterX,
        villageBottom]
      )

      amcTheatre.translatesAutoresizingMaskIntoConstraints = false

      let amcTop = NSLayoutConstraint(
        item: amcTheatre,
        attribute: .top,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0)

      let amcLeading = NSLayoutConstraint(
        item: amcTheatre,
        attribute: .leading,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .leading,
        multiplier: 1.0,
        constant: 0.0)

      let amcBottom = NSLayoutConstraint(
        item: amcTheatre,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .bottom,
        multiplier: 1.0,
        constant: 0.0)

      theatreView.addConstraints([
        amcTop,
        amcLeading,
        amcBottom]
      )

      lincolnTheatre.translatesAutoresizingMaskIntoConstraints = false

      let lincolnTop = NSLayoutConstraint(
        item: lincolnTheatre,
        attribute: .top,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0)

      let lincolnTrailing = NSLayoutConstraint(
        item: lincolnTheatre,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .trailing,
        multiplier: 1.0,
        constant: 0.0)

      let lincolnBottom = NSLayoutConstraint(
        item: lincolnTheatre,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .bottom,
        multiplier: 1.0,
        constant: 0.0)

      theatreView.addConstraints([
        lincolnTop,
        lincolnTrailing,
        lincolnBottom]
      )

    } else {
      locationDisabledLabel.translatesAutoresizingMaskIntoConstraints = false

      let labelTop = NSLayoutConstraint(
        item: locationDisabledLabel,
        attribute: .top,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0)

      let labelBottom = NSLayoutConstraint(
        item: locationDisabledLabel,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .bottom,
        multiplier: 1.0,
        constant: 0.0)

      let labelWidth = NSLayoutConstraint(
        item: locationDisabledLabel,
        attribute: .width,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .width,
        multiplier: 1.0,
        constant: 0.0)

      let labelCenterX = NSLayoutConstraint(
        item: locationDisabledLabel,
        attribute: .centerX,
        relatedBy: .equal,
        toItem: theatreView,
        attribute: .centerX,
        multiplier: 1.0,
        constant: 0.0)

      theatreView.addSubview(locationDisabledLabel)

      theatreView.addConstraints([
        labelTop,
        labelBottom,
        labelWidth,
        labelCenterX]
      )
    }
  }

  func setupConstraints() {

    genreLabel.translatesAutoresizingMaskIntoConstraints = false

    let genreTop = NSLayoutConstraint(
      item: genreLabel,
      attribute: .top,
      relatedBy: .equal,
      toItem: self,
      attribute: .top,
      multiplier: 1.0,
      constant: 20.0)

    let genreLeading = NSLayoutConstraint(
      item: genreLabel,
      attribute: .leading,
      relatedBy: .equal,
      toItem: self,
      attribute: .leading,
      multiplier: 1.0,
      constant: 20.0)

    let genreWidth = NSLayoutConstraint(
      item: genreLabel,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 0.9,
      constant: 0.0)

    addConstraints([
      genreTop,
      genreLeading,
      genreWidth]
    )

    languagesLabel.translatesAutoresizingMaskIntoConstraints = false

    let languagesTop = NSLayoutConstraint(
      item: languagesLabel,
      attribute: .top,
      relatedBy: .equal,
      toItem: genreLabel,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 10.0)

    let languagesLeading = NSLayoutConstraint(
      item: languagesLabel,
      attribute: .leading,
      relatedBy: .equal,
      toItem: self,
      attribute: .leading,
      multiplier: 1.0,
      constant: 20.0)

    let languagesWidth = NSLayoutConstraint(
      item: languagesLabel,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 0.9,
      constant: 0.0)

    addConstraints([
      languagesTop,
      languagesLeading,
      languagesWidth]
    )

    buyLabel.translatesAutoresizingMaskIntoConstraints = false

    let buyTop = NSLayoutConstraint(
      item: buyLabel,
      attribute: .top,
      relatedBy: .equal,
      toItem: languagesLabel,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 40.0)

    let buyCenterX = NSLayoutConstraint(
      item: buyLabel,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let buyWidth = NSLayoutConstraint(
      item: buyLabel,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 0.8,
      constant: 0.0)

    addConstraints([
      buyTop,
      buyCenterX,
      buyWidth]
    )

    let theatreTop = NSLayoutConstraint(
      item: theatreView,
      attribute: .top,
      relatedBy: .equal,
      toItem: buyLabel,
      attribute: .bottom,
      multiplier: 1.0,
      constant: 30.0)

    let theatreCenterX = NSLayoutConstraint(
      item: theatreView,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0)

    let theatreWidth = NSLayoutConstraint(
      item: theatreView,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 0.9,
      constant: 0.0)

    addConstraints([
      theatreTop,
      theatreCenterX,
      theatreWidth]
    )
  }
}
