import Foundation

protocol NetworkServiceProtocol {
    func get(
        url: String,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    )
    
    func download(
        url: String,
        progressBlock: ((Float) -> Void)?,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    )
}
