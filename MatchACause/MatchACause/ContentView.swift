import SwiftUI

struct Language: Identifiable {
    let id = UUID()
    let name: String
    let code: String
}

// Model to decode the token response from your FastAPI backend
struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

struct ContentView: View {
    @State private var emailOrUsername: String = ""
    @State private var password: String = ""
    @State private var showLanguageSelector = false
    @State private var selectedLanguage = "EN"
    @State private var showSignUp = false
    @State private var showHome = false
    
    // Error message displayed if sign-in fails
    @State private var signInError: String = ""
    
    let languages = [
        Language(name: "English", code: "EN"),
        Language(name: "Español", code: "ES"),
        Language(name: "हिंदी", code: "HI"),
        Language(name: "中文", code: "ZH"),
        Language(name: "Français", code: "FR"),
        Language(name: "Deutsche", code: "DE"),
        Language(name: "日本語", code: "JP")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.macBackground.ignoresSafeArea()
                
                VStack(spacing: 28) {
                    // App Title
                    Text("Match A Cause")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.macPrimary)
                        .padding(.top, 60)
                    
                    // Subtitle
                    Text("Swipe Right to\nMake a Difference")
                        .font(.system(size: 22, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.macTextSecondary)
                        .padding(.top, 4)
                        .padding(.bottom, 32)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .foregroundColor(.macTextSecondary)
                                .font(.system(size: 17, weight: .medium))
                            TextField("Username", text: $emailOrUsername)
                                .font(.system(size: 17))
                                .padding()
                                .background(Color.macSurface)
                                .foregroundColor(.macText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.macDivider, lineWidth: 1)
                                )
                                .autocapitalization(.none)
                                .keyboardType(.default)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .foregroundColor(.macTextSecondary)
                                .font(.system(size: 17, weight: .medium))
                            SecureField("••••••••", text: $password)
                                .font(.system(size: 17))
                                .padding()
                                .background(Color.macSurface)
                                .foregroundColor(.macText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.macDivider, lineWidth: 1)
                                )
                        }
                        
                        // Sign In Button
                        Button(action: {
                            signInError = ""  // Clear old error
                            signIn()
                        }) {
                            Text("Sign in")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.macPrimary)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        
                        // Error message if sign-in fails
                        if !signInError.isEmpty {
                            Text(signInError)
                                .foregroundColor(.macError)
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                                .padding(.top, 2)
                        }
                    }
                    .padding(24)
                    .background(Color.macSurface)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Sign Up Link
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Don't Have an Account? Sign up")
                            .foregroundColor(.macPrimary)
                            .font(.system(size: 17, weight: .medium))
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Language Toggle
                    Button(action: {
                        showLanguageSelector = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .foregroundColor(.macTextSecondary)
                            Text(selectedLanguage)
                                .foregroundColor(.macTextSecondary)
                                .font(.system(size: 17))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.macSurface)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.macDivider, lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 30)
                }
                .navigationBarHidden(true)
                .fullScreenCover(isPresented: $showSignUp) {
                    SignUpView()
                }
                .fullScreenCover(isPresented: $showHome) {
                    Home()
                }
                
                // Language Selection Overlay
                if showLanguageSelector {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showLanguageSelector = false
                        }
                    
                    VStack(spacing: 0) {
                        ForEach(languages) { language in
                            Button(action: {
                                selectedLanguage = language.code
                                showLanguageSelector = false
                            }) {
                                HStack {
                                    Text(language.name)
                                        .foregroundColor(.macText)
                                        .font(.system(size: 17))
                                    Spacer()
                                    Text(language.code)
                                        .foregroundColor(.macTextSecondary)
                                        .font(.system(size: 17))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    selectedLanguage == language.code ?
                                    Color.macTagBackground : Color.macSurface
                                )
                            }
                            
                            if language.id != languages.last?.id {
                                Divider()
                                    .background(Color.macDivider)
                            }
                        }
                    }
                    .background(Color.macSurface)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
                    .padding(.horizontal, 50)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showLanguageSelector)
                }
            }
        }
    }
}

// MARK: - Networking
extension ContentView {
    func signIn() {
        // Build your form-data body for login
        let bodyString = "username=\(emailOrUsername)&password=\(password)"
        let bodyData = bodyString.data(using: .utf8) ?? Data()
        
        guard let url = URL(string: "http://104.194.124.191:8000/token") else {
            signInError = "Invalid URL."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    signInError = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    signInError = "Incorrect username or password. Try again."
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                DispatchQueue.main.async {
                    // Save the token and username from login
                    SessionManager.shared.accessToken = tokenResponse.access_token
                    SessionManager.shared.username = emailOrUsername
                    showHome = true // or navigate accordingly
                }
            } catch {
                DispatchQueue.main.async {
                    signInError = "Failed to parse token response."
                }
            }
        }.resume()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
