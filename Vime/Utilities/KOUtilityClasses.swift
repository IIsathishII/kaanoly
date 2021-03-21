//
//  KOUtilityClasses.swift
//  Kaanoly
//
//  Created by SathishKumar on 08/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation

class WeakArrayElement<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}
