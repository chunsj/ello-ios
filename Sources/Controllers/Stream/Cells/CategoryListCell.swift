//
//  CategoryListCell.swift
//  Ello
//
//  Created by Colin Gray on 6/14/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import SnapKit

public class CategoryListCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryListCell"
    weak var discoverCategoryPickerDelegate: DiscoverCategoryPickerDelegate?

    struct Size {
        static let sideMargins: CGFloat = 15
        static let spacing: CGFloat = 15
    }

    var categories: [String] = [] {
        didSet {
            if categories != oldValue {
                updateCategoryViews()
            }
        }
    }
    var selectedCategory: String? {
        didSet {
            for button in categoryButtons {
                guard let category = button.currentTitle else { continue }

                let attributedString = CategoryListCell.buttonTitle(category, selected: category == selectedCategory)
                button.setAttributedTitle(attributedString, forState: UIControlState.Normal)
            }
        }
    }
    private var categoryButtons: [UIButton] = []
    private var secondaryCategoriesButton = UIButton()

    private class func buttonTitle(category: String, selected: Bool) -> NSAttributedString {
        var attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(),
        ]
        if selected {
            attrs[NSForegroundColorAttributeName] = UIColor.blackColor()
            attrs[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        else {
            attrs[NSForegroundColorAttributeName] = UIColor.greyA()
        }
        let attributedString = NSAttributedString(string: category, attributes: attrs)
        return attributedString
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        style()
        // bindActions()
        // setText()
        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func style() {
        secondaryCategoriesButton.setImage(.Dots, imageStyle: .Normal, forState: .Normal)
    }

    private func arrange() {
        addSubview(secondaryCategoriesButton)

        secondaryCategoriesButton.snp_makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-Size.sideMargins).priorityRequired()
        }
    }

    @objc
    func valueChanged(button: UIButton) {
        guard let category = button.currentTitle else { return }

        discoverCategoryPickerDelegate?.discoverCategoryTapped(category)
    }

    private func updateCategoryViews() {
        for view in categoryButtons {
            view.removeFromSuperview()
        }

        categoryButtons = categories.map { category in
            let button = UIButton()
            button.backgroundColor = .clearColor()
            button.addTarget(self, action: #selector(valueChanged(_:)), forControlEvents: .TouchUpInside)
            let attributedString = CategoryListCell.buttonTitle(category, selected: category == selectedCategory)
            button.setAttributedTitle(attributedString, forState: UIControlState.Normal)

            return button
        }

        var prevView: UIView? = nil
        for view in categoryButtons {
            contentView.addSubview(view)

            view.snp_makeConstraints { make in
                make.centerY.equalTo(contentView)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp_trailing).offset(Size.spacing)
                }
                else {
                    make.leading.equalTo(contentView.snp_leading).offset(Size.sideMargins)
                }
            }

            prevView = view
        }

        layoutIfNeeded()

        for view in categoryButtons {
            if view.frame.maxX > secondaryCategoriesButton.frame.minX {
                view.hidden = true
            }
        }
    }

}
