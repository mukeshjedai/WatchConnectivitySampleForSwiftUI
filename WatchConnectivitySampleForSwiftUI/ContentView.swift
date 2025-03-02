import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MessageListViewModel()

    var body: some View {
        VStack {
            // ✅ Display Latest RMSSD Data
            VStack {
                Text("Latest RMSSD (HRV)")
                    .font(.headline)
                    .padding()

                Text(viewModel.latestRMSSD)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .bold()
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()

            // ✅ Display Stress Level
            VStack {
                Text("Stress Level")
                    .font(.headline)
                    .padding()

                Text(viewModel.stressLevel)
                    .font(.title2)
                    .foregroundColor(.red)
                    .bold()
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()

            // ✅ Display Latest HRV SDNN Data
            VStack {
                Text("Latest HRV SDNN")
                    .font(.headline)
                    .padding()

                Text(viewModel.latestHRV)
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
        }
        .padding()
        .onAppear {
            print("📡 UI is ready. Waiting for RMSSD & HRV SDNN Data...")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
