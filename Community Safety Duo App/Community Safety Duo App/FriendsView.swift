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
                    ForEach(contacts) { contact in
                        ContactRow(contact: contact)
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
            
            Button(action: {
                // Function to add a contact
                self.addContact()
                self.isPresented = false
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
        // Assuming a function that would add the contact
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
