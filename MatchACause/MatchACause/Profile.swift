import SwiftUI
import Foundation

// MARK: - Data Model
struct ProfileData: Codable {
    let email: String
    let fullName: String
    let address: String?
    let dob: String?
    let embedding: [Float]?

    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case address
        case dob
        case embedding
    }
}

// MARK: - Session Manager
class SessionManager: ObservableObject {
    static let shared = SessionManager()
    @Published var username: String? // Must be set during login
    @Published var accessToken: String? // Must be set during login

    private init() {}
}

// MARK: - ViewModel
class ProfileViewModel: ObservableObject {
    @Published var profileData: ProfileData?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    private let username: String
    private let accessToken: String

    init(username: String, accessToken: String) {
        self.username = username
        self.accessToken = accessToken
        print("Fetching profile for username: \(username)") // Debug log
    }

    func fetchProfile() {
        if username.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Username is missing. Please log in again."
            }
            return
        }
        
        guard let url = URL(string: "http://104.194.124.191:8000/users/\(username)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid endpoint."
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Uncomment the following lines if your backend requires an Authorization header
        // if !accessToken.isEmpty {
        //     request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // }
        
        isLoading = true
        errorMessage = ""

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            // Debug: Print the raw JSON response
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "No response from server."
                }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode), let data = data {
                do {
                    let profile = try JSONDecoder().decode(ProfileData.self, from: data)
                    DispatchQueue.main.async {
                        self.profileData = profile
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode profile JSON: \(error.localizedDescription)"
                    }
                }
            } else {
                if let data = data,
                   let serverMessage = String(data: data, encoding: .utf8),
                   !serverMessage.isEmpty {
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error: \(serverMessage)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Request failed with status code \(httpResponse.statusCode)."
                    }
                }
            }
        }.resume()
    }
}

// MARK: - ProfileView
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var navigateToLogin = false

    // Initialize ProfileView using saved values from SessionManager
    init() {
        let username = SessionManager.shared.username ?? ""
        let token = SessionManager.shared.accessToken ?? ""
        _viewModel = StateObject(wrappedValue: ProfileViewModel(username: username, accessToken: token))
    }

    // Fixed order of interests (must match embedding length)
    let interestList = ["Education", "Environment", "Healthcare", "Animal Welfare", "Arts & Culture", "Community", "Social Justice", "Youth", "Elderly Care", "Disaster Relief", "Food Security", "Mental Health"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.macBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        if viewModel.isLoading {
                            ProgressView("Loading Profile...")
                                .foregroundColor(.macPrimary)
                                .padding()
                        } else if let data = viewModel.profileData {
                            VStack(spacing: 20) {
                                // Profile Header
                                VStack(spacing: 16) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.macPrimary)
                                    
                                    Text(data.fullName)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.macText)
                                    
                                    Text(data.email)
                                        .font(.system(size: 16))
                                        .foregroundColor(.macTextSecondary)
                                        .padding(.top, 2)
                                        
                                    if (data.address == nil || data.address?.isEmpty == true) && (data.dob == nil || data.dob?.isEmpty == true) {
                                        Text("Complete your profile by adding your address and date of birth")
                                            .font(.system(size: 14))
                                            .foregroundColor(.macSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                            .padding(.top, 8)
                                    }
                                }
                                .padding(.top, 30)
                                .padding(.bottom, 10)
                                
                                // Profile Information Card
                                VStack(spacing: 0) {
                                    ProfileInfoRow(label: "Username", value: SessionManager.shared.username ?? "")
                                    Divider().background(Color.macDivider)
                                    ProfileInfoRow(label: "Email", value: data.email)
                                    Divider().background(Color.macDivider)
                                    ProfileInfoRow(label: "Full Name", value: data.fullName)
                                    
                                    if data.address == nil || data.address?.isEmpty == true || data.dob == nil || data.dob?.isEmpty == true {
                                        Divider().background(Color.macDivider)
                                        Button(action: {
                                            // Navigate to profile edit view if needed
                                        }) {
                                            HStack {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.macPrimary)
                                                Text("Edit Profile Details")
                                                    .foregroundColor(.macPrimary)
                                                    .font(.system(size: 16, weight: .medium))
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                                .background(Color.macSurface)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                
                                // Interests Section
                                if let embedding = data.embedding, embedding.count == interestList.count {
                                    let selected = zip(interestList, embedding)
                                        .filter { $0.1 == 1.0 }
                                        .map { $0.0 }
                                    if !selected.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Interests")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.macText)
                                            Text(selected.joined(separator: ", "))
                                                .font(.system(size: 16))
                                                .foregroundColor(.macTextSecondary)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.macSurface)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    }
                                }
                                
                                // Settings Section
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Settings")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.macText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    
                                    Divider().background(Color.macDivider)
                                    
                                    NavigationLink(destination: SettingsView()) {
                                        HStack {
                                            Image(systemName: "gear")
                                                .foregroundColor(.macPrimary)
                                            Text("App Settings")
                                                .foregroundColor(.macText)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.macTextSecondary)
                                                .font(.system(size: 14))
                                        }
                                        .padding(16)
                                    }
                                    
                                    Divider().background(Color.macDivider)
                                    
                                    Button(action: {
                                        // Clear session data
                                        SessionManager.shared.username = nil
                                        SessionManager.shared.accessToken = nil
                                        navigateToLogin = true
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.right.square")
                                                .foregroundColor(.macError)
                                            Text("Sign Out")
                                                .foregroundColor(.macError)
                                            Spacer()
                                        }
                                        .padding(16)
                                    }
                                }
                                .background(Color.macSurface)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        } else {
                            Text("No profile found.")
                                .foregroundColor(.macTextSecondary)
                        }
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.macError)
                                .padding()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchProfile()
            }
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            ContentView() // Replace with your login view
        }
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.macTextSecondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.macText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - SettingsView (Placeholder)
struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.macBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Account")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.macText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    Divider().background(Color.macDivider)
                    SettingsRow(icon: "lock", title: "Change Password")
                    Divider().background(Color.macDivider)
                    SettingsRow(icon: "creditcard", title: "Manage Subscription")
                }
                .background(Color.macSurface)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Notifications")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.macText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    Divider().background(Color.macDivider)
                    SettingsRow(icon: "bell", title: "Push Notifications")
                    Divider().background(Color.macDivider)
                    SettingsRow(icon: "envelope", title: "Email Preferences")
                }
                .background(Color.macSurface)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.macPrimary)
                .frame(width: 24, height: 24)
            Text(title)
                .foregroundColor(.macText)
                .font(.system(size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.macTextSecondary)
                .font(.system(size: 14))
        }
        .padding(16)
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SessionManager.shared.username = "exampleUser"
        SessionManager.shared.accessToken = "exampleToken"
        return ProfileView()
    }
}
