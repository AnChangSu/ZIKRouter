//
//  TestConfig.h
//  ZIKRouter
//
//  Created by zuik on 2018/4/18.
//  Copyright © 2018 zuik. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AUTO_REGISTER_ROUTERS 0

#define TEST_BLOCK_ROUTE 1

@interface TestConfig: NSObject
@property (nonatomic, class) BOOL routeShouldFail;
@end
