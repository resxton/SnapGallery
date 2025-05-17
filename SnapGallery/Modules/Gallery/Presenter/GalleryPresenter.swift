import Foundation

final class GalleryPresenter: GalleryPresenterProtocol {

    // MARK: - Public Properties
    
    weak var view: GalleryViewProtocol?
    var productsCount: Int {
        productViewModels.count
    }
    
    // MARK: - Private Properties
    
    private let productRepository: ProductRepositoryProtocol
    private var products: [ProductDomain] = []
    private var productViewModels: [ProductViewModel] = []
    
    // Можно поменять на .withUpdatingTables чтобы соответствующие картинкам ячейки появлялись сразу после загрузки
    private let imagesLoadingMode: ImagesLoadingMode = .withoutUpdatingTable
    
    // MARK: - Initializers
    
    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        loadProducts()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        // TODO: Implement selection logic
    }
    
    func product(at index: Int) -> ProductViewModel {
        productViewModels[index]
    }
    
    // MARK: - Private Methods
    
    private func loadProducts() {
        guard let view = view else { return }
        
        DispatchQueue.main.async {
            view.setLoaderVisible(true)
            view.updateProgress(with: 0) // Reset progress
        }
        
        productRepository.fetchProductsList { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                view.setLoaderVisible(false)
            }
            
            switch result {
            case .success(let productsList):
                self.products = productsList
                self.loadImagesAccordingToMode()
            case .failure(let error):
                DispatchQueue.main.async {
                    view.presentAlert(title: Consts.errorAlertTitle, message: error.alertMessage)
                }
            }
        }
    }
    
    private func loadImagesAccordingToMode() {
        switch imagesLoadingMode {
        case .withoutUpdatingTable:
            loadImagesWithoutUpdatingTable()
        case .withUpdatingTable:
            loadImagesWithTableUpdates()
        }
    }
    
    private func loadImagesWithTableUpdates() {
        guard let view = view else { return }
        
        let totalCount = products.count
        var completedCount = 0
        
        products.forEach { product in
            downloadImage(for: product) { [weak self] viewModel in
                guard let self = self else { return }
                
                completedCount += 1
                let progress = Float(completedCount) / Float(totalCount)
                
                DispatchQueue.main.async {
                    self.productViewModels.append(viewModel)
                    view.updateProgress(with: progress)
                    view.updateTable()
                }
            } onFailure: { [weak view] message in
                DispatchQueue.main.async {
                    view?.presentAlert(title: Consts.errorAlertTitle, message: message)
                }
            }
        }
    }
    
    private func loadImagesWithoutUpdatingTable() {
        guard let view = view else { return }
        
        let group = DispatchGroup()
        var loadedViewModels: [ProductViewModel] = []
        let totalCount = products.count
        var completedCount = 0
        
        products.forEach { product in
            group.enter()
            
            downloadImage(for: product) { viewModel in
                completedCount += 1
                let progress = Float(completedCount) / Float(totalCount)
                
                DispatchQueue.main.async {
                    view.updateProgress(with: progress)
                }
                
                loadedViewModels.append(viewModel)
                group.leave()
            } onFailure: { [weak view] message in
                DispatchQueue.main.async {
                    view?.presentAlert(title: Consts.errorAlertTitle, message: message)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.productViewModels = loadedViewModels
            view.updateTable()
        }
    }
    
    private func downloadImage(
        for product: ProductDomain,
        onSuccess: @escaping (ProductViewModel) -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        // globalProgress приходит в это замыкание при обновлении любой загрузки
        // и рассчитывается исходя из общего прогресса
        productRepository.downloadImage(url: product.url) { [weak view] globalProgress in
            DispatchQueue.main.async {
                view?.updateProgress(with: globalProgress)
            }
        } completion: { result in
            switch result {
            case .success(let image):
                let viewModel = ProductViewModel(title: product.title, image: image)
                onSuccess(viewModel)
            case .failure(let error):
                onFailure(error.alertMessage)
            }
        }
    }
}

extension GalleryPresenter {
    private enum ImagesLoadingMode {
        case withoutUpdatingTable
        case withUpdatingTable
    }
    
    private enum Consts {
        static let errorAlertTitle = "Ошибка"
    }
}
