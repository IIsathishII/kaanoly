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
