//
//  KORecentLocalVideosMenuView.swift
//  Kaanoly
//
//  Created by SathishKumar on 30/10/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import AVFoundation

class KORecentLocalVideosMenuView : NSView {
    
    var thumbnail = NSImageView.init()
    var durationLabel = NSTextField.init(labelWithString: "")
    var assetNameLabel = NSTextField.init(labelWithString: "")
    
    var assetUrl : URL
    
    var isDragged = false
    
    init(url: URL) {
        self.assetUrl = url
        super.init(frame: .zero)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.assetUrl.startAccessingSecurityScopedResource()
        let asset = AVURLAsset.init(url: self.assetUrl)
        let imageGen = AVAssetImageGenerator.init(asset: asset)
        imageGen.appliesPreferredTrackTransform = true
        var time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 60)
        var actualTime = CMTime.zero
        var thumbnailImage : NSImage
        let image = try? imageGen.copyCGImage(at: time, actualTime: &actualTime)
        if image != nil {
            thumbnailImage = NSImage.init(cgImage: image!, size: .zero)
        } else {
            // TODO :: Add dummy image in case thumbnail is not available
            thumbnailImage = NSImage.init()
        }
        thumbnail.image = thumbnailImage
        thumbnail.wantsLayer = true
        thumbnail.layer?.backgroundColor = NSColor.black.cgColor
        self.addSubview(thumbnail)
        thumbnail.translatesAutoresizingMaskIntoConstraints = false

        let duration = Int(ceil(CMTimeGetSeconds(asset.duration)))
        let formatter = DateComponentsFormatter.init()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        let durationVal = formatter.string(from: TimeInterval.init(duration)) ?? ""

        self.durationLabel.stringValue = durationVal
        durationLabel.font = NSFont.systemFont(ofSize: 9)
        durationLabel.textColor = NSColor.secondaryLabelColor
        self.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        let assetName = asset.url.deletingPathExtension().lastPathComponent
        self.assetNameLabel.stringValue = assetName
        assetNameLabel.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        assetNameLabel.maximumNumberOfLines = 2
        assetNameLabel.lineBreakMode = .byCharWrapping
        assetNameLabel.usesSingleLineMode = false
        assetNameLabel.autoresizesSubviews = true
        assetNameLabel.cell?.wraps = true
        assetNameLabel.cell?.isScrollable = false
        assetNameLabel.cell?.truncatesLastVisibleLine = true
        self.addSubview(assetNameLabel)
        assetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnail.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            thumbnail.heightAnchor.constraint(equalToConstant: 48),
            thumbnail.widthAnchor.constraint(equalToConstant: 64),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),

            durationLabel.topAnchor.constraint(equalTo: assetNameLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: assetNameLabel.leadingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: assetNameLabel.trailingAnchor),

            assetNameLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 8),
            assetNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            assetNameLabel.topAnchor.constraint(equalTo: thumbnail.topAnchor),
            
            self.widthAnchor.constraint(equalToConstant: 240),
            self.heightAnchor.constraint(equalToConstant: 64)
        ])
        self.assetUrl.stopAccessingSecurityScopedResource()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.isDragged = false
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if let item = self.enclosingMenuItem, let menu = item.menu {
            menu.cancelTracking()
            menu.performActionForItem(at: menu.index(of: item))
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if !self.isDragged {
            self.beginDragging()
        }
    }

    func beginDragging() {
        let item = NSDraggingItem.init(pasteboardWriter: self.assetUrl as NSURL)
        item.setDraggingFrame(self.thumbnail.bounds, contents: self.thumbnail.image)
        self.beginDraggingSession(with: [item], event: self.window?.currentEvent ?? NSEvent.init(), source: self)
    }
    
    deinit {
        
    }
}

extension KORecentLocalVideosMenuView : NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        if context == .outsideApplication {
            return .copy
        }
        return []
    }
}
