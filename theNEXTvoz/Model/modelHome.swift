//
//  File.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import Foundation
import SwiftSoup
 

struct vozHome {
    let id = UUID()
    let headerSection:String
    let headerBody:[subFoModel]
}

struct subFoModel {
    let id = UUID()
    let title : String
    let link : String
    let infor : String
}
 

class NextVozManager { 
    func fetchData() async throws -> [vozHome] {
        var vozArr:Array<vozHome> = Array()
        let to = TodoService()
        let todos = try await to.fetch(url: "https://voz.vn")
        let document = try SwiftSoup.parse(todos).body()
        let blockContainer = try document?.getElementsByClass("p-body-pageContent").first()
        
        let block = try blockContainer?.getElementsByClass("block")
        
        for i in 0..<(block!.count) {
            var vozBod:Array<subFoModel> = Array()
            let myHeaderSection = try block?.get(i).getElementsByTag("h2").text() ?? ""
            let titleIndex = try block?.get(i).getElementsByClass("block-body").first()?.getElementsByClass("node")
            for titIndex in 0..<(titleIndex!.count){
                let myHeaderBody = try titleIndex?.get(titIndex).getElementsByClass("node-title").text() ?? ""
                let myHeaderLink = try titleIndex!.get(titIndex).getElementsByClass("node-title").first()!.getElementsByTag("a").first()!.attr("href")
                let subInfor = try titleIndex?.get(titIndex).getElementsByClass("node-statsMeta").text() ?? ""
                vozBod.append(subFoModel(title: myHeaderBody, link: "https://voz.vn"+myHeaderLink, infor: subInfor)) 
            }
            
            
            vozArr.append(vozHome(headerSection: myHeaderSection, headerBody: vozBod))
        }
        
        return vozArr
    }
}
