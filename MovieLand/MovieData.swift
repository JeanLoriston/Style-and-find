
import UIKit

//MARK: All Genres
enum Genre: String {
  case action
  case adventure
  case horror
  case scienceFiction
  case comedy
  case drama
  case documentary
  case tragedy
  case independent
  case war
  case western
  case fantasy
  case romance
  case thriller
  case filmNoir
  case mystery
  case crime
  case musical
  case animation
  case children
  case music
  case family
  case history

  static var count: Int { return Genre.history.hashValue + 1}
}

//MARK: All Sections
enum MovieSection: Int {
  case rate
  case topPicks
  case recent
  case alreadyRated

  func sectionName() -> String {
    switch self {
    case .topPicks:
      return "Top Picks"
    case .alreadyRated:
      return "Already Rated"
    case .recent:
      return "Recent"
    case .rate:
      return "Rate"
    }
  }

  static var count: Int { return MovieSection.alreadyRated.rawValue + 1}
}

//MARK: Filters
struct Filters {
  static func genres() -> [GenreFilter] {
    let allGenres: [Genre] = [.action, .adventure, .horror, .scienceFiction, .comedy, .drama, .documentary, .tragedy, .independent, .war, .western, .fantasy, .romance, .thriller, .filmNoir, .mystery, .crime, .musical, .animation, .children, .music, .family, .history]

    let allGenreFilters = allGenres.map { GenreFilter(name: $0.rawValue) }

    return allGenreFilters
  }
}

class GenreFilter {
  let name: String
  var added: Bool = false

  init(name: String) {
    self.name = name
  }
}

//MARK: Admission Rating
enum AdmissionRating: String {
  case PG13
  case R
  case G
  case PG
}

//MARK: Movie
class Movie: Equatable {
  let title: String
  let year: Int
  let length: Int // Minutes
  let languages: [String]
  let cast: [String]
  let director: String
  let genres: [Genre]
  let rating: Double
  let description: String
  let admissionRating: AdmissionRating
  let yourPredictedRating: Double
  var yourActualRating: Double?
  var movieSection: MovieSection
  let image: UIImage

  init(title: String, year: Int, length: Int, languages: [String], cast: [String], director: String, genres: [Genre], rating: Double, description: String, admissionRating: AdmissionRating, image: UIImage) {
    self.title                        = title
    self.year                         = year
    self.length                       = length
    self.languages                    = languages
    self.cast                         = cast
    self.director                     = director
    self.genres                       = genres
    self.rating                       = rating
    self.description                  = description
    self.admissionRating              = admissionRating
    self.image                        = image
    // This defaults to audience rating + or - 0.5 for presentation sake
    // We're not building a real prediction engine here
    let random                        = Int(arc4random_uniform(3)) - 1
    let yourPredictedRating           = rating + Double(random) * 0.5
    self.yourPredictedRating          = yourPredictedRating > 5 ? 5 : yourPredictedRating
    self.yourActualRating             = nil
    let movieSections: [MovieSection] = [.topPicks, .recent, .rate]
    self.movieSection                 = movieSections[random+1]
  }

  static func == (lhs: Movie, rhs: Movie) -> Bool {
    return lhs.title == rhs.title &&
      lhs.year == rhs.year &&
      lhs.length == rhs.length &&
      lhs.languages == rhs.languages &&
      lhs.cast == rhs.cast &&
      lhs.director == rhs.director &&
      lhs.genres == rhs.genres &&
      lhs.rating == rhs.rating &&
      lhs.description == rhs.description &&
      lhs.admissionRating == rhs.admissionRating
  }
}

//MARK: Movie Data
struct MovieStore {

  static func movies() -> [Movie] {
    return parseMovies()
  }

  static func moviesBySection(movies: [Movie]) -> [MovieSection : [Movie]] {
    var moviesBySection: [MovieSection:[Movie]] = [:]
    for movie in movies {
      if let existingSection = moviesBySection[movie.movieSection] {
        var sectionCopy = existingSection
        sectionCopy.append(movie)
        moviesBySection[movie.movieSection] = sectionCopy
      } else {
        moviesBySection[movie.movieSection] = [movie]
      }
    }

    return moviesBySection
  }

  static func genreResults(on movies: [Movie], for genres: [Genre]) -> [MovieSection: [Movie]] {
    let moviesToKeep = movies.filter { (movie) -> Bool in
      return movie.genres.filter({ (genre) -> Bool in
        return genres.index(of: genre) != nil
      }).count > 0
    }

    return moviesBySection(movies: moviesToKeep)
  }

  static func searchResults(on movies: [Movie], for query:String) -> [MovieSection : [Movie]] {
    // search by actor, director, year, languages,

    let titleResults = movies.filter { (movie) -> Bool in
      return movie.title.components(separatedBy: " ").filter({ (titlePart) -> Bool in
        return titlePart.lowercased() == query
      }).count > 0
    }

    let directorResults = movies.filter { (movie) -> Bool in
      return movie.director.components(separatedBy: " ").filter({ (directorPart) -> Bool in
        return directorPart.lowercased() == query
      }).count > 0
    }

    let yearResults = movies.filter{ String($0.year) == query }

    let castResults = movies.filter { (movie) -> Bool in
      return movie.cast.filter({ (castMember) -> Bool in
        return castMember.lowercased() == query
      }).count > 0
    }

    let languageResults = movies.filter { (movie) -> Bool in
      return movie.languages.filter({ (language) -> Bool in
        return language.lowercased() == query
      }).count > 0
    }

    let combinedResults = titleResults + directorResults + yearResults + castResults + languageResults

    return moviesBySection(movies: combinedResults)
  }

  private static func parseMovies() -> [Movie] {

    let filePath = Bundle.main.path(forResource: "Movies", ofType: "plist")!
    let dictionary = NSDictionary(contentsOfFile: filePath)!
    let movieData = dictionary["Movies"] as! [[String : AnyObject]]

    let movies = movieData.map { dict -> Movie in
      let genreStrings = dict["genres"] as! [String]
      let genres: [Genre] = genreStrings.filter{ Genre(rawValue: $0.lowercased()) != nil }
        .map{ Genre(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased())! }

      return Movie(
        title: dict["title"] as! String,
        year: dict["year"] as! Int,
        length: dict["length"] as! Int,
        languages: dict["languages"] as! [String],
        cast: dict["cast"] as! [String],
        director: dict["director"] as! String,
        genres: genres,
        rating: dict["rating"] as! Double,
        description: dict["description"] as! String,
        admissionRating: AdmissionRating(rawValue: dict["admissionRating"] as! String)!,
        image: UIImage(named: dict["imageName"] as! String)!)
    }

    return movies
  }
}
