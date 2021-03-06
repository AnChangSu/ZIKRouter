//
//  ZIKViewRouterPrepareDestinationTests.m
//  ZIKRouterTests
//
//  Created by zuik on 2018/4/19.
//  Copyright © 2018 zuik. All rights reserved.
//

#import "ZIKRouterTestCase.h"
#import "AViewInput.h"
#import "AViewController.h"

@interface ZIKViewRouterPrepareDestinationTests : ZIKRouterTestCase

@end

@implementation ZIKViewRouterPrepareDestinationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPrepareDestinationWithSuccessHandler {
    XCTestExpectation *successHandlerExpectation = [self expectationWithDescription:@"successHandler"];
    XCTestExpectation *performerSuccessHandlerExpectation = [self expectationWithDescription:@"performerSuccessHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest];
        AViewController *destination = [[AViewController alloc] init];
        self.router = [ZIKRouterToView(AViewInput) prepareDestination:destination configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
            config.prepareDestination = ^(id<AViewInput>  _Nonnull destination) {
                destination.title = @"test title";
            };
            config.successHandler = ^(id  _Nonnull destination) {
                [successHandlerExpectation fulfill];
            };
            config.performerSuccessHandler = ^(id  _Nonnull destination) {
                [performerSuccessHandlerExpectation fulfill];
            };
            config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                XCTAssert(NO, @"errorHandler should not be called");
            };
            config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                XCTAssert(NO, @"performerErrorHandler should not be called");
            };
            config.completionHandler = ^(BOOL success, id  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                XCTAssertTrue(success);
                [completionHandlerExpectation fulfill];
                [self handle:^{
                    XCTAssertNotNil(self.router);
                    [self leaveTest];
                }];
            };
        }];
        XCTAssert([destination.title isEqualToString:@"test title"]);
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPrepareDestinationWithErrorHandler {
    XCTestExpectation *errorHandlerExpectation = [self expectationWithDescription:@"errorHandler"];
    XCTestExpectation *performerErrorHandlerExpectation = [self expectationWithDescription:@"performerErrorHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest];
        id invalidDestination = [[UIViewController alloc] init];
        self.router = [ZIKRouterToView(AViewInput) prepareDestination:invalidDestination configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
            config.prepareDestination = ^(id<AViewInput>  _Nonnull destination) {
                destination.title = @"test title";
            };
            config.successHandler = ^(id  _Nonnull destination) {
                XCTAssert(NO, @"successHandler should not be called");
            };
            config.performerSuccessHandler = ^(id  _Nonnull destination) {
                XCTAssert(NO, @"performerErrorHandler should not be called");
            };
            config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                [errorHandlerExpectation fulfill];
            };
            config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                [performerErrorHandlerExpectation fulfill];
            };
            config.completionHandler = ^(BOOL success, id  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                XCTAssertFalse(success);
                XCTAssertNotNil(error);
                [completionHandlerExpectation fulfill];
                [self handle:^{
                    XCTAssertNil(self.router);
                    [self leaveTest];
                }];
            };
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPrepareDestinationWithSuccessHandler {
    XCTestExpectation *successHandlerExpectation = [self expectationWithDescription:@"successHandler"];
    XCTestExpectation *performerSuccessHandlerExpectation = [self expectationWithDescription:@"performerSuccessHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest];
        AViewController *destination = [[AViewController alloc] init];
        self.router = [ZIKRouterToView(AViewInput)
                       prepareDestination:destination
                       strictConfiguring:^(ZIKPerformRouteStrictConfiguration<id<AViewInput>> *config, ZIKViewRouteConfiguration * _Nonnull module) {
                           config.prepareDestination = ^(id<AViewInput> destination) {
                               destination.title = @"test title";
                           };
                           
                           config.successHandler = ^(id<AViewInput> destination) {
                               [successHandlerExpectation fulfill];
                           };
                           config.performerSuccessHandler = ^(id<AViewInput> destination) {
                               [performerSuccessHandlerExpectation fulfill];
                           };
                           config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                               XCTAssert(NO, @"errorHandler should not be called");
                           };
                           config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                               XCTAssert(NO, @"performerErrorHandler should not be called");
                           };
                           config.completionHandler = ^(BOOL success, id<AViewInput> _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                               XCTAssertTrue(success);
                               [completionHandlerExpectation fulfill];
                               [self handle:^{
                                   XCTAssertNotNil(self.router);
                                   [self leaveTest];
                               }];
                           };
                       }];
        XCTAssert([destination.title isEqualToString:@"test title"]);
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPrepareDestinationWithErrorHandler {
    XCTestExpectation *errorHandlerExpectation = [self expectationWithDescription:@"errorHandler"];
    XCTestExpectation *performerErrorHandlerExpectation = [self expectationWithDescription:@"performerErrorHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    
    {
        [self enterTest];
        id invalidDestination = [[UIViewController alloc] init];
        self.router = [ZIKRouterToView(AViewInput)
                       prepareDestination:invalidDestination
                       strictConfiguring:^(ZIKPerformRouteStrictConfiguration<id<AViewInput>> *config, ZIKViewRouteConfiguration * _Nonnull module) {
                           config.prepareDestination = ^(id<AViewInput> destination) {
                               destination.title = @"test title";
                           };
                           config.successHandler = ^(id<AViewInput> destination) {
                               XCTAssert(NO, @"successHandler should not be called");
                           };
                           config.performerSuccessHandler = ^(id<AViewInput> destination) {
                               XCTAssert(NO, @"performerErrorHandler should not be called");
                           };
                           config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                               [errorHandlerExpectation fulfill];
                           };
                           config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                               [performerErrorHandlerExpectation fulfill];
                           };
                           config.completionHandler = ^(BOOL success, id<AViewInput> _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                               XCTAssertFalse(success);
                               XCTAssertNotNil(error);
                               [completionHandlerExpectation fulfill];
                               [self handle:^{
                                   XCTAssertNil(self.router);
                                   [self leaveTest];
                               }];
                           };
                       }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

@end
