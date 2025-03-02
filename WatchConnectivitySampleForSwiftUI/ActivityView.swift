import SwiftUI

struct ActivityView: View {
    @StateObject private var healthManager = HealthManager()

    var body: some View {
        NavigationView { // ✅ Works in iOS 14, 15, 16+
            VStack {
                 
                                Text("Welcome, User!")
                                    .font(.headline)

                                Button("Save Health Data") {
                                  
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        
                Text("Today's Activity")
                    .font(.title)
                    .bold()

                HStack {
                    VStack {
                        Text("Steps")
                            .font(.headline)
                        Text("\(healthManager.steps)")
                            .font(.largeTitle)
                    }
                    .padding()

                    VStack {
                        Text("Calories")
                            .font(.headline)
                        Text("\(healthManager.calories, specifier: "%.0f") kcal")
                            .font(.largeTitle)
                    }
                    .padding()

                    VStack {
                        Text("Exercise Time")
                            .font(.headline)
                        Text("\(healthManager.exerciseTime, specifier: "%.0f") min")
                            .font(.largeTitle)
                    }
                    .padding()
                }

                // ✅ Navigation to DetailView (iOS 14+)
                NavigationLink(destination: ContentView()) {
                    Text("View More Details")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
           

        }
    

