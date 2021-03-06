//
//  Extensions.swift
//  Goalscorer
//
//  Created by tichinose1 on 2018/10/22.
//  Copyright © 2018 example.com. All rights reserved.
//

import UIKit
import SafariServices
import FirebaseAnalytics

extension UIViewController {

    func presentSafariViewController(url: String, contentType: String, itemID: String) {
        // select_contentの場合、content_typeとitem_idしかダッシュボードで使えないようなので、コンテンツ名をitem_idで指定する
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: itemID,
                                                                     AnalyticsParameterContentType: contentType])

        guard let url = URL(string: url) else { fatalError() }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true) {
        }
    }

    func setScreenName(_ screenName: String) {
        Analytics.setScreenName(screenName, screenClass: classForCoder.description())
    }
}

extension JSONDecoder {
    // TODO: sharedでやっちゃっていいか検討する
    static let shared: JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {

    static let shared: JSONEncoder = {
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

extension UserDefaults {

    var favoriteScorers: Data? {
        get { return data(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}

import UIKit
import FlagKit

extension Association {

    var image: UIImage? {
        switch regionCode {
        case "CAF", "CAS", "CEU", "CNA", "COC", "CSA", "WW":
            return UIImage(named: regionCode)
        default:
            return Flag(countryCode: regionCode)?.image(style: .roundedRect)
        }
    }
}
