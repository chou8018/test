//
//  LNUploadImage.swift
//  dealers
//
//  Created by 付耀辉 on 2021/10/8.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit

class LNUploadImage: InitFailable, Codable, ArrayBuildable {
    let url: String
    let id: String
    
    let cdn_url: String
    let cdn_watermark_url: String
    let collection_name: String
    let file_name: String
    let thumbnail_url: String
    let updated_at: String
    let mime_type: String
    var base64: String?

    required init?(json: [String : Any]) {
        if json.keys.count == 0 {
            return nil
        }
        self.url = json.string("url") ?? ""
        self.id = json.number("id")?.stringValue ?? ""
        
        self.cdn_url = json.string("cdn_url") ?? ""
        self.cdn_watermark_url = json.string("cdn_watermark_url") ?? ""
        self.collection_name = json.string("collection_name") ?? ""
        self.file_name = json.string("file_name") ?? ""
        self.mime_type = json.string("mime_type") ?? ""
        self.thumbnail_url = json.string("thumbnail_url") ?? ""
        self.updated_at = json.string("updated_at") ?? ""

    }
    
    func jsonString() -> String {
        if let dic = dicValue() {
            return getJSONStringFromData(obj: dic)
        }
        return ""
    }

    func dicValue() -> [String:Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            do {
                guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {return nil}
                return dict
            } catch {
                return nil
            }
        } catch  {
            return nil
        }
    }
}
