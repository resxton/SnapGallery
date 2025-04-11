import UIKit
import SnapKit

class GalleryViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private var tableView = UITableView()
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.tintColor = .accent
        progressBar.trackTintColor = .customBlack
        return progressBar
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.hidesWhenStopped = true
        loader.color = .customBlack
        return loader
    }()
    
    // MARK: - Private Properties
    
    private let presenter: GalleryPresenterProtocol

    // MARK: - Initializers
    
    init(presenter: GalleryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(loader)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.layoutMarginsGuide)
        }
        
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - GalleryViewProtocol

extension GalleryViewController: GalleryViewProtocol {
    func setLoaderVisible(_ isVisible: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if isVisible {
                loader.startAnimating()
            } else {
                loader.stopAnimating()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension GalleryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: Consts.cellIdentifier) else {
//            return UITableViewCell()
//        }
        
        // let photo = presenter.photo(at: indexPath.row)
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension GalleryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
}

// MARK: - Consts

extension GalleryViewController {
    private enum Consts {
        static let cellIdentifier = "GalleryCell"
    }
}
