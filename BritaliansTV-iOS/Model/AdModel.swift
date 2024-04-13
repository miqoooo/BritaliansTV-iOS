//
//  AdModel.swift
//  BritaliansTV
//
//  Created by miqo on 12.11.23.
//

import Foundation

struct AdModel: Codable {
    var ad_url: String?
    var ad_interval: Int? = 1
    let video_url: String?
}
