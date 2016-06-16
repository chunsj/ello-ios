//
//  CategorySpec.swift
//  Ello
//
//  Created by Colin Gray on 6/14/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class CategorySpec: QuickSpec {
    override func spec() {
        describe("Category") {
            describe("+fromJSON(:)") {
                it("parses correctly") {
                    let data: [String: AnyObject] = [
                        "id": "1",
                        "name": "Featured",
                        "slug": "featured",
                        "order": 0,
                        "level": "primary"
                    ]
                    let category = Category.fromJSON(data, fromLinked: false) as? Ello.Category
                    expect(category?.id) == "1"
                    expect(category?.name) == "Featured"
                    expect(category?.slug) == "featured"
                    expect(category?.order) == 0
                    expect(category?.level) == .Primary
                }
            }
        }
    }
}
