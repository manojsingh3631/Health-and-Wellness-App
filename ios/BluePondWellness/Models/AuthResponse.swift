// AuthResponse.swift
// BluePond Wellness

import Foundation

struct AuthResponse: Codable {
    var accessToken: String
    var tokenType: String
    var expiresIn: Int
    var refreshToken: String
    var user: UserInfo

    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case tokenType    = "token_type"
        case expiresIn    = "expires_in"
        case refreshToken = "refresh_token"
        case user
    }

    struct UserInfo: Codable {
        var id: String
        var email: String

        enum CodingKeys: String, CodingKey {
            case id
            case email
        }
    }
}
