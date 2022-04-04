//
//  GrosseryItemsStorage.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import Foundation
import SwiftUI

final class GrosseryItemsStorage: ObservableObject {
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
    }
    
    @Published var connectionState: ConnectionState = .disconnected {
        didSet {
            if connectionState == .disconnected { groupItems() }
        }
    }
    
    @Published var items: [GrosseryItem] = []
    
    private var loader: GrosseryItemsLoaderType?
    
    func register(loader: GrosseryItemsLoaderType) {
        loader.delegate = self
        loader.start()
        self.loader = loader
    }
    
    func disconnect() {
        loader?.stop()
    }
    
    func resume() {
        connectionState = .connecting
        loader?.start()
    }
    
    private func groupItems() {
        let dictionary = Dictionary(grouping: items, by: \.bagColor)
        var sortedItems: [GrosseryItem] = []
        dictionary.values.forEach { sortedItems.append(contentsOf: $0) }
        self.items = sortedItems
    }
}

extension GrosseryItemsStorage: GrosseryItemsLoaderDelegate {
    func loader(_ loader: GrosseryItemsLoaderType, didLoadItem item: GrosseryItem) {
        items.append(item)
    }
    
    func loaderDidEstablishConnection(_ loader: GrosseryItemsLoaderType) {
        connectionState = .connected
    }
    
    func loaderDidCloseConnection(_ loader: GrosseryItemsLoaderType) {
        connectionState = .disconnected
    }
    
   
}
