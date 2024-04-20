import SwiftUI

struct FriendsView: View {
    @State private var contacts: [Contact] = []
    @State private var isAddingContact = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Emergency Contacts")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 30)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    self.isAddingContact = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Contact")
                    }
                    .padding()
                    .background(Color.skyBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 30)
                .padding(.trailing, 20)
            }
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(contacts, id: \.id) { contact in
                        ContactRow(contact: contact, removeAction: { contactId in
                            NetworkManager.shared.removeContactFromTrusted(userId: 1, contactId: contactId) { result in
                                switch result {
                                case .success(_):
                                    print("Contact removed successfully")
                                    self.fetchContacts()
                                case .failure(let error):
                                    print("Error removing contact: \(error.localizedDescription)")
                                }
                            }
                        })
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
        .onAppear {
            fetchContacts()
        }
        .sheet(isPresented: $isAddingContact) {
            AddContactForm(isPresented: self.$isAddingContact, contacts: self.$contacts)
        }
    }
    
    func fetchContacts() {
        NetworkManager.shared.fetchTrustedContacts(forUserId: 1) { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.contacts = users.map { user in
                        Contact(
                            id: user.id,
                            name: user.name,
                            phone: user.phone,
                            trusted_ids: user.trusted_ids,
                            profile_picture: user.profile_picture
                        )
                    }
                    self.contacts.forEach { contact in
                        print("User ID: \(contact.id), Name: \(contact.name), Phone: \(contact.phone), Trusted IDs: \(contact.trusted_ids ?? []), picture: \(contact.profile_picture)")
                    }
                }
            case .failure(let error):
                print("Failed to fetch users: \(error)")
            }
        }
    }
}

struct ContactRow: View {
    var contact: Contact
    var removeAction: (Int) -> Void
    
    var body: some View {
        HStack {
            if let imageName = contact.profile_picture, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image("placeholder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(contact.phone)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                            self.removeAction(contact.id)  // Call the removal action
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
            .padding(.trailing)
            
            Button(action: {
                // Placeholder for a call action
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
            }
            .padding(.trailing)
            
            Button(action: {
                // Placeholder for location sharing action
            }) {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct AddContactForm: View {
    @Binding var isPresented: Bool
    @Binding var contacts: [Contact]
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text("Add Contact")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    self.isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .padding()
                        .foregroundColor(.black)
                }
            }
            
            Text("Add a trusted friend or family member as an emergency contact.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Spacer()
            
            // Error message positioned right above the Save Contact button
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                self.errorMessage = nil
                self.addContact()
            }) {
                Text("Save Contact")
                    .font(.headline)
                    .padding()
                    .background(Color.skyBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .background(Color.white)
    }
    
    func addContact() {
        NetworkManager.shared.fetchUserByNameAndPhone(name: name, phone: phoneNumber) { result in
            switch result {
            case .success(let user):
                NetworkManager.shared.getFirstUser { firstUserResult in
                    switch firstUserResult {
                    case .success(let firstUser):
                        if firstUser.id == user.id {
                            DispatchQueue.main.async {
                                self.errorMessage = "Cannot add oneself as a trusted contact."
                            }
                            return
                        }
                        
                        if firstUser.trusted_ids?.contains(user.id) ?? false {
                            DispatchQueue.main.async {
                                self.errorMessage = "This user is already in your trusted list."
                            }
                            return
                        }
                        
                        NetworkManager.shared.updateFirstUserTrustedContacts(userId: firstUser.id, newContactId: user.id) { updateResult in
                            switch updateResult {
                            case .success(_):
                                DispatchQueue.main.async {
                                    self.fetchContacts() // Fetch all contacts again to update the view
                                    self.errorMessage = nil
                                    self.isPresented = false
                                }
                            case .failure(let updateError):
                                DispatchQueue.main.async {
                                    self.fetchContacts() // Fetch all contacts again to update the view
                                    self.errorMessage = nil
                                    self.isPresented = false
                                }
                            }
                        }
                    case .failure(let firstUserError):
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to fetch first user: \(firstUserError.localizedDescription)"
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    print(name);
                    print(phoneNumber);
                    self.errorMessage = "This user doesn't use our app yet."
                }
            }
        }
    }
    func fetchContacts() {
        NetworkManager.shared.fetchTrustedContacts(forUserId: 1) { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.contacts = users.map { user in
                        Contact(
                            id: user.id,
                            name: user.name,
                            phone: user.phone,
                            trusted_ids: user.trusted_ids,
                            profile_picture: user.profile_picture
                        )
                    }
                    self.contacts.forEach { contact in
                        print("User ID: \(contact.id), Name: \(contact.name), Phone: \(contact.phone), Trusted IDs: \(contact.trusted_ids ?? []), picture: \(contact.profile_picture)")
                    }
                }
            case .failure(let error):
                print("Failed to fetch users: \(error)")
            }
        }
    }
    
}
