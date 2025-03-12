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

struct SendMessageButton: View {
    let eventName: String
    let eventLocation: String
    let eventStartDate: Date
    let viewController: MSMessagesAppViewController  // Reference to iMessage ViewController

    var body: some View {
        Button("Send ICS File") {
            sendMessage()
        }
        .padding()
    }

    private func sendMessage() {
        let icsContent = generateICSContent()
        if let fileURL = saveICSFile(content: icsContent) {
            sendMessageWithFile(fileURL: fileURL)
        }
    }

    private func generateICSContent() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        let startDate = dateFormatter.string(from: eventStartDate)
        let endDate = dateFormatter.string(from: eventStartDate.addingTimeInterval(3600)) // 1-hour duration

        return """
        BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VEVENT
        SUMMARY:\(eventName)
        LOCATION:\(eventLocation)
        DTSTART:\(startDate)
        DTEND:\(endDate)
        END:VEVENT
        END:VCALENDAR
        """
    }

    private func saveICSFile(content: String) -> URL? {
        let fileName = "event.ics"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving ICS file: \(error)")
            return nil
        }
    }

    private func sendMessageWithFile(fileURL: URL) {
        let session = MSSession()
        let message = MSMessage(session: session)

        let layout = MSMessageTemplateLayout()
        layout.caption = "Here's your event: \(eventName)"
        layout.subcaption = "Location: \(eventLocation)"
        layout.trailingCaption = "Tap to add to calendar"
        layout.image = UIImage(systemName: "calendar") // Optional image

        message.layout = layout
        message.url = fileURL // Attach the ICS file URL

        viewController.activeConversation?.insert(message, completionHandler: { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        })
    }
}

struct MessagesView: View {
    let viewController: UIViewController

    var body: some View {
        VStack {
            Text("Event Planner")
                .font(.title2)
            SendMessageButton(
                eventName: "YOGO Meeting",
                eventLocation: "Discord",
                eventStartDate: Date(),
                viewController: viewController as! MSMessagesAppViewController
            )
        }
        .padding()
    }
}

// Bridge to UIKit for iMessage extension
class MessagesViewController: MSMessagesAppViewController, UIDocumentPickerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftUIView = UIHostingController(rootView: MessagesView(viewController: self))
        addChild(swiftUIView)
        swiftUIView.view.frame = view.frame
        view.addSubview(swiftUIView.view)
        swiftUIView.didMove(toParent: self)
    }
}
