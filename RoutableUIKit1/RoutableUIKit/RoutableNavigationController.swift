//
//  RoutableNavigationController.swift
//  RoutableUIKit
//
//  Created by Lineholm, Henrik on 2017-08-18.
//  Copyright © 2017 RouteableUIKit. All rights reserved.
//
//  Based on https://github.com/ReSwift/ReSwift-Router/pull/74


import UIKit


/**
 A dummy view controller returned when popViewController is canceled
 */
public final class PopWasIgnored: UIViewController {}


open class RoutableNavigationController: UINavigationController {
    fileprivate var isSwipping: Bool = false
    fileprivate var isPerformingPop: Bool = false
    
    func handlePopSwipe(){
        self.isSwipping = true
    }
    open func popRoute(){
        print("WARNING: \(#function) has not been implemented, put your custom routing here!")
    }
    
    // MARK: UINavigationController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.addTarget(
            self,
            action: #selector(RoutableNavigationController.handlePopSwipe)
        )
        self.delegate = self
    }
    override open func popViewController(animated: Bool) -> UIViewController? {
        guard !self.isSwipping else { return PopWasIgnored() }
        self.isPerformingPop = true
        return super.popViewController(animated: animated)
    }
}

extension RoutableNavigationController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool) {
        
        self.isSwipping = false
    }
}

extension RoutableNavigationController: UINavigationBarDelegate {
    public func navigationBar(
        _ navigationBar: UINavigationBar,
        shouldPop item: UINavigationItem) -> Bool {
        
        defer { isPerformingPop = false }
        
        if !isPerformingPop || self.isSwipping {
            self.popRoute()
        }
        
        return isPerformingPop
    }
}

extension UINavigationController {
    open func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void) {
        
        self.pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    open func popViewController(
        animated: Bool,
        completion: @escaping () -> Void) -> UIViewController? {
        
        let popped = self.popViewController(animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return popped
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
        
        return popped
    }
}
