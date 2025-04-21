import Foundation

final class AppDIContainer {
    
    // MARK: - Private Properties
    
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    
    private lazy var productRepository: ProductRepositoryProtocol = {
        ProductRepository(networkService: networkService)
    }()
    
    // MARK: - Public Methods
    
    func makeGalleryViewController() -> GalleryViewController {
        let presenter = GalleryPresenter(productRepository: productRepository)
        let view = GalleryViewController(presenter: presenter)
        presenter.view = view
        
        return view
    }
}
