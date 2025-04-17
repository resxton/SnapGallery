import UIKit
import SnapKit

class GalleryViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.tintColor = .accent
        progressBar.trackTintColor = .customBlack
        return progressBar
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.alpha = 0
        loader.color = .customBlack
        loader.backgroundColor = .accent
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
        view.backgroundColor = .systemBackground
        view.addSubview(progressBar)
        view.addSubview(tableView)
        view.addSubview(loader)
    }
    
    private func setupConstraints() {
        progressBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.layoutMarginsGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
            make.top.equalTo(progressBar.snp.bottom).offset(Consts.verticalSpacing)
        }
        
        loader.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
                loader.alpha = 1
            } else {
                UIView.animate(withDuration: Consts.animationDuration, animations: {
                    self.loader.alpha = 0
                }, completion: { _ in
                    self.loader.stopAnimating()
                })
            }
        }
    }
    
    func updateTable() {
        tableView.reloadData()
    }
    
    func updateProgress(with amount: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            progressBar.setProgress(amount, animated: false)
        }
    }
    
    func presentAlert(title: String, message: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: Consts.actionTitle, style: .cancel)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension GalleryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.productsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Consts.cellIdentifier) else {
            return UITableViewCell()
        }
        
        let product = presenter.product(at: indexPath.row)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = product.title
        contentConfiguration.image = product.image
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GalleryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Consts

extension GalleryViewController {
    private enum Consts {
        static let cellIdentifier = "GalleryCell"
        static let actionTitle = "ОК"
        static let verticalSpacing: CGFloat = 16
        static let animationDuration: TimeInterval = 0.3
    }
}
