//
//  SwiftUIView.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .gray)) 
            .frame(maxWidth: .infinity, maxHeight: .infinity )
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView()
        }
    }
}
