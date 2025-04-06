import SwiftUI

// Model for the user profile data to send to your backend.
struct UserProfile: Codable {
    var username: String
    var email: String
    var full_name: String
    var password: String
}

struct Test: View {
    // State variables to bind to text fields.
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var full_name: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                
                // Simple text section for Name.
                Section(header: Text("Username")) {
                    TextField("Enter your username", text: $username)
                        .autocapitalization(.words)
                }
                
                // Simple text section for Email.
                Section(header: Text("Email")) {
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Simple text section for Name.
                Section(header: Text("Name")) {
                    TextField("Enter your name", text: $full_name)
                        .autocapitalization(.words)
                }
                
                // Simple text section for Password.
                Section(header: Text("Password")) {
                    SecureField("Enter your password", text: $password)
                }
                
                // Section with Submit button to update the database.
                Section {
                    Button(action: {
                        updateProfile()
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                // Display a message on completion or error.
                if !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("User Profile")
        }
    }
    
    // Function to encode the profile and send it via POST to the backend.
    func updateProfile() {
        let profile = UserProfile(username: username, email: email, full_name: full_name, password: password)
        
        // Replace the URL with your actual backend endpoint.
        guard let url = URL(string: "http://0.0.0.0:8000/users/register") else {
            message = "Invalid URL."
            return
        }
        
        // Encode the profile into JSON.
        guard let encoded = try? JSONEncoder().encode(profile) else {
            message = "Failed to encode profile."
            return
        }
        
        // Debug: Print the JSON being sent to the backend.
        if let jsonString = String(data: encoded, encoding: .utf8) {
            print("Sending JSON: \(jsonString)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        // Perform the POST request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    message = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            // Check for a valid HTTP response status.
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    message = "Profile updated successfully!"
                }
            } else {
                DispatchQueue.main.async {
                    message = "Server error. Please try again."
                }
            }
        }.resume()
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
