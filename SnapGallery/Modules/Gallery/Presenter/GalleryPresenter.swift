import Foundation

final class GalleryPresenter: GalleryPresenterProtocol {

    // MARK: - Public Properties
    
    weak var view: GalleryViewProtocol?
    var productsCount: Int {
        products.count
    }
    
    // MARK: - Private Properties
    
    private let productRepository: ProductRepositoryProtocol
    private var products: [Product] = []
    
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
    
    public func product(at index: Int) -> Product {
        products[index]
    }
    
    // MARK: - Private Methods
    
    private func loadPhotos() {
        guard let view else { return }
        
        view.setLoaderVisible(true)
        
        self.productRepository.fetchProductsList { [weak self] result in
            guard let self else { return }
            
            view.setLoaderVisible(false)
            
            switch result {
            case .success(let productsList):
                DispatchQueue.main.async {
                    self.products = productsList
                    self.view?.updateTable()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
