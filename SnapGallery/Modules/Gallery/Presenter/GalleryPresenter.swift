import Foundation

final class GalleryPresenter: GalleryPresenterProtocol {

    // MARK: - Public Properties
    
    weak var view: GalleryViewProtocol?
    
    // MARK: - Private Properties
    
    private let productRepository: ProductRepositoryProtocol
    
    // MARK: - Initializers
    
    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }
    
    // MARK: - Public Methods
    
    public func viewDidLoad() {
        loadPhotos()
    }
    
    public func didSelectRow(at indexPath: IndexPath) {
        
    }
    
    // MARK: - Private Methods
    
    private func loadPhotos() {
        guard let view else { return }
        
        view.setLoaderVisible(true)
        
        
        productRepository.fetchProductsList { result in
            view.setLoaderVisible(false)
            
            switch result {
            case .success(let productsList):
                print(productsList[0])
            case .failure(let error):
                print(error)
            }
        }
    }
}
