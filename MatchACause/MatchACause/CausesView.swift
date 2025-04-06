import SwiftUI

struct CausesView: View {
    let acceptedCards: [VolunteerCard]
    let rejectedCards: [VolunteerCard]
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                CausesTabButton(
                    title: "Not for Me",
                    count: rejectedCards.count,
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                CausesTabButton(
                    title: "Learn More",
                    count: acceptedCards.count,
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                // Not for Me
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(rejectedCards) { card in
                            CauseCard(card: card, type: .passed)
                        }
                    }
                    .padding()
                }
                .tag(0)
                
                // Learn More
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(acceptedCards) { card in
                            CauseCard(card: card, type: .liked)
                        }
                    }
                    .padding()
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.macBackground)
    }
}

struct CausesTabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("\(count)")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSelected ? Color.macPrimary.opacity(0.15) : Color.macTextSecondary.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Rectangle()
                    .fill(isSelected ? Color.macPrimary : Color.clear)
                    .frame(height: 2)
            }
            .foregroundColor(isSelected ? Color.macPrimary : .macTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CauseCard: View {
    let card: VolunteerCard
    let type: CardType
    @Environment(\.openURL) var openURL
    
    enum CardType {
        case liked
        case passed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.macText)
                    
                    Text(card.organization)
                        .font(.system(size: 15))
                        .foregroundColor(.macTextSecondary)
                }
                
                Spacer()
                
                // Status Badge
                Text(type == .liked ? "Learn More" : "Not for Me")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(type == .liked ? .white : .macTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(type == .liked ? Color.macPrimary : Color.macTextSecondary.opacity(0.15))
                    .cornerRadius(12)
            }
            
            // Description
            Text(card.description)
                .font(.system(size: 15))
                .foregroundColor(.macTextSecondary)
                .lineLimit(2)
            
            // Details
            HStack(spacing: 16) {
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                    Text(card.location)
                }
                .font(.system(size: 14))
                .foregroundColor(.macPrimary)
                
                // Date
                HStack(spacing: 4) {
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
        .padding()
        .background(Color.macSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        // Tapping on the card opens the Rick Astley URL
        .onTapGesture {
            if let url = URL(string: "https://news.sophos.com/wp-content/uploads/2016/03/rickastley.jpg?w=640") {
                openURL(url)
            }
        }
    }
}

struct CausesView_Previews: PreviewProvider {
    static var previews: some View {
        CausesView(
            acceptedCards: [
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
                )
            ],
            rejectedCards: [
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
                )
            ]
        )
    }
}
