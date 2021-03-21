//
//  KOPartOfScreenSelectionView.swift
//  Kaanoly
//
//  Created by SathishKumar on 09/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

protocol KOPartOfScreenSelectionViewDelegate : class {
    
    func selectionAreaSelected()
}

class KOPartOfScreenSelectionView : NSView {
    
    var viewDelegate : KOPartOfScreenSelectionViewDelegate?
    
    var confirmButton : KOCircularImageButton = KOCircularImageButton.init(color: KOStyleProperties.Color.acceptButtonColor, image: NSImage.init(named: "acceptCheck")!)
    
    init() {
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.setConfirmButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConfirmButton() {
        self.addSubview(self.confirmButton)
        self.confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.confirmButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.confirmButton.widthAnchor.constraint(equalToConstant: 48),
            self.confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        self.confirmButton.target = self
        self.confirmButton.action = #selector(handleConfirm)
    }
    
    @objc func handleConfirm() {
        self.viewDelegate?.selectionAreaSelected()
    }
}
