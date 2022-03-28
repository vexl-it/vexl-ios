//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

protocol ContactServiceType {
    func createUser(with key: String, hash: String) -> AnyPublisher<Any, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<Any, Error>
    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<Any, Error>
}

class ContactService: ContactServiceType {
    func createUser(with key: String, hash: String) -> AnyPublisher<Any, Error> {
        
    }
    
    func importContacts(_ contacts: [String]) -> AnyPublisher<Any, Error> {
        
    }
    
    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<Any, Error> {
        
    }
}
