import SwiftUI
import MapKit

struct ContentView: View {
    @State private var location: String = ""
    @State private var weatherInfo: String = "Enter a location to get the weather"
    @State private var isLoading: Bool = false
    @State private var temperature: Double = 0
    @State private var weatherType: String = "clear"
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 90, longitudeDelta: 180)
    )
    
    let apiKey = "09563acd37dd0b4e62a7488106de357d" // Replace with a secure API key management method

    var body: some View {
        NavigationView {
            ScrollView { // Added ScrollView
                VStack(spacing: 20) {
                    // Top Section: Weather Info
                    VStack {
                        Image(systemName: "cloud.sun.fill")
                            .imageScale(.large)
                            .foregroundColor(.yellow)
                        
                        TextField("Enter location", text: $location)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(8)
                            .keyboardType(.default)
                            .autocapitalization(.words)
                            .shadow(color: Color.gray.opacity(0.4), radius: 3, x: 0, y: 2)
                            .padding(.horizontal)
                        
                        Button("Show Forecast") {
                            if !location.isEmpty {
                                fetchWeather(for: location)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 3)
                        
                        if isLoading {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else {
                            Text(weatherInfo)
                                .padding()
                                .multilineTextAlignment(.center)
                                .font(.headline)
                                .animation(.easeInOut(duration: 0.5), value: temperature)
                        }
                    }
                    .padding(.top, 20)
                    
                  
                    
                    // Navigation Links for New Features
                    HStack(spacing: 20) {
                        NavigationLink(destination: WeeklyForecastView(cityName: location)) {
                            Text("7-Day Forecast")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: FavoritesView()) {
                            Text("Favorites")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.red]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    // Map Section
                    ZStack {
                        Map(coordinateRegion: $mapRegion)
                            .frame(height: 300) // Fixed height for the map
                            .cornerRadius(20)
                            .padding(.horizontal)
                        
                        WeatherOverlay(weatherType: weatherType)
                        
                        VStack {
                            Text("Temp: \(Int(temperature))°C")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(.top, 20)
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Welcome WeatherTV")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    func fetchWeather(for location: String) {
        isLoading = true
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(location)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                weatherInfo = "Invalid URL"
                isLoading = false
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.updateUI(with: weatherResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.weatherInfo = "Error parsing data."
                        self.isLoading = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.weatherInfo = "Error fetching data. Please check the location."
                    self.isLoading = false
                }
            }
        }
        task.resume()
    }
    
    func updateUI(with weatherResponse: WeatherResponse) {
        let latitude = weatherResponse.coord.lat
        let longitude = weatherResponse.coord.lon
        temperature = weatherResponse.main.temp
        weatherType = weatherResponse.weather.first?.main.lowercased() ?? "clear"
        weatherInfo = "Temp: \(temperature)°C\nDescription: \(weatherResponse.weather.first?.description ?? "No description")"
        
        withAnimation {
            mapRegion.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        }
        
        isLoading = false
    }
}

// New Views for Features
struct WeeklyForecastView: View {
    var cityName: String
    let forecasts = [
        ("Monday", "Sunny", 28),
        ("Tuesday", "Rainy", 22),
        ("Wednesday", "Cloudy", 24),
        ("Thursday", "Stormy", 20),
        ("Friday", "Snowy", -2),
        ("Saturday", "Sunny", 30),
        ("Sunday", "Cloudy", 25)
    ] // Replace with API data for real forecasts
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7-Day Forecast for \(cityName)")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(forecasts, id: \.0) { day, description, temp in
                        HStack {
                            Text(day)
                                .font(.headline)
                            Spacer()
                            Text("\(description)")
                                .italic()
                            Spacer()
                            Text("\(temp)°C")
                                .bold()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle("7-Day Forecast")
    }
}


struct FavoritesView: View {
    @State private var favorites: [String] = ["New York", "London", "Tokyo"] // Initial favorites
    @State private var newLocation: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Manage Your Favorite Locations")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            // Add New Location
            HStack {
                TextField("Enter new location", text: $newLocation)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                Button(action: {
                    if !newLocation.isEmpty {
                        favorites.append(newLocation)
                        newLocation = ""
                    }
                }) {
                    Text("Add")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 20)
            
            // List of Favorites
            List {
                ForEach(favorites, id: \.self) { location in
                    HStack {
                        Text(location)
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            favorites.removeAll { $0 == location }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Favorites")
    }
}


struct WeatherOverlay: View {
    var weatherType: String
    
    var body: some View {
        switch weatherType {
        case "rain":
            RainAnimation()
        case "snow":
            SnowAnimation()
        case "clouds":
            CloudyAnimation()
        default:
            ClearSkyAnimation()
        }
    }
}

// Simplified animations for performance
struct RainAnimation: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            ForEach(0..<100, id: \.self) { _ in
                Rectangle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 2, height: 15)
                    .position(x: CGFloat.random(in: 0...screenWidth), y: CGFloat.random(in: -50...screenHeight))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            }
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(0.5)) // Optional: Adds a background effect
    }
}

struct SnowAnimation: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            ForEach(0..<75, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .position(x: CGFloat.random(in: 0...screenWidth), y: CGFloat.random(in: -50...screenHeight))
                    .animation(Animation.linear(duration: CGFloat.random(in: 2...5)).repeatForever(autoreverses: false))
            }
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(0.3)) // Optional: Adds a snowy night background
    }
}

struct CloudyAnimation: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { _ in
                Ellipse()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: CGFloat.random(in: 150...300), height: CGFloat.random(in: 80...120))
                    .position(x: CGFloat.random(in: 0...screenWidth), y: CGFloat.random(in: 0...(screenHeight / 2)))
                    .animation(Animation.linear(duration: 20).repeatForever(autoreverses: false))
            }
        }
        .ignoresSafeArea()
        .background(Color.gray.opacity(0.5)) // Optional: Adds an overcast background
    }
}

struct ClearSkyAnimation: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let coord: Coord
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let main: String
    let description: String
}

struct Coord: Codable {
    let lat: Double
    let lon: Double
}

#Preview {
    ContentView()
}
