protocol PicsumPhotoRepositoryProtocol {
    func fetchPhotosList(completion: @escaping (Result<[PicsumPhoto], NetworkError>) -> Void)
}
