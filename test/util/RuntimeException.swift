//
//  RuntimeException.swift
//  test
//
//  Created by apple on 2018/6/20.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

enum RuntimeException: Error {
    case error(String)
    case ok(String)
}
