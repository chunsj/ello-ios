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
    private var buttonSlugLookup: [UIButton: String] = [:]

    struct Size {
        static let sideMargins: CGFloat = 15
        static let spacing: CGFloat = 15
    }

    var categories: [(title: String, slug: String)] = [] {
        didSet {
            let changed: Bool = (categories.count != oldValue.count) || oldValue.enumerate().any { (index, info) in
                return info.title != categories[index].title || info.slug != categories[index].slug
            }
            if changed {
                updateCategoryViews()
            }
        }
    }
    var selectedCategory: String? {
        didSet {
            for button in categoryButtons {
                guard let title = button.currentTitle ?? button.currentAttributedTitle?.string else { continue }
                guard let category = buttonSlugLookup[button] else { continue }

                let attributedString = CategoryListCell.buttonTitle(title, selected: category == selectedCategory)
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
        backgroundColor = .whiteColor()
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
        guard let slug = buttonSlugLookup[button] else { return }
        discoverCategoryPickerDelegate?.discoverCategoryTapped(slug)
    }

    private func updateCategoryViews() {
        for view in categoryButtons {
            view.removeFromSuperview()
        }
        buttonSlugLookup = [:]

        categoryButtons = categories.map { (category, slug) in
            let button = UIButton()
            buttonSlugLookup[button] = slug
            button.backgroundColor = .clearColor()
            button.addTarget(self, action: #selector(valueChanged(_:)), forControlEvents: .TouchUpInside)
            let attributedString = CategoryListCell.buttonTitle(category, selected: slug == selectedCategory)
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
