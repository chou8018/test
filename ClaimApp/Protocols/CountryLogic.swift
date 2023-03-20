//
//  CountryLogic.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 8/1/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import Foundation

protocol CountryLogic {
    var defaultLanguageCode: String { get }
}

extension CountryLogic {
    var defaultLanguageCode: String { return "en" }
}
