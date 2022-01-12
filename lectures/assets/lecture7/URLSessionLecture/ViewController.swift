import UIKit
import Foundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var albums = [Album]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            do {
                let albums = try await AlbumsFetcher.fetchAlbumsWithAsyncURLSession()
                reloadTableView(albums)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func reloadTableView(_ albums: [Album]) {
        // reloading...
        self.albums = albums
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = albums[indexPath.row].collectionName
        
        return cell
    }
}

struct AlbumsFetcher {
    enum AlbumsFetcherError: Error {
        case invalidUrl
        case serverError
        case missingData
        case invalidData
    }
    
    static func fetchAlbums(completionHandler: @escaping (Result<[Album], Error>) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album") else {
            completionHandler(.failure(AlbumsFetcherError.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completionHandler(.failure(AlbumsFetcherError.serverError))
                return
            }
            
            guard let content = data, content.count > 0 else {
                completionHandler(.failure(AlbumsFetcherError.missingData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ITunesResult.self, from: content)
                completionHandler(.success(result.results))
            } catch {
                completionHandler(.failure(AlbumsFetcherError.invalidData))
            }
        }.resume()
    }
    
    static func fetchAlbumsWithContinuation() async throws -> [Album] {
        let albums = try await withCheckedThrowingContinuation { continuation in
            fetchAlbums { continuation.resume(with: $0) }
        }
        
        return albums
    }
    
    static func fetchAlbumsWithAsyncURLSession() async throws -> [Album] {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album") else {
            throw AlbumsFetcherError.invalidUrl
        }
        
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        
        let result = try JSONDecoder().decode(ITunesResult.self, from: data)
        
        return result.results
    }
    
}

struct ITunesResult: Decodable {
    let results: [Album]
}

struct Album: Decodable {
    let collectionId: Int
    let collectionName: String
    let collectionPrice: Float
}

