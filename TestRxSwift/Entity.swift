//
//  Entity.swift
//  TestRxSwift
//
//  Created by Zhicong Zang on 9/20/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Argo
import Moya
import Curry

struct User {
    let name: String
    let userToken: String
}

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return curry(self.init)
            <^> json <| "name"
            <*> json <| "user_token"
    }
}

enum ResponseResult {
    case succeed(user: User)
    case faild(message: String)
    
    var user: User? {
        switch self {
        case let .succeed(user):
            return user
        default:
            return nil
        }
    }
}

extension ResponseResult: Decodable {
    init(statusCode: Int, message: String, user: User?) {
        if let user = user where statusCode == 200 {
            self = .succeed(user: user)
        } else {
            self = .faild(message: message)
        }
    }
    
    static func decode(json: JSON) -> Decoded<ResponseResult> {
        return curry(self.init)
            <^> json <| "status_code"
            <*> json <| "message"
            <*> json <|? "user"
    }
}

enum ValidateResult {
    case succeed
    case faild(message: String)
    case empty
}

infix operator ^-^ {}
func ^-^(lhs: ValidateResult, rhs: ValidateResult) -> Bool {
    switch(lhs, rhs) {
    case (.succeed, .succeed):
        return true
    default:
        return false
    }
}

enum RequestTarget {
    case login(telNum: String, password: String)
}

extension RequestTarget: TargetType {
    var baseURL: NSURL {
        return NSURL(string: "")!
    }
    
    var path: String {
        return "/login"
    }
    
    var method: Moya.Method {
        return .POST
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case let .login(telNum, password):
            return ["tel_num": telNum, "password": password]
        default:
            return nil
        }
    }
    
    var sampleData: NSData {
        let jsonString = "{\"status_code\":200, \"message\":\"登录成功\", \"user\":{\"name\":\"Tangent\",\"user_token\":\"abcdefg123456\"}}"
        return jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
}



















