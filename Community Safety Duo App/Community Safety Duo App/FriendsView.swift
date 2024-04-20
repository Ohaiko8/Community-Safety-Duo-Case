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
                    self.isAddingContact = true // Set isAddingContact to true to present the form
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
        NetworkManager.shared.fetchUsers { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.contacts = users
                }
            case .failure(let error):
                print("Failed to fetch users: \(error)")
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}

struct ContactRow: View {
    var contact: Contact
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.tomatoRed)
            }
            .padding(.trailing)
            
            Button(action: {
                // Track action
            }) {
                Image(systemName: "location.fill")
                    .foregroundColor(.skyBlue)
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
                    .fontWeight(.bold) // Make title bold
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
            
            Text("Add a trusted friend/family as an emergency contact to notify about your SOS situation and share your location with.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity) // Ensure both fields have the same width
                .padding(.horizontal)
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity) // Ensure both fields have the same width
                .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
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
                .padding(.trailing)
            }
            .padding(.bottom) // Adjusted padding to remove the shadow line
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(0)
        .shadow(radius: 0)
        
        Image("companion2")
            .resizable()
            .scaledToFit()
    }
    
    func addContact() {
        let newContact = Contact(name: name, phoneNumber: phoneNumber)
       
    }
}
