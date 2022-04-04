//
//  GrosseryItemsStorage.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import Foundation
import SwiftUI

final class GrosseryItemsStorage: NSObject, ObservableObject {
    @Published var isConnected = false {
        didSet {
            if !isConnected { groupItems() }
        }
    }
    @Published var items: [GrosseryItem] = []
    
    private let url: URL
    private var urlSession: URLSession!
    private var socket: URLSessionWebSocketTask!
    
    private let decoder = JSONDecoder()
    
    init(with url: URL) {
        self.url = url
        super.init()
        
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        resume()
    }
    
    func cancel() {
        socket.cancel(with: .goingAway, reason: nil)
    }
    
    func resume() {
        socket = urlSession.webSocketTask(with: url)
        establishConnection()
    }
    
    private func groupItems() {
        let dictionary = Dictionary(grouping: items, by: \.bagColor)
        var sortedItems: [GrosseryItem] = []
        dictionary.values.forEach { sortedItems.append(contentsOf: $0) }
        self.items = sortedItems
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
        items.append(item)
    }
}

extension GrosseryItemsStorage: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
    }
}
