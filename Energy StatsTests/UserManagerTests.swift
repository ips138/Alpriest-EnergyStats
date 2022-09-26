//
//  UserManagerTests.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import XCTest
@testable import Energy_Stats
import Combine

@MainActor
final class UserManagerTests: XCTestCase {
    private var sut: UserManager!
    private var keychainStore: MockKeychainStore!
    private var networking: MockNetworking!

    override func setUp() {
        keychainStore = MockKeychainStore()
        networking = MockNetworking()
        sut = UserManager(networking: networking, store: keychainStore)
    }

    func test_IsLoggedIn_SetsOnInitialisation() {
        var expectation: XCTestExpectation? = self.expectation(description: #function)
        keychainStore.hasCredentials = true

        sut.$isLoggedIn
            .receive(subscriber: Subscribers.Sink(receiveCompletion: { _ in
            }, receiveValue: { value in
                if value {
                    expectation?.fulfill()
                    expectation = nil
                }
            }))

        wait(for: [expectation!], timeout: 1.0)
        XCTAssertTrue(sut.isLoggedIn)
    }

    func test_returns_username_from_keychain() {
        keychainStore.username = "bob"

        XCTAssertEqual(sut.getUsername(), "bob")
    }
}
