import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white

        let mainViewController = ViewController()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // 暂停正在运行的任务
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 释放共享资源，保存用户数据
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // 还原应用程序状态
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // 重启任何暂停的任务
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // 保存数据
    }
}