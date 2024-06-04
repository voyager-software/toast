import UIKit

extension UIApplication {
    var appScene: UIWindowScene? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            .compactMap { $0 as? UIWindowScene }
            .first
    }
    
    var appWindow: UIWindow? {
        self.appScene?.windows.first { $0.isKeyWindow }
    }
    
    #if os(iOS)
    var interfaceOrientation: UIInterfaceOrientation {
        self.appScene?.interfaceOrientation ?? .unknown
    }
    #endif
}
