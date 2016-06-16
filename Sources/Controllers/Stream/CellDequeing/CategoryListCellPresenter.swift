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
            cell.selectedCategory = categoryList.selectedCategory?.name
            cell.categories = categoryList.categories.map { $0.name }
        }
    }

}
