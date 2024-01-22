//
//  ContentView.swift
//  SwiftTechToTechProject
//
//  Created by goldorak on 22/01/2024.
//

import SwiftUI

class EventViewModel: ObservableObject {
    // Sample data for demonstration
    @Published var day1Schedule: [Activity] = [
        Activity(title: "Opening Keynote", time: "9:00 AM - 10:00 AM", room: "Main Hall"),
        Activity(title: "Security Trends", time: "10:30 AM - 11:30 AM", room: "Room A"),
        // Add more activities for day 1 as needed
    ]

    @Published var day2Schedule: [Activity] = [
        Activity(title: "Advanced Encryption Techniques", time: "9:00 AM - 10:00 AM", room: "Main Hall"),
        Activity(title: "Cybersecurity Panel", time: "10:30 AM - 11:30 AM", room: "Room A"),
        // Add more activities for day 2 as needed
    ]
}

// Model to represent an activity
struct Activity: Identifiable {
    var id = UUID()
    var title: String
    var time: String
    var room: String
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
                        Text("\(activity.title) - \(activity.time)")
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

            Text("Time: \(activity.time)")
                .padding()

            Text("Room: \(activity.room)")
                .padding()
        }
        .navigationTitle("Activity Detail")
    }
}
