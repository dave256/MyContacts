//
//  ContactCell.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

struct ContactCell: View {
    
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(contact.fullName)
            Text(contact.email)
            Text(contact.phone)
        }
    }
}

struct ContactCell_Previews: PreviewProvider {
    static var previews: some View {
        ContactCell(contact: .mock)
    }
}
