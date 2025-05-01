import Foundation

protocol GalleryPresenterProtocol {
    var productsCount: Int { get }
    
    func viewDidLoad()
    func didSelectRow(at indexPath: IndexPath)
    func product(at index: Int) -> ProductViewModel
}
