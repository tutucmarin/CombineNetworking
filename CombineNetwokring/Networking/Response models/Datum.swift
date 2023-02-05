//
//  Datum.swift
//  CombineNetwokring
//
//  Created by Marin Tutuc on 05.02.2023.
//

import Foundation

// MARK: - Datum
struct Datum: Codable{
    let id: Int?
    let email, firstName, lastName: String?
    let avatar: String?
    
    var fullname: String? {
        if let firstName = self.firstName,
           let lastName = self.lastName {
            return firstName + " " + lastName
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}
