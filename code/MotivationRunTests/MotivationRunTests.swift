//
//  MotivationRunTests.swift
//  MotivationRunTests
//
//  Created by 주장규 on 2/10/26.
//

import XCTest
@testable import MotivationRun

final class MotivationRunTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testRunJournalEntryRoundTrip() throws {
        let original = RunJournalEntry(difficulty: 0.75, diary: "힘들었지만 완주!", updatedAt: Date(timeIntervalSince1970: 0))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RunJournalEntry.self, from: data)
        XCTAssertEqual(decoded.difficulty, 0.75)
        XCTAssertEqual(decoded.diary, "힘들었지만 완주!")
        XCTAssertEqual(decoded.updatedAt, Date(timeIntervalSince1970: 0))
    }

    func testRunSessionDecodesWithoutHkWorkoutID() throws {
        // 구형 JSON에 hkWorkoutID 없어도 nil로 복원되어야 함
        let json = """
        {"id":"E621E1F8-C36C-495A-93FC-0C247A3E6E5F","date":0,"distanceKm":3.5,"calories":200,"durationMinutes":30}
        """
        let data = json.data(using: .utf8)!
        let session = try JSONDecoder().decode(RunSession.self, from: data)
        XCTAssertNil(session.hkWorkoutID)
        XCTAssertEqual(session.distanceKm, 3.5)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
