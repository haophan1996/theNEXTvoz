//
//  modelReaction.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 2/27/22.
//

import Foundation
import SwiftSoup


struct reactionModel{
    let id = UUID()
    let userName: String
    let title: String
    let score: String
    let reaction: String
    let avatar: String
    let userNameColor: String?
    
}
 
class ReactionManager{
    func matches(for regex:String, in text:String) -> [String]{
        do{
            let regex = try NSRegularExpression(pattern: regex)
            let result = regex.matches(in: text, range: NSRange(text.startIndex...,in:text))
            
            return result.map{
                String(text[Range($0.range, in: text)!])
            }
        }catch{
            return []
        }
    }
    
    func fetchData(link: String) async throws -> [reactionModel] {
        
        var arr:Array<reactionModel> = Array()
        let todos = try await TodoService().fetch(url: link)
        let document = try SwiftSoup.parse(todos).body()
        
        let blockBody = try document?.getElementsByClass("block-body js-reactionList-0").first()?.getElementsByClass("block-row block-row--separated")
        
        for index in 0..<(blockBody?.count ?? 0){
            let userName = try blockBody![index].getElementsByClass("contentRow-header").first()?.text() ?? ""
            let title = try blockBody![index].getElementsByClass("contentRow-lesser").first()?.text() ?? ""
            let score = try blockBody![index].getElementsByClass("contentRow-minor").first()?.text() ?? ""
            let reaction = try blockBody![index].getElementsByClass("contentRow-extra").first()?.getElementsByTag("span").first()?.attr("data-reaction-id") ?? ""
        
            let avatarColor = (try blockBody![index].getElementsByClass("contentRow-figure").first()?.getElementsByClass("avatar").first()?.classNames().count ?? 2)
             
            
            if avatarColor == 2 {
                let avatar = try blockBody![index].getElementsByClass("contentRow-figure").first()?.getElementsByTag("img").first()?.attr("src") ?? ""
                arr.append(reactionModel(userName: userName, title: title, score: score, reaction: reaction == "1" ? "1" : "2", avatar: avatar, userNameColor: nil))
            } else {
                let color = try blockBody![index].getElementsByClass("contentRow-figure").first()?.getElementsByTag("a").first()?.attr("style") ?? ""
                let avatar = matches(for: "\\.*#.{6}", in: color) //start at #, and end with only range 6 characters
                arr.append(reactionModel(userName: userName, title: title, score: score, reaction: reaction == "1" ? "1" : "2", avatar: avatar[0], userNameColor: avatar[1]))
            }
            
        }
        
        
        
        return arr
    }
        
}
