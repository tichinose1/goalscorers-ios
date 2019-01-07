//
//  Association.swift
//  Goalscorer
//
//  Created by tichinose1 on 2018/12/31.
//  Copyright © 2018 example.com. All rights reserved.
//

import CoreLocation
import RealmSwift

@objcMembers
class Association: Object {
    dynamic var name: String = ""
    dynamic var regionCode: String = ""
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    let competitions = LinkingObjects(fromType: Competition.self, property: "association")

    convenience init(name: String, regionCode: String, latitude: Double, longitude: Double, competitions: [Competition], players: [Player]) {
        self.init()

        self.name = name
        self.regionCode = regionCode
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
