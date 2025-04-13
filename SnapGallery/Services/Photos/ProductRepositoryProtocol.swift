import UIKit

protocol ProductRepositoryProtocol {
    func fetchProductsList(completion: @escaping (Result<[Product], NetworkError>) -> Void)
    func downloadImage(
        url: String,
        progressBlock: @escaping (Float) -> Void,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void
    )
}
