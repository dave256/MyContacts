//
//  Contact.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import Foundation
// from PointFree open source packages
import Tagged

// demo of a property wrapper that forces string not to have any leading and trailing whitespace
@propertyWrapper
struct Trimmed {
    var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// for value types in which all the data types it consists of, you get automatic conformance
// to these protocols
extension Trimmed: Codable, Equatable, Hashable {

//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let stringValue = try container.decode(String.self)
//        self.wrappedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(wrappedValue)
//    }

}

/// stores a Contact's information
/// many SwiftUI views require items to be Identifiable so they can determine what changed and update the view
/// some SwiftUI view functionality requires items to be Hashable; again automatic conformance for value types consisting of Hashable types
/// Swift will create func == if all elements are equal
/// Codable is useful for writing to JSON and/or storing to a file, etc.
struct Contact: Identifiable, Equatable, Hashable, Codable {
    // note this may actually not be a good idea since can't type double first names such as "Mary Jo" into a TextField
    // would need to type MaryJ or MaryJo and then insert a space before the J
    @Trimmed var firstName: String = ""
    @Trimmed var lastName: String = ""
    @Trimmed var phone: String = ""
    @Trimmed var email: String = ""
    /// UUID should always be different and use Tagged so couldn't compare the id of two different types
    public private(set) var id: Tagged<Self, UUID>

    init(firstName: String = "", lastName: String = "", phone: String = "", email: String = "", id: Tagged<Contact, UUID>? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        if let id {
            self.id = id
        } else {
            self.id = Contact.ID(UUID())
        }
    }

    /// first and last name (removes whitespace in case one of the names is empty)
    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines) }

    // for creating a new blank contact (each newly created one will have a different id)
    public static var blank: Contact { Contact() }

    // consider empty if none of fields have a value (ignore id)
    var isEmpty: Bool { firstName.isEmpty && lastName.isEmpty && phone.isEmpty && email.isEmpty }
}

/// add Comparable conformance for sorting an array of Contact (compares last names and then breaks tie with first name)
extension Contact: Comparable {
    static func < (lhs: Contact, rhs: Contact) -> Bool {
        // first compare last names
        if lhs.lastName < rhs.lastName {
            return true
        } else if lhs.lastName > rhs.lastName {
            return false
        } else {
            // if last names the same, try to break tie with first name
            return lhs.firstName < rhs.firstName
        }
    }
}

/// some sample data
extension Contact {
    // these only get created once so for a given run of the program they will be the same each time you access/create one
    // but they will not be the same as in previous executions of the program
    public static let jane = Contact(firstName: "Jane", lastName: "Smith", phone: "614-555-3456", email: "jsmith@devnull.com")
    public static var george = Contact(firstName: "George", lastName: "Jones", phone: "614-555-1234", email: "gjones@devnull.com")
    public static var kim = Contact(firstName: "Kim", lastName: "Wilson", phone: "614-555-5678", email: "kwilson@devnull.com")
    public static var noEmail = Contact(firstName: "No", lastName: "Email", phone: "614-555-4321", email: "")
    public static var nameOnly = Contact(firstName: "Name", lastName: "Only", phone: "", email: "")
    public static var noPhone = Contact(firstName: "No", lastName: "Phone", phone: "", email: "nophone@devnull.com")

    public static var mock = Contact.jane
    public static var mockArray = [Contact].mock
}

extension [Contact] {
    static var mock: [Contact] = [.jane, .noEmail, .noPhone, .nameOnly, .george, .kim]
}
