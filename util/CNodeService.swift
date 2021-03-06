//
//  CNodeService.swift
//  CNodeJS-Swift
//
//  Created by H on 2018/6/29.
//  Copyright © 2018年 H. All rights reserved.
//

import Foundation
import Moya

enum CNodeService {
    case topics(page: Int, tab: String)
    case topicDetail(id: String)
    case accessToken(token: String)
    case user(loginname: String)
    case collect(loginname: String, page: Int)
    case messages(token: String)
    case favorite(_ token: String, _ topic_id: String)
    case addReply(_ topic_id: String, _ accesstoken: String, _ content: String, _ reply_id: String?)
    case up(_ reply_id: String, _ accesstoken: String)
    case message_count(_ accesstoken: String)
    case message_mark_all(_ accesstoken: String)
}

extension CNodeService: TargetType {
    var baseURL: URL {
        return URL(string: "\(BASE_URL)/api/v1")!
    }
    
    var path: String {
        switch self {
        case .topics:
            return "/topics"
        case .topicDetail(let id):
            return "/topic/\(id)"
        case .accessToken:
            return "/accesstoken"
        case .user(let loginname):
            return "/user/\(loginname)"
        case .collect(let loginname, _):
            return "/topic_collect/\(loginname)"
        case .messages:
            return "/messages"
        case .favorite:
            return "/topic_collect/collect"
        case .addReply(let topic_id, _, _, _):
            return "/topic/\(topic_id)/replies"
        case .up(let reply_id, _):
            return "/reply/\(reply_id)/ups"
        case .message_count:
            return "/message/count"
        case .message_mark_all:
            return "/message/mark_all"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .topics, .topicDetail, .user, .collect, .messages, .message_count:
            return .get
        case .accessToken, .favorite, .addReply, .up, .message_mark_all:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .topics(let page, let tab):
            return .requestParameters(parameters: ["page": page, "tab": tab, "limit": 50], encoding: URLEncoding.default)
        case .topicDetail:
            return .requestPlain
        case .accessToken(let token), .messages(let token), .message_count(let token), .message_mark_all(let token):
            return .requestParameters(parameters: ["accesstoken": token], encoding: URLEncoding(destination: .queryString))
        case .user:
            return .requestPlain
        case .collect(_, let page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.default)
        case .favorite(let accesstoken, let topic_id):
            return .requestParameters(parameters: ["accesstoken": accesstoken, "topic_id": topic_id], encoding: JSONEncoding.default)
        case .addReply(let topic_id, let accesstoken, let content, let reply_id):
            return .requestParameters(parameters: ["topic_id": topic_id, "accesstoken": accesstoken, "content": content, "reply_id": reply_id as Any], encoding: JSONEncoding.default)
        case .up(let reply_id, let accesstoken):
            return .requestParameters(parameters: ["reply_id": reply_id, "accesstoken": accesstoken], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}

