//
//  TestAddAsChildViewController.m
//  ZIKRouterDemo
//
//  Created by zuik on 2017/7/5.
//  Copyright © 2017 zuik. All rights reserved.
//

#import "TestAddAsChildViewController.h"
@import ZIKRouter;
#import "ZIKInfoViewProtocol.h"

@interface TestAddAsChildViewController () <ZIKInfoViewDelegate>
@property (nonatomic, strong) ZIKViewRouter *infoViewRouter;
@end

@implementation TestAddAsChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)addAsChildViewController:(id)sender {
    __weak typeof(self) weakSelf = self;
    self.infoViewRouter = [ZIKViewRouterToView(ZIKInfoViewProtocol)
                           performFromSource:self
                           configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                               config.routeType = ZIKViewRouteTypeAddAsChildViewController;
                               config.prepareDestination = ^(id<ZIKInfoViewProtocol>  _Nonnull destination) {
                                   destination.delegate = weakSelf;
                                   destination.name = @"Zuik";
                                   destination.age = 18;
                               };
                               config.routeCompletion = ^(UIViewController * _Nonnull destination) {
                                    //If use containerWrapper to wrap destination in a container, router will add container as source's child, so you have to add container's view to source's view, not the destination's view, and call container's didMoveToParentViewController:
                                   destination.view.frame = weakSelf.view.frame;
                                   destination.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                   //ZIKViewRouter use UIViewController's transitionCoordinator to do completion, so this will let the router complete before animation real complete
                                   [UIView animateWithDuration:2 animations:^{
                                       destination.view.backgroundColor = [UIColor redColor];
                                       [weakSelf.view addSubview:destination.view];
                                       destination.view.transform = CGAffineTransformIdentity;
                                   } completion:^(BOOL finished) {
                                       [destination didMoveToParentViewController:weakSelf];
                                   }];
                               };
                               config.errorHandler = ^(ZIKRouteAction routeAction, NSError * _Nonnull error) {
                                   NSLog(@"addChildViewController failed: %@",error);
                               };
                           }];
}

- (void)removeInfoViewController {
    if (![self.infoViewRouter canRemove]) {
        NSLog(@"Can't remove router now:%@",self.infoViewRouter);
        return;
    }
    [self.infoViewRouter removeRouteWithSuccessHandler:^{
        NSLog(@"remove success");
    } errorHandler:^(ZIKRouteAction routeAction, NSError * _Nonnull error) {
        NSLog(@"remove failed,error:%@",error);
    }];
}

- (void)handleRemoveInfoViewController:(UIViewController *)infoViewController {
    [self removeInfoViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
