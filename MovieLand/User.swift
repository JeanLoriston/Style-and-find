

import UIKit

protocol UserOnboardingDelegate: class {
  func userProgressed(to step: Int)
}

enum OnboardingProgress: Int {
  case greet
  case explain
  case learnToRate
  case rateFive
  case scrollToBottom
  case afterScrolling
  case settingsPrompt
  case toSettings
  case showSignUp
  case sayGoodbye

  func message() -> String {
    switch self {
    case .greet:
      return "\n\nHello Stranger! 🤗 \n\n Welcome to MovieLand 🎬 \n\nIf you're wondering: \n'What should I watch tonight?'\n\n TAP ME to find out more."
    case .explain:
      return "MovieLand uses colaborative item-to-item filtering. \n\nThe more you rate, the better I can suggest movies you might enjoy, and help you avoid the ones that you won't."
    case .learnToRate:
      return "To start, TAP and HOLD a movie below to rate it.\n\nEach rating helps me improve what I show you in your Top Picks."
    case .rateFive:
      return "Good job! 👌\n\nNow rate a few more to get us going."
    case .scrollToBottom:
      return "Great! You're a pro 😎!\n\nSCROLL to the bottom, to find the movies you've already rated. \n\nThey'll be on a grey background."
    case .afterScrolling:
      return "If you want to find specific movies to rate, or a specific genre then\n\nDRAG me down.\n\n⬇️"
    case .settingsPrompt:
      return "Awesome 👌.\n\nAnd if you want to see how many movies you've already rated, \n\nDRAG me down again.\n(But this time, put some muscle into it!)"
    case .toSettings:
      return "Here you can view your progress and change your recommender system.\n\nBut for me to remember that... 🤔"
    case .showSignUp:
      return  "You'll need to \n\nSIGN UP\n\nso that I can sync your recommendations across devices."
    case .sayGoodbye:
      return "Keep on rating to help me help you find your perfect movie!\n\nEnjoy the show(s) 🍿"
    }
  }

  static var count: Int { return OnboardingProgress.sayGoodbye.rawValue + 1 }
}

enum LocationOnboardingProgress: Int {
  case howToClose
  case explainSection
  case explainLocationNeed
  case askForLocation

  func message(withUsername: String?, locationEnabled: Bool) -> String {
    switch self {
    case .howToClose:
      return "Hello again 👋🏻!\n\nSWIPE down to dismiss me.\n\n⬇️⬇️⬇️\n\n(But come back for more.)"
    case .explainSection:
      return "Here you can find the closest theatres where you can watch this movie.\n\nAnd you can BUY a ticket right here! \n\n👆"
    case .explainLocationNeed:
      return "But to do that, I'll need to access your location when you're using the app.\n\nIs that okay 🙈?"
    case .askForLocation:
      if !locationEnabled {
        return "Well, if you don't want to share your location, then I refuse to stay here any longer! \n\n Good Day! 👿\n\n(If you change your mind TAP HERE)"
      } else {
        return "Alright!\n\nYou're all set up now.\n\nGoodbye for now. 🙂"
      }
    }
  }

  static var count: Int { return LocationOnboardingProgress.askForLocation.rawValue + 1 }
}

class User {

  weak var delegate: UserOnboardingDelegate?

  var name:String?
  var numberRated: Int = 0

  var locationProgress: LocationOnboardingProgress

  var locationOnboardingSteps: Int {
    didSet {
      if let progress = LocationOnboardingProgress(rawValue: locationOnboardingSteps) {
        locationProgress = progress
      }
    }
  }

  var onboardingSteps: Int {
    didSet {
      if let progress = OnboardingProgress(rawValue: onboardingSteps) {
        onboardingProgress = progress
      }
      delegate?.userProgressed(to: onboardingSteps)
    }
  }

  var onboardingProgress: OnboardingProgress

  init(with name: String?) {
    self.name = name
    self.onboardingSteps = 0
    self.onboardingProgress = OnboardingProgress(rawValue: 0)!
    self.locationOnboardingSteps = 0
    self.locationProgress = LocationOnboardingProgress(rawValue: 0)!
  }
}
