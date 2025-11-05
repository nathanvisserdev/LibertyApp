//
//  LibertySocialApp.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import SwiftUI

@main
struct LibertySocialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    // DI
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let notificationManager: NotificationManaging
    private let feedService: FeedSession
    private let groupInviteService: GroupInviteSession
    private let groupService: GroupSession
    private let subnetService: SubnetSession
    private let commentService: CommentService

    @StateObject private var session: SessionStore
    private let appCoordinator: AppCoordinator
    private let loginCoordinator: LoginCoordinator

    @MainActor
    init() {
        let authManager = AuthService()
        let tokenProvider: TokenProviding = authManager
        let notificationManager = NotificationManager(tokenProvider: tokenProvider)
        let feedService = FeedService()
        let groupInviteService = GroupInviteService()
        let groupService = GroupService()
        let subnetService = SubnetService()
        let commentService = DefaultCommentService(auth: authManager)
        
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.notificationManager = notificationManager
        self.feedService = feedService
        self.groupInviteService = groupInviteService
        self.groupService = groupService
        self.subnetService = subnetService
        self.commentService = commentService

        _session = StateObject(
            wrappedValue: SessionStore(
                authManager: authManager,
                tokenProvider: tokenProvider,
                notificationManager: notificationManager
            )
        )

        let loginCoordinator = LoginCoordinator()
        self.loginCoordinator = loginCoordinator
        self.appCoordinator = AppCoordinator(
            loginCoordinator: loginCoordinator,
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService
        )
        defer { appDelegate.notificationManager = notificationManager }
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .environmentObject(session)
                .onAppear { Task { await session.refresh() } }
        }
    }
}

