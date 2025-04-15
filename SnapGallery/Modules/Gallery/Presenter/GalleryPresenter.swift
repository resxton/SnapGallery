import Foundation

final class GalleryPresenter: GalleryPresenterProtocol {

    // MARK: - Public Properties
    
    weak var view: GalleryViewProtocol?
    var productsCount: Int {
        productsWithImage.count
    }
    
    // MARK: - Private Properties
    
    private let productRepository: ProductRepositoryProtocol
    private var products: [Product] = []
    private var productsWithImage: [ProductWithImage] = []
    
    // Можно поменять на .withUpdatingTables чтобы соответствующие картинкам ячейки появлялись сразу после загрузки
    private let imagesLoadingMode: ImagesLoadingMode = .withoutUpdatingTable
    
    // MARK: - Initializers
    
    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }
    
    // MARK: - Public Methods
    
    public func viewDidLoad() {
        loadProducts()
    }
    
    public func didSelectRow(at indexPath: IndexPath) {
        // TODO: 
    }
    
    public func product(at index: Int) -> ProductWithImage {
        productsWithImage[index]
    }
    
    // MARK: - Private Methods
    
    private func loadProducts() {
        guard let view else { return }
        
        view.setLoaderVisible(true)
        
        self.productRepository.fetchProductsList { [weak self] result in
            guard let self else { return }
            
            view.setLoaderVisible(false)
            
            switch result {
            case .success(let productsList):
                DispatchQueue.main.async {
                    self.products = productsList
                    switch self.imagesLoadingMode {
                    case .withoutUpdatingTable:
                        self.loadImagesWithoutUpdatingTable()
                    case .withUpdatingTable:
                        self.loadImages()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadImages() {
        products.forEach { product in
            productRepository.downloadImage(url: product.url) { [weak self] amount in
                guard let self else { return }
                
                view?.updateProgress(with: amount)
                print(amount)
            } completion: { result in
                switch result {
                case .success(let image):
                    let productWithImage = ProductWithImage(title: product.title, image: image)
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        
                        productsWithImage.append(productWithImage)
                        view?.updateTable()
                        print("Image loaded")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func loadImagesWithoutUpdatingTable() {
        let group = DispatchGroup()
        var loadedProductsWithImage: [ProductWithImage] = []
        
        products.forEach { product in
            group.enter()
            
            productRepository.downloadImage(url: product.url) { [weak self] amount in
                guard let self else { return }
                
                view?.updateProgress(with: amount)
            } completion: { result in
                switch result {
                case .success(let image):
                    let productWithImage = ProductWithImage(title: product.title, image: image)
                    loadedProductsWithImage.append(productWithImage)
                case .failure(let error):
                    print("Image loading error:", error)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.productsWithImage = loadedProductsWithImage
            self.view?.updateTable()
        }
    }

}

extension GalleryPresenter {
    private enum ImagesLoadingMode {
        case withoutUpdatingTable
        case withUpdatingTable
    }
}
