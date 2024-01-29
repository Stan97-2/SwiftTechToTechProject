import SwiftUI

// Model
struct Records: Codable {
    let records: [Activity]?
}

struct Activity: Codable, Identifiable {
    let id: String
    let fields: Fields
}

struct Fields: Codable {
    let activity: String
    let startDate: String
    let endDate: String
    let location: String
    let speakers: [String]?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case activity = "Activity"
        case startDate = "Start"
        case endDate = "End"
        case location = "Location"
        case speakers = "Speaker(s)"
        case notes = "Notes"
    }
}

struct Response: Codable {
    let id: String
}

struct ErrorResponse: Codable {
    let error: String
}

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

enum CustomError: Error {
    case requestError
    case statusCodeError
    case parsingError
}

// Request Factory
protocol RequestFactoryProtocol {
    func createRequest(urlStr: String) -> URLRequest
    func getActivitiesList(completion: @escaping (Result<[Activity], CustomError>) -> Void)
}

class RequestFactory: RequestFactoryProtocol {
    internal func createRequest(urlStr: String) -> URLRequest {
        let url: URL = URL(string: urlStr)!

        var request = URLRequest(url: url)
        request.timeoutInterval = 100
        request.httpMethod = RequestType.get.rawValue

        let accessToken = "patikQ2NLt8ZuefWF.bab4360644fa68db943fec3ff9db7a0bb990674f092136422b3a0be9212e229d"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return request
    }

    func getActivitiesList(completion: @escaping (Result<[Activity], CustomError>) -> Void) {
        let activitiesUrlStr = "https://api.airtable.com/v0/apps3Rtl22fQOI9Ph/%F0%9F%93%86%20Schedule"
        let session = URLSession(configuration: .default)

        let task = session.dataTask(with: createRequest(urlStr: activitiesUrlStr)) { data, response, error in
            // Handle data error
            guard error == nil, let data = data else {
                completion(.failure(CustomError.requestError))
                return
            }
            // Log response body
            if let dataStr = String(data: data, encoding: .utf8) {
                print("Response Body: \(dataStr)")
            }
            // Handle http error
            guard let responseHttp = response as? HTTPURLResponse else {
                completion(.failure(CustomError.requestError))
                return
            }
            // Handle status code error
            guard responseHttp.statusCode == 200 else {
                completion(.failure(CustomError.statusCodeError))
                return
            }
            // Handle parsing error
            guard let result = try? JSONDecoder().decode(Records.self, from: data) else {
                completion(.failure(CustomError.parsingError))
                return
            }
            // If everything went good
            if let activities = result.records {
                completion(.success(activities))
            } else {
                completion(.failure(CustomError.parsingError))
            }
        }
        task.resume()
    }
}

// SwiftUI

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

                if selectedDay == 1 {
                    List(viewModel.day1Schedule.sorted(by: { $0.fields.startDate < $1.fields.startDate })) { activity in
                        NavigationLink(destination: ActivityDetail(activity: activity)) {
                            VStack(alignment: .leading) {
                                Text(activity.fields.activity)
                                    .font(.headline)
                                Text("\(formatDate(activity.fields.startDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else if selectedDay == 2 {
                    List(viewModel.day2Schedule.sorted(by: { $0.fields.startDate < $1.fields.startDate })) { activity in
                        NavigationLink(destination: ActivityDetail(activity: activity)) {
                            VStack(alignment: .leading) {
                                Text(activity.fields.activity)
                                    .font(.headline)
                                Text("\(formatDate(activity.fields.startDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Event Schedule")
            .onAppear {
                viewModel.fetchActivities(for: selectedDay)
            }
            .onChange(of: selectedDay) { newDay in
                viewModel.fetchActivities(for: newDay)
            }
        }
    }
}


func formatDate(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = dateFormatter.date(from: dateString) {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    } else {
        return "Invalid Date"
    }
}

struct ActivityDetail: View {
    var activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(activity.fields.activity)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            KeyValueRow(key: "Type", value: activity.fields.activity)
            KeyValueRow(key: "Start Date", value: activity.fields.startDate)
            KeyValueRow(key: "End Date", value: activity.fields.endDate)
            KeyValueRow(key: "Location", value: activity.fields.location)
            KeyValueRow(key: "Speakers", value: activity.fields.speakers?.joined(separator: ", ") ?? "")
        }
        .padding()
        .navigationTitle("Activity Detail")
    }
}

struct KeyValueRow: View {
    var key: String
    var value: String

    var body: some View {
        HStack {
            Text("\(key):")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.gray)

            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()
        }
    }
}



class EventViewModel: ObservableObject {
    @Published var day1Schedule: [Activity] = []
    @Published var day2Schedule: [Activity] = []

    func fetchActivities(for day: Int) {
        let requestFactory = RequestFactory()

        requestFactory.getActivitiesList { result in
            switch result {
            case .success(let activities):
                DispatchQueue.main.async {
                    // Filter activities based on the selected day
                    let filteredActivities = activities.filter { activity in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                        guard let startDate = dateFormatter.date(from: activity.fields.startDate) else {
                            return false
                        }

                        let day1Date = dateFormatter.date(from: "2024-02-08T00:00:00.000Z")
                        let day2Date = dateFormatter.date(from: "2024-02-09T00:00:00.000Z")

                        if day == 1 && Calendar.current.isDate(startDate, inSameDayAs: day1Date ?? Date()) {
                            return true
                        } else if day == 2 && Calendar.current.isDate(startDate, inSameDayAs: day2Date ?? Date()) {
                            return true
                        }
                        return false
                    }

                    if day == 1 {
                        self.day1Schedule = filteredActivities
                    } else if day == 2 {
                        self.day2Schedule = filteredActivities
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

