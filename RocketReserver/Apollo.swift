//
//  Apollo.swift
//  RocketReserver
//
//  Created by Aleksander Kulikov on 14.05.2021.
//

import Foundation
import Apollo


class Network {
  static let shared = Network()
    
  lazy var apollo = ApolloClient(url: URL(string: "https://apollo-fullstack-tutorial.herokuapp.com/")!)
}


