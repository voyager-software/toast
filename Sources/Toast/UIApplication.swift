import UIKit

public extension UIApplication {
    var windowScene: UIWindowScene? {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.session.role == .windowApplication }
    }

    var appWindow: UIWindow? {
        self.windowScene?.keyWindow
    }

    #if os(iOS)
    var interfaceOrientation: UIInterfaceOrientation {
        self.windowScene?.interfaceOrientation ?? .unknown
    }
    #endif
}
