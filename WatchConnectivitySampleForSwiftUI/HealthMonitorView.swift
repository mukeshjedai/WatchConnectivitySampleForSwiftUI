import SwiftUI

struct HealthMonitorView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var heartRate: Int = 78
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Mukesh Kumar")
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    Image(systemName: "bell")
                }
                .padding()
                
                LiveHeartRateCard(heartRate: $heartRate)
                    
                    VStack(spacing: 50) {
                        Button("Request Permission") {
                                        NotificationManager.instance.requestPermission()
                                    }
                                    Button("Send Notification") {
                                        NotificationManager.instance.scheduleNotification()
                                    }
                        
                        HStack{
                            HealthCard(title: "Total Sleep", value: "1260", unit: "gl/d", status: "", color: .purple)
                                .frame(minWidth: 80, idealWidth: 100, maxWidth: .infinity, minHeight: 40, idealHeight: 50, maxHeight: 60)
                                .padding(0) // Reduced padding
                        }
                        .padding(20)
                        // Second Row: Two Cards Side by Side
                        HStack(spacing: 8) { // Reduced spacing
                            HealthCard(title: "Bedtime", value: "12:30", unit: "time", status: "", color: .purple)
                                .frame(minWidth: 80, idealWidth: 100, maxWidth: 120, minHeight: 40, idealHeight: 50, maxHeight: 60)
                                .padding(0) // Reduced padding

                            HealthCard(title: "WakeUp Time", value: "12:60", unit: "time", status: "", color: .purple)
                                .frame(minWidth: 80, idealWidth: 100, maxWidth: 120, minHeight: 40, idealHeight: 50, maxHeight: 60)
                                .padding(0) // Reduced padding
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(20)
                
                
                HStack {
                    HealthCard(title: "Total Step Count", value: "8000", unit: "", status: "", color: .purple)
                        .frame(minWidth: 80, idealWidth: 100, maxWidth: .infinity, minHeight: 40, idealHeight: 50, maxHeight: 60)
                        .padding(0) // Reduced padding
                        .font(.custom("Helvetica", size: 24)) // Clean & widely used
                }
                    
            }
            
        }
    }
    
    struct HealthCard: View {
        var title: String
        var value: String
        var unit: String
        var status: String
        var color: Color
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(status)
                    .font(.subheadline)
                    .foregroundColor(color)
                Text(value)
                    .font(.largeTitle)
                    .bold()
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
        }
    }
    
    struct LiveHeartRateCard: View {
        @Binding var heartRate: Int
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Live Heartbeat")
                    .font(.headline)
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(heartRate) BPM")
                        .font(.largeTitle)
                        .bold()
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
    
    struct AnimatedHeartRateGraph: View {
        @State private var waveOffset: CGFloat = 0.0
        
        var body: some View {
            ZStack {
                HeartRateWave()
                    .stroke(Color.green, lineWidth: 2)
                    .offset(x: waveOffset)
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .onAppear {
                        waveOffset = -200
                    }
            }
            .frame(height: 100)
            .cornerRadius(10)
        }
    }
    
    struct HeartRateWave: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let midHeight = rect.midY
            let width = rect.width
            let step = max(width / 20, 1)

            
            path.move(to: CGPoint(x: 0, y: midHeight))
            
            for i in stride(from: 0, to: width, by: step) {
                let x = i
                let y = midHeight + sin((x / width) * .pi * 4) * 20
                // path.addLine(to: CGPoint(x: x, y: y))
            }
            
            return path
        }
    }
    
    struct VitaminPill: View {
        var text: String
        var color: Color
        
        var body: some View {
            Text(text)
                .padding()
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(20)
        }
    }
    
    struct HealthMonitorView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                HealthMonitorView()
                    .preferredColorScheme(.light)
                HealthMonitorView()
                    .preferredColorScheme(.dark)
            }
        }
    }
    
}

#Preview {
    
    HealthMonitorView()
}

