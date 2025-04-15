import Foundation

final class NetworkService: NSObject {
    
    // MARK: - Private Properties

    private var progressBlocks: [Int: (Float) -> Void] = [:]
    private var completionBlocks: [Int: (Result<Data, NetworkError>) -> Void] = [:]
    private var receivedData: [Int: Data] = [:]
    
    var totalBytesExpectedToWrite: Int64 = 0
    var totalBytesWritten: Int64 = 0
    
    private lazy var urlSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
}

// MARK: - NetworkServiceProtocol

extension NetworkService: NetworkServiceProtocol {
    
    // MARK: - Public Methods
    
    public func get(
        url: String,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299) ~= httpResponse.statusCode else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.unknown(description: Consts.noDataMessage)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    public func download(
        url: String,
        progressBlock: ((Float) -> Void)?,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        let task = urlSession.dataTask(with: request)
        
        progressBlocks[task.taskIdentifier] = progressBlock
        completionBlocks[task.taskIdentifier] = completion
        
        task.resume()
    }
}

// MARK: - URLSessionDataDelegate

extension NetworkService: URLSessionDataDelegate {
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (
            URLSession.ResponseDisposition
        ) -> Void
    ) {
        if let httpResponse = response as? HTTPURLResponse,
           let contentLength = httpResponse.allHeaderFields[Consts.contentLength] as? String {
            let totalLength = Int64(contentLength) ?? 0
            totalBytesExpectedToWrite += totalLength
        }
        completionHandler(.allow)
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        let taskID = dataTask.taskIdentifier
        
        receivedData[taskID, default: Data()].append(data)

        if let progressBlock = progressBlocks[taskID] {
            totalBytesWritten += Int64(data.count)
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            progressBlock(progress)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let taskID = task.taskIdentifier
        defer {
            progressBlocks.removeValue(forKey: taskID)
            completionBlocks.removeValue(forKey: taskID)
            receivedData.removeValue(forKey: taskID)
        }
        
        guard let completion = completionBlocks[taskID] else { return }
        
        if let error {
            completion(.failure(.unknown(description: error.localizedDescription)))
            return
        }
        
        guard let data = receivedData[taskID], !data.isEmpty else {
            completion(.failure(.unknown(description: Consts.noDataMessage)))
            return
        }
        
        completion(.success(data))
    }
}

// MARK: - Consts

extension NetworkService {
    private enum Consts {
        static let noDataMessage = "Empty data"
        static let contentLength = "Content-Length"
    }
}
