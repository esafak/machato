//
//  ShareGPT.swift
//  Machato
//
//  Created by Théophile Cailliau on 10/05/2023.
//

import Foundation
import JavaScriptCore

struct ShareGPT {
    static public let shared = ShareGPT();
    
    private var marked : JSValue? = nil;
    
    init() {
        let jsContext = JSContext()!
        guard let fileURL = Bundle.main.url(forResource: "sharegpt-prepare", withExtension: "js") else {
            print("bundle not found")
            return
        }
        let fileContents = try? String(contentsOf: fileURL, encoding: .utf8)
        jsContext.evaluateScript(fileContents)
        guard let parse = jsContext.objectForKeyedSubscript("marked") else {
            print("marked was nil")
            return
        }
        marked = parse
    }
    
    func share(conversation : Conversation) async -> String? {
        let url = URL(string: "https://sharegpt.com/api/conversations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let conversationData : [String: Any] = [
            "avatarUrl": "data:image/png;base64,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", // Machato logo
            "items": (conversation.has_messages?.sortedArray(using: [NSSortDescriptor(keyPath: \Message.date, ascending: true)]) as? [Message])?
                .map { m in
                    return [
                        "from" : m.is_response ? "gpt" : "human",
                        "value" : m.is_response ? markup(m.content ?? "") : m.content ?? ""
                    ]
                } ?? [],
            "title": conversation.title ?? "Untitled",
            "model": "Model: \(PreferencesManager.getConversationSettings(conversation).model.name.uppercased())"
        ];
        
        let jsonData = try! JSONSerialization.data(withJSONObject: conversationData)
        
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            guard let conversationId = jsonResponse["id"] as? String else {
                fatalError("jsonResponse did not contain an id")
            }
            return "https://shareg.pt/\(conversationId)"
        } catch {
            print(error)
            return nil
        }
    }
    
    func markup(_ markdown: String) -> String {
        let parsed = marked?.invokeMethod("parse", withArguments: [markdown])
        return parsed?.toString() ?? markdown
    }
}
