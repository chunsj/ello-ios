//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public class DiscoverViewController: StreamableViewController {
    let tmpCategoryList: CategoryList = CategoryList.tmp()

    var screen: DiscoverScreen!

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Sparkles, insets: UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)) }
        set { self.tabBarItem = newValue }
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)

        addSearchButton()
        title = InterfaceString.Discover.Title
        elloNavigationItem.title = title
        streamViewController.streamKind = .Discover(type: .Recommended, perPage: 10)
        streamViewController.customStreamCellItems = { jsonables, defaultItems in
            var items: [StreamCellItem] = []

            let toggleCellItem = StreamCellItem(jsonable: JSONAble(version: 1), type: .ColumnToggle)
            let categoryList = self.tmpCategoryList
            categoryList.selectedCategory = categoryList.categories.first
            let categoryListItem = StreamCellItem(jsonable: categoryList, type: .CategoryList)
            items += [toggleCellItem, categoryListItem]

            items += defaultItems()
            return items
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        self.screen = DiscoverScreen(navigationItem: elloNavigationItem)
        self.view = screen
        viewContainer = screen.streamContainer
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar, streamController: streamViewController)
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }
}
