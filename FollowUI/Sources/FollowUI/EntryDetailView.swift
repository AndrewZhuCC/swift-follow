//
//  EntryDetailView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/16.
//

import FollowAPI
import MarkdownUI
import SwiftUI
import WebKit

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString("""
                            <head>
                                <meta name="viewport" content="width=device-width, initial-scale=0.8, user-scalable=yes">
                            </head>
"""+htmlContent, baseURL: nil)
    }
}

struct EntryDetailView: View {
    var entry: PostEntries.EntryData
    var onRead: () -> Void

    @Environment(\.openURL) var openURL
    @State private var entryDetail: GetEntries.EntriesData?

    //    var parsedContent: String {
    //        guard let content = entryDetail?.entries.content else {
    //            return ""
    //        }
    //
    ////        return (try? HTMLToMarkdownParser().parseHTML(content: content)) ?? ""
    //        return content
    //    }

    var body: some View {
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            scrollView
                .toolbarVisibility(.hidden, for: .tabBar)
        } else {
            scrollView
        }
    }

    private var scrollView: some View {
//        ScrollView {
            //            if let parsedContent = entryDetail?.entries.content, let nsAttributedString = try? NSAttributedString(data: Data(parsedContent.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
            //                       let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
            //                        Text(attributedString)
            //                    } else {
            //                        // fallback...
            //                        Text("failed to load")
            //                    }
            HTMLStringView(htmlContent: entryDetail?.entries.content ?? "")
//                .padding()
            //            Markdown(parsedContent)
            //                .markdownTheme(.docC)
//        }
        .navigationTitle(entry.entries.title ?? "")
        .toolbar(content: {
            if let urlString = entry.entries.url,
                let url = URL(string: urlString)
            {
                Button("Open in Safari", systemImage: "safari") {
                    openURL(url)
                }
            }
        })
        .onAppear {
            let service = EntriesService()

            Task {
                do {
                    let result = try await service.getEntry(
                        id: entry.entries.id)
                    DispatchQueue.main.async {
                        self.entryDetail = result.data
                    }

                    if !(entry.read ?? false) {
                        let readsService = ReadsService()
                        let _ = try await readsService.postReads(entryIds: [
                            entry.id
                        ])
                        onRead()
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
