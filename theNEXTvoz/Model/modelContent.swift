//
//  modelContent.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/22/22.
//

import Foundation
import SwiftSoup



struct contentModel{
    let id = UUID()
    var content : String
    var totalPage : String
    var currentPage : String
}

class CtManager{ 
    func fetchData(link: String) async throws -> [contentModel]{
        var arr:Array<contentModel> = Array()
        var contents = ""
        let to = TodoService()
        let todos = try await to.fetch(url: link)
        let document = try SwiftSoup.parse(todos).body()
        
        let cts = try document?.getElementsByClass("block-body").first()?.getElementsByClass("message")
        let currentPage = try document?.getElementsByClass("pageNav-page pageNav-page--current ").first()?.text() ?? "1"
        let totalPage = try document?.getElementsByClass("pageNav-page ").last()?.text() ?? "1"
    
         
        for index in 0..<(cts?.count ?? 0){
            contents += try cts!.get(index).outerHtml()
        }
        
        let contentDoc = try SwiftSoup.parse(contents).getElementsByClass("smilie smilie--emoji")
         
        for index in 0..<(contentDoc.count){
            contents = contents.replacingOccurrences(of: try contentDoc.get(index).outerHtml() , with: try contentDoc.get(index).attr("alt"))
        }
         
        contents = contents.replacingOccurrences(of: "\"/", with: "\"https://voz.vn/").replacingOccurrences(of: ", /", with: ", https://voz.vn/")
         
        arr.append(contentModel(content: contents, totalPage: totalPage, currentPage: currentPage))
        return arr
    }
    
}
