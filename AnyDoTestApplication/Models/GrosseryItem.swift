//
//  GrosseryItem.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import Foundation

struct GrosseryItem: Decodable, Identifiable {
    let id = UUID()
    let bagColor: String
    let name: String
    let weight: String
}
