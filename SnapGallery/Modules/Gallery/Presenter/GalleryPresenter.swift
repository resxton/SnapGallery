import Foundation

final class GalleryPresenter: GalleryPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: GalleryViewProtocol?
    
    // MARK: - Private Properties
    
    private let photoRepository: PicsumPhotoRepositoryProtocol
    
    // MARK: - Initializers
    
    init(photoRepository: PicsumPhotoRepositoryProtocol) {
        self.photoRepository = photoRepository
    }
    
    // MARK: - Public Methods
    
    public func viewDidLoad() {
        loadPhotos()
    }
    
    // MARK: - Private Methods
    
    private func loadPhotos() {
        photoRepository.fetchPhotosList { result in
            switch result {
            case .success(let photosList):
                print(photosList[0])
            case .failure(let error):
                print(error)
            }
        }
    }
}
