//
//  HTMLView.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/22/22.
//

import SwiftUI
import WebKit
import SafariServices


struct WebView: UIViewRepresentable{
    let htmlContent: String 
    @StateObject var webViewModel: WebViewStateModel
    
    let header = """
            <head>
               <meta charset="UTF-8">
                   <meta http-equiv="X-UA-Compatible" content="IE=edge">
                   <meta name="viewport" content="width=device-width, initial-scale=1.0 maximum-scale=1.0 user-scalable=no">
             <link rel="stylesheet" type="text/css" href="style.css">
               
            </head>
            <body>
    """
    
    let script = """
            <script>
                var check = document.getElementsByClassName('reactionsBar js-reactionsList');
                for(let c of check) {
                   if(!c.className.includes('reactionsBar js-reactionsList is-active')){
                       c.style.display = 'none';
                   }
                }
                var checkBlockQuoteHeight = document.getElementsByClassName('bbCodeBlock-expandLink');
                for (var i = 0; i < checkBlockQuoteHeight.length; i++){
                    checkBlockQuoteHeight[i].parentNode.parentNode.className += ' is-expanded';
                    checkBlockQuoteHeight[i].style.display = 'none';
                    if (checkBlockQuoteHeight[i].parentNode.parentNode.offsetHeight > 300){
                        checkBlockQuoteHeight[i].parentNode.parentNode.className = 'bbCodeBlock bbCodeBlock--expandable bbCodeBlock--quote js-expandWatch';
                        checkBlockQuoteHeight[i].style.display = 'block';
                    }
                }
                for(let buttons of checkBlockQuoteHeight){
                    buttons.addEventListener('click', function (event){
                    buttons.style.display = 'none';
                    buttons.parentNode.parentNode.className += " is-expanded";
                    })
                }
                var scrollToQuote = document.getElementsByClassName("bbCodeBlock-title")
                        for(let quote of scrollToQuote){
                          quote.addEventListener("click", function (event){ 
                            event.preventDefault();
        window.webkit.messageHandlers.backHomePage.postMessage("success");
                            var idPost = quote.children[0].getAttribute('data-content-selector').substring(1);
                            var findIDPost = document.getElementsByClassName("u-anchorTarget");
                            for(let findID of findIDPost){
                              if (findID.getAttribute('id') == idPost){
                                findID.scrollIntoView({ behavior: 'smooth', block: 'start' });
                              }
                            }
                          })
                        }
        
                var div = document.getElementsByClassName('reaction reaction--small actionBar-action actionBar-action--reaction');
                for (let button of div) {
                    button.addEventListener('click', function (event) {
                        event.preventDefault();
                        document.getElementById("overlay-search").style.display = "block";
                        alert(button.offsetTop);
                    })
                }
                var closeBtn = document.getElementById('close');
                closeBtn.addEventListener('click', function (ev) {
                    document.getElementById("overlay-search").style.display = "none";
                });
            </script>
        </body>
        """
    
    // Make a coordinator to co-ordinate with WKWebView's default delegate functions
    func makeCoordinator() -> WebView.Coordinator {
//        return Coordinator(webViewModel: webViewModel)
         return Coordinator(self)
    }
     
    func makeUIView(context: Context) ->  WKWebView {
        //let userContentController = WKUserContentController()
        //userContentController.add(context.coordinator , name: "bridge")
        
        //let configuration = WKWebViewConfiguration()
        //configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero)//, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor .clear
        webView.loadHTMLString(header+htmlContent+script, baseURL: Bundle.main.resourceURL)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if webViewModel.reload {
            uiView.loadHTMLString(header+htmlContent+script, baseURL: Bundle.main.resourceURL)
            DispatchQueue.main.async {
                self.webViewModel.reload = false
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate{//, WKScriptMessageHandler {
        var parent: WebView
        
        init(_ uiWebView: WebView) {
            self.parent = uiWebView
        }
        
        deinit{
           // print("deinit wkwebview")
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
           // print("loadstatischanged")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }
          
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            //print("error")
        }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
             
            let urlString = navigationAction.request.url?.absoluteString
            if urlString?.contains("https://voz.vn/u/") ?? false {
                //Interact username Link
                decisionHandler(.cancel)
//                let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='200%'"//dual size
//                    webView.evaluateJavaScript(js, completionHandler: nil)
                if self.parent.webViewModel.request == true{
                    self.parent.webViewModel.request = false
                }
                self.parent.webViewModel.request.toggle()
                self.parent.webViewModel.type = "userName"
                self.parent.webViewModel.link = urlString!
            } else if urlString?.contains("https://voz.vn/p/") ?? false {
                //Interact reactions
                decisionHandler(.cancel)
                if self.parent.webViewModel.request == true{
                    self.parent.webViewModel.request = false
                }
                self.parent.webViewModel.request.toggle()
                self.parent.webViewModel.type = "reactions"
                self.parent.webViewModel.link = urlString!
            } else if urlString?.contains("youtube.com") ?? false {
                decisionHandler(.allow)
            } else if urlString?.contains("https://") ?? false {
                decisionHandler(.cancel)
            }else {
                decisionHandler(.allow)
            }
        }
    }
}

