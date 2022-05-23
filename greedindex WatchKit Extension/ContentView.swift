//
//  ContentView.swift
//  greedindex WatchKit Extension
//
//  Created by Ostap Pyrih on 22.05.2022.
//

import SwiftUI
import Combine

class ApiController: ObservableObject {
    @Published var response = Response(data: [])
    
    private var can: AnyCancellable?
    let url = URL(string: "https://api.alternative.me/fng")!

    init() {
        self.fetchData()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            self.fetchData()
        }
    }
    
    func fetchData() {
        self.can = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                print(completion)
            }, receiveValue: {data in
                self.response = data
            })
    }
}

struct ProgressBar : ProgressViewStyle {
        
    func makeBody(configuration: ProgressViewStyleConfiguration) -> some View {
        let progress = CGFloat(configuration.fractionCompleted ?? 0)
        let gradient = AngularGradient(
            gradient: Gradient(colors: [Color.red, .orange, .yellow, .green]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(270))

        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(gradient, style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(Animation.linear, value: progress)

            Text(String(format: "%.0f %%", min(progress, 1.0)*100.0))
                .font(.title2)
                .bold()
        }
    }
}

struct ContentView: View {
    @ObservedObject var apiController: ApiController = ApiController()
    var greedIndex: Double { Double(apiController.self.response.data?.first?.value ?? "0") ?? 0.0 }
    var greedText: String { apiController.self.response.data?.first?.value_classification ?? "" }

    var body: some View {
        VStack {
            Spacer(minLength: 15)
            ProgressView(value: greedIndex, total: 100)
                .progressViewStyle(ProgressBar())
            Spacer(minLength: 15)
            Text(greedText)
        }
    }
}

struct Response: Decodable, Hashable {
    var name: String?
    var data: [Data]?
}

struct Data: Decodable, Hashable {
    var value: String?
    var value_classification: String?
    var timestamp: String?
    var time_until_update: String?
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
