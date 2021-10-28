//
//  TestMockServer.m
//  MockWebServer
//
//  Created by Jae Han on 12/10/16.
//  Copyright © 2016 jaehan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MockWebServer/MockWebServer.h>

@interface TestMockServer : XCTestCase {

    MockWebServer *mockWebServer;
}

@end

@implementation TestMockServer

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    mockWebServer = [[MockWebServer alloc] init];
    [mockWebServer start:9000];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [mockWebServer stop];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    DispatchMap *dispatchMap = [[DispatchMap alloc] init];
    Dispatch *dispatch = [[Dispatch alloc] init];
    [dispatch requestContainString:@"/test"];
    [dispatch setResponseCode:200];
    [dispatch responseString:@"ResponseTest"];
    [dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
    [dispatch setBody:@"foo"];
    [dispatchMap addDispatch:dispatch];
    [mockWebServer setDispatch:dispatchMap];
    
    TestConditionWait *testWait = [TestConditionWait instance];
    NSString *dataUrl = @"http://127.0.0.1:9000/test";
    NSURL *url = [NSURL URLWithString:dataUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *test = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *output = [NSString stringWithUTF8String:[data bytes]];
        
        XCTAssert([output compare:@"ResponseTest"] == NSOrderedSame, @"Response body don't match.");
        
        [testWait wakeup];

    }];
    
    [test resume];
    [testWait waitFor:1];

}


@end
