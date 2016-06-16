//
//  CategoryList.swift
//  Ello
//
//  Created by Colin Gray on 6/14/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import SwiftyJSON

public let CategoryListVersion = 1

public class CategoryList: JSONAble {
    public var selectedCategory: Category?
    public let categories: [Category]

    public init(categories: [Category]) {
        self.categories = categories.sort { $0.order < $1.order }
        super.init(version: CategoryListVersion)
    }

    public required init(coder: NSCoder) {
        let decoder = Coder(coder)
        categories = decoder.decodeKey("categories")
        super.init(coder: coder)
    }

    public override func encodeWithCoder(coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(categories, forKey: "categories")
        super.encodeWithCoder(coder)
    }

    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        let categories: [Category]
        if let jsonCategories = json["categories"].array {
            let unsorted: [(order: Int, category: Category)] = jsonCategories.flatMap { json in
                if let val = json.object as? [String: AnyObject],
                    category = Category.fromJSON(val) as? Category
                {
                    return (order: json["order"].intValue, category: category)
                }
                return nil
            }

            categories = unsorted.sort { entryA, entryB in
                return entryA.order < entryB.order
            }.map { $0.category }
        }
        else {
            categories = []
        }
        return CategoryList(categories: categories)
    }

}

extension CategoryList {
    class func tmp() -> CategoryList {
        return CategoryList(categories: [
            Category(id: "1", name: "Featured", slug: "featured", order: 0, level: .Primary),
            Category(id: "2", name: "Art", slug: "art", order: 1, level: .Primary),
            Category(id: "3", name: "Architecture", slug: "architecture", order: 2, level: .Primary),
            Category(id: "4", name: "Design", slug: "design", order: 3, level: .Primary),
            Category(id: "5", name: "GIFs", slug: "gifs", order: 4, level: .Primary),
            Category(id: "6", name: "Literature", slug: "literature", order: 5, level: .Primary),
        ])
    }
}
