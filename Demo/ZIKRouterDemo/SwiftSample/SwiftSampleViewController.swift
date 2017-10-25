//
//  SwiftSampleViewController.swift
//  ZIKRouterDemo
//
//  Created by zuik on 2017/9/8.
//  Copyright © 2017 zuik. All rights reserved.
//

import UIKit
import ZIKRouter
import ZIKRouterSwift

///Mark the protocol routable 
@objc protocol SwiftSampleViewProtocol: ZIKViewRoutable {
    
}

class SwiftSampleViewController: UIViewController, SwiftSampleViewProtocol, ZIKInfoViewDelegate {
    var infoRouter: ZIKViewRouter<ZIKViewRouteConfiguration, ZIKViewRemoveConfiguration>?
    var alertRouter: ZIKViewRouter<ZIKViewRouteConfiguration & ZIKCompatibleAlertConfigProtocol, ZIKViewRemoveConfiguration>?
    
    //You can inject alertRouterClass from outside, then use the router directly
    var alertRouterClass: ZIKViewRouter<ZIKViewRouteConfiguration & ZIKCompatibleAlertConfigProtocol, ZIKViewRemoveConfiguration>.Type!
    
    @IBAction func testRouteForView(_ sender: Any) {
        self.infoRouter = Router.router(forViewProtocol: ZIKInfoViewProtocol.self)?.perform { config in
            config.source = self
            config.routeType = ZIKViewRouteType.presentModally
            config.prepareForRoute = { [weak self] d in
                guard let destination = d as? ZIKInfoViewProtocol else {
                    return
                }
                destination.delegate = self
                destination.name = "zuik"
                destination.age = 18
            }
        }
    }
    
    func handleRemoveInfoViewController(_ infoViewController: UIViewController!) {
        self.infoRouter?.removeRoute(successHandler: {
            print("remove success")
        }, performerErrorHandler: { (action, error) in
            print("remove failed,error:%@",error)
        })
    }
    
    @IBAction func testRouteForConfig(_ sender: Any) {
        let router: ZIKViewRouter<ZIKViewRouteConfiguration, ZIKViewRemoveConfiguration>?
        
        router = Router.router(forViewConfig: ZIKCompatibleAlertConfigProtocol.self)?.perform { configuration in
            let config = configuration as! ZIKViewRouteConfiguration & ZIKCompatibleAlertConfigProtocol
            config.source = self
            config.title = "Compatible Alert"
            config.message = "Test custom route for alert with UIAlertView and UIAlertController"
            config.addCancelButtonTitle("Cancel", handler: {
                print("Tap cancel alert")
            })
            config.addOtherButtonTitle("Hello", handler: {
                print("Tap Hello alert")
            })
            config.routeCompletion = { d in
                print("show custom alert complete")
            }
            config.performerErrorHandler = { (action, error) in
                print("show custom alert failed: %@",error)
            }
        }
        self.alertRouter = (router as! ZIKViewRouter<ZIKViewRouteConfiguration & ZIKCompatibleAlertConfigProtocol, ZIKViewRemoveConfiguration>)
    }
    
    @IBAction func testInjectedRouter(_ sender: Any) {
        let router = self.alertRouterClass.perform { config in
            config.source = self
            config.title = "Compatible Alert"
            config.message = "Test custom route for alert with UIAlertView and UIAlertController"
            config.addCancelButtonTitle("Cancel", handler: {
                print("Tap cancel alert")
            })
            config.addOtherButtonTitle("Hello", handler: {
                print("Tap Hello alert")
            })
            config.routeCompletion = { d in
                print("show custom alert complete")
            }
            config.performerErrorHandler = { (action, error) in
                print("show custom alert failed: %@",error)
            }
        }
        self.alertRouter = router
    }

    @IBAction func testRouteForSwiftService(_ sender: Any) {
        let service = Router.destination(forServiceProtocol: SwiftServiceInput.self)
        service?.swiftFunction()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}