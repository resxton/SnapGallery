import Foundation

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
}

// MARK: - Constants

extension ProductRepository {
    private enum Consts {
        static let productsListUrl = "https://fakestoreapi.com/products"
    }
}
