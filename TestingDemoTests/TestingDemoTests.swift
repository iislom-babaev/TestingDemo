//
//  TestingDemoTests.swift
//  TestingDemoTests
//
//  Created by Islom Babaev on 10/03/22.
//

import XCTest

//Service -> Loads list of strings
protocol Loader {
    func load(completion: @escaping (Result<[String], NSError>) -> Void)
}

protocol URLSessionClient {
    func request(completion: @escaping (Result<(Data, HTTPURLResponse), NSError>) -> Void)
}

//invoke load -> list of strings
//invoke load -> error

final class MyLoader {
    
    private let client: URLSessionClient
    
    init(client: URLSessionClient) {
        self.client = client
    }
 
    func load(completion: @escaping (Result<[String], NSError>) -> Void) {
        client.request { result in
            completion(.success([]))
        }
    }
}

class TestingDemoTests: XCTestCase {
    
    func test_load_shoudLoadEmptyListOfStrings() throws {
        let client = URLSessionClientSpy()
        let sut = MyLoader(client: client)
        
        var receivedResult: Result<[String], NSError>?
        sut.load { result in
            receivedResult = result
        }
        client.completeSuccesfullyWith(items: (Data(), HTTPURLResponse()))
        
        XCTAssertNotNil(receivedResult)
        
        let unwrappedResult = try XCTUnwrap(receivedResult)
        
        XCTAssertEqual(unwrappedResult, .success([]))

    }
    
    final class URLSessionClientSpy : URLSessionClient {
        
        private var requests = [(Result<(Data, HTTPURLResponse), NSError>) -> Void]()
        
        func request(completion: @escaping (Result<(Data, HTTPURLResponse), NSError>) -> Void) {
            requests.append(completion)
        }
        
        func completeSuccesfullyWith(items: (Data, HTTPURLResponse)) {
            requests[0](.success(items))
        }
        
        
    }
    
}


