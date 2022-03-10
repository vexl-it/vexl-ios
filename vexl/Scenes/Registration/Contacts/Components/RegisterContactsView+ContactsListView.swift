//
//  RegisterContactsView+ContactsListView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import SwiftUI

extension RegisterContactsView {

    struct RegisterContactItem: Identifiable {
        var id: Int
        var name: String
        var phone: String
        var avatar: Data?

        static func stub() -> [RegisterContactItem] {
            [
                RegisterContactItem(id: 1, name: "Diego Espinoza 1", phone: "999 944 222", avatar: nil),
                RegisterContactItem(id: 2, name: "Diego Espinoza 2", phone: "929 944 222", avatar: nil),
                RegisterContactItem(id: 3, name: "Diego Espinoza 3", phone: "969 944 222", avatar: nil)
            ]
        }
    }

    struct ContactItemView: View {

        private let imageSize = CGSize(width: 48, height: 48)
        private let checkSize = CGSize(width: 38, height: 38)

        let item: RegisterContactItem

        var body: some View {
            HStack {
                Image(R.image.onboarding.emptyAvatar.name)
                    .resizable()
                    .frame(size: imageSize)

                Spacer()

                VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {
                    Text(item.name)
                        .textStyle(.paragraph)
                        .foregroundColor(Appearance.Colors.primaryText)

                    Text(item.phone)
                        .textStyle(.descriptionSemibold)
                        .foregroundColor(Appearance.Colors.gray3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Appearance.GridGuide.point)

                Spacer()

                Circle()
                    .frame(size: checkSize)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.bottom, Appearance.GridGuide.point)
        }
    }

    struct ContactListView: View {

        private let items: [RegisterContactItem] = RegisterContactItem.stub()

        var body: some View {
            VStack {

                HStack(spacing: Appearance.GridGuide.point) {
                    TextField("Search", text: .constant(""))
                    Button("Deselect All") {
                        print("123")
                    }
                }
                .padding(Appearance.GridGuide.padding)

                ForEach(items) { item in
                    RegisterContactsView.ContactItemView(item: item)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .cornerRadius(Appearance.GridGuide.padding)
        }
    }
}

struct RegisterContacts_ContactListViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.ContactListView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
