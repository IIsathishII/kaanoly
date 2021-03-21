//
//  KOClassExtensions.swift
//  Kaanoly
//
//  Created by SathishKumar on 27/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

extension NSView {
    
    func bringSubviewToFront(_ view: NSView) {
        var viewToSendToFront = view
        self.sortSubviews({ (viewA, viewB, rawPointer) in
            let view = rawPointer?.load(as: NSView.self)
            switch view {
                case viewA : return .orderedDescending
                case viewB : return .orderedAscending
                default : return .orderedSame
            }
            
        }, context: &viewToSendToFront)
    }
    
    func sendSubviewToBack(_ view: NSView) {
        var viewToSendToBack = view
        self.sortSubviews({ (viewA, viewB, rawPointer) in
            let view = rawPointer?.load(as: NSView.self)
            switch view {
                case viewA : return .orderedAscending
                case viewB : return .orderedDescending
                default : return .orderedSame
            }
            
        }, context: &viewToSendToBack)
    }
}

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
                case .moveTo: path.move(to: points[0])
                case .lineTo: path.addLine(to: points[0])
                case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePath: path.closeSubpath()
            }
        }
        return path
    }
}

extension CGDirectDisplayID {
    func getIOService() -> io_service_t {
        var serialPortIterator = io_iterator_t()
        var ioServ: io_service_t = 0

        let matching = IOServiceMatching("IODisplayConnect")

        let kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &serialPortIterator)
        if KERN_SUCCESS == kernResult && serialPortIterator != 0 {
            ioServ = IOIteratorNext(serialPortIterator)

            while ioServ != 0 {
                let info = IODisplayCreateInfoDictionary(ioServ, UInt32(kIODisplayOnlyPreferredName)).takeRetainedValue() as NSDictionary as! [String: AnyObject]
                let venderID = info[kDisplayVendorID] as? UInt32
                let productID = info[kDisplayProductID] as? UInt32
                let serialNumber = info[kDisplaySerialNumber] as? UInt32 ?? 0

                if CGDisplayVendorNumber(self) == venderID &&
                    CGDisplayModelNumber(self) == productID &&
                    CGDisplaySerialNumber(self) == serialNumber {
                    print("found the target io_service_t")
                    break
                }

                ioServ = IOIteratorNext(serialPortIterator)
            }

            IOObjectRelease(serialPortIterator)
        }

        return ioServ
    }
}

extension NSScreen {
    
    func getScreenNumber() -> CGDirectDisplayID? {
        return self.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID
    }
    
    func getDeviceName() -> String? {
        guard let displayID =
            deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID else {
            print( "can not get CGDirectDisplayID from NSScreen.")
            return nil
        }

        let ioServicePort = displayID.getIOService()
        if ioServicePort == 0 {
            print("can not get valide io_service_t.")
            return nil
        }

        guard let info = IODisplayCreateInfoDictionary(ioServicePort, UInt32(kIODisplayOnlyPreferredName)).takeRetainedValue() as? [String: AnyObject] else {
            print("IODisplayCreateInfoDictionary can not convert to [String: AnyObject]")
            return nil
        }

        if let productName = info["DisplayProductName"] as? [String: String],
            let firstKey = Array(productName.keys).first {
            return productName[firstKey]!
        }

        return nil
    }
}
