protocol ProductRepositoryProtocol {
    func fetchProductsList(completion: @escaping (Result<[Product], NetworkError>) -> Void)
}
