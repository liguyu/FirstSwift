//
//  DownloadHelper.swift
//  test
//
//  Created by apple on 2018/6/4.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class SyncHelper: NSObject {
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var url: String;
    
    public override init(syncurl url: Stirng) {
        self.url = url
        
    }
}
