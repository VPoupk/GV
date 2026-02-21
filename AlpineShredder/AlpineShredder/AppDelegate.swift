import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = StartViewController()
        window?.makeKeyAndVisible()

        #if targetEnvironment(macCatalyst)
        configureMacWindow()
        #endif

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if GameManager.shared.state == .playing {
            GameManager.shared.pauseGame()
        }
    }

    #if targetEnvironment(macCatalyst)
    private func configureMacWindow() {
        guard let windowScene = window?.windowScene else { return }

        windowScene.title = "Alpine Shredder"

        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .visible
            titlebar.toolbarStyle = .unified
        }

        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 700)
        windowScene.sizeRestrictions?.maximumSize = CGSize(width: 600, height: 1000)
    }

    override func buildMenu(with builder: any UIMenuBuilder) {
        super.buildMenu(with: builder)

        // Remove menus that don't apply to this game
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
    }
    #endif
}
