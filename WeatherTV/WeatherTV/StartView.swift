import SwiftUI

struct StartView: View {
    @State private var showFullScreenView = true // For full-screen presentation
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Image(systemName: "sun.max.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.yellow)
                        .padding()
                    
                    Text("Welcome to Weather App")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                    
                    // NavigationLink to navigate to ContentView
                    NavigationLink(destination: ContentView()) {
                        Text("Start")
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(maxWidth: 300)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.bottom, 10)
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height) // Ensures the VStack takes the full screen size
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea() // Ensures the background fills the entire screen
        }
    }
}

// Preview for testing
#Preview {
    StartView()
}


