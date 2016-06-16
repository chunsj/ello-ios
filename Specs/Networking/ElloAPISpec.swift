//
//  ElloAPISpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import Ello
import Quick
import Moya
import Nimble


class ElloAPISpec: QuickSpec {
    override func spec() {

        var provider: MoyaProvider<ElloAPI>!

        beforeEach {
            provider = ElloProvider.StubbingProvider()
        }

        afterEach {
            provider = ElloProvider.DefaultProvider()
        }

        describe("DiscoverType") {
            describe("name") {
                it("is correct for each case") {
                    expect(DiscoverType.Recommended.name) == "Featured"
                    expect(DiscoverType.Trending.name) == "Trending"
                    expect(DiscoverType.Recent.name) == "Recent"
                }
            }
        }

        describe("ElloAPI") {
            describe("paths") {

                context("are valid") {
                    it("AmazonCredentials is valid") {
                        expect(ElloAPI.AmazonCredentials.path) ==  "/api/v2/assets/credentials"
                    }
                    it("Auth is valid") {
                        expect(ElloAPI.Auth(email: "", password: "").path) == "/api/oauth/token"
                    }
                    it("Availability is valid") {
                        expect(ElloAPI.Availability(content: [:]).path) == "/api/v2/availability"
                    }
                    it("AwesomePeopleStream is valid") {
                        expect(ElloAPI.AwesomePeopleStream.path) == "/api/v2/discover/users/onboarding"
                    }
                    it("CommunitiesStream is valid") {
                        expect(ElloAPI.CommunitiesStream.path) == "/api/v2/interest_categories/members"
                    }
                    it("CreatePost is valid") {
                        expect(ElloAPI.CreatePost(body: [:]).path) == "/api/v2/posts"
                    }
                    it("Discover.Recommended is valid") {
                        expect(ElloAPI.Discover(type: DiscoverType.Recommended, perPage: 5).path) == "/api/v2/discover/posts/recommended"
                    }
                    it("Discover.Trending is valid") {
                        expect(ElloAPI.Discover(type: DiscoverType.Trending, perPage: 5).path) == "/api/v2/discover/users/trending"
                    }
                    it("Discover.Recent is valid") {
                        expect(ElloAPI.Discover(type: DiscoverType.Recent, perPage: 5).path) == "/api/v2/discover/posts/recent"
                    }
                    it("FlagComment is valid") {
                        expect(ElloAPI.FlagComment(postId: "555", commentId: "666", kind: "some-string").path) == "/api/v2/posts/555/comments/666/flag/some-string"
                    }
                    it("FlagPost is valid") {
                        expect(ElloAPI.FlagPost(postId: "456", kind: "another-kind").path) == "/api/v2/posts/456/flag/another-kind"
                    }
                    it("FindFriends is valid") {
                        expect(ElloAPI.FindFriends(contacts: [:]).path) == "/api/v2/profile/find_friends"
                    }
                    it("FriendStream is valid") {
                        expect(ElloAPI.FriendStream.path) == "/api/v2/streams/friend"
                    }
                    it("InfiniteScroll is valid") {
                        let infiniteScrollEndpoint = ElloAPI.InfiniteScroll(queryItems: []) { return ElloAPI.FriendStream }
                        expect(infiniteScrollEndpoint.path) == "/api/v2/streams/friend"
                    }
                    it("InviteFriends is valid") {
                        expect(ElloAPI.InviteFriends(contact: "someContact").path) == "/api/v2/invitations"
                    }
                    it("NoiseStream is valid") {
                        expect(ElloAPI.NoiseStream.path) == "/api/v2/streams/noise"
                    }
                    it("NotificationsStream is valid") {
                        expect(ElloAPI.NotificationsStream(category: nil).path) == "/api/v2/notifications"
                    }
                    it("PostDetail is valid") {
                        expect(ElloAPI.PostDetail(postParam: "some-param", commentCount: 10).path) == "/api/v2/posts/some-param"
                    }
                    it("PostComments is valid") {
                        expect(ElloAPI.PostComments(postId: "fake-id").path) == "/api/v2/posts/fake-id/comments"
                    }
                    it("Profile is valid") {
                        expect(ElloAPI.CurrentUserStream.path) == "/api/v2/profile"
                    }
                    it("ProfileUpdate is valid") {
                        expect(ElloAPI.ProfileUpdate(body: [:]).path) == "/api/v2/profile"
                    }
                    it("ProfileDelete is valid") {
                        expect(ElloAPI.ProfileDelete.path) == "/api/v2/profile"
                    }
                    it("ReAuth is valid") {
                        expect(ElloAPI.ReAuth(token: "").path) == "/api/oauth/token"
                    }
                    it("Relationship is valid") {
                        expect(ElloAPI.Relationship(userId: "1234", relationship: "friend").path) == "/api/v2/users/1234/add/friend"
                    }
                    it("UserStream is valid") {
                        expect(ElloAPI.UserStream(userParam: "999").path) == "/api/v2/users/999"
                    }
                    it("UserStreamFollowers is valid") {
                        expect(ElloAPI.UserStreamFollowers(userId: "321").path) == "/api/v2/users/321/followers"
                    }
                    it("UserStreamFollowing is valid") {
                        expect(ElloAPI.UserStreamFollowing(userId: "123").path) == "/api/v2/users/123/following"
                    }
                    it("DeletePost is valid") {
                        expect(ElloAPI.DeletePost(postId: "666").path) == "/api/v2/posts/666"
                    }
                    it("DeleteComment is valid") {
                        expect(ElloAPI.DeleteComment(postId: "666", commentId: "777").path) == "/api/v2/posts/666/comments/777"
                    }
                }
            }

            describe("mappingType") {

                let currentUserId = "123"

                let expectations: [(ElloAPI, MappingType)] = [
                    (.AmazonCredentials, .AmazonCredentialsType),
                    (.AnonymousCredentials, .ErrorType),
                    (.Auth(email: "", password: ""), .ErrorType),
                    (.Availability(content: ["":""]), .AvailabilityType),
                    (.AwesomePeopleStream, .UsersType),
                    (.CommentDetail(postId: "", commentId: ""), .CommentsType),
                    (.Categories, .PostCategoriesType),
                    (.CommunitiesStream, .UsersType),
                    (.CreateComment(parentPostId: "", body: ["": ""]), .CommentsType),
                    (.CreateLove(postId: ""), .LovesType),
                    (.CreatePost(body: ["": ""]), .PostsType),
                    (.CurrentUserProfile, .UsersType),
                    (.CurrentUserStream, .UsersType),
                    (.DeleteComment(postId: "", commentId: ""), .ErrorType),
                    (.DeleteLove(postId: ""), .NoContentType),
                    (.DeletePost(postId: ""), .ErrorType),
                    (.DeleteSubscriptions(token: NSData()), .NoContentType),
                    (.Discover(type: .Recommended, perPage: 0), .PostsType),
                    (.Discover(type: .Trending, perPage: 0), .UsersType),
                    (.Discover(type: .Recent, perPage: 0), .PostsType),
                    (.EmojiAutoComplete(terms: ""), .AutoCompleteResultType),
                    (.FindFriends(contacts: ["": [""]]), .UsersType),
                    (.FlagComment(postId: "", commentId: "", kind: ""), .NoContentType),
                    (.FlagPost(postId: "", kind: ""), .NoContentType),
                    (.FriendStream, .ActivitiesType),
                    (.FriendNewContent(createdAt: NSDate()), .ErrorType),
                    (.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), .UsersType),
                    (.InviteFriends(contact: ""), .NoContentType),
                    (.Join(email: "", username: "", password: "", invitationCode: ""), .UsersType),
                    (.Loves(userId: ""), .LovesType),
                    (.Loves(userId: currentUserId), .LovesType),
                    (.NoiseStream, .ActivitiesType),
                    (.NoiseNewContent(createdAt: NSDate()), .ErrorType),
                    (.NotificationsNewContent(createdAt: NSDate()), .ErrorType),
                    (.NotificationsStream(category: ""), .ActivitiesType),
                    (.PostComments(postId: ""), .CommentsType),
                    (.PostDetail(postParam: "", commentCount: 0), .PostsType),
                    (.PostLovers(postId: ""), .UsersType),
                    (.PostReposters(postId: ""), .UsersType),
                    (.ProfileDelete, .NoContentType),
                    (.ProfileToggles, .DynamicSettingsType),
                    (.ProfileUpdate(body: ["": ""]), .UsersType),
                    (.PushSubscriptions(token: NSData()), .NoContentType),
                    (.ReAuth(token: ""), .ErrorType),
                    (.RePost(postId: ""), .PostsType),
                    (.Relationship(userId: "", relationship: ""), .RelationshipsType),
                    (.RelationshipBatch(userIds: [""], relationship: ""), .NoContentType),
                    (.SearchForUsers(terms: ""), .UsersType),
                    (.SearchForPosts(terms: ""), .PostsType),
                    (.UpdatePost(postId: "", body: ["": ""]), .PostsType),
                    (.UpdateComment(postId: "", commentId: "", body: ["": ""]), .CommentsType),
                    (.UserStream(userParam: ""), .UsersType),
                    (.UserStream(userParam: currentUserId), .UsersType),
                    (.UserStreamFollowers(userId: ""), .UsersType),
                    (.UserStreamFollowing(userId: ""), .UsersType),
                    (.UserNameAutoComplete(terms: ""), .AutoCompleteResultType)
                ]
                for (endpoint, mappingType) in expectations {
                    it("\(endpoint.description) has the correct mappingType \(mappingType)") {
                        expect(endpoint.mappingType) == mappingType
                    }
                }
            }

            describe("headers") {

                context("Accept-Language endpoints") {
                    let endpoints: [ElloAPI] = [
                        .AmazonCredentials,
                        .AnonymousCredentials,
                        .Auth(email: "", password: ""),
                        .Availability(content: [:]),
                        .AwesomePeopleStream,
                        .CommunitiesStream,
                        .CreateComment(parentPostId: "", body: [:]),
                        .CreateLove(postId: ""),
                        .CreatePost(body: [:]),
                        .DeleteComment(postId: "", commentId: ""),
                        .DeleteLove(postId: ""),
                        .DeletePost(postId: ""),
                        .DeleteSubscriptions(token: NSData()),
                        .Discover(type: .Trending, perPage: 0),
                        .EmojiAutoComplete(terms: ""),
                        .FindFriends(contacts: [:]),
                        .FlagComment(postId: "", commentId: "", kind: ""),
                        .FlagPost(postId: "", kind: ""),
                        .FriendNewContent(createdAt: NSDate()),
                        .FriendStream,
                        .InfiniteScroll(queryItems: [""], elloApi: { () -> ElloAPI in
                            return ElloAPI.Auth(email: "", password: "")
                        }),
                        .InfiniteScroll(queryItems: [""], elloApi: { () -> ElloAPI in
                            return ElloAPI.FriendStream
                        }),
                        .InviteFriends(contact: ""),
                        .Join(email: "", username: "", password: "", invitationCode: ""),
                        .Loves(userId: ""),
                        .NoiseNewContent(createdAt: NSDate()),
                        .NoiseStream,
                        .NotificationsNewContent(createdAt: NSDate()),
                        .NotificationsStream(category: ""),
                        .PostComments(postId: ""),
                        .PostDetail(postParam: "", commentCount: 10),
                        .PostLovers(postId: ""),
                        .PostReposters(postId: ""),
                        .CurrentUserStream,
                        .ProfileDelete,
                        .ProfileToggles,
                        .ProfileUpdate(body: [:]),
                        .PushSubscriptions(token: NSData()),
                        .ReAuth(token: ""),
                        .Relationship(userId: "", relationship: ""),
                        .RelationshipBatch(userIds: [""], relationship: ""),
                        .RePost(postId: ""),
                        .SearchForPosts(terms: ""),
                        .SearchForUsers(terms: ""),
                        .UserNameAutoComplete(terms: ""),
                        .UserStream(userParam: ""),
                        .UserStreamFollowers(userId: ""),
                        .UserStreamFollowing(userId: ""),
                    ]
                    for endpoint in endpoints {
                        it("\(endpoint) has the correct headers") {
                            expect(endpoint.headers()["Accept-Language"]) == ""
                            expect(endpoint.headers()["Accept"]) == "application/json"
                            expect(endpoint.headers()["Content-Type"]) == "application/json"
                        }
                    }
                }

                context("If-Modified-Since endpoints") {
                    let date = NSDate()
                    let endpoints: [ElloAPI] = [
                        .FriendNewContent(createdAt: date),
                        .NoiseNewContent(createdAt: date),
                        .NotificationsNewContent(createdAt: date)
                    ]
                    for endpoint in endpoints {
                        it("\(endpoint) has the correct headers") {
                            expect(endpoint.headers()["If-Modified-Since"]) == date.toHTTPDateString()
                        }
                    }
                }

                context("normal authorization required") {
                    let endpoints: [ElloAPI] = [
                        .AmazonCredentials,
                        .Availability(content: [:]),
                        .AwesomePeopleStream,
                        .CommunitiesStream,
                        .CreateComment(parentPostId: "", body: [:]),
                        .CreateLove(postId: ""),
                        .CreatePost(body: [:]),
                        .DeleteComment(postId: "", commentId: ""),
                        .DeleteLove(postId: ""),
                        .DeletePost(postId: ""),
                        .DeleteSubscriptions(token: NSData()),
                        .Discover(type: .Trending, perPage: 0),
                        .EmojiAutoComplete(terms: ""),
                        .FindFriends(contacts: ["" : [""]]),
                        .FlagComment(postId: "", commentId: "", kind: ""),
                        .FlagPost(postId: "", kind: ""),
                        .FriendStream,
                        .InfiniteScroll(queryItems: [""], elloApi: { () -> ElloAPI in
                            return ElloAPI.FriendStream
                        }),
                        .InviteFriends(contact: ""),
                        .Join(email: "", username: "", password: "", invitationCode: ""),
                        .Loves(userId: ""),
                        .NoiseStream,
                        .NotificationsStream(category: ""),
                        .PostComments(postId: ""),
                        .PostDetail(postParam: "", commentCount: 10),
                        .PostLovers(postId: ""),
                        .PostReposters(postId: ""),
                        .CurrentUserStream,
                        .ProfileDelete,
                        .ProfileToggles,
                        .ProfileUpdate(body: [:]),
                        .RePost(postId: ""),
                        .PushSubscriptions(token: NSData()),
                        .Relationship(userId: "", relationship: ""),
                        .RelationshipBatch(userIds: [""], relationship: ""),
                        .SearchForUsers(terms: ""),
                        .SearchForPosts(terms: ""),
                        .UserStream(userParam: ""),
                        .UserStreamFollowers(userId: ""),
                        .UserStreamFollowing(userId: ""),
                        .UserNameAutoComplete(terms: "")
                    ]
                    for endpoint in endpoints {
                        it("\(endpoint) has the correct headers") {
                            expect(endpoint.headers()["Authorization"]) == AuthToken().tokenWithBearer ?? ""
                        }
                    }
                }
            }

            describe("parameter values") {

                it("AnonymousCredentials") {
                    let params = ElloAPI.AnonymousCredentials.parameters!
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["grant_type"] as? String) == "client_credentials"
                }

                it("Auth") {
                    let params = ElloAPI.Auth(email: "me@me.me", password: "p455w0rd").parameters!
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["email"] as? String) == "me@me.me"
                    expect(params["password"] as? String) == "p455w0rd"
                    expect(params["grant_type"] as? String) == "password"
                }

                it("Availability") {
                    let content = ["username": "sterlingarcher"]
                    expect(ElloAPI.Availability(content: content).parameters as? [String: String]) == content
                }

                it("AwesomePeopleStream") {
                    let params = ElloAPI.AwesomePeopleStream.parameters!
                    expect(params["per_page"] as? Int) == 25
                    expect(params["seed"]).notTo(beNil())
                }

                it("CommunitiesStream") {
                    let params = ElloAPI.CommunitiesStream.parameters!
                    expect(params["name"] as? String) == "onboarding"
                    expect(params["per_page"] as? Int) == 25
                }

                it("CreateComment") {
                    let content = ["text": "my sweet comment content"]
                    expect(ElloAPI.CreateComment(parentPostId: "id", body: content).parameters as? [String: String]) == content
                }

                it("CreatePost") {
                    let content = ["text": "my sweet post content"]
                    expect(ElloAPI.CreatePost(body: content).parameters as? [String: String]) == content
                }

                it("Discover") {
                    let params = ElloAPI.Discover(type: .Recommended, perPage: 10).parameters!
                    expect(params["per_page"] as? Int) == 10
                    expect(params["include_recent_posts"] as? Bool) == true
                    expect(params["seed"]).notTo(beNil())
                }

                xit("FindFriends") {

                }

                it("FriendStream") {
                    let params = ElloAPI.FriendStream.parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                it("InfiniteScroll") {
                    let queryItems = NSURLComponents(string: "ttp://ello.co/api/v2/posts/278/comments?after=2014-06-02T00%3A00%3A00.000000000%2B0000&per_page=2")!.queryItems
                    let infiniteScroll = ElloAPI.InfiniteScroll(queryItems: queryItems!) { return ElloAPI.Discover(type: .Recommended, perPage: 10) }
                    let params = infiniteScroll.parameters!
                    expect(params["per_page"] as? String) == "2"
                    expect(params["include_recent_posts"] as? Bool) == true
                    expect(params["seed"]).notTo(beNil())
                    expect(params["after"]).notTo(beNil())
                }

                it("InviteFriends") {
                    let params = ElloAPI.InviteFriends(contact: "me@me.me").parameters!
                    expect(params["email"] as? String) == "me@me.me"
                }

                describe("Join") {
                    context("without an invitation code") {
                        let params = ElloAPI.Join(email: "me@me.me", username: "sweetness", password: "password", invitationCode: nil).parameters!
                        expect(params["email"] as? String) == "me@me.me"
                        expect(params["username"] as? String) == "sweetness"
                        expect(params["password"] as? String) == "password"
                        expect(params["invitation_code"]).to(beNil())
                    }

                    context("with an invitation code") {
                        let params = ElloAPI.Join(email: "me@me.me", username: "sweetness", password: "password", invitationCode: "my-sweet-code").parameters!
                        expect(params["email"] as? String) == "me@me.me"
                        expect(params["username"] as? String) == "sweetness"
                        expect(params["password"] as? String) == "password"
                        expect(params["invitation_code"] as? String) == "my-sweet-code"
                    }
                }

                it("NoiseStream") {
                    let params = ElloAPI.NoiseStream.parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                describe("NotificationsStream") {

                    it("without a category") {
                        let params = ElloAPI.NotificationsStream(category: nil).parameters!
                        expect(params["per_page"] as? Int) == 10
                        expect(params["category"]).to(beNil())
                    }

                    it("with a category") {
                        let params = ElloAPI.NotificationsStream(category: "all").parameters!
                        expect(params["per_page"] as? Int) == 10
                        expect(params["category"] as? String) == "all"
                    }
                }

                it("PostComments") {
                    let params = ElloAPI.PostComments(postId: "comments-id").parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                describe("PostDetail") {
                    it("commentCount 10") {
                        let params = ElloAPI.PostDetail(postParam: "post-id", commentCount: 10).parameters!
                        expect(params["comment_count"] as? Int) == 10
                    }
                    it("commentCount 0") {
                        let params = ElloAPI.PostDetail(postParam: "post-id", commentCount: 0).parameters!
                        expect(params["comment_count"] as? Int) == 0
                    }
                }

                it("Profile") {
                    let params = ElloAPI.CurrentUserStream.parameters!
                    expect(params["post_count"] as? Int) == 10
                }

                xit("PushSubscriptions, DeleteSubscriptions") {

                }

                it("ReAuth") {
                    let params = ElloAPI.ReAuth(token: "refresh").parameters!
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["grant_type"] as? String) == "refresh_token"
                    expect(params["refresh_token"] as? String) == "refresh"
                }

                it("RelationshipBatch") {
                    let params = ElloAPI.RelationshipBatch(userIds: ["1", "2", "8"], relationship: "friend").parameters!
                    expect(params["user_ids"] as? [String]) == ["1", "2", "8"]
                    expect(params["priority"] as? String) == "friend"
                }

                it("RePost") {
                    let params = ElloAPI.RePost(postId: "666").parameters!
                    expect(params["repost_id"] as? Int) == 666
                }

                it("SearchForPosts") {
                    let params = ElloAPI.SearchForPosts(terms: "blah").parameters!
                    expect(params["terms"] as? String) == "blah"
                    expect(params["per_page"] as? Int) == 10
                }

                it("SearchForUsers") {
                    let params = ElloAPI.SearchForUsers(terms: "blah").parameters!
                    expect(params["terms"] as? String) == "blah"
                    expect(params["per_page"] as? Int) == 10
                }

                it("UserNameAutoComplete") {
                    let params = ElloAPI.UserNameAutoComplete(terms: "blah").parameters!
                    expect(params["terms"] as? String) == "blah"
                }
            }

            describe("valid enpoints") {
                describe("with stubbed responses") {
                    describe("a provider") {
                        it("returns stubbed data for auth request") {
                            var message: String?

                            let target: ElloAPI = .Auth(email:"test@example.com", password: "123456")
                            provider.request(target, completion: { (result) in
                                switch result {
                                case let .Success(moyaResponse):
                                    message = NSString(data: moyaResponse.data, encoding: NSUTF8StringEncoding) as? String
                                default: break
                                }
                            })

                            let sampleData = target.sampleData as NSData
                            expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                        }

                        it("returns stubbed data for friends stream request") {
                            var message: String?

                            let target: ElloAPI = .FriendStream
                            provider.request(target, completion: { (result) in
                                switch result {
                                case let .Success(moyaResponse):
                                    message = NSString(data: moyaResponse.data, encoding: NSUTF8StringEncoding) as? String
                                default: break
                                }
                            })

                            let sampleData = target.sampleData as NSData
                            expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                        }
                    }
                }
            }
        }
    }
}
