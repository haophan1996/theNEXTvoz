//
//  Content.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/21/22.
//

import SwiftUI
import WebKit
 
struct ContentForums: View {
    
    let title : String , link : String
    @EnvironmentObject var monitor: NetworkMonitor
    @State var vozArr : [contentModel]?
    @State var isLoading = 0
    @State var isLoadingNext = 0
    @StateObject var webViewStateModel = WebViewStateModel()
    
     
    var body: some View {
        let contentManager = CtManager()
        
        HStack{
            if isLoading == 1 {
                if let vozArr = vozArr {
                    WebView(htmlContent: vozArr[0].content, webViewModel: webViewStateModel)
                }
            }
            else {
                if isLoading == 2 { // error
                    Text("Server is offline, can't connect to voz.vn").frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if isLoading == 3 { //network off
                    ///Todo network off
                } else {
                    LoadingView().task{
                        do {
                            vozArr = try await contentManager.fetchData(link: link)
                            self.isLoading = 1
                        } catch {
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
        .sheet(isPresented: $webViewStateModel.request, onDismiss: {webViewStateModel.request = false}){
            if webViewStateModel.type == "userName" {
                Text(webViewStateModel.link).background(.red)
            } else if webViewStateModel.type == "reactions", webViewStateModel.request == true {
                ViewReaction(link: webViewStateModel.link)
            }
        }
        .navigationTitle("\(title)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItemGroup(placement: .bottomBar){
                Button(action: {
                    Task(priority: .medium){
                        if (isLoadingNext == 0){
                            do {
                                self.isLoadingNext = 1
                                let page = (Int(vozArr?[0].currentPage ?? "1") ?? 1) + 1
                                vozArr = try await contentManager.fetchData(link: "\(link)page-\(page)")
                                self.isLoadingNext = 0
                                webViewStateModel.reload = true
                            } catch {
                                self.isLoadingNext = 0
                            }
                        }
                    }
                }){
                    Text("Next")
                }
                
                Spacer()
                
                Text(" \(vozArr?[0].currentPage ?? "") / \(vozArr?[0].totalPage ?? "") ")
                
                Spacer()
                
                Button(action: {
                    Task(priority: .medium){
                        if (isLoadingNext == 0){
                            do {
                                self.isLoadingNext = 1
                                let page = (Int(vozArr?[0].currentPage ?? "1") ?? 1) - 1
                                vozArr = try await contentManager.fetchData(link: "\(link)page-\(page)")
                                self.isLoadingNext = 0
                                webViewStateModel.reload = true
                            } catch {
                                self.isLoadingNext = 0
                            }
                        }
                    }
                }){
                    Text("Previous")
                }
            }
        }
        
    }
}

struct ContentForums_Previews: PreviewProvider {
    static var previews: some View {
        ContentForums(title: "F15", link: "https://voz.vn/t/nga-don-them-quan-toi-bien-gioi-ukraine.479227/", webViewStateModel: WebViewStateModel())
    }
}
