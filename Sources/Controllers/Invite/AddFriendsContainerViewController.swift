//
//  AddFriendsContainerViewController.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class AddFriendsContainerViewController: StreamableViewController {

    enum FindOption {
        case Find
        case Invite
    }

    @IBOutlet weak public var pageView: UIView!
    @IBOutlet weak public var findButton: FindInviteButton!
    @IBOutlet weak public var inviteButton: FindInviteButton!
    @IBOutlet weak public var navigationBar: UINavigationBar!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!

    public let pageViewController: UIPageViewController
    public let findFriendsViewController: FindFriendsViewController
    public let inviteFriendsViewController: InviteFriendsViewController
    public var userTappedDelegate: UserTappedDelegate? {
        didSet {
            self.findFriendsViewController.userTappedDelegate = self.userTappedDelegate
            self.inviteFriendsViewController.userTappedDelegate = self.userTappedDelegate
        }
    }
    let addressBook: ContactList

    required public init(addressBook: ContactList) {
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.findFriendsViewController = FindFriendsViewController()
        self.inviteFriendsViewController = InviteFriendsViewController()
        self.addressBook = addressBook
        super.init(nibName: "AddFriendsContainerViewController", bundle: NSBundle(forClass: FindFriendsViewController.self))
        self.title = "Add Friends"
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: remove this and convert to streamViewController
    override func setupStreamController() {
        // noop
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupPageViewController()
        setupButtons()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController() {
            findFriendsFromContacts()
            updateInsets()
        }
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
    }

    private func updateInsets() {
        if let tableView = findFriendsViewController.tableView {
            tableView.contentInset.bottom = ElloTabBar.Size.height
            tableView.scrollIndicatorInsets.bottom = ElloTabBar.Size.height
        }
        if let tableView = inviteFriendsViewController.tableView {
            tableView.contentInset.bottom = ElloTabBar.Size.height
            tableView.scrollIndicatorInsets.bottom = ElloTabBar.Size.height
        }
    }

    // MARK: - Private

    private func setupNavBar() {
        navigationController?.navigationBarHidden = true
        navigationItem.title = self.title
        navigationBar.items = [navigationItem]
        if !isRootViewController() {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
            self.navigationItem.leftBarButtonItems = [item]
            self.navigationItem.fixNavBarItemPadding()
        }
    }

    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = pageView.bounds

        pageViewController.setViewControllers([self.findFriendsViewController],
            direction: .Forward,
            animated: true,
            completion: .None)

        pageViewController.willMoveToParentViewController(self)
        addChildViewController(pageViewController)
        pageView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }

    private func setupButtons() {
        findButton.selected = true
    }

    private func findFriendsFromContacts() {
        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        ElloHUD.showLoadingHud()
        InviteService().find(contacts, currentUser: self.currentUser, success: { users in
            self.findFriendsViewController.setUsers(users)

            let userIdentifiers = users.map { $0.identifiableBy ?? "" }

            let mixed: [(LocalPerson, User?)] = self.addressBook.localPeople.map {
                if let index = find(userIdentifiers, $0.identifier) {
                    return ($0, users[index])
                }
                return ($0, .None)
            }
            self.inviteFriendsViewController.setContacts(mixed)
            ElloHUD.hideLoadingHud()
        }, failure: { _ in
            let contacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .None) }
            self.inviteFriendsViewController.setContacts(contacts)
            ElloHUD.hideLoadingHud()
        })
    }

    private func selectButton(option: FindOption) {
        inviteButton.selected = false
        findButton.selected = false
        switch option {
        case .Find:
            findButton.selected = true
        case .Invite:
            inviteButton.selected = true
        }
    }

    // MARK: - IBActions

    @IBAction func findFriendsTapped(sender: FindInviteButton) {
        selectButton(.Find)
        Tracker.sharedTracker.screenAppeared("Find Friends")
        pageViewController.setViewControllers([findFriendsViewController],
            direction: .Reverse,
            animated: true)
        { finished in
            self.updateInsets()
        }
    }

    @IBAction func inviteFriendsTapped(sender: FindInviteButton) {
        selectButton(.Invite)
        Tracker.sharedTracker.screenAppeared("Invite Friends")
        pageViewController.setViewControllers([inviteFriendsViewController],
            direction: .Forward,
            animated: true)
        { finished in
            self.updateInsets()
        }
    }
}

// MARK: AddFriendsContainerViewController : UIPageViewControllerDelegate
extension AddFriendsContainerViewController: UIPageViewControllerDelegate {

    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if completed {
            let viewController = previousViewControllers.first as? UIViewController

            if (viewController as? FindFriendsViewController != nil) {
                selectButton(.Invite)
            }
            else if (viewController as? InviteFriendsViewController != nil) {
                selectButton(.Find)
            }
        }
    }
}

// MARK: AddFriendsContainerViewController : UIPageViewControllerDataSource
extension AddFriendsContainerViewController: UIPageViewControllerDataSource {

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        if (viewController as? InviteFriendsViewController != nil) {
            return findFriendsViewController
        }
        return nil
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        if (viewController as? FindFriendsViewController != nil) {
            return inviteFriendsViewController
        }
        return nil
    }

}
