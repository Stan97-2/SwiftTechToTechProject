import SwiftUI
import Combine

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
    func getActivitiesList(callback: @escaping ((errorType: CustomError?, errorMessage: String?), [Activity]?) -> Void)
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

    func getActivitiesList(callback: @escaping ((errorType: CustomError?, errorMessage: String?), [Activity]?) -> Void) {
        let activitiesUrlStr = "https://api.airtable.com/v0/apps3Rtl22fQOI9Ph/%F0%9F%93%86%20Schedule"
        let session = URLSession(configuration: .default)

        let task = session.dataTask(with: createRequest(urlStr: activitiesUrlStr)) { data, response, error in
            // Handle data error
            guard error == nil, let data = data else {
                callback((CustomError.requestError, error?.localizedDescription ?? "Unknown error"), nil)
                return
            }
            // Log response body
            if let dataStr = String(data: data, encoding: .utf8) {
                print("Response Body: \(dataStr)")
            }
            // Handle http error
            guard let responseHttp = response as? HTTPURLResponse else {
                callback((CustomError.requestError, "No HTTP response"), nil)
                return
            }
            // Handle status code error
            guard responseHttp.statusCode == 200 else {
                callback((CustomError.statusCodeError, "Status code: \(responseHttp.statusCode)"), nil)
                return
            }
            // Handle parsing error
            guard let result = try? JSONDecoder().decode(Records.self, from: data) else {
                callback((CustomError.parsingError, "Parsing error"), nil)
                return
            }
            // If everything went good
            callback((nil, nil), result.records)
        }
        task.resume()
    }
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
                        Text("\(activity.fields.activity) - \(activity.fields.startDate)")
                    }
                }
                .onAppear {
                    viewModel.fetchActivities(for: selectedDay)
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
            Text(activity.fields.activity)
                .font(.title)
                .padding()

            Text("Type: \(activity.fields.activity)")
                .padding()

            Text("Start Date: \(activity.fields.startDate)")
                .padding()

            Text("End Date: \(activity.fields.endDate)")
                .padding()

            Text("Location: \(activity.fields.location)")
                .padding()

            Text("Speakers: \(activity.fields.speakers?.joined(separator: ", ") ?? "")")
                .padding()

            Text("Notes: \(activity.fields.notes ?? "")")
                .padding()
        }
        .navigationTitle("Activity Detail")
    }
}
class EventViewModel: ObservableObject {
    @Published var day1Schedule: [Activity] = []
    @Published var day2Schedule: [Activity] = []
    
    private var cancellables: Set<AnyCancellable> = []

    func fetchActivities(for day: Int) {
        let requestFactory = RequestFactory()

        requestFactory.getActivitiesList { (errorHandle, activities) in
            if let errorType = errorHandle.errorType, let errorMessage = errorHandle.errorMessage {
                print("Error: \(errorType), Message: \(errorMessage)")
            } else if let activityList = activities {
                DispatchQueue.main.async {
                    if day == 1 {
                        self.day1Schedule = activityList
                    } else if day == 2 {
                        self.day2Schedule = activityList
                    }
                }
            } else {
                print("Houston, we've got a problem.")
            }
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy hh:mma"
    return formatter
}()


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

