//
//  AutoCompleteResultSpec.swift
//  Ello
//
//  Created by Sean on 6/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class AutoCompleteResultSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONDataArray("users_getting_a_list_for_autocompleted_usernames", "autocomplete_results")
                let result = AutoCompleteResult.fromJSON(data.first!) as! AutoCompleteResult

                expect(result.name) == "lanakane32d"
                expect(result.url?.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/43/ello-small-e5fcdb7d.png"
            }
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("AutoCompleteResultSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let result: AutoCompleteResult = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(result, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let result: AutoCompleteResult = stub([
                        "name" : "777",
                        "url" : NSURL(string:"http://www.example.com/meow")!
                    ])

                    NSKeyedArchiver.archiveRootObject(result, toFile: filePath)
                    let unArchivedAutoCompleteResult = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! AutoCompleteResult

                    expect(unArchivedAutoCompleteResult).toNot(beNil())
                    expect(unArchivedAutoCompleteResult.version) == 1

                    expect(unArchivedAutoCompleteResult.name) == "777"
                    expect(unArchivedAutoCompleteResult.url?.absoluteString) == "http://www.example.com/meow"
                }
            }
        }
    }
}