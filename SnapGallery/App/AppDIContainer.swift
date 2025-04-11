import Foundation

final class AppDIContainer {
    
    // MARK: - Private Properties
    
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    
    private lazy var picsumPhotoRepository: PicsumPhotoRepositoryProtocol = {
        PicsumPhotoRepository(networkService: networkService)
    }()
    
    // MARK: - Public Methods
    
    public func makeGalleryViewController() -> GalleryViewController {
        let presenter = GalleryPresenter(photoRepository: picsumPhotoRepository)
        let view = GalleryViewController(presenter: presenter)
        presenter.view = view
        
        return view
    }
}
