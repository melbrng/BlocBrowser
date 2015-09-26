//
//  BlocBrowserTests.m
//  BlocBrowserTests
//
//  Created by Melissa Boring on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface BlocBrowserTests : XCTestCase

@property (nonatomic,strong) ViewController *viewController;

@end

@implementation BlocBrowserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.viewController = [[ViewController alloc ] init ];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testForURL {
    NSURL *expectedURL = [NSURL URLWithString:@"http://www.google.com"];
    NSURL *actualURL = [self.viewController setURLForWebOrQueryTerms:@"www.google.com"];
    
    XCTAssertEqualObjects(expectedURL, actualURL ,@"objects not equal");
    
}

- (void)testForQueryURL {
    NSURL *expectedQuery = [NSURL URLWithString:@"http://www.google.com/search?q=monkey+hats"];
    NSURL *actualQuery = [self.viewController setURLForWebOrQueryTerms:@"monkey hats"];
    
    XCTAssertEqualObjects(expectedQuery, actualQuery ,@"objects not equal");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
