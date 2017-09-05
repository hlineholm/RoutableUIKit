//
//  RoutableNavigationController.swift
//  RoutableUIKit
//
//  Created by Lineholm, Henrik on 2017-08-18.
//  Copyright © 2017 RouteableUIKit. All rights reserved.
//


import UIKit


open class RoutableNavigationController: UINavigationController, UINavigationControllerDelegate {

    public var routingDelegate: RoutableNavigationControllerDelegate?
    private var hasPopped = false

    // MARK: UIViewController
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    // MARK: UINavigationController
    
    open override var delegate: UINavigationControllerDelegate? {
        didSet {
            if !(delegate is RoutableNavigationController) {
                defaultDelegate = delegate
                delegate = oldValue
            }
        }
    }
    private var defaultDelegate: UINavigationControllerDelegate?
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        hasPopped = false
        super.pushViewController(viewController, animated: animated)
    }
    open override func popViewController(animated: Bool) -> UIViewController? {
        hasPopped = true
        return super.popViewController(animated: animated)
    }
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        hasPopped = true
        return super.popToRootViewController(animated: animated)
    }
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        hasPopped = true
        return super.popToViewController(viewController, animated: animated)
    }
    
    // MARK: UINavigationControllerDelegate
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let nvc = navigationController as? RoutableNavigationController else { fatalError() }
        
        if nvc.hasPopped {
            routingDelegate?.routableNavigationController(self, didPop: viewController, animated: animated)
        }
        
        defaultDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        defaultDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    open func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        if let function = defaultDelegate?.navigationControllerSupportedInterfaceOrientations {
            return function(navigationController)
        } else {
            return .all
        }
    }
    open func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        if let function = defaultDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation {
            return function(navigationController)
        } else {
            return .portrait
        }
    }
    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return defaultDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return defaultDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}

public protocol RoutableNavigationControllerDelegate {
    func routableNavigationController(_ rnvc: RoutableNavigationController, didPop vc: UIViewController, animated: Bool)
}
