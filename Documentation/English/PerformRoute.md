# Perform Route

You need get a router subclass for your destination module to perform route. You can use protocol to get router class.

ZIKRouter is written in Objective-C. If your project is in Swift, use `ZRouter`.

## Type Safe Perform

It's safe to perform route with routable protocol.

```swift
class TestViewController: UIViewController {
    func showEditorViewController() {
        Router.perform(
            to: RoutableView<NoteEditorInput>(),
            from: self,
            configuring: { (config, prepareDestiantion, _) in
                //Config the route
                //Config route type, such as push,present,show,showDetail,custom
                config.routeType = ViewRouteType.push
                config.routeCompletion = { destination in
                    //Transition completed
                }
                config.errorHandler = { (action, error) in
                    //Transition failed
                }
                //Config the destination before performing route
                prepareDestination({ destination in
                    //destination is inferred as NoteEditorInput
                    //Config editor view
                    destination.delegate = self
                    destination.constructForCreatingNewNote()
                })
        })
    }
}
```

## Switchable Perform

When a route is for showing views from a limited list, you can use `Switchable`.

```swift
enum RequestError: Error {
    case invalidAccount
    case networkNotConnected
}

class TestViewController: UIViewController {
    func showViewForError(_ error: RequestError) {
        var switchableView: SwitchableView
        switch error {
        case invalidAccount:
            switchableView = SwitchableView(RoutableView<LoginViewInput>())
        case networkNotConnected:
            switchableView = SwitchableView(RoutableView<NetworkDisconnectedViewInput>())
        }
        Router.to(switchableView)?.perform(from: self, routeType: .push)
    }
}
```

## Dynamic Perform

When you need highly dynamic routing, you can perform route with protocol's name string:

```swift
func handleOpenURLWithViewName(_ viewName: String) {
    Router.to(dynamicView: viewName)?.perform(from: self, routeType: .push)
    }

```
You should only use this when you really need it. If the protocol name is wrong, the routing will be failed. So it's not that safe.

## Perform in Objective-C

```objectivec
@implementation TestViewController

- (void)showEditorViewController {
	[ZIKRouterToView(NoteEditorInput)
	          performFromSource:self
	          configuring:^(ZIKViewRouteConfiguration *config) {
	              config.routeType = ZIKViewRouteTypePresentModally;
	              config.animated = YES;
	              config.prepareDestination = ^(id<NoteEditorInput> destination) {
	                  destination.delegate = self;
	                  [destination constructForCreatingNewNote];
	              };
	              config.routeCompletion = ^(id<NoteEditorInput> destination) {
	                  //Transition completed
	              };
	              config.errorHandler = ^(ZIKRouteAction routeAction, NSError *error) {
	                  //Transition failed
	              };
	          }];
}
```

It's much safer to prepare destination in `prepareDest` or `prepareModule` block with those strict methods: 

```objectivec
@implementation TestViewController

- (void)showEditorViewController {
	[ZIKRouterToView(NoteEditorInput)
	          performFromSource:self
	          strictConfiguring:^(ZIKViewRouteConfiguration *config,
	          					  void (^prepareDest)(void (^)(id<NoteEditorInput>)),
                        		  void (^prepareModule)(void (^)(ZIKViewRouteConfig *))) {
	              config.routeType = ZIKViewRouteTypePresentModally;
	              config.animated = YES;
	              //Type of prepareDest block changes with the router's generic parameters.
	              prepareDest(^(id<NoteEditorInput> destination){
	                  destination.delegate = self;
	                  [destination constructForCreatingNewNote];
	              });
	              config.routeCompletion = ^(id<NoteEditorInput> destination) {
	                  //Transition completed
	              };
	              config.errorHandler = ^(ZIKRouteAction routeAction, NSError *error) {
	                  //Transition failed
	              };
	          }];
}
```

Type of `prepareDest` and `prepareModule` block changes with the router's generic parameters. So there will be compile checking when you change the protocol in `ZIKRouterToView()`.

But there is bug in Xcode auto completions. These parameters in block are not correctly completed, you have to manually fix the code.

## Lazy Perform

You can create the router, then perform it later. This let you separate the router's provider and performer.

When performer performs the router, it may fail. The router may be performed already and can't be performed unless it's removed. So the performer need to check the router's state.

```swift
class TestViewController: UIViewController {
    var router: DestinationViewRouter<EditorViewInput>?
    func viewDidLoad() {
        super.viewDidLoad()
        router = Router.to(RoutableView<EditorViewInput>())
    }
    
    func showEditor() {
        guard let router = self.router, router.canPerform else {
            return
        }
        router?.perform(from: self, routeType: .push)
    }
}
```

<details><summary>Objective-C Sample</summary>

```objectivec
@implementation ZIKTestPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.router = [[ZIKViewRouter.classToView(ZIKRoutableProtocol(EditorViewInput)) alloc]
                           initWithConfiguring:^(ZIKViewRouteConfiguration *config) {
                               config.source = self;
                               config.routeType = ZIKViewRouteTypePush;
                           }
                           removing:nil];
}
- (void)showEditor {
    if (![self.router canPerform]) {
        NSLog(@"Can't perform route now:%@",self.router);
        return;
    }
    [self.router performRouteWithSuccessHandler:^{
        NSLog(@"did show editor");
    } errorHandler:^(SEL routeAction, NSError *error) {
        NSLog(@"failed to show editor with error: %@",error);
    }];
}
@end
```

</details>

## Custom Transition

### View Router

Steps to support custom transition:

1. Override `supportedRouteTypes`, add`ZIKViewRouteTypeCustom`
2. If the router needs to validate the configuration, override `-validateCustomRouteConfiguration:removeConfiguration:`
3. Override `canPerformCustomRoute` to check whether the router can perform route now because the default return value is false
4. Override `performCustomRouteOnDestination:fromSource:configuration:` to do custom transition. If the transition is performing a segue, use `_performSegueWithIdentifier:fromSource:sender:`
5. Manage router's state with `beginPerformRoute`、`endPerformRouteWithSuccess`、`endPerformRouteWithError:`

### Service Router

If you want to do custom route action, override `-performRouteOnDestination:configuration:`.

Most service routers are just for getting a service object. You can use [Make Destination](MakeDestination.md).

After performing, you will get a router instance. You can hold the router and remove route later. See [Remove Route](RemoveRoute.md).