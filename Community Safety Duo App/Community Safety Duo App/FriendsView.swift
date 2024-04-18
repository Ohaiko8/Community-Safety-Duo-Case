import SwiftUI

struct FriendsView: View {
    @State private var contacts = [
        Contact(name: "Jane Doe", phoneNumber: "+1234567890"),
        Contact(name: "Alex Smith", phoneNumber: "+0987654321"),
        Contact(name: "Emily Johnson", phoneNumber: "+1122334455"),
        Contact(name: "Michael Brown", phoneNumber: "+3344556677")
    ]
    @State private var isAddingContact = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Emergency Contacts")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(contacts) { contact in
                        ContactRow(contact: contact)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: {
                self.isAddingContact.toggle()
            }) {
                Text("Add Contact")
                    .padding()
                    .background(Color.skyBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 20)
            .sheet(isPresented: $isAddingContact, onDismiss: {
                self.resetForm()
            }) {
                AddContactForm(isPresented: self.$isAddingContact, contacts: self.$contacts)
            }
        }
        .padding(.top, 20)
    }
    
    func resetForm() {
        self.isAddingContact = false
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

struct Contact: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
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
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    self.isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            Button(action: {
                self.addContact()
                self.isPresented = false
            }) {
                Text("Add Contact")
                    .padding()
                    .background(Color.skyBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    func addContact() {
        let newContact = Contact(name: name, phoneNumber: phoneNumber)
        contacts.append(newContact)
    }
}
