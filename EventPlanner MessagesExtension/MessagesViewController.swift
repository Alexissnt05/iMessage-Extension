//
//  MessagesViewController.swift
//  EventPlanner MessagesExtension
//
//  Created by Alexis Santiago on 3/2/25.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit
import Messages

struct AddToCalendarButton: View {
    let eventName: String
    let eventLocation: String
    let eventStartDate: Date

    var body: some View {
        Button("Add to Calendar") {
            openCalendar()
        }
        .padding()
    }

    private func openCalendar() {
        let timestamp = eventStartDate.timeIntervalSince1970
        if let url = URL(string: "calshow:\(timestamp)") {
            UIApplication.shared.open(url)
        }
    }
}

struct MessagesView: View {
    var body: some View {
        VStack {
            Text("Event Planner")
                .font(.title2)
            AddToCalendarButton(
                eventName: "YOGO Meeting",
                eventLocation: "Discord",
                eventStartDate: Date()
            )
        }
        .padding()
    }
}

// Bridge to UIKit for iMessage extension
class MessagesViewController: MSMessagesAppViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftUIView = UIHostingController(rootView: MessagesView())
        addChild(swiftUIView)
        swiftUIView.view.frame = view.frame
        view.addSubview(swiftUIView.view)
        swiftUIView.didMove(toParent: self)
    }
}

