//
//  fetchData.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import Foundation

enum ErrorTodo: Error{
    case invlidRequest
    case failedToDecode
    case custom(error: Error)
}

class TodoService { 
    func fetch(url:String) async throws -> String {
        deleteCookies() 
        let htmlUrl = URL(string:url)!
        
        let urlRequest = URLRequest(url: htmlUrl)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
                  throw ErrorTodo.invlidRequest
              }
        
        
 //       let fields = response.allHeaderFields as? [String :String]
 //       let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields!, for: response.url!)
//        for cookie in cookies {
//                print("name: \(cookie.name) value: \(cookie.value)")
//            }
        let decode = String(decoding: data, as: UTF8.self)
        return decode
       // return String(decoding: data, as: UTF8.self)
    }
    
    func deleteCookies() {
        let DOMAIN_NAME = "voz.vn"
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies{
            for cookie in cookies {
                if(cookie.domain.contains(DOMAIN_NAME)){
                    storage.deleteCookie(cookie)
                }
            }
        }
    }
}

 
