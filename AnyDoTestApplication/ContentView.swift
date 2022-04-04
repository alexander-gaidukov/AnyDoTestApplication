//
//  ContentView.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var storage = GrosseryItemsStorage(with: URL(string: "ws://superdo-groceries.herokuapp.com/receive")!)
    var body: some View {
        
        NavigationView {
            ScrollView(.vertical) {
                LazyVStack(spacing: 20) {
                    ForEach(storage.items.reversed()) { item in
                        Text(item.name)
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .transition(.move(edge: .top))
                    }
                }
                .animation(.default, value: storage.items.count)
            }
            .navigationTitle("Grossery List")
            .toolbar {
                Button(
                    action: {
                        if storage.isConnected { storage.cancel() } else { storage.resume() }
                    },
                    label: { Text(storage.isConnected ? "Disconnect" : "Connect") }
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
