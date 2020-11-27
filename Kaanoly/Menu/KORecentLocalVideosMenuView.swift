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
    
    var titleLabel = NSTextField.init(labelWithString: "Recent Videos")
    var recentVideosTableView = NSTableView.init()
    
    var videoPaths : [URL] = []
    
    init(paths: [URL]) {
        self.videoPaths = paths
        super.init(frame: .zero)
        self.setupTitle()
        self.setVideoThumbnails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitle() {
        self.titleLabel.font = NSFont.systemFont(ofSize: 12)
        self.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            
            self.widthAnchor.constraint(equalToConstant: 224)
        ])
    }
    
    func setVideoThumbnails() {
        self.recentVideosTableView.headerView = nil
        self.recentVideosTableView.delegate = self
        self.recentVideosTableView.dataSource = self
        if #available(OSX 11.0, *) {
            self.recentVideosTableView.style = .plain
        }
        
        let column = NSTableColumn.init()
        column.width = 224
        self.recentVideosTableView.headerView = nil
        self.recentVideosTableView.addTableColumn(column)
        
        self.addSubview(self.recentVideosTableView)
        self.recentVideosTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.recentVideosTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.recentVideosTableView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            self.recentVideosTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.recentVideosTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension KORecentLocalVideosMenuView : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = NSView.init()
        view.autoresizingMask = [.width]
        self.videoPaths[row].startAccessingSecurityScopedResource()
        let asset = AVURLAsset.init(url: self.videoPaths[row])
        let imageGen = AVAssetImageGenerator.init(asset: asset)
        imageGen.appliesPreferredTrackTransform = true
        var time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 60)
        var actualTime = CMTime.zero
        guard let image = try? imageGen.copyCGImage(at: time, actualTime: &actualTime) else { return nil }
        let thumbnail = NSImage.init(cgImage: image, size: .zero)
        let thumbnailView = NSImageView.init(image: thumbnail)
        thumbnailView.wantsLayer = true
        thumbnailView.layer?.cornerRadius = 5
        thumbnailView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.75).cgColor
        thumbnailView.layer?.borderColor = NSColor.black.withAlphaComponent(0.75).cgColor
        thumbnailView.layer?.borderWidth = 1.5
        view.addSubview(thumbnailView)
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        
        let duration = Int(ceil(CMTimeGetSeconds(asset.duration)))
        let formatter = DateComponentsFormatter.init()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        guard let durationVal = formatter.string(from: TimeInterval.init(duration)) else { return nil }
        var durationLabel = NSTextField.init(labelWithString: durationVal)
        durationLabel.font = NSFont.systemFont(ofSize: 9)
        view.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let assetName = asset.url.lastPathComponent
        var assetNameLabel = NSTextField.init(labelWithString: assetName)
        assetNameLabel.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        assetNameLabel.maximumNumberOfLines = 2
        assetNameLabel.lineBreakMode = .byCharWrapping
        assetNameLabel.usesSingleLineMode = false
        assetNameLabel.autoresizesSubviews = true
        assetNameLabel.cell?.wraps = true
        assetNameLabel.cell?.isScrollable = false
        assetNameLabel.cell?.truncatesLastVisibleLine = true
        view.addSubview(assetNameLabel)
        assetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            thumbnailView.heightAnchor.constraint(equalToConstant: 32),
            thumbnailView.widthAnchor.constraint(equalToConstant: 48),
            thumbnailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            durationLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor),
            durationLabel.centerXAnchor.constraint(equalTo: thumbnailView.centerXAnchor),
            
            assetNameLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 8),
            assetNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            assetNameLabel.topAnchor.constraint(equalTo: thumbnailView.topAnchor),
            assetNameLabel.bottomAnchor.constraint(equalTo: thumbnailView.bottomAnchor)
        ])
        self.videoPaths[row].stopAccessingSecurityScopedResource()
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 48
    }
}

extension KORecentLocalVideosMenuView : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.videoPaths.count
    }
    
    
}
