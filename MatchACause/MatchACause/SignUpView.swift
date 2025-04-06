import SwiftUI
import Combine

// MARK: - Keyboard Dismiss Extension
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// Updated struct including new fields: address, dob, and embedding
struct UserSignUp: Codable {
    var username: String
    var email: String
    var password: String
    var full_name: String
    var address: String
    var dob: String
    var embedding: [Float]
}

// MARK: - SelectableButton Component
struct SelectableButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ?
                    Color(red: 0.0, green: 0.48, blue: 1.0) :
                    Color(red: 0.92, green: 0.92, blue: 0.92))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Page/Flow Management
    @State private var currentPage = 0
    
    // Error Handling
    @State private var registrationError = ""
    
    // Page 0 (Account)
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordError = ""
    
    // Page 1 (Personal Info)
    @State private var fullName = ""
    @State private var address = ""
    @State private var birthDate = Date()
    
    // Page 2 (Availability)
    @State private var selectedDays: Set<String> = []
    @State private var selectedTimes: Set<String> = []
    
    // Page 3 (Interests)
    @State private var selectedInterests: Set<String> = []
    
    let interests = [
        "Education", "Environment", "Healthcare", "Animal Welfare",
        "Arts & Culture", "Community", "Social Justice", "Youth",
        "Elderly Care", "Disaster Relief", "Food Security", "Mental Health"
    ]
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday",
                      "Friday", "Saturday", "Sunday"]
    
    let timeSlots = [
        "Morning (8AM-12PM)", "Afternoon (12PM-4PM)",
        "Evening (4PM-8PM)", "Night (8PM-12AM)"
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Title and Progress
                VStack(spacing: 4) {
                    Text("Match A Cause")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                    
                    ProgressView(value: Double(currentPage), total: 4)
                        .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .padding(.top, 60)
                
                // Content Pages wrapped in ScrollView with extra bottom padding
                TabView(selection: $currentPage) {
                    ScrollView {
                        accountDetailsView
                            .padding(.bottom, 100)
                    }
                    .tag(0)
                    
                    ScrollView {
                        personalInfoView
                            .padding(.bottom, 100)
                    }
                    .tag(1)
                    
                    ScrollView {
                        availabilityView
                            .padding(.bottom, 100)
                    }
                    .tag(2)
                    
                    ScrollView {
                        interestsView
                            .padding(.bottom, 100)
                    }
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Display any registration error
                if !registrationError.isEmpty {
                    Text(registrationError)
                        .foregroundColor(.red)
                        .font(.system(size: 15))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                }
                
                // Navigation Buttons (fixed at bottom)
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            currentPage -= 1
                            hideKeyboard()
                        }) {
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                    }
                    
                    Button(action: {
                        handleNextButton()
                        hideKeyboard()
                    }) {
                        Text(currentPage == 3 ? "Complete" : "Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }
}

// MARK: - Navigation & Registration
extension SignUpView {
    private func handleNextButton() {
        if currentPage == 0 {
            if password != confirmPassword {
                passwordError = "Passwords are not the same"
                return
            } else {
                passwordError = ""
            }
        }
        
        if currentPage < 3 {
            currentPage += 1
        } else {
            registerUser()
        }
    }
    
    private func registerUser() {
        registrationError = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateFormatter.string(from: birthDate)
        
        // Compute embedding from the interests selection.
        // Order is preserved by mapping over the interests array.
        let embedding = interests.map { selectedInterests.contains($0) ? Float(1.0) : Float(0.0) }
        
        let signUpPayload = UserSignUp(
            username: username,
            email: email,
            password: password,
            full_name: fullName,
            address: address,
            dob: dobString,
            embedding: embedding
        )
        
        guard let url = URL(string: "http://104.194.124.191:8000/users/register") else {
            registrationError = "Invalid URL."
            return
        }
        
        guard let encoded = try? JSONEncoder().encode(signUpPayload) else {
            registrationError = "Failed to encode signup data."
            return
        }
        
        if let jsonString = String(data: encoded, encoding: .utf8) {
            print("Sending JSON: \(jsonString)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.registrationError = "Error: \(error.localizedDescription)"
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.registrationError = "No response from server."
                }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.dismiss()
                }
            } else {
                if let data = data,
                   let serverMessage = String(data: data, encoding: .utf8),
                   !serverMessage.isEmpty {
                    DispatchQueue.main.async {
                        self.registrationError = "Server error: \(serverMessage)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.registrationError = "Registration failed. Status code \(httpResponse.statusCode)."
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Subviews for Each Page
extension SignUpView {
    private var accountDetailsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Create Account")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    TextField("Choose your username", text: $username)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    TextField("Enter your email", text: $email)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    SecureField("Create a password", text: $password)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .cornerRadius(8)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Confirm Password")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    SecureField("Confirm your password", text: $confirmPassword)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .cornerRadius(8)
                }
            }
            if !passwordError.isEmpty {
                Text(passwordError)
                    .foregroundColor(.red)
                    .font(.system(size: 15))
            }
            Spacer()
        }
        .padding(24)
    }
    
    private var personalInfoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Personal Information")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Name")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    TextField("Enter your full name", text: $fullName)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .cornerRadius(8)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Address")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    TextField("Enter your address", text: $address)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .cornerRadius(8)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Date of Birth")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                    HStack {
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 0.92, green: 0.92, blue: 0.92))
                    .cornerRadius(8)
                }
            }
            Spacer()
        }
        .padding(24)
    }
    
    private var availabilityView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Availability")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Days")
                            .foregroundColor(.gray)
                            .font(.system(size: 17))
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                SelectableButton(title: day, isSelected: selectedDays.contains(day)) {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preferred Time Slots")
                            .foregroundColor(.gray)
                            .font(.system(size: 17))
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                            ForEach(timeSlots, id: \.self) { timeSlot in
                                SelectableButton(title: timeSlot, isSelected: selectedTimes.contains(timeSlot)) {
                                    if selectedTimes.contains(timeSlot) {
                                        selectedTimes.remove(timeSlot)
                                    } else {
                                        selectedTimes.insert(timeSlot)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .padding(24)
    }
    
    private var interestsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Interests")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Text("Select causes you're passionate about")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(interests, id: \.self) { interest in
                        SelectableButton(title: interest, isSelected: selectedInterests.contains(interest)) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(24)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
