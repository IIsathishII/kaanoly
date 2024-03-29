//
//  KOObjectSubscriber.swift
//  Kaanoly
//
//  Created by SathishKumar on 28/10/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation

var deinitCallbackKey = "DEINITCALLBACK"

class KOObjectSubscriber {
    
    static func onObjectDeinit(forObject object: NSObject,
                                 callbackId: String,
                                 callback: @escaping () -> ()) {
        let rem = deinitCallback(forObject: object)
        rem.callbacks.append(callback)
    }
    
    static fileprivate func deinitCallback(forObject object: NSObject) -> DeinitCallback {
        
        if let deinitCallback = objc_getAssociatedObject(object, &deinitCallbackKey) as? DeinitCallback {
            return deinitCallback
        } else {
            let rem = DeinitCallback()
            objc_setAssociatedObject(object, &deinitCallbackKey, rem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return rem
        }
    }
}

@objc fileprivate class DeinitCallback: NSObject {
  var callbacks: [() -> ()] = []
  deinit {
    callbacks.forEach({ $0() })
  }
}
