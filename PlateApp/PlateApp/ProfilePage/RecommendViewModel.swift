import Foundation
import FirebaseFirestore

class RecommendationViewModel: ObservableObject {
    @Published var suggestedUsers: [UserProfile] = []
    private var db = Firestore.firestore()
    @Published var incomingRequests: [UserProfile] = []
    
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
            
            print(excludedIDs)
            print(currentUserID)
            
            // 2. Fetch a batch of users (fetching 50 to ensure we have enough after filtering)
            let userSnapshot = try await db.collection("users")
                .limit(to: 50)
                .getDocuments()
            
            // 3. Filter out excluded IDs and limit to 5
            self.suggestedUsers = userSnapshot.documents.compactMap { doc -> UserProfile? in
                let user = try? doc.data(as: UserProfile.self)
                if let id = user?.id, !excludedIDs.contains(id) {
                    print(id)
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
            "recipientID": targetID,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("friendships").document(docID).setData(data)
        
        // Remove from UI immediately for that "snappy" feel
        self.suggestedUsers.removeAll(where: { $0.id == targetID })
    }
    
    @MainActor
    func fetchRequests(currentUserID: String) async {
        do {
            // Use arrayContains on userIDs to avoid any need for a composite index on recipientID + status
            let friendshipSnapshot = try await db.collection("friendships")
                .whereField("userIDs", arrayContains: currentUserID)
                .getDocuments()
            
            let pendingDocs = friendshipSnapshot.documents.filter { doc in
                let data = doc.data()
                let status = data["status"] as? String
                let recipientID = data["recipientID"] as? String
                return status == "pending" && recipientID == currentUserID
            }
            
            let senderIDs = pendingDocs.compactMap { $0.data()["senderID"] as? String }
            
            if senderIDs.isEmpty {
                        self.incomingRequests = []
                        print("empty sender ids")
                        return
                    }
            
            print("Sender IDs found: \(senderIDs)")
            let usersSnapshot = try await db.collection("users")
                        .whereField(FieldPath.documentID(), in: senderIDs)
                        .getDocuments()
            
            
            let profiles = usersSnapshot.documents.compactMap { document -> UserProfile? in
                        try? document.data(as: UserProfile.self)
                    }
            
            self.incomingRequests = profiles
    
        } catch {
            print("Error fetching requests: \(error.localizedDescription)")
        }

    }
    
    
    @MainActor
    func acceptRequest(currentUserID: String, targetID: String) async {
        let updatePayload: [String: Any] = ["status": "accepted"]
        
        do {
            // Using your deterministic ID logic from sendRequest
            let docID = [currentUserID, targetID].sorted().joined(separator: "_")
            let docRef = db.collection("friendships").document(docID)
            
            try await docRef.updateData(updatePayload)
            
            self.incomingRequests.removeAll(where: { $0.id == targetID })
            
            print("friendship added successfully")
            
        } catch {
            print("error accepting friend request: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func declineRequest(currentUserID: String, targetID: String) async {
        
        do {
            // Using your deterministic ID logic from sendRequest
            let docID = [currentUserID, targetID].sorted().joined(separator: "_")
            let docRef = db.collection("friendships").document(docID)
            
            try await docRef.delete()
            
            self.incomingRequests.removeAll(where: { $0.id == targetID })
            
            print("friendship removed successfully")
            
        } catch {
            print("error declining friend request: \(error.localizedDescription)")
        }
    }
}
