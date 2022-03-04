//
//  WebViewStateModel.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 2/26/22.
//

import Foundation

class WebViewStateModel: ObservableObject {
    @Published var request: Bool = false
    @Published var reload: Bool = false
    var type: String = ""
    var link: String = ""
    
     
}
