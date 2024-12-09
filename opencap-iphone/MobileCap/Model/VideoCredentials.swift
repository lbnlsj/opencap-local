//
//  VideoCredentials.swift
//  OpenCap
//
//  Created by Nik on 17.04.2023.
//

import Foundation

struct VideoCredentials: Decodable {
    let url: String
    let key: String
    let accessKeyId: String
    let policy: String
    let signature: String

   enum CodingKeys: String, CodingKey {
        case url
        case fields
    }
    
    enum FieldsKeys: String, CodingKey {
        case key
        case accessKeyId = "AWSAccessKeyId"
        case policy
        case signature
    }
    
    // MARK: - init with decoder
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let fields = try values.nestedContainer(keyedBy: FieldsKeys.self, forKey: .fields)
        url = try values.decode(String.self, forKey: .url)
        key = try fields.decode(String.self, forKey: .key)
        accessKeyId = try fields.decode(String.self, forKey: .accessKeyId)
        policy = try fields.decode(String.self, forKey: .policy)
        signature = try fields.decode(String.self, forKey: .signature)
    }
}
