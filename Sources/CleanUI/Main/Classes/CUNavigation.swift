//  Copyright © 2021 - present Julian Gerhards
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  GitHub https://github.com/knoggl/CleanUI
//

import SwiftUI
import Combine

/// This class handles all sorts of programmatic navigation
public class CUNavigation {
    
    public enum BottomSheetSize {
        case halfDontAllowFull
        case fullDontAllowHalf
        case fullAllowHalf
        case halfAllowFull
    }
    
    /// Trys to pop to the rootViewController / View inside of the current UINavigationController
    /// - Parameter animated: Animated, default `true`
    public static func popToRootView(_ animated: Bool = true) {
        if let navigationController = self.getCurrentNavigationController() {
            navigationController.popToRootViewController(animated: animated)
        }
    }
    
    /// Trys to pop the current view to navigate one step back
    /// - Parameter animated: Animated, default `true`
    public static func pop(_ animated: Bool = true) {
        if let navigationController = self.getCurrentNavigationController() {
            navigationController.popViewController(animated: animated)
        }
    }
    
    /// Trys to pop all view controllers except the currently visible one and the root view controller
    public static func popIntermediateViews() {
        if let viewController = getCurrentNavigationController() {
            // pop on reverse order as the list shrinks one item in each iteration
            for index in (1..<viewController.children.count - 1).reversed() {
                viewController.children[index].removeFromParent()
            }
        }
    }

    /// Trys to pop all view controllers except the currently visible one
    public static func clearBackStack() {
        if let viewController = getCurrentNavigationController() {
            // pop on reverse order as the list shrinks one item in each iteration
            for index in (0..<viewController.children.count - 1).reversed() {
                viewController.children[index].removeFromParent()
            }
        }
    }

    
    /// Trys to find the current active UINavigationController.
    /// - Returns: An optional UINavigationController
    public static func getCurrentNavigationController() -> UINavigationController? {
        
        if let rootViewController = CUStd.getMainUIWindow()?.rootViewController {
            
            // Search for the UINavigationController
            for vc in rootViewController.children {
                
                // Did we find a UITabBarController? Search in the current
                // selected tab for an UINavigationController
                if let tabBarController = vc as? UITabBarController {
                    let currentTabIndex = tabBarController.selectedIndex
                    let currentTabViewController = vc.children[currentTabIndex]
                    for vc2 in currentTabViewController.children {
                        if(vc2 is UINavigationController) {
                            if let navigationController = vc2 as? UINavigationController {
                                return navigationController
                            }
                        }
                    }
                }else { // Without UITabBarController
                    // Check if the first viewController is a UINavigationController
                    if let navigationController = vc as? UINavigationController {
                        return navigationController
                    }else { // Continue search in subviews
                        for vc2 in vc.children {
                            if let navigationController = vc2 as? UINavigationController {
                                return navigationController
                            }
                        }
                    }
                }
            }
        }
        
        print("CUNavigation.getCurrentNavigationController() -> CURRENT UINAVIGATIONCONTROLLER NOT FOUND!")
        return nil
    }
    
    public enum ViewStackBehaviour {
        case keep
        case clearExceptRoot
        case clearAll
    }
    
    /// Try's to push to a SwiftUI View inside the current UINavigationController
    /// - Parameter animated: Push using a animation, default `true`
    /// - Parameter enableBackNavigation: Enable or disbale back swipe gesture, default `true`
    /// - Parameter stackBehaviour: Controls if all intermediate views, all views or no views on the stack should be popped after pushing the new view
    public static func pushToSwiftUiView<Content: View>(
        _ view: Content, animated: Bool = true,
        enableBackNavigation: Bool = true,
        stackBehaviour: ViewStackBehaviour = .keep
    ) {
        if let navigationController = self.getCurrentNavigationController() {
            let viewController = UIHostingController(rootView: view)
            viewController.navigationItem.largeTitleDisplayMode = .never
            navigationController.pushViewController(viewController, animated: animated)
            navigationController.interactivePopGestureRecognizer?.isEnabled = enableBackNavigation
            
            switch(stackBehaviour) {
                case .clearExceptRoot: popIntermediateViews()
                case .clearAll: clearBackStack()
                default: break
            }
        }
    }
    
    /// Pushes to a native UISheetPresentationController
    public static func pushBottomSheet<Content: View>(_ view: Content, size: CUNavigation.BottomSheetSize = .halfAllowFull){
        var detents: [UISheetPresentationController.Detent]
        
        switch size {
        case .halfDontAllowFull:
            detents = [.medium()]
        case .fullDontAllowHalf:
            detents = [.large()]
        case .fullAllowHalf:
            detents = [.large(), .medium()]
        case .halfAllowFull:
            detents = [.medium(), .large()]
        }
        
        if let rootViewController = CUStd.getMainUIWindow()?.rootViewController {
            let sheetHostingController = SheetHostingController(rootView: view, detents: detents)
            rootViewController.present(sheetHostingController, animated: true)
        }
    }
}

final class SheetHostingController<T: View>: UIHostingController<T>, UISheetPresentationControllerDelegate {
    
    private let detents: [UISheetPresentationController.Detent]
    private let prefersEdgeAttachedInCompactHeight: Bool
    private let prefersScrollingExpandsWhenScrolledToEdge: Bool
    
    init(
        rootView: T,
        title: String? = nil,
        largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode  = .never,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        prefersEdgeAttachedInCompactHeight: Bool = true,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true
    ) {
        self.detents = detents
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        super.init(rootView: rootView)
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = largeTitleDisplayMode
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sheetPresentationController = presentationController as? UISheetPresentationController {
            sheetPresentationController.delegate = self
            sheetPresentationController.detents = detents
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
            sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        }
    }
    
    func set(to detentIdentifier: UISheetPresentationController.Detent.Identifier?) {
        guard let sheetPresentationController = presentationController as? UISheetPresentationController else { return }
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = detentIdentifier
        }
    }
}
