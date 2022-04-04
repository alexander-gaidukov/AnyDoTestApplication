//
//  GrosseryItemsLoader.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import Foundation

protocol GrosseryItemsLoaderDelegate: AnyObject {
    func loader(_ loader: GrosseryItemsLoaderType, didLoadItem item: GrosseryItem)
    func loaderDidEstablishConnection(_ loader: GrosseryItemsLoaderType)
    func loaderDidCloseConnection(_ loader: GrosseryItemsLoaderType)
}

protocol GrosseryItemsLoaderType: AnyObject {
    var delegate: GrosseryItemsLoaderDelegate? { get set }
    func start()
    func stop()
}

final class GrosseryItemsLoader: NSObject, GrosseryItemsLoaderType {
    weak var delegate: GrosseryItemsLoaderDelegate?
    
    private let url: URL
    private var urlSession: URLSession!
    private var socket: URLSessionWebSocketTask!
    
    private let decoder = JSONDecoder()
    
    init(with url: URL) {
        self.url = url
        super.init()
        
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    func start() {
        socket = urlSession.webSocketTask(with: url)
        establishConnection()
    }
    
    func stop() {
        socket.cancel(with: .goingAway, reason: nil)
    }
    
    private func establishConnection() {
        addListener()
        socket.resume()
    }
    
    private func addListener() {
        socket.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                switch response {
                case .data(let data):
                    self.addGrosseryItem(with: data)
                case .string(let message):
                    if let data = message.data(using: .utf8) { self.addGrosseryItem(with: data) }
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Error is received \(error.localizedDescription)")
            }
            
            self.addListener()
        }
    }
    
    private func addGrosseryItem(with data: Data) {
        guard let item = try? decoder.decode(GrosseryItem.self, from: data) else { return }
        delegate?.loader(self, didLoadItem: item)
    }
}

extension GrosseryItemsLoader: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        delegate?.loaderDidEstablishConnection(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        delegate?.loaderDidCloseConnection(self)
    }
}
