//
//  TabBarFinder.swift
//  Toast
//
//  Created by Gábor Sajó on 2026-02-17.
//

import UIKit

@MainActor
enum TabBarFinder {
    // MARK: Internal

    static func findTabBar(in view: UIView) -> UITabBar? {
        // If view is already a window, search its hierarchy directly
        if view is UIWindow {
            return self.findTabBarInHierarchy(view: view)
        }

        // Walk up the responder chain to find a view controller
        var responder: UIResponder? = view
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                // Check if this VC is in a tab bar controller
                if let tabBarController = viewController.tabBarController {
                    return tabBarController.tabBar
                }
                // Check if this VC itself is a tab bar controller
                if let tabBarController = viewController as? UITabBarController {
                    return tabBarController.tabBar
                }
            }
            responder = nextResponder
        }

        // Fallback: search the view hierarchy for a tab bar
        if let window = view.window {
            return self.findTabBarInHierarchy(view: window)
        }

        return nil
    }

    // MARK: Private

    private static func findTabBarInHierarchy(view: UIView) -> UITabBar? {
        if let tabBar = view as? UITabBar {
            return tabBar
        }

        for subview in view.subviews {
            if let found = findTabBarInHierarchy(view: subview) {
                return found
            }
        }

        return nil
    }
}
