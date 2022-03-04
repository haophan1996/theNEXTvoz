//
//  SubForum.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import SwiftUI

struct SubForum: View {
    
    @State var vozArr: [subForumModel]?
    @State var isLoading = 0
    @State var isLoadingNext = 0
    @EnvironmentObject var monitor: NetworkMonitor
    @State var isSharingsheet = false
    let title : String, link : String
      
    var body: some View {
        let subManager = SubForumManager()
        
        ZStack{
            if isLoading == 1{
                List{
                    if let vozArr = vozArr {
                        if vozArr[0].haveSubForums == true{
                            Section(header: Text("Sub-forums").font(Font.custom("Be Vietnam Pro", size: 22, relativeTo: .title2))) {
                                ForEach(vozArr[0].subForum, id: \.id){ index in
                                    NavigationLink(destination: SubForum(title: index.title, link: index.link)){
                                        VStack{
                                            Text("\(index.title)").font(Font.custom("Be Vietnam Pro", size: 17)).fontWeight(.bold).frame(maxWidth: .infinity,alignment: .leading)
                                            Text("\(index.infor)").font(Font.custom("Be Vietnam Pro", size: 12)).font(.caption).frame(maxWidth: .infinity,alignment: .leading).foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        Section(header: Text("Threads").font(Font.custom("Be Vietnam Pro", size: 22, relativeTo: .title2))){
                            ForEach(vozArr[0].threadData, id: \.id) { index in
                                NavigationLink(destination: ContentForums(title: "\(index.title)", link : "\(index.link)")){VStack(alignment: .leading){
                                    if index.prefix != nil{
                                        Text("\(index.prefix!) ").font(Font.custom("Be Vietnam Pro", size: 17)).fontWeight(.bold) +
                                        Text("\(index.title)").font(Font.custom("Be Vietnam Pro", size: 17)).foregroundColor(index.isSticky == true ? .red : .primary).fontWeight(index.isSticky == true ? .bold : .none)
                                    } else {
                                        Text("\(index.title)").font(Font.custom("Be Vietnam Pro", size: 17)).foregroundColor(index.isSticky == true ? .red : .primary).fontWeight(index.isSticky == true ? .bold : .none)
                                    }
                                    Text("\(index.infor)").font(Font.custom("Be Vietnam Pro", size: 12)).foregroundColor(.gray)
                                    Text("\(index.userName)").font(Font.custom("Be Vietnam Pro", size: 12)).foregroundColor(Color(hue: 0.049, saturation: 0.878, brightness: 0.895))
                                }
                                .lineLimit(2)
                                    //                                .onTapGesture {
                                    //                                    shareSheet(url: index.link)
                                    //                                }
                                    
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable{
                    do{
                        vozArr = try await subManager.fetchData(url: link)
                        self.isLoading = 1 // done loading
                    }catch {
                        if (monitor.isConnected){
                            self.isLoading = 2 // error
                        } else {
                            self.isLoading = 3 //network off
                        }
                    }
                } //end list
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action:{
                            Task(priority: .medium){
                                if (isLoadingNext == 0){
                                    do {
                                        isLoadingNext = 1
                                        vozArr = try await subManager.fetchUpdateThreads(vozArr: vozArr!, url: link, gotoPage: (Int((vozArr?[0].currentPage)!) ?? 1) + 1
                                        )
                                        isLoadingNext = 0
                                    } catch{
                                        print("error next page")
                                    }
                                }
                                
                            }
                        }){
                            Text("Next")
                        }
                        Spacer()
                        Text("\(vozArr?[0].currentPage ?? "1") / \(vozArr?[0].totalPage ?? "1")")
                        Spacer()
                        
                        Button("Previous") {
                            print("Pressed")
                        }
                    }
                }
            }
            else {
                if isLoading == 2 {
                    Text("Server is offline, can't connect to voz.vn").frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if isLoading == 3 {
                    if monitor.isConnected{
                        LoadingView().task{
                            do {
                                vozArr?.removeAll()
                                vozArr = try await subManager.fetchData(url: link)
                                self.isLoading = 1 // done loading
                            }catch {
                                self.isLoading = 2 // error
                            }
                        }
                    } else {
                        Image(systemName: "wifi.slash").font(.system(size: 56)).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                } else {
                    LoadingView().task {
                        do {
                            vozArr = try await subManager.fetchData(url: link)
                            self.isLoading = 1 // done loading
                        } catch{
                            if (monitor.isConnected){
                                self.isLoading = 2 // error
                            } else {
                                self.isLoading = 3 //network off
                            }
                        }
                    }
                }
                
            }
            
        }
        .onDisappear{
            monitor.remove()
        }
        .navigationTitle("\(title)")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(Group{
            if isLoadingNext == 1{
                LoadingView()
            }
        })
        
    }
    func shareSheet(url:String) {
        isSharingsheet.toggle()
        print(url)
        let url = URL(string: url)
        let av = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(av, animated: true)
    }
}


struct SubForum_Previews: PreviewProvider {
    static var previews: some View {
        SubForum(title: "title", link: "https://voz.vn/t/se-ra-sao-neu-nga-danh-ukraine-tq-danh-dl-cung-luc.479746/")
    }
}
