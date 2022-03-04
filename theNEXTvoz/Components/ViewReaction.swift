//
//  ViewReaction.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 2/27/22.
//

import SwiftUI

struct ViewReaction: View {
    
    @State var vozArr: [reactionModel]?
    @State var isLoading = 0
    let link: String
    var body: some View {
        List{
            if isLoading == 1, let vozArr = vozArr {
                ForEach(vozArr, id: \.id){ index in
                    ReactionCell(avatarlink: index.avatar, userName: index.userName, title: index.title, score: index.score, reaction: index.reaction, userNameColor: index.userNameColor)
                } 
            }
        }
        .listStyle(PlainListStyle())
        .overlay(Group{
            if isLoading == 0 {
                LoadingView()
            }
        })
        .onDisappear{
            vozArr?.removeAll()
            //print("deinit")
        }
        .task {
            if vozArr != nil{
                return
            }
            self.isLoading = 0
            do {
                let vozReaction = ReactionManager()
                vozArr = try await vozReaction.fetchData(link: link)
                self.isLoading = 1
            }catch{
            }
        }
    }
}


struct ViewReaction_Previews: PreviewProvider {
    static var previews: some View {
        ViewReaction(link: "https://voz.vn/p/14969558/reactions")
    }
}



struct ReactionCell: View{
    var avatarlink: String
    var userName: String
    var title: String
    var score: String
    var reaction: String
    var userNameColor: String?
    
    var body: some View {
        HStack(spacing: 20){
            ZStack(alignment: .center){
                if avatarlink.count > 7 {
                    AsyncImage(url: URL(string: avatarlink)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                } else {
                    Circle()
                        .fill(Color(hex: avatarlink)!)
                        .frame(width: 50, height: 50)
                    Text(userName.prefix(1))
                        .foregroundColor(Color(hex: userNameColor!))
                        .font(Font.custom("Be Vietnam Pro", size: 20)).fontWeight(.bold).textCase(.uppercase)
                }
                
                Image(reaction)
                    .resizable()
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 25, height: 25, alignment: .bottomTrailing).offset(x: 25, y: 17)
            }
            
            VStack(alignment:.leading){
                Text(userName).font(Font.custom("Be Vietnam Pro", size: 17)).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1).foregroundColor(Color("userName"))
                Text(title).font(Font.custom("Be Vietnam Pro", size: 11)).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                Text(score).font(Font.custom("Be Vietnam Pro", size: 11)).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
            }
        }
    }
}
