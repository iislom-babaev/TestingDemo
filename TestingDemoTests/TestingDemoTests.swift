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
            switch result {
            case .success:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

class TestingDemoTests: XCTestCase {
    
    func test_load_shoudLoadEmptyListOfStrings() throws {
        let (sut, client) = makeSUT()
        
        try expect(sut, when: { client.completeSuccesfullyWith(items: (Data(), HTTPURLResponse())) }, expectedResult: .success([]))
    }
    
    func test_load_shoudCompleteWithAnyNSErorr() throws {
        let (sut, client) = makeSUT()
        let anyNSError = NSError(domain: "any", code: 0)
        
        try expect(sut, when: { client.completeWithError(error: anyNSError) }, expectedResult: .failure(anyNSError))
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (MyLoader,URLSessionClientSpy) {
        let client = URLSessionClientSpy()
        let sut = MyLoader(client: client)
        return (sut, client)
    }
    
    func expect(_ sut: MyLoader, when action: () -> Void, expectedResult: Result<[String], NSError>) throws {
        var receivedResult: Result<[String], NSError>?
        sut.load { receivedResult = $0 }
        
        action()
        
        XCTAssertNotNil(receivedResult)
        
        let unwrappedResult = try XCTUnwrap(receivedResult)
        
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
    
    final class URLSessionClientSpy : URLSessionClient {
        
        private var requests = [(Result<(Data, HTTPURLResponse), NSError>) -> Void]()
        
        func request(completion: @escaping (Result<(Data, HTTPURLResponse), NSError>) -> Void) {
            requests.append(completion)
        }
        
        func completeSuccesfullyWith(items: (Data, HTTPURLResponse)) {
            requests[0](.success(items))
        }
        
        func completeWithError(error: NSError) {
            requests[0](.failure(error))
        }
        
        
    }
    
}


