//
//  ContentView.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import SwiftUI

struct GrosseryItemCell: View {
    let item: GrosseryItem
    let namespace: Namespace.ID
    let onTouch: () -> ()
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2.0)
                .background(
                    Circle().fill(Color(hex: item.bagColor))
                )
                .zIndex(1000)
                .matchedGeometryEffect(id: item.id, in: namespace)
                .frame(width: 40, height: 40)
                .onTapGesture {
                    onTouch()
                }
            VStack(spacing: 0) {
                Text(item.name)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.lightGray)
                    
                Divider()
                    .background(Color.gray)
                Text(item.weight)
                    .font(.caption)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

struct DetailView: View {
    @Binding var item: GrosseryItem?
    let namespace: Namespace.ID
    
    var body: some View {
        if let item = item {
            Color(hex: item.bagColor)
                .matchedGeometryEffect(id: item.id, in: namespace)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { self.item = nil }
                }
        }
    }
}

struct ContentView: View {
    @StateObject var storage = GrosseryItemsStorage()
    
    @Namespace var animation
    
    @State var selectedItem: GrosseryItem?
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 20) {
                        ForEach(storage.items.reversed()) { item in
                            GrosseryItemCell(
                                item: item,
                                namespace: animation,
                                onTouch: {
                                    guard storage.connectionState == .disconnected else { return }
                                    withAnimation {
                                        selectedItem = item
                                    }
                                }
                            )
                                .transition(.move(edge: .top))
                        }
                    }
                    .animation(.default, value: storage.items.count)
                }
                .navigationTitle("Grossery List")
                .toolbar {
                    Button(
                        action: {
                            switch storage.connectionState {
                            case .disconnected:
                                storage.resume()
                            case .connecting:
                                break
                            case .connected:
                                storage.disconnect()
                            }
                        },
                        label: {
                            switch storage.connectionState {
                            case .disconnected:
                                Text("Connect")
                            case .connecting:
                                Text("Connecting...")
                            case .connected:
                                Text("Disconnect")
                            }
                        }
                    )
                        .disabled(storage.connectionState == .connecting)
                }
            }
            .task {
                let loader = GrosseryItemsLoader(with:  URL(string: "ws://superdo-groceries.herokuapp.com/receive")!)
                storage.register(loader: loader)
            }
            
            if selectedItem != nil {
                DetailView(item: $selectedItem, namespace: animation)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
