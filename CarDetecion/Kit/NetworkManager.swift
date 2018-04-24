//
//  NetworkManager.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/13.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let sharedInstall = NetworkManager() // 单例
    // 119.23.128.214 开发环境 119.23.19.66 生产环境
//    #if DEBUG
   //     let domain = "http://119.23.128.214:8080/carWeb"
//    #else
        let domain = "http://119.23.19.66:8080/carWeb"
   // #endif
    
    
    enum CustomError : Int , Error {
        case Custom
    }
    
    func request(url: String , params : Parameters? , callback : @escaping (_ json : JSON? ,_ error : Error?)->()) {
        var strUrl = "\(domain)/\(url)?"
        if let param = params {
            for (key, value) in param {
                strUrl += "&\(key)=\(value)"
            }
        }
        print("请求：\(strUrl)")
        Alamofire.request("\(domain)/\(url)", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print("是否为主线程:\(Thread.isMainThread)")
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print("返回内容：\(value)")
                    callback(JSON(value) , nil)
                }else{
                    callback(nil , CustomError.Custom)
                }
                
            case .failure(let error):
                callback(nil , error)
                Bugly.reportError(error)
            }
        }
    }
    
    func requestString(url: String , params : Parameters? , callback : @escaping (_ json : JSON? ,_ error : Error?)->()) {
        var strUrl = "\(domain)/\(url)?"
        if let param = params {
            for (key, value) in param {
                strUrl += "&\(key)=\(value)"
            }
        }
        print("请求：\(strUrl)")
        Alamofire.request("\(domain)/\(url)", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            print("是否为主线程:\(Thread.isMainThread)")
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print("返回内容：\(value)")
                    var json = value.replacingOccurrences(of: "}\n        },", with: "},")
                    json = json.replacingOccurrences(of: "\n", with: "")
                    json = json.replacingOccurrences(of: "\t", with: "")
                    json = json.replacingOccurrences(of: " ", with: "")
                    json = json.replacingOccurrences(of: ",}", with: "}")
                    do{
                        let data = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: .allowFragments)
                        callback(JSON(data) , nil)
                    }catch{
                        callback(nil , CustomError.Custom)
                    }
                    
                }else{
                    callback(nil , CustomError.Custom)
                }
                
            case .failure(let error):
                callback(nil , error)
                Bugly.reportError(error)
            }
        }
    }
    
    func upload(url: String , params : [String : String]? ,data : Data? , callback : @escaping (_ json : JSON? ,_ error : Error?)->()) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if data != nil {
                    multipartFormData.append(data!, withName: "image", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
                if params != nil {
                    for (key , value) in params! {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
                }
        },
            to: "\(domain)/\(url)",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value {
                            print("返回内容：\(value)")
                            callback(JSON(value), nil)
                        }else{
                            print("返回错误\(response.error?.localizedDescription ?? "")")
                            callback(nil, nil)
                        }
                        
                    }
                case .failure(let encodingError):
                    callback(nil , encodingError)
                }
        }
        )
    }
}
