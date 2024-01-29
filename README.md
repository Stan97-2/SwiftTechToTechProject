# Event Schedule App

This iOS application is designed for attendees of a security conference, providing easy access to the event schedule for a two-day duration. Users can navigate through different activities and obtain detailed information about each of them.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Code Structure](#code-structure)

## Features

- **Home Page:** Displays the schedule for the first day.
- **Activity Details:** Detailed information about each activity, including the title, start and end times, location, and speakers.
- **Day Selection:** Users can switch between Day 1 and Day 2 to view the respective schedules.
- **API Integration:** Fetches schedule data from the provided Airtable API.
- **Error Handling:** Implements error handling for potential issues during data retrieval, status code errors.

## Requirements

- Xcode (Minimum version: 13.2.1)
- Swift

## Installation

1. Open the project in Xcode.

2. Build and run the project.

## Usage
Upon launching the app, users are presented with the schedule for the current or the first day.

Use the segmented control at the top to switch between Day 1 and Day 2.

Tap on any activity to view detailed information about the session, including the title, type, start and end times, location, and speakers.

Navigate back to the schedule by using the back button in the navigation bar.

## Code Structure

Model: Defines the data structures used for decoding JSON responses from the API.
EventViewModel: Manages the application's data and orchestrates the communication between the views and the data model.
ContentView: The main view that displays the schedule, allows day selection, and handles navigation to activity details.


## Contributors

François CHARVET

Stanley DELLON

Antoine RINCHEVAL
