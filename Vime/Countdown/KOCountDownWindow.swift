//
//  KOCountDownWindow.swift
//  Kaanoly
//
//  Created by SathishKumar on 20.01.21.
//  Copyright © 2021 Ghost. All rights reserved.
//

import AppKit

class KOCountDownWindow : NSWindow {
    
    var countDownView = KOCountDownView.init()
    var count = 3
    
    init() {
        super.init(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear
        self.contentView = self.countDownView
    }
    
    func setupFrame() {
        self.setContentSize(NSSize.init(width: 100, height: 100))
    }
    
    func startCount(completion: @escaping () -> ()) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.count == 1 {
                timer.invalidate()
                completion()
            } else {
                self.countDownView.countLabel.stringValue = "\(self.count-1)"
                self.count -= 1
            }
        }
    }
}

class KOCountDownView : NSVisualEffectView {
    
    var countLabel = NSTextField.init(labelWithString: "3")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.material = .selection
        self.alphaValue = 0.8
        self.wantsLayer = true
        self.layer?.cornerRadius = 10
        self.layer?.backgroundColor = NSColor.black.cgColor
        self.setLabelProps()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelProps() {
        self.countLabel.font = NSFont.systemFont(ofSize: 75, weight: .bold)
        self.countLabel.textColor = NSColor.textColor
        
        self.addSubview(self.countLabel)
        self.countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.countLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.countLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
