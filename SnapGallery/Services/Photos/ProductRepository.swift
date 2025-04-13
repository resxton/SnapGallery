import UIKit

class ProductRepository: ProductRepositoryProtocol {
    
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
    
    public func fetchProductsList(
        completion: @escaping (Result<[Product], NetworkError>) -> Void
    ) {
        networkService.get(url: Consts.productsListUrl) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let productsDTO = try jsonDecoder.decode([ProductDTO].self, from: data)
                    let products = productsDTO.map {
                        $0.toDomain()
                    }
                    completion(.success(products))
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
    
    public func downloadImage(
        url: String,
        progressBlock: @escaping (Float) -> Void,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void
    ) {
        networkService.download(url: url, progressBlock: progressBlock) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    return
                }
                let targetSize = CGSize(width: 100, height: 100)
                let resizedImage = image.resizeImage(to: targetSize)
                completion(.success(resizedImage ?? image))
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}

// MARK: - Constants

extension ProductRepository {
    private enum Consts {
        static let productsListUrl = "https://fakestoreapi.com/products"
    }
}
