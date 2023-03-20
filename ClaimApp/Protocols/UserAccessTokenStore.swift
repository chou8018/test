//
//  UserAccessTokenStore.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 15/7/19.
//  Copyright © 2019 Trusty Cars. All rights reserved.
//

import Foundation

protocol UserAccessTokenStore {
    var userAccessToken: AccessToken? { get set }
    func cleanAccessTokenToKeychain()
}
