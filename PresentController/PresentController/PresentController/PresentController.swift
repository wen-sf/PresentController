//
//  PresentController.swift
//  PresentBottomVC
//
//  Created by HongXiangWen on 2018/3/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

// MARK: - UIPresentationController子类，重写present相关属性和方法
class PresentController: UIPresentationController {

    /// 动画方式
    private var position: PresentControllerPosition = .bottom
    /// 是否点击背景按钮收起
    private var canClickBgDismiss: Bool = true
    /// 弹出view的size
    private var contentSize: CGSize = CGSize.zero
    /// 动画时间
    private var animateTime: CGFloat = 0.25
    /// 是否pan手势收起
    private var canPanDown: Bool = false
    /// pan的起始Y值
    private var panStartY: CGFloat = 0
    
    /// 内容视图的frame
    override var frameOfPresentedViewInContainerView: CGRect {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        switch position {
        case .top:
            return CGRect(x: (screenWidth - contentSize.width) / 2, y: 0, width: contentSize.width, height: contentSize.height)
        case .bottom:
            return CGRect(x: (screenWidth - contentSize.width) / 2, y: screenHeight - contentSize.height, width: contentSize.width, height: contentSize.height)
        case .center:
            return CGRect(x: (screenWidth - contentSize.width) / 2, y: (screenHeight - contentSize.height) / 2, width: contentSize.width, height: contentSize.height)
        }
    }
    
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        if let viewController = presentedViewController as? PresentControllerType {
            position = viewController.position
            contentSize = viewController.contentSize
            canPanDown = viewController.canPanDown
            canClickBgDismiss = viewController.canClickBgDismiss
            animateTime = viewController.animateTime
        }
    }
    
    /// 半透明背景按钮
    private lazy var backgroundBtn: UIButton = {
        let backgroundBtn = UIButton()
        backgroundBtn.frame = containerView?.bounds ?? UIScreen.main.bounds
        backgroundBtn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundBtn.alpha = 0
        if canClickBgDismiss {
            backgroundBtn.addTarget(self, action: #selector(backgroundBtnClicked), for: .touchUpInside)
        }
        return backgroundBtn
    }()
    
    
    /// 将要弹出时添加背景按钮
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(backgroundBtn)
        UIView.animate(withDuration: TimeInterval(animateTime)) {
            self.backgroundBtn.alpha = 1
        }
    }
    
    /// 已经弹出视图
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if canPanDown && position != .center {
            let panGuesture = UIPanGestureRecognizer(target: self, action: #selector(panGuestureAction(panGuesture:)))
            presentedViewController.view.addGestureRecognizer(panGuesture)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: TimeInterval(animateTime)) {
            self.backgroundBtn.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundBtn.removeFromSuperview()
        }
    }

    ///  点击背景按钮收起
    @objc private func backgroundBtnClicked() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    /// 处理pan手势
    @objc func panGuestureAction(panGuesture: UIPanGestureRecognizer) {
        let offsetY = panGuesture.translation(in: presentedView).y
        if panGuesture.state == .began {
            panStartY = offsetY
        } else if panGuesture.state == .changed {
            switch position {
            case .top:
                let deltaY = min(contentSize.height, max(panStartY - offsetY, 0))
                let alpha = 1 - deltaY / contentSize.height
                presentedViewController.view.transform = CGAffineTransform(translationX: 0, y: -deltaY)
                self.backgroundBtn.alpha = alpha
            case .bottom:
                let deltaY = max(0, min(offsetY - panStartY, presentedViewController.view.frame.size.height))
                let alpha = 1 - deltaY / presentedViewController.view.frame.size.height
                presentedViewController.view.transform = CGAffineTransform(translationX: 0, y: deltaY)
                self.backgroundBtn.alpha = alpha
            default:
                break
            }
        } else if panGuesture.state == .ended || panGuesture.state == .cancelled || panGuesture.state == .failed {
            if (position == .bottom && offsetY - panStartY > min(contentSize.height / 2, 100)) || (position == .top && panStartY - offsetY > min(contentSize.height / 2, 100)){
                backgroundBtnClicked()
            } else {
                openView()
            }
        }
    }
    
    private func openView() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.presentedViewController.view.transform = CGAffineTransform.identity
            self.backgroundBtn.alpha = 1
        })
    }
    
}

// MARK: -  模态弹出位置
enum PresentControllerPosition {
    /// 从底部由下至上弹出
    case bottom
    /// 从中间缩放弹出
    case center
    /// 从顶部由上至下弹出
    case top
}

// MARK: -  模态弹出的ViewController必须遵守此协议
protocol PresentControllerType {
    /// 容器view的size
    var contentSize: CGSize { get }
    /// 模态弹出位置
    var position: PresentControllerPosition { get }
    /// 是否pan手势,只能在top或者bottom使用
    var canPanDown: Bool { get }
    /// 是否点击背景按钮收起
    var canClickBgDismiss: Bool { get }
    /// 动画时间
    var animateTime: CGFloat { get }
}

extension PresentControllerType {
    /// 默认从底部弹出
    var position: PresentControllerPosition {
        return .bottom
    }
    /// 默认开启下拉关闭手势
    var canPanDown: Bool {
        return true
    }
    /// 默认开启点击背景按钮收起
    var canClickBgDismiss: Bool {
        return true
    }
    /// 动画时间默认0.25s
    var animateTime: CGFloat {
        return 0.25
    }
}

// MARK: - UIViewController & PresentControllerType
typealias PresenViewController = UIViewController & PresentControllerType

// MARK: - 提供自定义present方法
extension UIViewController: UIViewControllerTransitioningDelegate {
    
    /// 自定义present方法
    func presentViewController(_ viewController: PresenViewController ) {
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: -  UIViewControllerTransitioningDelegate
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let viewController = presented as? PresentControllerType {
            return PresentTransitionAnimator(.present, position: viewController.position, animateTime: viewController.animateTime)
        }
        return PresentTransitionAnimator(.present)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let viewController = dismissed as? PresentControllerType {
            return PresentTransitionAnimator(.dismiss, position: viewController.position, animateTime: viewController.animateTime)
        }
        return PresentTransitionAnimator(.dismiss)
    }
    
}

// MARK: - 自定义segue，在storyboard中设置custom，且destination必须遵守PresentControllerType
class PresentSegue: UIStoryboardSegue {
    
    override func perform() {
        guard let destination = destination as? PresenViewController else {
            fatalError("destination must be UIViewController & PresentBottomType")
        }
        source.presentViewController(destination)
    }
    
}

// MARK: -  自定义动画类
class PresentTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum PresentTransitionAnimateType {
        case present
        case dismiss
    }
    
    private var animateTime: CGFloat
    private var animateType: PresentTransitionAnimateType
    private var position: PresentControllerPosition
    
    init(_ animateType: PresentTransitionAnimateType, position: PresentControllerPosition = .bottom, animateTime: CGFloat = 0.25) {
        self.animateTime = animateTime
        self.animateType = animateType
        self.position = position
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(animateTime)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animateType {
        case .present:
            presentAnimation(transitionContext)
        case .dismiss:
            dismissAnimation(transitionContext)
        }
    }
    
    /// present动画
    func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let controller = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        transitionContext.containerView.addSubview(controller.view)
        let finalFrame = transitionContext.finalFrame(for: controller)
        var initialFrame = finalFrame
        switch position {
        case .top:
            initialFrame.origin.y = -finalFrame.height
        case .center:
            initialFrame = CGRect(x: 0, y: 0, width: 10, height: 10)
            initialFrame.origin = CGPoint(x: finalFrame.midX - initialFrame.width / 2, y: finalFrame.midY - initialFrame.height / 2)
        case .bottom:
            initialFrame.origin.y = transitionContext.containerView.frame.size.height
        }
        controller.view.frame = initialFrame
        controller.view.layoutIfNeeded()
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            controller.view.frame = finalFrame
            controller.view.layoutIfNeeded()
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    /// dismiss动画
    func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let controller = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let initialFrame = transitionContext.finalFrame(for: controller)
        var finalFrame = initialFrame
        switch position {
        case .top:
            finalFrame.origin.y = -initialFrame.height
        case .center:
            finalFrame = CGRect(x: 0, y: 0, width: 10, height: 10)
            finalFrame.origin = CGPoint(x: initialFrame.midX - finalFrame.width / 2, y: initialFrame.midY - finalFrame.height / 2)
        case .bottom:
            finalFrame.origin.y = transitionContext.containerView.frame.size.height
        }
        controller.view.frame = initialFrame
        controller.view.layoutIfNeeded()
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            controller.view.frame = finalFrame
            controller.view.layoutIfNeeded()
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
}

















