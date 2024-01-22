//
//  ContentView.swift
//  SwiftTechToTechProject
//
//  Created by goldorak on 22/01/2024.
//

import SwiftUI

struct Activity: Identifiable {
    var id = UUID()
    var title: String
    var type: String
    var startDate: Date
    var endDate: Date
    var location: String
    var speakers: [String]
    var notes: String

    // Additional init method for creating Activity with Date
    init(title: String, type: String, startDate: Date, endDate: Date, location: String, speakers: [String], notes: String) {
        self.title = title
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.speakers = speakers
        self.notes = notes
    }
}

class EventViewModel: ObservableObject {
    @Published var day1Schedule: [Activity] = [
        Activity(title: "Welcome Breakfast", type: "Meal", startDate: Date(), endDate: Date(), location: "President's Dining Hall", speakers: ["Belinda Chen", "Deepa Vartak"], notes: "Belinda is going to need the projector"),
        Activity(title: "Morning Keynote", type: "Keynote", startDate: Date(), endDate: Date(), location: "Grand Ballroom", speakers: ["Katina Frey"], notes: ""),
        // Add more activities for day 1 as needed
    ]

    @Published var day2Schedule: [Activity] = [
        Activity(title: "Lunch Panel", type: "Panel", startDate: Date(), endDate: Date(), location: "Conference Room A", speakers: ["John Smith", "Alice Johnson"], notes: "Panel discussion on cybersecurity trends"),
        Activity(title: "Closing Remarks", type: "Keynote", startDate: Date(), endDate: Date(), location: "Main Hall", speakers: ["Robert Johnson"], notes: ""),
        // Add more activities for day 2 as needed
    ]
}

struct ContentView: View {
    @ObservedObject var viewModel = EventViewModel()
    @State private var selectedDay = 1

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Day", selection: $selectedDay) {
                    Text("Day 1").tag(1)
                    Text("Day 2").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Text("Schedule - Day \(selectedDay)")
                    .font(.title)
                    .padding()

                List(selectedDay == 1 ? viewModel.day1Schedule : viewModel.day2Schedule) { activity in
                    NavigationLink(destination: ActivityDetail(activity: activity)) {
                        Text("\(activity.title) - \(activity.startDate, formatter: dateFormatter)")
                    }
                }
            }
            .navigationTitle("Event Schedule")
        }
    }
}

struct ActivityDetail: View {
    var activity: Activity

    var body: some View {
        VStack {
            Text(activity.title)
                .font(.title)
                .padding()

            Text("Type: \(activity.type)")
                .padding()

            Text("Start Date: \(activity.startDate, formatter: dateFormatter)")
                .padding()

            Text("End Date: \(activity.endDate, formatter: dateFormatter)")
                .padding()

            Text("Location: \(activity.location)")
                .padding()

            Text("Speakers: \(activity.speakers.joined(separator: ", "))")
                .padding()

            Text("Notes: \(activity.notes)")
                .padding()
        }
        .navigationTitle("Activity Detail")
    }
}

// DateFormatter to format date for display
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy hh:mma"
    return formatter
}()
