//
//  LoadState.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 22/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

enum LoadState {
    case notLoaded
    case loading
    case loaded
    case loadingMore
    case notMore
    case error(Error)
}
