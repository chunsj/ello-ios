//
//  CategoryListCellPresenter.swift
//  Ello
//
//  Created by Colin Gray on 6/14/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public struct CategoryListCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? CategoryListCell,
            categoryList = streamCellItem.jsonable as? CategoryList
        {
            let searchFor: String?
            if case let .Discover(category) = streamKind {
                searchFor = category
            }
            else {
                searchFor = nil
            }

            var selectedCategory: String? = nil
            for category in categoryList.categories {
                if category.slug == searchFor {
                    selectedCategory = category.slug
                    break
                }
            }

            cell.selectedCategory = selectedCategory
            cell.categories = categoryList.categories.map { (title: $0.name, slug: $0.slug) }
        }
    }

}
