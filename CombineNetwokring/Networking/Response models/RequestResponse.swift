//
//  RequestResponse.swift
//  CombineNetwokring
//
//  Created by Marin Tutuc on 05.02.2023.
//

import Foundation

public struct RequestResponse<T: Codable> {
    
    let response: T?
    let error: Error?

    init(response: T? = nil, error: Error? = nil) {
        self.response = response
        self.error = error
    }
}
