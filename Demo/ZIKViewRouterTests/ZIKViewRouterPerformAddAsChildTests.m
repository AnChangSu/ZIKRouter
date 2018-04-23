//
//  ZIKViewRouterPerformAddAsChildTests.m
//  ZIKViewRouterTests
//
//  Created by zuik on 2018/4/17.
//  Copyright © 2018 zuik. All rights reserved.
//

#import "ZIKViewRouterTestCase.h"

@interface ZIKViewRouterPerformAddAsChildTests : ZIKViewRouterTestCase

@end

@implementation ZIKViewRouterPerformAddAsChildTests

- (void)setUp {
    [super setUp];
    self.routeType = ZIKViewRouteTypeAddAsChildViewController;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)configRouteConfiguration:(ZIKViewRouteConfiguration *)configuration source:(UIViewController *)source {
    configuration.animated = YES;
}

+ (void)addChildToParentView:(UIView *)parentView childView:(UIView *)childView completion:(void(^)(void))completion {
    childView.frame = parentView.frame;
    childView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.5 animations:^{
        childView.backgroundColor = [UIColor redColor];
        [parentView addSubview:childView];
        childView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)testPerformWithPrepareDestination {
    XCTestExpectation *expectation = [self expectationWithDescription:@"prepareDestination"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performFromSource:source configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.prepareDestination = ^(id<AViewInput>  _Nonnull destination) {
                    destination.title = @"test title";
                };
                config.successHandler = ^(UIViewController<AViewInput> * _Nonnull destination) {
                    XCTAssertNotNil(destination);
                    XCTAssert([destination.title isEqualToString:@"test title"]);
                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                        [destination didMoveToParentViewController:source];
                        [expectation fulfill];
                        [self handle:^{
                            XCTAssert(self.router.state == ZIKRouterStateRouted);
                            [self leaveTest];
                        }];
                    }];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithSuccessCompletionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performFromSource:source configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.completionHandler = ^(BOOL success, UIViewController  *_Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                    XCTAssertTrue(success);
                    XCTAssertNil(error);
                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                        [destination didMoveToParentViewController:source];
                        [expectation fulfill];
                        [self handle:^{
                            XCTAssert(self.router.state == ZIKRouterStateRouted);
                            [self leaveTest];
                        }];
                    }];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithErrorCompletionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performFromSource:nil configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.completionHandler = ^(BOOL success, id  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                    XCTAssertFalse(success);
                    XCTAssertNotNil(error);
                    [expectation fulfill];
                    [self handle:^{
                        XCTAssert(self.router == nil || self.router.state == ZIKRouterStateUnrouted);
                        [self leaveTest];
                    }];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithSuccessCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performPath:[self pathFromSource:source] completion:^(BOOL success, UIViewController<AViewInput> *_Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                XCTAssertTrue(success);
                XCTAssertNil(error);
                [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                    [destination didMoveToParentViewController:source];
                    [expectation fulfill];
                    [self handle:^{
                        XCTAssert(self.router.state == ZIKRouterStateRouted);
                        [self leaveTest];
                    }];
                }];
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithErrorCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performPath:nil completion:^(BOOL success, id<AViewInput>  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                XCTAssertFalse(success);
                XCTAssertNotNil(error);
                [expectation fulfill];
                [self handle:^{
                    XCTAssert(self.router == nil || self.router.state == ZIKRouterStateUnrouted);
                    [self leaveTest];
                }];
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformRouteWithSuccessCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    expectation.assertForOverFulfill = YES;
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performPath:[self pathFromSource:source] completion:^(BOOL success, UIViewController<AViewInput> *_Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                XCTAssertTrue(success);
                XCTAssertNil(error);
                
                [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                    [destination didMoveToParentViewController:source];
                    [self handle:^{
                        XCTAssert(self.router.state == ZIKRouterStateRouted);
                        [self.router removeRouteWithSuccessHandler:^{
                            XCTAssert(self.router.state == ZIKRouterStateRemoved);
                            [self.router performRouteWithCompletion:^(BOOL success, UIViewController *_Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                                XCTAssert(self.router.state == ZIKRouterStateRouted);
                                XCTAssertTrue(success);
                                XCTAssertNil(error);
                                [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                    [destination didMoveToParentViewController:source];
                                    [expectation fulfill];
                                    [self leaveTest];
                                }];
                            }];
                        } errorHandler:nil];
                    }];
                }];
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformRouteWithErrorCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    expectation.assertForOverFulfill = YES;
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performPath:[self pathFromSource:source] completion:^(BOOL success, UIViewController<AViewInput> *_Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                XCTAssertTrue(success);
                [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                    [destination didMoveToParentViewController:source];
                    [self handle:^{
                        XCTAssert(self.router.state == ZIKRouterStateRouted);
                        [self.router performRouteWithCompletion:^(BOOL success, id  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                            XCTAssert(self.router.state == ZIKRouterStateRouted);
                            XCTAssertFalse(success);
                            XCTAssertNotNil(error);
                            [expectation fulfill];
                            [self leaveTest];
                        }];
                    }];
                }];
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithSuccess {
    XCTestExpectation *expectation = [self expectationWithDescription:@"successHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performFromSource:source configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.successHandler = ^(UIViewController * _Nonnull destination) {
                    XCTAssertNotNil(destination);
                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                        [destination didMoveToParentViewController:source];
                        [expectation fulfill];
                        [self handle:^{
                            XCTAssert(self.router.state == ZIKRouterStateRouted);
                            [self leaveTest];
                        }];
                    }];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithPerformerSuccess {
    XCTestExpectation *successHandlerExpectation = [self expectationWithDescription:@"successHandler"];
    successHandlerExpectation.expectedFulfillmentCount = 2;
    XCTestExpectation *performerSuccessHandlerExpectation = [self expectationWithDescription:@"performerSuccessHandler once"];
    performerSuccessHandlerExpectation.assertForOverFulfill = YES;
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performFromSource:source configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.successHandler = ^(id  _Nonnull destination) {
                    XCTAssertNotNil(destination);
                    [successHandlerExpectation fulfill];
                };
                config.performerSuccessHandler = ^(UIViewController * _Nonnull destination) {
                    XCTAssertNotNil(destination);
                    [performerSuccessHandlerExpectation fulfill];
                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                        [destination didMoveToParentViewController:source];
                        [self handle:^{
                            XCTAssert(self.router.state == ZIKRouterStateRouted);
                            [self.router removeRouteWithSuccessHandler:^{
                                XCTAssert(self.router.state == ZIKRouterStateRemoved);
                                [self.router performRouteWithSuccessHandler:^(UIViewController<AViewInput> *_Nonnull destination) {
                                    XCTAssert(self.router.state == ZIKRouterStateRouted);
                                    XCTAssertNotNil(destination);
                                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                        [destination didMoveToParentViewController:source];
                                        [self leaveTest];
                                    }];
                                } errorHandler:^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                    
                                }];
                            } errorHandler:nil];
                        }];
                    }];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformWithError {
    XCTestExpectation *providerErrorExpectation = [self expectationWithDescription:@"providerErrorHandler"];
    XCTestExpectation *performerErrorExpectation = [self expectationWithDescription:@"performerErrorHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput) performFromSource:nil configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.successHandler = ^(id  _Nonnull destination) {
                    XCTAssert(NO, @"successHandler should not be called");
                };
                config.performerSuccessHandler = ^(id  _Nonnull destination) {
                    XCTAssert(NO, @"successHandler should not be called");
                };
                config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                    XCTAssertNotNil(error);
                    [providerErrorExpectation fulfill];
                };
                config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                    XCTAssertNotNil(error);
                    [performerErrorExpectation fulfill];
                    [self handle:^{
                        XCTAssert(self.router == nil || self.router.state == ZIKRouterStateUnrouted);
                        [self leaveTest];
                    }];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformOnDestinationSuccess {
    XCTestExpectation *successHandlerExpectation = [self expectationWithDescription:@"successHandler"];
    XCTestExpectation *performerSuccessHandlerExpectation = [self expectationWithDescription:@"performerSuccessHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            id destination = [ZIKRouterToView(AViewInput) makeDestination];
            self.router = [ZIKRouterToView(AViewInput) performOnDestination:destination fromSource:source configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.successHandler = ^(UIViewController * _Nonnull destination) {
                    [successHandlerExpectation fulfill];
                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                        [destination didMoveToParentViewController:source];
                        [self handle:^{
                            [self leaveTest];
                        }];
                    }];
                };
                config.performerSuccessHandler = ^(id  _Nonnull destination) {
                    [performerSuccessHandlerExpectation fulfill];
                };
                config.completionHandler = ^(BOOL success, id _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                    XCTAssertTrue(success);
                    [completionHandlerExpectation fulfill];
                };
                config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                    XCTAssert(NO, @"errorHandler should not be called");
                };
                config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                    XCTAssert(NO, @"performerErrorHandler should not be called");
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testPerformOnDestinationError {
    XCTestExpectation *errorHandlerExpectation = [self expectationWithDescription:@"errorHandler"];
    XCTestExpectation *performerErrorHandlerExpectation = [self expectationWithDescription:@"performerErrorHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            id invalidDestination = nil;
            self.router = [ZIKRouterToView(AViewInput) performOnDestination:invalidDestination fromSource:source configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                [self configRouteConfiguration:config source:source];
                config.routeType = self.routeType;
                config.successHandler = ^(id  _Nonnull destination) {
                    XCTAssert(NO, @"successHandler should not be called");
                };
                config.performerSuccessHandler = ^(id  _Nonnull destination) {
                    XCTAssert(NO, @"performerSuccessHandler should not be called");
                };
                config.completionHandler = ^(BOOL success, UIViewController * _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                    XCTAssertFalse(success);
                    XCTAssertNotNil(error);
                    [completionHandlerExpectation fulfill];
                    [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                        [destination didMoveToParentViewController:source];
                        [self handle:^{
                            [self leaveTest];
                        }];
                    }];
                };
                config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                    [errorHandlerExpectation fulfill];
                };
                config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                    [performerErrorHandlerExpectation fulfill];
                };
            }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}


#pragma mark Strict

- (void)testStrictPerformWithPrepareDestination {
    XCTestExpectation *expectation = [self expectationWithDescription:@"prepareDestination"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput)
                           performFromSource:source
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^prepareDest)(void (^)(id<AViewInput> destination)),
                                               void (^prepareModule)(void (^)(ZIKViewRouteConfig *config))) {
                               [self configRouteConfiguration:config source:source];
                               config.routeType = self.routeType;
                               prepareDest(^(id<AViewInput> destination) {
                                   destination.title = @"test title";
                               });
                               config.successHandler = ^(UIViewController<AViewInput> * _Nonnull destination) {
                                   XCTAssertNotNil(destination);
                                   XCTAssert([destination.title isEqualToString:@"test title"]);
                                   [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                       [destination didMoveToParentViewController:source];
                                       [expectation fulfill];
                                       [self handle:^{
                                           XCTAssert(self.router.state == ZIKRouterStateRouted);
                                           [self leaveTest];
                                       }];
                                   }];
                               };
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformWithSuccessCompletionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput)
                           performFromSource:source
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^prepareDest)(void (^)(id<AViewInput> destination)),
                                               void (^prepareModule)(void (^)(ZIKViewRouteConfig *config))) {
                               [self configRouteConfiguration:config source:source];
                               config.routeType = self.routeType;
                               config.completionHandler = ^(BOOL success, UIViewController *_Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                                   XCTAssertTrue(success);
                                   XCTAssertNil(error);
                                   [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                       [destination didMoveToParentViewController:source];
                                       [expectation fulfill];
                                       [self handle:^{
                                           XCTAssert(self.router.state == ZIKRouterStateRouted);
                                           [self leaveTest];
                                       }];
                                   }];
                               };
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformWithErrorCompletionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput)
                           performFromSource:nil
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^prepareDest)(void (^)(id<AViewInput> destination)),
                                               void (^prepareModule)(void (^)(ZIKViewRouteConfig *config))) {
                               [self configRouteConfiguration:config source:source];
                               config.routeType = self.routeType;
                               config.completionHandler = ^(BOOL success, id  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                                   XCTAssertFalse(success);
                                   XCTAssertNotNil(error);
                                   [expectation fulfill];
                                   [self handle:^{
                                       XCTAssert(self.router == nil || self.router.state == ZIKRouterStateUnrouted);
                                       [self leaveTest];
                                   }];
                               };
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformWithSuccess {
    XCTestExpectation *expectation = [self expectationWithDescription:@"successHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput)
                           performFromSource:source
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^prepareDest)(void (^)(id<AViewInput> destination)),
                                               void (^prepareModule)(void (^)(ZIKViewRouteConfig *config))) {
                               [self configRouteConfiguration:config source:source];
                               config.routeType = self.routeType;
                               config.successHandler = ^(UIViewController *_Nonnull destination) {
                                   XCTAssertNotNil(destination);
                                   [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                       [destination didMoveToParentViewController:source];
                                       [expectation fulfill];
                                       [self handle:^{
                                           XCTAssert(self.router.state == ZIKRouterStateRouted);
                                           [self leaveTest];
                                       }];
                                   }];
                               };
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformWithPerformerSuccess {
    XCTestExpectation *successHandlerExpectation = [self expectationWithDescription:@"successHandler"];
    successHandlerExpectation.expectedFulfillmentCount = 2;
    XCTestExpectation *performerSuccessHandlerExpectation = [self expectationWithDescription:@"performerSuccessHandler once"];
    performerSuccessHandlerExpectation.assertForOverFulfill = YES;
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput)
                           performFromSource:source
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^prepareDest)(void (^)(id<AViewInput> destination)),
                                               void (^prepareModule)(void (^)(ZIKViewRouteConfig *config))) {
                               [self configRouteConfiguration:config source:source];
                               config.routeType = self.routeType;
                               config.successHandler = ^(id  _Nonnull destination) {
                                   XCTAssertNotNil(destination);
                                   [successHandlerExpectation fulfill];
                               };
                               config.performerSuccessHandler = ^(UIViewController * _Nonnull destination) {
                                   XCTAssertNotNil(destination);
                                   [performerSuccessHandlerExpectation fulfill];
                                   
                                   [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                       [destination didMoveToParentViewController:source];
                                       [self handle:^{
                                           XCTAssert(self.router.state == ZIKRouterStateRouted);
                                           [self.router removeRouteWithSuccessHandler:^{
                                               XCTAssert(self.router.state == ZIKRouterStateRemoved);
                                               [self.router performRouteWithSuccessHandler:^(UIViewController<AViewInput> *_Nonnull destination) {
                                                   XCTAssert(self.router.state == ZIKRouterStateRouted);
                                                   XCTAssertNotNil(destination);
                                                   [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                                       [destination didMoveToParentViewController:source];
                                                       [self leaveTest];
                                                   }];
                                               } errorHandler:^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                                   
                                               }];
                                           } errorHandler:nil];
                                       }];
                                   }];
                               };
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformWithError {
    XCTestExpectation *providerErrorExpectation = [self expectationWithDescription:@"providerErrorHandler"];
    XCTestExpectation *performerErrorExpectation = [self expectationWithDescription:@"performerErrorHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            self.router = [ZIKRouterToView(AViewInput)
                           performFromSource:nil
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^prepareDest)(void (^)(id<AViewInput> destination)),
                                               void (^prepareModule)(void (^)(ZIKViewRouteConfig *config))) {
                               [self configRouteConfiguration:config source:source];
                               config.routeType = self.routeType;
                               config.successHandler = ^(id  _Nonnull destination) {
                                   XCTAssert(NO, @"successHandler should not be called");
                               };
                               config.performerSuccessHandler = ^(id  _Nonnull destination) {
                                   XCTAssert(NO, @"successHandler should not be called");
                               };
                               config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                   XCTAssertNotNil(error);
                                   [providerErrorExpectation fulfill];
                               };
                               config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                   XCTAssertNotNil(error);
                                   [performerErrorExpectation fulfill];
                                   [self handle:^{
                                       XCTAssert(self.router == nil || self.router.state == ZIKRouterStateUnrouted);
                                       [self leaveTest];
                                   }];
                               };
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformOnDestinationSuccess {
    XCTestExpectation *successHandlerExpectation = [self expectationWithDescription:@"successHandler"];
    XCTestExpectation *performerSuccessHandlerExpectation = [self expectationWithDescription:@"performerSuccessHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            id destination = [ZIKRouterToView(AViewInput) makeDestination];
            self.router = [ZIKRouterToView(AViewInput)
                           performOnDestination:destination
                           fromSource:source
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^ _Nonnull prepareDest)(void (^ _Nonnull)(id<AViewInput> _Nonnull)),
                                               void (^ _Nonnull prepareModule)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))) {
                               [self configRouteConfiguration:config source:source];
                               prepareModule(^(ZIKViewRouteConfiguration *config) {
                                   config.routeType = self.routeType;
                                   config.successHandler = ^(UIViewController * _Nonnull destination) {
                                       [successHandlerExpectation fulfill];
                                       [[self class] addChildToParentView:source.view childView:destination.view completion:^{
                                           [destination didMoveToParentViewController:source];
                                           [self handle:^{
                                               [self leaveTest];
                                           }];
                                       }];
                                   };
                                   config.performerSuccessHandler = ^(id  _Nonnull destination) {
                                       [performerSuccessHandlerExpectation fulfill];
                                   };
                                   config.completionHandler = ^(BOOL success, id _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                                       XCTAssertTrue(success);
                                       [completionHandlerExpectation fulfill];
                                   };
                                   config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                       XCTAssert(NO, @"errorHandler should not be called");
                                   };
                                   config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                       XCTAssert(NO, @"performerErrorHandler should not be called");
                                   };
                               });
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

- (void)testStrictPerformOnDestinationError {
    XCTestExpectation *errorHandlerExpectation = [self expectationWithDescription:@"errorHandler"];
    XCTestExpectation *performerErrorHandlerExpectation = [self expectationWithDescription:@"performerErrorHandler"];
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completionHandler"];
    {
        [self enterTest:^(UIViewController *source) {
            id invalidDestination = nil;
            self.router = [ZIKRouterToView(AViewInput)
                           performOnDestination:invalidDestination
                           fromSource:source
                           strictConfiguring:^(ZIKViewRouteConfiguration * _Nonnull config,
                                               void (^ _Nonnull prepareDest)(void (^ _Nonnull)(id<AViewInput> _Nonnull)),
                                               void (^ _Nonnull prepareModule)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))) {
                               [self configRouteConfiguration:config source:source];
                               prepareModule(^(ZIKViewRouteConfiguration *config) {
                                   config.routeType = self.routeType;
                                   config.successHandler = ^(id  _Nonnull destination) {
                                       XCTAssert(NO, @"successHandler should not be called");
                                   };
                                   config.performerSuccessHandler = ^(id  _Nonnull destination) {
                                       XCTAssert(NO, @"performerSuccessHandler should not be called");
                                   };
                                   config.completionHandler = ^(BOOL success, id  _Nullable destination, ZIKRouteAction  _Nonnull routeAction, NSError * _Nullable error) {
                                       XCTAssertFalse(success);
                                       XCTAssertNotNil(error);
                                       [completionHandlerExpectation fulfill];
                                       [self handle:^{
                                           [self leaveTest];
                                       }];
                                   };
                                   config.errorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                       [errorHandlerExpectation fulfill];
                                   };
                                   config.performerErrorHandler = ^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
                                       [performerErrorHandlerExpectation fulfill];
                                   };
                               });
                           }];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        !error? : NSLog(@"%@", error);
    }];
}

@end

@interface ZIKViewRouterPerformAddAsChildWithoutAnimationTests : ZIKViewRouterPerformAddAsChildTests

@end

@implementation ZIKViewRouterPerformAddAsChildWithoutAnimationTests

+ (void)addChildToParentView:(UIView *)parentView childView:(UIView *)childView completion:(void(^)(void))completion {
    childView.frame = parentView.frame;
    childView.backgroundColor = [UIColor redColor];
    [parentView addSubview:childView];
    if (completion) {
        completion();
    }
}

@end
