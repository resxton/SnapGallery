import Foundation

class PicsumPhotoRepository: PicsumPhotoRepositoryProtocol {
    
    // MARK: - Private Properties
    
    private let networkService: NetworkServiceProtocol
    private let jsonDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Initializers
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    public func fetchPhotosList(
        completion: @escaping (Result<[PicsumPhoto], NetworkError>) -> Void
    ) {
        networkService.get(url: Consts.photosListUrl) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let photos = try jsonDecoder.decode([PicsumPhoto].self, from: data)
                    completion(.success(photos))
                } catch {
                    completion(.failure(.decodingError(underlying: error)))
                }
            case .failure(let error):
                switch error {
                case .invalidURL:
                    completion(.failure(.invalidURL))
                case .invalidResponse:
                    completion(.failure(.invalidResponse))
                case .serverError(let statusCode):
                    completion(.failure(.serverError(statusCode: statusCode)))
                case .noConnection:
                    completion(.failure(.noConnection))
                case .timeout:
                    completion(.failure(.timeout))
                default:
                    completion(.failure(.unknown(description: error.localizedDescription)))
                }
            }
        }
    }
}

// MARK: - Constants

extension PicsumPhotoRepository {
    private enum Consts {
        static let photosListUrl = "https://picsum.photos/v2/list"
    }
}
