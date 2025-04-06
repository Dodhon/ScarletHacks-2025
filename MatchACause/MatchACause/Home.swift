import SwiftUI

struct VolunteerCard: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let urgency: String
    let commitment: String
    let tags: [String]
    let date: String
    let description: String
    let location: String
    let organization: String
}

struct Home: View {
    @State private var cards: [VolunteerCard] = [
        VolunteerCard(
            image: "soccer_referee",
            title: "Soccer Referees",
            urgency: "Needed Tomorrow",
            commitment: "Weekly",
            tags: ["Sports", "Active", "One-Day", "Sunday"],
            date: "Sunday",
            description: "Youth soccer league needs referees for weekend games. Experience preferred but training provided.",
            location: "City Sports Complex",
            organization: "Youth Sports League"
        ),
        VolunteerCard(
            image: "food_bank",
            title: "Food Bank Helper",
            urgency: "Needed This Week",
            commitment: "Flexible",
            tags: ["Community", "Indoor", "Weekend"],
            date: "Saturday",
            description: "Help sort and distribute food to families in need. Morning and afternoon shifts available.",
            location: "Community Food Bank",
            organization: "Food for All"
        ),
        VolunteerCard(
            image: "elderly_care",
            title: "Senior Companion",
            urgency: "Regular Need",
            commitment: "Weekly",
            tags: ["Healthcare", "Social", "Weekday"],
            date: "Monday-Friday",
            description: "Provide companionship and basic assistance to seniors in their homes.",
            location: "Various Locations",
            organization: "Elder Care Services"
        ),
        VolunteerCard(
            image: "beach_cleanup",
            title: "Beach Cleanup",
            urgency: "This Weekend",
            commitment: "One-Time",
            tags: ["Environment", "Outdoor", "Weekend"],
            date: "Saturday",
            description: "Join our monthly beach cleanup initiative. Equipment and refreshments provided.",
            location: "Coastal Beach",
            organization: "Clean Oceans Now"
        ),
        VolunteerCard(
            image: "animal_shelter",
            title: "Animal Shelter",
            urgency: "Ongoing Need",
            commitment: "Flexible",
            tags: ["Animals", "Care", "Daily"],
            date: "Any Day",
            description: "Help care for shelter animals, including feeding, walking, and socialization.",
            location: "City Animal Shelter",
            organization: "Paws & Care"
        ),
        VolunteerCard(
            image: "literacy_tutor",
            title: "Literacy Tutor",
            urgency: "Starting Next Week",
            commitment: "Bi-Weekly",
            tags: ["Education", "Teaching", "Weekday"],
            date: "Tuesday/Thursday",
            description: "Help adults improve their reading and writing skills. Training provided.",
            location: "Public Library",
            organization: "Literacy First"
        ),
        VolunteerCard(
            image: "homeless_shelter",
            title: "Shelter Assistant",
            urgency: "Immediate Need",
            commitment: "Flexible",
            tags: ["Community", "Social Work", "Evening"],
            date: "Any Day",
            description: "Help prepare beds, serve meals, and assist staff at local homeless shelter. Evening shifts available.",
            location: "Downtown Shelter",
            organization: "Hope Housing"
        ),
        VolunteerCard(
            image: "tech_mentor",
            title: "Tech Workshop Mentor",
            urgency: "Starting Next Month",
            commitment: "Monthly",
            tags: ["Technology", "Teaching", "Weekend"],
            date: "First Saturday",
            description: "Guide seniors through basic computer skills and internet safety. Perfect for tech-savvy volunteers.",
            location: "Community Center",
            organization: "Digital Bridge"
        ),
        VolunteerCard(
            image: "garden_helper",
            title: "Community Garden",
            urgency: "Seasonal",
            commitment: "Weekly",
            tags: ["Environment", "Outdoor", "Morning"],
            date: "Wednesday/Saturday",
            description: "Help maintain and harvest from our community garden. All produce goes to local food banks.",
            location: "Urban Gardens",
            organization: "Green Growth"
        ),
        VolunteerCard(
            image: "museum_guide",
            title: "Museum Guide",
            urgency: "Training Next Week",
            commitment: "Bi-Weekly",
            tags: ["Arts", "Education", "Weekend"],
            date: "Weekends",
            description: "Lead tours and educational programs at the city museum. Perfect for history and art enthusiasts.",
            location: "City Museum",
            organization: "Cultural Heritage"
        ),
        VolunteerCard(
            image: "youth_mentor",
            title: "Youth Mentor",
            urgency: "Ongoing Need",
            commitment: "6 Months Min",
            tags: ["Youth", "Mentoring", "Flexible"],
            date: "Flexible",
            description: "Be a positive role model for at-risk youth. Training and ongoing support provided.",
            location: "Various Schools",
            organization: "Future Leaders"
        ),
        VolunteerCard(
            image: "pet_therapy",
            title: "Pet Therapy Visit",
            urgency: "Weekly Need",
            commitment: "Weekly",
            tags: ["Animals", "Healthcare", "Afternoon"],
            date: "Weekdays",
            description: "Bring your certified therapy pet to visit patients in hospitals and nursing homes.",
            location: "Local Hospitals",
            organization: "Healing Paws"
        ),
        VolunteerCard(
            image: "food_delivery",
            title: "Meals on Wheels",
            urgency: "Daily Need",
            commitment: "Flexible",
            tags: ["Senior Care", "Driving", "Morning"],
            date: "Weekdays",
            description: "Deliver meals to homebound seniors. Must have valid driver's license and vehicle.",
            location: "City-wide",
            organization: "Senior Support"
        ),
        VolunteerCard(
            image: "festival_helper",
            title: "Cultural Festival",
            urgency: "Next Month",
            commitment: "One-Time",
            tags: ["Events", "Culture", "Weekend"],
            date: "June 15-16",
            description: "Help organize and run our annual cultural diversity festival. Various roles available.",
            location: "City Park",
            organization: "Unity Festival"
        ),
        VolunteerCard(
            image: "crisis_line",
            title: "Crisis Line Support",
            urgency: "Critical Need",
            commitment: "Monthly",
            tags: ["Mental Health", "Support", "Remote"],
            date: "Flexible",
            description: "Provide emotional support via phone/text. Comprehensive training provided. Remote opportunity.",
            location: "Remote/Virtual",
            organization: "Crisis Support Network"
        ),
        VolunteerCard(
            image: "habitat_build",
            title: "Home Builder",
            urgency: "Project-Based",
            commitment: "Weekends",
            tags: ["Construction", "Skilled", "Weekend"],
            date: "Saturdays",
            description: "Help build homes for families in need. All skill levels welcome, training provided on-site.",
            location: "Various Sites",
            organization: "Habitat for Humanity"
        )
    ]
    
    @State private var currentIndex = 0
    @State private var offset = CGSize.zero
    @State private var selectedTab = 0
    @State private var acceptedCards: [VolunteerCard] = []
    @State private var rejectedCards: [VolunteerCard] = []
    @State private var isAnimating = false
    @State private var cardRotation: Double = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var stackTransitionProgress: CGFloat = 0
    @State private var cardTransitionDirection: CGFloat = 0
    @State private var cardRemoved = false
    
    var body: some View {
        VStack(spacing: 0) {
            TopNavigationBar().padding(.bottom, 25)
            
            // Switch views based on selectedTab
            if selectedTab == 0 {
                if currentIndex < cards.count {
                    swipeableCardsView
                } else {
                    VStack {
                        EmptyStateView()
                            .padding()
                        Button(action: {
                            // If there are any rejected cards, set them as the new deck and reset index.
                            if !rejectedCards.isEmpty {
                                cards = rejectedCards
                                currentIndex = 0
                                rejectedCards = []
                            }
                        }) {
                            Text("Review Not for Me Events")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
            } else if selectedTab == 1 {
                CausesView(
                    acceptedCards: acceptedCards,
                    rejectedCards: rejectedCards
                )
            } else if selectedTab == 2 {
                // Explore page with Coming Soon message
                ZStack {
                    Color.macBackground.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                
                        Text("Explore")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.macText)
                        
                        Text("Coming Soon")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.macSecondary)
                        
                        Text("We're working on exciting new ways for you to discover volunteer opportunities and like minded poeple in your area.")
                            .font(.system(size: 16))
                            .foregroundColor(.macTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                    }
                }
            } else if selectedTab == 3 {
                ProfileView()
            }

            BottomNavigationBar(selectedTab: $selectedTab)
                .padding(.top, 10)
                .background(Color.macSurface)
        }
        .background(Color.macBackground)
    }
    
    // MARK: - Swipeable Cards
    private var swipeableCardsView: some View {
        Group {
            if currentIndex < cards.count {
                CardStackView(
                    cards: cards,
                    currentIndex: currentIndex,
                    offset: $offset,
                    isAnimating: $isAnimating,
                    cardRotation: $cardRotation,
                    cardScale: $cardScale,
                    stackTransitionProgress: $stackTransitionProgress,
                    cardTransitionDirection: $cardTransitionDirection,
                    cardRemoved: $cardRemoved,
                    onSwipe: swipeCard
                )
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                EmptyStateView()
                    .padding()
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Swiping Logic
    private func swipeCard(width: CGFloat) {
        let swipeThreshold: CGFloat = 100
        
        if abs(width) > swipeThreshold && !isAnimating {
            isAnimating = true
            
            // Determine swipe direction and set final position
            let finalOffset: CGFloat = width > 0 ? 500 : -500
            cardTransitionDirection = width > 0 ? 1 : -1
            
            // Animate the card off screen
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                offset.width = finalOffset
                cardRotation = width > 0 ? 15 : -15
                cardScale = 0.9
            }
            
            // Handle acceptance/rejection
            if currentIndex < cards.count {
                if width > 0 {
                    acceptedCards.append(cards[currentIndex])
                } else {
                    rejectedCards.append(cards[currentIndex])
                }
            }
            
            // Move to next card after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if currentIndex < cards.count {
                    currentIndex += 1
                }
                
                offset = .zero
                cardRotation = 0
                cardScale = 1.0
                stackTransitionProgress = 0
                cardRemoved = false
                
                isAnimating = false
            }
        } else {
            // Return card to center if not swiped far enough
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                offset = .zero
                cardRotation = 0
                cardScale = 1.0
            }
        }
    }
}

// MARK: - Top Navigation
struct TopNavigationBar: View {
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.macSurface)
                .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
                .edgesIgnoringSafeArea(.top)
            
            // Content
            VStack(spacing: 0) {
                Text("Match A Cause")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.macPrimary)
            }
            .frame(height: 60)
            .padding(.top, 20)
        }
        .frame(height: 60)
    }
}

// MARK: - Card Stack
struct CardStackView: View {
    let cards: [VolunteerCard]
    let currentIndex: Int
    @Binding var offset: CGSize
    @Binding var isAnimating: Bool
    @Binding var cardRotation: Double
    @Binding var cardScale: CGFloat
    @Binding var stackTransitionProgress: CGFloat
    @Binding var cardTransitionDirection: CGFloat
    @Binding var cardRemoved: Bool
    let onSwipe: (CGFloat) -> Void
    
    var body: some View {
        ZStack {
            ForEach(cards.indices.reversed(), id: \.self) { index in
                if index >= currentIndex && index <= currentIndex + 2 {
                    CardStackItem(
                        card: cards[index],
                        isTopCard: index == currentIndex,
                        cardOffset: CGFloat(index - currentIndex),
                        offset: $offset,
                        isAnimating: $isAnimating,
                        cardRotation: $cardRotation,
                        cardScale: $cardScale,
                        stackTransitionProgress: $stackTransitionProgress,
                        cardTransitionDirection: $cardTransitionDirection,
                        cardRemoved: $cardRemoved,
                        onSwipe: onSwipe
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CardStackItem: View {
    let card: VolunteerCard
    let isTopCard: Bool
    let cardOffset: CGFloat
    @Binding var offset: CGSize
    @Binding var isAnimating: Bool
    @Binding var cardRotation: Double
    @Binding var cardScale: CGFloat
    @Binding var stackTransitionProgress: CGFloat
    @Binding var cardTransitionDirection: CGFloat
    @Binding var cardRemoved: Bool
    let onSwipe: (CGFloat) -> Void
    
    var body: some View {
        CardView(card: card)
            .offset(isTopCard ? offset : .zero)
            .rotationEffect(.degrees(isTopCard ? cardRotation : 0))
            .zIndex(isTopCard ? 1 : 0)
            .scaleEffect(isTopCard ? cardScale : 1.0)
            .opacity(isTopCard && cardRemoved && abs(offset.width) > 50 ? 0 : 1)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if isTopCard && !isAnimating {
                            offset = gesture.translation
                            cardRotation = Double(gesture.translation.width / 30)
                            cardScale = 1.0 - abs(gesture.translation.width) / 2000
                        }
                    }
                    .onEnded { gesture in
                        if isTopCard && !isAnimating {
                            onSwipe(gesture.translation.width)
                        }
                    }
            )
            .overlay(SwipeOverlay(isTopCard: isTopCard, offset: offset))
    }
}

// MARK: - Swipe Overlays
struct SwipeOverlay: View {
    let isTopCard: Bool
    let offset: CGSize
    
    var body: some View {
        ZStack {
            // NO overlay
            Text("Not for Me")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.macError)
                .padding(20)
                .border(Color.macError, width: 4)
                .rotationEffect(.degrees(-30))
                .opacity(
                    offset.width < -20 && isTopCard ?
                    Double(-offset.width / 100) : 0
                )
            
            // YES overlay
            Text("Learn More")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.macSuccess)
                .padding(20)
                .border(Color.macSuccess, width: 4)
                .rotationEffect(.degrees(30))
                .opacity(
                    offset.width > 20 && isTopCard ?
                    Double(offset.width / 100) : 0
                )
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.macPrimary)
            Text("You're all caught up!")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.macText)
            Text("Check back later for more opportunities")
                .foregroundColor(.macTextSecondary)
        }
    }
}

// MARK: - Bottom Navigation
struct BottomNavigationBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(image: "bolt", title: "Swipes", isSelected: selectedTab == 0)
                .onTapGesture { selectedTab = 0 }
            TabButton(image: "list.bullet", title: "Causes", isSelected: selectedTab == 1)
                .onTapGesture { selectedTab = 1 }
            TabButton(image: "magnifyingglass", title: "Explore", isSelected: selectedTab == 2)
                .onTapGesture { selectedTab = 2 }
            TabButton(image: "person", title: "Profile", isSelected: selectedTab == 3)
                .onTapGesture { selectedTab = 3 }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let image: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: image)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
        }
        .foregroundColor(isSelected ? Color.macPrimary : .macTextSecondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Sample for SavedListView or Re-Usable
struct SavedListView: View {
    let cards: [VolunteerCard]
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(cards) { card in
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.title)
                        .font(.system(size: 20, weight: .bold))
                    
                    Text(card.organization)
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                    
                    Text(card.description)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text(card.location)
                    }
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(card.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.9, green: 0.95, blue: 1.0))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// MARK: - The Main Card View
struct CardView: View {
    let card: VolunteerCard
    @State private var imageLoadError = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if !imageLoadError {
                Image(card.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .onAppear {
                        if UIImage(named: card.image) == nil {
                            imageLoadError = true
                        }
                    }
            } else {
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.macPrimary.opacity(0.9),
                                    Color.macPrimary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    ForEach(0..<20) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .offset(
                                x: CGFloat.random(in: -200...200),
                                y: CGFloat.random(in: -400...400)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Bottom gradient overlay and content
            VStack(spacing: 0) {
                // Black gradient overlay for better text visibility
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.black.opacity(0),
                            Color.black.opacity(0.7)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                
                // Card information
                VStack(spacing: 16) {
                    // Title & Urgency
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.macText)
                        
                        HStack {
                            Text(card.organization)
                                .font(.system(size: 16))
                                .foregroundColor(.macTextSecondary)
                            
                            Spacer()
                            
                            Text(card.urgency)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(card.urgency.contains("Tomorrow") || card.urgency.contains("Immediate") ? Color.macSecondary : Color.macPrimary)
                                .cornerRadius(12)
                        }
                    }
                    
                    // Description
                    Text(card.description)
                        .font(.system(size: 16))
                        .foregroundColor(.macText)
                        .lineLimit(3)
                    
                    Divider()
                        .background(Color.macDivider)
                    
                    // Details
                    HStack(spacing: 16) {
                        // Location
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                            Text(card.location)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.macPrimary)
                        
                        Spacer()
                        
                        // Date
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                            Text(card.date)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.macTextSecondary)
                    }
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(card.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.macPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.macTagBackground)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.macSurface)
            }
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}

// MARK: - Preview
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
