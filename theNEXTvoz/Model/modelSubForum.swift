//
//  modelSubForum.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import Foundation
import SwiftSoup

struct subForumModel {
    let id = UUID()
    var threadData : [subThreadModel]
    let subForum : [subFoModel] //from modelHome
    var totalPage : String
    var currentPage : String
    let haveSubForums : Bool
} 

struct subThreadModel {
    let id = UUID()
    let title : String
    let userName : String
    let prefix : String?
    let link : String
    let isSticky : Bool
    let infor : String
}

class SubForumManager {
    
    func fetchUpdateThreads(vozArr: [subForumModel], url: String, gotoPage: Int) async throws -> [subForumModel] {
        var vozArr = vozArr 
        var subthreArr:Array<subThreadModel> = Array()
        let to = TodoService()
        let todos = try await to.fetch(url: url+"page-"+String(gotoPage))
        let document = try SwiftSoup.parse(todos).body()
        let block = try document?.getElementsByClass("p-body-pageContent").first?.getElementsByClass("block")
          
        if ( try block!.first()!.className() == "block"){
            let thread = try block?.last()?.getElementsByClass("structItem")
            for i in 0..<(thread!.count){
                let subTit = try thread!.get(i).getElementsByClass("structItem-title").first()!.getElementsByTag("a")
                let subLink = try thread!.get(i).getElementsByClass("structItem-title").first()!.getElementsByTag("a").last()!.attr("href")
                let subUsername = try thread!.get(i).getElementsByClass("structItem-minor").first()!.getElementsByTag("a").first()!.text()
                let replies = try thread!.get(i).getElementsByClass("structItem-cell structItem-cell--meta").first()?.getElementsByClass("pairs pairs--justified").first()?.text() ?? "N/A"
                let time = try thread!.get(i).getElementsByClass("structItem-latestDate u-dt").first()?.text() ?? "N/A"
                let subInfor = replies + "  \u{2022}  " + time
                let sticky = try thread!.get(i).getElementsByClass("structItem-status structItem-status--sticky").count
                
                subthreArr.append(subThreadModel(title: try subTit.last()!.text(), userName: subUsername, prefix: subTit.count == 2 ? try subTit.first()!.text() : nil, link: "https://voz.vn"+subLink, isSticky: sticky == 1 ? true : false, infor: subInfor))
            }
        }else {
            // truyen voz f17
            let thread = try block?.last()?.getElementsByClass("block-body").first()?.getElementsByClass("message")
            for i in 0..<(thread!.count){
                let subName = try thread!.get(i).getElementsByClass("articlePreview-title").text()
                let subUsername = try thread!.get(i).getElementsByClass("username").text()
                let subInfor = try thread!.get(i).getElementsByClass("articlePreview-replies").text() + "  \u{2022}  Started By: " +  thread!.get(i).getElementsByClass("u-dt").text()
                let subLink = try thread!.get(i).getElementsByClass("articlePreview-title").first()!.getElementsByTag("a").attr("href")
                subthreArr.append(subThreadModel(title: subName, userName: subUsername, prefix: nil, link: "https://voz.vn"+subLink, isSticky: false, infor: subInfor))
            }
        }
        vozArr[0].totalPage = try document?.getElementsByClass("pageNav-main").first()?.getElementsByTag("li").last()?.text() ?? "1"
        vozArr[0].currentPage = try document?.getElementsByClass("pageNav-page pageNav-page--current ").first()?.text() ?? "1"
        vozArr[0].threadData = subthreArr
        
        return vozArr
    }
    
    func fetchData(url: String) async throws -> [subForumModel] {
        var vozArr:Array<subForumModel> = Array()
        var subfoArr:Array<subFoModel> = Array()
        var subthreArr:Array<subThreadModel> = Array()
        let to = TodoService()
        let todos = try await to.fetch(url: url)
        let document = try SwiftSoup.parse(todos).body()
        let block = try document?.getElementsByClass("p-body-pageContent").first?.getElementsByClass("block")
        
        let totalPage = try document?.getElementsByClass("pageNav-main").first()?.getElementsByTag("li").last()?.text() ?? "1"
        
        //if it has subforums
        if block!.count == 2 {
            let subForums = try block?.first()?.getElementsByClass("node")
            for i in 0..<(subForums!.count){
                let subName = try subForums?.get(i).getElementsByClass("node-title").text() ?? ""
                let subLink = try subForums?.get(i).getElementsByClass("node-title").first()?.getElementsByTag("a").attr("href") ?? ""
                let subInfor = try subForums?.get(i).getElementsByClass("node-meta").text() ?? "" 
                subfoArr.append(subFoModel(title: subName, link: "https://voz.vn"+subLink, infor: subInfor))
            }
        }
        
        
        //do thread
        if ( try block!.first()!.className() == "block"){
            let thread = try block?.last()?.getElementsByClass("structItem--thread")
             
            for i in 0..<(thread!.count){
                let subTit = try thread!.get(i).getElementsByClass("structItem-title").first()!.getElementsByTag("a")
                let subLink = try thread!.get(i).getElementsByClass("structItem-title").first()!.getElementsByTag("a").last()!.attr("href")
               
                let subUsername = try thread!.get(i).getElementsByClass("structItem-minor").first()!.getElementsByTag("a").first()!.text()
                let replies = try thread!.get(i).getElementsByClass("structItem-cell structItem-cell--meta").first()?.getElementsByClass("pairs pairs--justified").first()?.text() ?? "N/A"
                let time = try thread!.get(i).getElementsByClass("structItem-latestDate u-dt").first()?.text() ?? "N/A"
                let subInfor = replies + "  \u{2022}  " + time
                let sticky = try thread!.get(i).getElementsByClass("structItem-status structItem-status--sticky").count
                 
                subthreArr.append(subThreadModel(title: try subTit.last()!.text(), userName: subUsername, prefix: subTit.count == 2 ? try subTit.first()!.text() : nil, link: "https://voz.vn"+subLink, isSticky: sticky == 1 ? true : false, infor: subInfor))
            }
        } else {
            // truyen voz f17
            let thread = try block?.last()?.getElementsByClass("block-body").first()?.getElementsByClass("message")
            for i in 0..<(thread!.count){
                let subName = try thread!.get(i).getElementsByClass("articlePreview-title").text()
                let subUsername = try thread!.get(i).getElementsByClass("username").text()
                let subInfor = try thread!.get(i).getElementsByClass("articlePreview-replies").text() + "  \u{2022}  Started By: " +  thread!.get(i).getElementsByClass("u-dt").text()
                let subLink = try thread!.get(i).getElementsByClass("articlePreview-title").first()!.getElementsByTag("a").attr("href")
                subthreArr.append(subThreadModel(title: subName, userName: subUsername, prefix: nil, link: "https://voz.vn"+subLink, isSticky: false, infor: subInfor))
            }
        }
        vozArr.append(subForumModel(threadData: subthreArr, subForum: subfoArr, totalPage: totalPage, currentPage: "1", haveSubForums: block!.count == 2 ? true : false))
        
        
        return vozArr
    }
}
