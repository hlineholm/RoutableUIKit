//
//  RoutableNavigationController.swift
//  RoutableUIKit
//
//  Created by Lineholm, Henrik on 2017-08-18.
//  Copyright © 2017 RouteableUIKit. All rights reserved.
//

import UIKit

public typealias RNC = RoutableNavigationController
public typealias RNCD = RoutableNavigationControllerDelegate
public typealias UIVC = UIViewController
public typealias UINC = UINavigationController
public typealias UINCD = UINavigationControllerDelegate
public typealias UIIO = UIInterfaceOrientation
public typealias UIIOM = UIInterfaceOrientationMask
public typealias UIVCAT = UIViewControllerAnimatedTransitioning
public typealias UIVCIT = UIViewControllerInteractiveTransitioning
public typealias UINCO = UINavigationControllerOperation


open class RoutableNavigationController<Delegate: RNCD>: UINC, UINCD {
    
    private enum Action { case idle, pushing, poping }
    private typealias State = (action: Action, sender: Any?)
    
    public var route: Delegate.Route?
    public var routingDelegate: Delegate?
    private var state: State = (.idle, nil)
    
    public func pushViewController(_ vc: UIVC, animated: Bool, sender: Any) {
        self.state = (.pushing, sender)
        super.pushViewController(vc, animated: animated)
    }
    public func popViewController(animated: Bool, sender: Any) -> UIVC? {
        self.state = (.poping, sender)
        return super.popViewController(animated: animated)
    }
    public func popToRootViewController(animated: Bool, sender: Any) -> [UIVC]? {
        self.state = (.poping, sender)
        return super.popToRootViewController(animated: animated)
    }
    public func popToViewController(_ vc: UIVC, animated: Bool, sender: Any) -> [UIVC]? {
        self.state = (.poping, sender)
        return super.popToViewController(vc, animated: animated)
    }
    
    // MARK: UIVC
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    // MARK: UINavigationController
    
    open override var delegate: UINCD? {
        didSet {
            if !(delegate is RNC<Delegate>) {
                defaultDelegate = delegate
                delegate = oldValue
            }
        }
    }
    private var defaultDelegate: UINCD?
    
    open override func pushViewController(_ vc: UIVC, animated: Bool) {
        state = (.pushing, nil)
        super.pushViewController(vc, animated: animated)
    }
    open override func popViewController(animated: Bool) -> UIVC? {
        state = (.poping, nil)
        return super.popViewController(animated: animated)
    }
    open override func popToRootViewController(animated: Bool) -> [UIVC]? {
        state = (.poping, nil)
        return super.popToRootViewController(animated: animated)
    }
    open override func popToViewController(_ vc: UIVC, animated: Bool) -> [UIVC]? {
        state = (.poping, nil)
        return super.popToViewController(vc, animated: animated)
    }
    
    // MARK: UINavigationControllerDelegate
    
    open func navigationController(_ nc: UINC, didShow vc: UIVC, animated: Bool) {
        defaultDelegate?.navigationController?(nc, didShow: vc, animated: animated)
        
        if state.action == .pushing {
            routingDelegate?.routableNavigationController(self, didPush: vc, animated: animated, sender: state.sender)
        } else if state.action == .poping {
            routingDelegate?.routableNavigationController(self, didPop: vc, animated: animated, sender: state.sender)
        }
        
        state = (.idle, nil)
    }
    open func navigationController(_ nc: UINC, willShow vc: UIVC, animated: Bool) {
        defaultDelegate?.navigationController?(nc, willShow: vc, animated: animated)
        if let tc = topViewController?.transitionCoordinator {
            tc.notifyWhenInteractionChanges({ [unowned self] (context) in
                if context.isCancelled {
                    self.state = (.idle, nil)
                }
            })
        }
    }
    open func navigationControllerSupportedInterfaceOrientations(_ nc: UINC) -> UIIOM {
        if let function = defaultDelegate?.navigationControllerSupportedInterfaceOrientations {
            return function(nc)
        } else {
            return .all
        }
    }
    open func navigationControllerPreferredInterfaceOrientationForPresentation(_ nc: UINC) -> UIIO {
        if let function = defaultDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation {
            return function(nc)
        } else {
            return .portrait
        }
    }
    open func navigationController(_ nc: UINC, interactionControllerFor ac: UIVCAT) -> UIVCIT? {
        return defaultDelegate?.navigationController?(nc, interactionControllerFor: ac)
    }
    open func navigationController(_ nc: UINC, animationControllerFor operation: UINCO, from fromVC: UIVC, to toVC: UIVC) -> UIVCAT? {
        return defaultDelegate?.navigationController?(nc, animationControllerFor: operation, from: fromVC, to: toVC)
    }
    
}


public protocol RoutableNavigationControllerDelegate {
    associatedtype Route
    func routableNavigationController(_ rnc: RNC<Self>, didPush vc: UIVC, animated: Bool, sender: Any?)
    func routableNavigationController(_ rnc: RNC<Self>, didPop vc: UIVC, animated: Bool, sender: Any?)
}
