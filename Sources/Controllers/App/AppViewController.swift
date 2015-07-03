//
//  AppViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Crashlytics

struct NavigationNotifications {
    static let showingNotificationsTab = TypedNotification<[String]>(name: "co.ello.NavigationNotification.NotificationsTab")
}


@objc
protocol HasAppController {
    var parentAppController: AppViewController? { get set }
}

public class AppViewController: BaseElloViewController {

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var logoView: ElloLogoView!
    @IBOutlet weak public var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var socialRevolution: UILabel!
    @IBOutlet weak public var signInButton: LightElloButton!
    @IBOutlet weak public var joinButton: ElloButton!

    var visibleViewController: UIViewController?
    private var userLoggedOutObserver: NotificationObserver?
    private var receivedPushNotificationObserver: NotificationObserver?
    private var externalWebObserver: NotificationObserver?
    private var apiOutOfDateObserver: NotificationObserver?

    private var pushPayload: PushPayload?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        setupStyles()

        scrollView.scrollsToTop = false
    }

    deinit {
        removeNotificationObservers()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if view.frame.height - logoView.frame.maxY < 250 {
            let top = view.frame.height - 250 - logoView.frame.height
            logoTopConstraint.constant = top
        }
        scrollView.contentSize = view.frame.size
    }

    var isStartup = true
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if isStartup {
            isStartup = false
            checkIfLoggedIn()
        }
    }

    public class func instantiateFromStoryboard() -> AppViewController {
        return UIStoryboard.storyboardWithId(.App, storyboardName: "App") as! AppViewController
    }

    public override func didSetCurrentUser() {
        ElloWebBrowserViewController.currentUser = currentUser
    }

// MARK: - Private

    private func setupStyles() {
        scrollView.backgroundColor = .whiteColor()
        view.backgroundColor = .whiteColor()
        view.setNeedsDisplay()
    }

    private func checkIfLoggedIn() {
        let authToken = AuthToken()

        let defaults = NSUserDefaults.standardUserDefaults()
        var introDisplayed = Defaults["IntroDisplayed"].bool ?? false

        if authToken.isPresent && authToken.isAuthenticated {
            self.loadCurrentUser()
        }
        else if !introDisplayed {
            presentViewController(IntroController(), animated: false) {
                Defaults["IntroDisplayed"] = true
                self.showButtons()
            }
        }
        else {
            self.showButtons()
        }
    }

    public func loadCurrentUser(var failure: ElloErrorCompletion? = nil) {
        if failure == nil {
            logoView.animateLogo()
            failure = { _ in
                self.logoView.stopAnimatingLogo()
            }
        }

        let profileService = ProfileService()
        profileService.loadCurrentUser(ElloAPI.Profile(perPage: 1),
            success: { user in
                self.logoView.stopAnimatingLogo()
                self.currentUser = user

                let shouldShowOnboarding = !Onboarding.shared().hasSeenLatestVersion()
                if shouldShowOnboarding {
                    self.showOnboardingScreen(user)
                }
                else {
                    self.showMainScreen(user)
                }
            },
            failure: { (error, _) in
                self.failedToLoadCurrentUser(failure, error: error)
            },
            invalidToken: { error in
                self.failedToLoadCurrentUser(failure, error: error)
            })
    }

    func failedToLoadCurrentUser(failure: ElloErrorCompletion?, error: NSError) {
        let authToken = AuthToken()
        authToken.reset()
        showButtons()
        failure?(error: error)
    }

    private func showButtons(animated: Bool = true) {
//        println("---------PROFILING: AppVC not logged in: \(NSDate().timeIntervalSinceDate(LaunchDate))")
        Tracker.sharedTracker.screenAppeared("Startup")
        animate(animated: animated) {
            self.joinButton.alpha = 1.0
            self.signInButton.alpha = 1.0
            self.socialRevolution.alpha = 1.0
        }
    }

    private func hideButtons() {
        self.joinButton.alpha = 0.0
        self.signInButton.alpha = 0.0
        self.socialRevolution.alpha = 0.0
    }

    private func setupNotificationObservers() {
        userLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.userLoggedOut, block: userLoggedOut)
        receivedPushNotificationObserver = NotificationObserver(notification: PushNotificationNotifications.interactedWithPushNotification, block: receivedPushNotification)
        externalWebObserver = NotificationObserver(notification: externalWebNotification) { url in
            self.showExternalWebView(url)
        }
        apiOutOfDateObserver = NotificationObserver(notification: ElloProvider.ErrorStatusCode.Status410.notification) { error in
            let message = NSLocalizedString("The version of the app you’re using is too old, and is no longer compatible with our API.\n\nPlease update the app to the latest version, using the “Updates” tab in the App Store.", comment: "App out of date message")
            let alertController = AlertViewController(message: message)

            let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
            alertController.addAction(action)

            self.presentViewController(alertController, animated: true, completion: nil)
            self.apiOutOfDateObserver?.removeObserver()
            postNotification(AuthenticationNotifications.invalidToken, false)
        }
    }

    private func removeNotificationObservers() {
        userLoggedOutObserver?.removeObserver()
        receivedPushNotificationObserver?.removeObserver()
        externalWebObserver?.removeObserver()
        apiOutOfDateObserver?.removeObserver()
    }

}


// MARK: Screens
extension AppViewController {

    public func showJoinScreen() {
        pushPayload = .None
        let joinController = JoinViewController()
        joinController.parentAppController = self
        swapViewController(joinController)
        Crashlytics.sharedInstance().setObjectValue("Join", forKey: CrashlyticsKey.StreamName.rawValue)
    }

    public func showSignInScreen() {
        pushPayload = .None
        let signInController = SignInViewController()
        signInController.parentAppController = self
        swapViewController(signInController)
        Crashlytics.sharedInstance().setObjectValue("Login", forKey: CrashlyticsKey.StreamName.rawValue)
    }

    public func showOnboardingScreen(user: User) {
        currentUser = user

        let vc = OnboardingViewController()
        vc.parentAppController = self
        vc.currentUser = user
        self.presentViewController(vc, animated: true, completion: nil)
    }

    public func doneOnboarding() {
        Onboarding.shared().updateVersionToLatest()

        dismissViewControllerAnimated(true, completion: nil)
        self.showMainScreen(currentUser!)
    }

    public func showMainScreen(user: User) {
        Tracker.sharedTracker.identify(user)

        var vc = ElloTabBarController.instantiateFromStoryboard()
        ElloWebBrowserViewController.elloTabBarController = vc
        vc.setProfileData(user)

        swapViewController(vc) {
            if let payload = self.pushPayload {
                self.navigateToDeepLink(payload.applicationTarget)
                self.pushPayload = .None
            }

            vc.activateTabBar()
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                vc.presentViewController(alert, animated: true, completion: .None)
            }
        }
    }
}

extension AppViewController {

    func showExternalWebView(url: String) {
        Tracker.sharedTracker.webViewAppeared(url)
        let externalWebController = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
        presentViewController(externalWebController, animated: true, completion: nil)
        if let externalWebView = externalWebController.rootWebBrowser() {
            externalWebView.tintColor = UIColor.greyA()
            externalWebView.loadURLString(url)
        }
    }

    public override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        // Unsure why WKWebView calls this controller - instead of it's own parent controller
        if let vc = presentedViewController {
            vc.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }

}

// MARK: Screen transitions
extension AppViewController {

    public func swapViewController(newViewController: UIViewController, completion: ElloEmptyCompletion? = nil) {
        newViewController.view.alpha = 0

        visibleViewController?.willMoveToParentViewController(nil)
        newViewController.willMoveToParentViewController(self)

        prepareToShowViewController(newViewController)

        if let tabBarController = visibleViewController as? ElloTabBarController {
            tabBarController.deactivateTabBar()
        }

        UIView.animateWithDuration(0.2, animations: {
            self.visibleViewController?.view.alpha = 0
            newViewController.view.alpha = 1
            self.scrollView.alpha = 0
        }, completion: { _ in
            self.visibleViewController?.view.removeFromSuperview()
            self.visibleViewController?.removeFromParentViewController()

            self.addChildViewController(newViewController)
            if let childController = newViewController as? HasAppController {
                childController.parentAppController = self
            }

            newViewController.didMoveToParentViewController(self)

            self.hideButtons()
            self.visibleViewController = newViewController
            completion?()
        })
    }

    public func removeViewController(completion: ElloEmptyCompletion? = nil) {
        if let presentingViewController = presentingViewController {
            dismissViewControllerAnimated(false, completion: .None)
        }
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)

        if let visibleViewController = visibleViewController {
            visibleViewController.willMoveToParentViewController(nil)

            if let tabBarController = visibleViewController as? ElloTabBarController {
                tabBarController.deactivateTabBar()
            }

            UIView.animateWithDuration(0.2, animations: {
                self.showButtons(animated: false)
                visibleViewController.view.alpha = 0
                self.scrollView.alpha = 1
            }, completion: { _ in
                visibleViewController.view.removeFromSuperview()
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nil
                completion?()
            })
        }
        else {
            showButtons()
            scrollView.alpha = 1
            completion?()
        }
    }

    private func prepareToShowViewController(newViewController: UIViewController) {
        let controller = (newViewController as? UINavigationController)?.topViewController ?? newViewController
        Tracker.sharedTracker.screenAppeared(controller)

        view.addSubview(newViewController.view)
        newViewController.view.frame = self.view.bounds
        newViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }

}


// MARK: Logout events
public extension AppViewController {
    func userLoggedOut() {
        if isLoggedIn() {
            logOutCurrentUser()
            removeViewController()
        }
    }

    public func forceLogOut(shouldAlert: Bool) {
        if isLoggedIn() {
            logOutCurrentUser()

            removeViewController() {
                if shouldAlert {
                    let message = NSLocalizedString("You have been automatically logged out", comment: "Automatically logged out message")
                    let alertController = AlertViewController(message: message)

                    let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
                    alertController.addAction(action)

                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func isLoggedIn() -> Bool {
        if let visibleViewController = visibleViewController
        where visibleViewController is ElloTabBarController
        {
            return true
        }
        return false
    }

    private func logOutCurrentUser() {
        PushNotificationController.sharedController.deregisterStoredToken()
        AuthToken().reset()
        currentUser = nil
    }
}

// MARK: Push Notification Handling
extension AppViewController {
    func receivedPushNotification(payload: PushPayload) {
        if let vc = self.visibleViewController as? ElloTabBarController {
            navigateToDeepLink(payload.applicationTarget)
        } else {
            self.pushPayload = payload
        }
    }
}

// MARK: URL Handling
extension AppViewController {
    func navigateToDeepLink(path: String) {
        let vc = self.visibleViewController as? ElloTabBarController

        var components = path.pathComponents
        if components.first == "/" {
            components.removeAtIndex(0)
        }
        if count(components) == 0 {
            return
        }

        let firstComponent = components.removeAtIndex(0)

        switch firstComponent {
        case "stream":
            vc?.selectedTab = .Stream
        case "notifications":
            vc?.selectedTab = .Notifications
            postNotification(NavigationNotifications.showingNotificationsTab, components)
        default:
            break
        }
    }
}


// MARK: - IBActions
public extension AppViewController {

    @IBAction func signInTapped(sender: ElloButton) {
        Tracker.sharedTracker.tappedSignInFromStartup()
        showSignInScreen()
    }

    @IBAction func joinTapped(sender: ElloButton) {
        Tracker.sharedTracker.tappedJoinFromStartup()
        showJoinScreen()
    }

}
