//
//  KOMediaSettingConstants.swift
//  Kaanoly
//
//  Created by SathishKumar on 02/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation

class KOMediaSettings {
    
    public struct MediaSource : OptionSet {
        let rawValue: Int

        static let camera = MediaSource.init(rawValue: 1 << 0)
        static let screen = MediaSource.init(rawValue: 1 << 1)
        static let audio = MediaSource.init(rawValue: 1 << 2)
    }
}
