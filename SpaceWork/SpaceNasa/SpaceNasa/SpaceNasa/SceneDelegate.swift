//
//  SceneDelegate.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // ADD: Onboarding'in tek sefer denenmesi için bayrak
    private var didAttemptOnboarding = false
    // ADD: İlk kullanımda gösterildi mi kalıcılığı
    private let onboardingPersistence = UserDefaultsOnboardingPersistence()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        // ADD: Pencere hazırlandıktan sonra bir sonraki döngüde onboarding'i dene
        DispatchQueue.main.async { [weak self] in
            self?.presentOnboardingIfNeeded()
        }
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

        // ADD: Soğuk başlatma dışındaki aktifleştirmelerde de bir kere dene
        if !didAttemptOnboarding {
            DispatchQueue.main.async { [weak self] in
                self?.presentOnboardingIfNeeded()
            }
        }
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

    // ADD: Onboarding sunumu (Presenter kaldırıldı; doğrudan VC ile göster)
    private func presentOnboardingIfNeeded() {
        guard !didAttemptOnboarding else { return }
        guard onboardingPersistence.hasSeen == false else { return }
        didAttemptOnboarding = true

        guard let top = topMostViewController(from: window?.rootViewController) else { return }
        let ob = OnboardingViewController()
        ob.modalPresentationStyle = .fullScreen
        top.present(ob, animated: true)
    }

    // ADD: Görünür (top-most) VC'yi bul (Nav/Tab/present zincirlerini çözer)
    private func topMostViewController(from root: UIViewController?) -> UIViewController? {
        if let nav = root as? UINavigationController {
            return topMostViewController(from: nav.visibleViewController ?? nav.topViewController)
        }
        if let tab = root as? UITabBarController {
            return topMostViewController(from: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topMostViewController(from: presented)
        }
        return root
    }
}
