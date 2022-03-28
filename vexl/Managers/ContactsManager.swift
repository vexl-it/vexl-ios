//
//  ContactsManager.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

protocol ContactsManangerType {
    var contacts: CurrentValueSubject<[String], Never> { get set }
}

final class ContactsManager: ContactsManangerType {
    var contacts: CurrentValueSubject<[String], Never> = .init([])
}
