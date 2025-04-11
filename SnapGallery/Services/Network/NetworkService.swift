import Foundation

final class NetworkService: NSObject {
    
    // MARK: - Private Properties

    private var progressBlocks: [Int: (Double) -> Void] = [:]
    private var completionBlocks: [Int: (Result<Data, NetworkError>) -> Void] = [:]
    
    private lazy var urlSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
}

// MARK: - NetworkServiceProtocol

extension NetworkService: NetworkServiceProtocol {
    
    // MARK: - Public Methods
    
    public func get(
        url: String,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299) ~= httpResponse.statusCode else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.unknown(description: Consts.noDataMessage)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    public func download(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        // TODO: Download
    }
}

// MARK: - URLSessionDataDelegate

extension NetworkService: URLSessionDataDelegate {
    
}

// MARK: - Consts

extension NetworkService {
    private enum Consts {
        static let noDataMessage = "Empty data"
    }
}
