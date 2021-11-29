//
//  SceneDelegate.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/10/8.
//

import UIKit
import GitHubAPI
import Alamofire

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    lazy var session: Session = {
        let config = URLSessionConfiguration.ephemeral
        return Session(configuration: config)
    }()
    
    convenience init(session: Session) {
        self.init()
        self.session = session
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://api.github.com/users?since=0&per_page=20")!
        
        //let loader = RemoteLoader<UserProfileURLPackage>(url: url, session: session, mapping: UserProfileMapper().map(_:))
        //let loader = PaginatedRemoteUserProfileLoader(url: url, session: session, mapping: UserProfileMapper().map(_:))
        
        let factory = { [session] in PaginatedRemoteUserProfileLoader(url: url, session: session, mapping: UserProfileMapper().map(_:)) }
        
        let imageDataLoader = RemoteImageDataLoader(session: session)
        let remoteImageDataLoaderWithCache = ImageDataLoaderCacheDecorator(decoratee: imageDataLoader)
        
        let vc = UserProfileUIComposer.make(
            onSelectProfile: showUserDetail(for:),
            userProfileLoaderFactory: factory,
            avatarImageDataLoader: remoteImageDataLoaderWithCache)
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func showUserDetail(for userProfile: UserProfile) {
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension PaginatedRemoteUserProfileLoader: UserProfileLoader {}

extension RemoteUserDetailLoader: UserDetailLoader {}
