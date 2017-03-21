//
//  ViewController.swift
//  CustomTransitionFailure
//
//  Created by Brian Michel on 3/20/17.
//  Copyright © 2017 Brian Michel. All rights reserved.
//

import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresenting: Bool = false

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        var viewToMessWith: UIView?

        if isPresenting, let view = transitionContext.view(forKey: .to)  {
            viewToMessWith = view
            view.frame.origin = CGPoint(x: 0, y: containerView.bounds.maxY)
            containerView.addSubview(view)
        } else if let view = transitionContext.view(forKey: .from) {
            viewToMessWith = view
        }

        viewToMessWith?.frame.size = containerView.bounds.size

        UIView.animate(withDuration: 0.3, animations: {
            viewToMessWith?.frame.origin = CGPoint(x: 0, y: (self.isPresenting ? 0 : containerView.bounds.maxY))
        }, completion: { completed in
            transitionContext.completeTransition(completed)
        })

    }
}

final class PresentationController: UIPresentationController {
    private let respectsPresentationContext: Bool

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         respectsPresentationContext: Bool) {
        self.respectsPresentationContext = respectsPresentationContext
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var shouldPresentInFullscreen: Bool {
        return false
    }

    var _shouldRespectDefinesPresentationContext: Bool {
        return respectsPresentationContext
    }
}

final class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = Animator()
        animation.isPresenting = false

        return animation
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = Animator()
        animation.isPresenting = true

        return animation
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        /**
         Setting `false` for the parameter `respectsPresentationContext` will simulate the behavior
         that is currently represented for custom `UIPresentationController` objects. Setting this
         parameter to `true` will represent what private, Apple provided controllers have access to.
         */
        let presentation = PresentationController(presentedViewController: presented,
                                                  presenting: presenting,
                                                  respectsPresentationContext: false)

        return presentation
    }
}

final class ThirdViewController: UIViewController {
    let animator = TransitionDelegate()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        modalPresentationStyle = .custom
        transitioningDelegate = animator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
    }
}

final class OtherViewController: UIViewController {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "I'm a view controller...";
        label.sizeToFit()

        return label
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange

        let tap = UITapGestureRecognizer(target: self, action: #selector(doThing))
        view.addGestureRecognizer(tap)

        view.addSubview(label)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        label.center = view.center
    }

    @objc func doThing() {
        definesPresentationContext = true
        let viewController = ThirdViewController()

        let tap = UITapGestureRecognizer(target: self, action: #selector(undoThing))

        present(viewController, animated: true, completion: {
            viewController.view.addGestureRecognizer(tap)
        })
    }

    @objc func undoThing() {
        dismiss(animated: true, completion: nil)
    }
}

class ViewController: UIViewController {

    let navController = UINavigationController(rootViewController: OtherViewController())

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(navController)
        view.addSubview(navController.view)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        navController.view.frame.size = CGSize(width: 300, height: 450)
        navController.view.center = view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


