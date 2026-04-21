import Foundation
import FirebaseFirestore

class RecommendationViewModel: ObservableObject {
    @Published var suggestedUsers: [UserProfile] = []
    private var db = Firestore.firestore()
    
    @MainActor
    func fetchRecommendations(currentUserID: String) async {
        do {
            // 1. Get all existing relationships (Friends + Pending)
            let friendshipSnapshot = try await db.collection("friendships")
                .whereField("userIDs", arrayContains: currentUserID)
                .getDocuments()
            
            var excludedIDs: Set<String> = [currentUserID] // Don't suggest yourself
            
            for doc in friendshipSnapshot.documents {
                if let ids = doc.data()["userIDs"] as? [String] {
                    for id in ids { excludedIDs.insert(id) }
                }
            }
            
            // 2. Fetch a batch of users (fetching 50 to ensure we have enough after filtering)
            let userSnapshot = try await db.collection("users")
                .limit(to: 50)
                .getDocuments()
            
            // 3. Filter out excluded IDs and limit to 5
            self.suggestedUsers = userSnapshot.documents.compactMap { doc -> UserProfile? in
                let user = try? doc.data(as: UserProfile.self)
                if let id = user?.id, !excludedIDs.contains(id) {
                    return user
                }
                return nil
            }.prefix(5).map { $0 } // Take only the first 5
            
        } catch {
            print("Error fetching recommendations: \(error.localizedDescription)")
        }
    }
    
    func sendRequest(from myID: String, to targetUser: UserProfile) {
        guard let targetID = targetUser.id else { return }
        
        // Using your deterministic ID logic
        let docID = [myID, targetID].sorted().joined(separator: "_")
        
        let data: [String: Any] = [
            "userIDs": [myID, targetID],
            "senderID": myID,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("friendships").document(docID).setData(data)
        
        // Remove from UI immediately for that "snappy" feel
        self.suggestedUsers.removeAll(where: { $0.id == targetID })
    }
}
