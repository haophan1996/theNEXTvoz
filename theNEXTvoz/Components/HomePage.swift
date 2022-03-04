//
//  ContentView.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import SwiftUI
import Network

struct HomePage: View {
    
    @EnvironmentObject var monitor: NetworkMonitor
    
    @State var vozArr: [vozHome]?
    @State var isLoading = 0
    
    init()  {
        UITableView.appearance().backgroundColor = .clear
    }
     
    var body: some View {
        NavigationView{
            List{
                if let vozArr = vozArr{
                    ForEach(vozArr, id: \.id){ indexVoz in
                        Section(header: Text("\(indexVoz.headerSection)").font(Font.custom("Be Vietnam Pro", size: 22, relativeTo: .title2)).fontWeight(.bold)){
                            ForEach(indexVoz.headerBody, id: \.id){ indexBody in
                                NavigationLink(destination: SubForum(title: indexBody.title, link: indexBody.link)){
                                    VStack{
                                        Text("\(indexBody.title)").font(Font.custom("Be Vietnam Pro", size: 17)).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(indexBody.infor)").font(Font.custom("Be Vietnam Pro", size: 12)).font(.caption).frame(maxWidth: .infinity,alignment: .leading).foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("NextVoz")
            .navigationBarItems(trailing: Text("Login"))
            .overlay(Group{
                if isLoading == 0{
                    LoadingView()
                } else if isLoading == 2 {
                    Text("Server is offline, can't connect to voz.vn").frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if isLoading == 3 {
                    if monitor.isConnected{
                        LoadingView().task{
                            do {
                                let nextVozModel = NextVozManager()
                                vozArr = try await nextVozModel.fetchData()
                                self.isLoading = 1 // done loading
                            }catch {
                                self.isLoading = 2 // error
                            }
                        }
                    } else {
                        Image(systemName: "wifi.slash").font(.system(size: 56)).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            })
            .refreshable{
                self.isLoading = 0
                do {
                    let nextVozModel = NextVozManager()
                    vozArr = try await nextVozModel.fetchData()
                    self.isLoading = 1
                } catch {
                    if monitor.isConnected {
                        self.isLoading = 2 // error
                    } else {
                        self.isLoading = 3 // network off
                    }
                }
            }
            .task{
                if vozArr != nil{
                    return
                }
                self.isLoading = 0 // loading
                do{
                    let nextVozModel = NextVozManager()
                    vozArr = try await nextVozModel.fetchData()
                    self.isLoading = 1 // done loading
                }catch  {
                    if monitor.isConnected {
                        self.isLoading = 2 // error
                    } else {
                        self.isLoading = 3 // network off
                    }
                }
            }
        }.navigationViewStyle(.stack)
    }
}


struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
