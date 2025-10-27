//
//  GroupDetailViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation
import Combine

@MainActor
final class GroupDetailViewModel: ObservableObject {
    @Published var groupDetail: GroupDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isJoining: Bool = false
    @Published var joinSuccessMessage: String?
    
    private let groupId: String
    
    init(groupId: String) {
        self.groupId = groupId
    }
    
    func fetchGroupDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await GroupDetailModel.fetchGroupDetail(groupId: groupId)
            groupDetail = detail
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching group detail: \(error)")
        }
        
        isLoading = false
    }
    
    func joinGroup() async {
        isJoining = true
        errorMessage = nil
        joinSuccessMessage = nil
        
        do {
            try await GroupDetailModel.joinGroup(groupId: groupId)
            joinSuccessMessage = "Join request sent."
            
            // Refresh group details to update membership status
            await fetchGroupDetail()
        } catch {
            errorMessage = error.localizedDescription
            print("Error joining group: \(error)")
        }
        
        isJoining = false
    }
}
