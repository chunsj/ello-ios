//
//  DiscoverScreen.swift
//  Ello
//
//  Created by Colin Gray on 6/14/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

// public protocol DiscoverDelegate {
// }

public class DiscoverScreen: UIView {
    let navigationBar = ElloNavigationBar()
    var navigationBarTopConstraint: NSLayoutConstraint!
    let streamContainer = UIView()

    public required init(navigationItem: UINavigationItem) {
        navigationBar.items = [navigationItem]
        super.init(frame: UIScreen.mainScreen().bounds)

        arrange()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiscoverScreen {
    private func arrange() {
        addSubview(streamContainer)
        addSubview(navigationBar)

        navigationBar.snp_makeConstraints { make in
            let c = make.top.equalTo(self).constraint
            self.navigationBarTopConstraint = c.nativeConstraints().first!
            make.left.equalTo(self)
            make.right.equalTo(self)
        }

        streamContainer.snp_makeConstraints { make in
            make.edges.equalTo(self)
            streamContainer.frame = self.bounds
        }
    }
}
