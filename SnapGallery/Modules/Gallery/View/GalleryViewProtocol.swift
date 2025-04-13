protocol GalleryViewProtocol: AnyObject {
    func setLoaderVisible(_ isVisible: Bool)
    func updateTable()
    func updateProgress(with amount: Float)
}
