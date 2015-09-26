//
//  BlocBrowserUITests.m
//  BlocBrowserUITests
//
//  Created by Melissa Boring on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BlocBrowserUITests : XCTestCase

@end

@implementation BlocBrowserUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testURL {
    
    //queries to look for objects in app
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *websiteUrlTextField = app.textFields[@"Enter Website URL or Search Terms"];
    
    
    [websiteUrlTextField tap];
    [websiteUrlTextField typeText:@"www.google.com"];
    [app typeText:@"\r"];
    
}

- (void)testSearchQuery {
    
    //queries to look for objects in app
    XCUIApplication *app2 = [[XCUIApplication alloc] init];
    XCUIElement *enterWebsiteUrlOrSearchTermsTextField = app2.textFields[@"Enter Website URL or Search Terms"];
    [enterWebsiteUrlOrSearchTermsTextField tap];
    [enterWebsiteUrlOrSearchTermsTextField typeText:@"monkey hats"];
    [app2 typeText:@"\r"];
    
    
}

@end
