import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - UI Components
    var sceneView: ARSCNView!
    var weatherLabel: UILabel!
    var locationTextField: UITextField!
    var fetchButton: UIButton!
    var weatherNode: SCNNode?
    var profileButton: UIButton!
    var audioPlayer: AVAudioPlayer?
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupWeatherLabel()
        setupInputFieldAndButton()
        setupProfileButton()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Keyboard Dismissal
    @objc private func dismissKeyboard() {
        view.endEditing(true) // Dismiss the keyboard
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create and configure AR session
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - Scene View Setup
    func setupSceneView() {
        // Initialize ARSCNView
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Load Scene
        guard let scene = SCNScene(named: "art.scnassets/ship.scn") else {
            fatalError("ship.scn file not found.")
        }
        sceneView.scene = scene
        
        // Animate the ship
        if let _ = scene.rootNode.childNode(withName: "ship", recursively: true) {
            animateShip()
        } else {
            print("Ship node not found in the scene.")
        }
    }

    // MARK: - UI Setup
    func setupWeatherLabel() {
        weatherLabel = UILabel()
        weatherLabel.frame = CGRect(x: 20, y: 50, width: view.bounds.width - 40, height: 100)
        weatherLabel.textColor = .white
        weatherLabel.font = UIFont.systemFont(ofSize: 18)
        weatherLabel.numberOfLines = 0
        weatherLabel.textAlignment = .left
        weatherLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        weatherLabel.layer.cornerRadius = 8
        weatherLabel.clipsToBounds = true
        weatherLabel.text = "Enter a city to get weather data."
        view.addSubview(weatherLabel)
    }
    
    func setupInputFieldAndButton() {
        // Location Input
        locationTextField = UITextField()
        locationTextField.frame = CGRect(x: 20, y: 160, width: 200, height: 40)
        locationTextField.borderStyle = .roundedRect
        locationTextField.placeholder = "Enter city"
        view.addSubview(locationTextField)
        
        // Fetch Button
        fetchButton = UIButton(type: .system)
        fetchButton.frame = CGRect(x: 230, y: 160, width: 100, height: 40)
        fetchButton.setTitle("Fetch", for: .normal)
        fetchButton.addTarget(self, action: #selector(fetchWeatherButtonTapped), for: .touchUpInside)
        view.addSubview(fetchButton)
    }
    func setupProfileButton() {
        profileButton = UIButton(type: .system)
        profileButton.setTitle("Profile", for: .normal)
        profileButton.setTitleColor(.white, for: .normal)
        profileButton.backgroundColor = .systemBlue
        profileButton.layer.cornerRadius = 8
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(profileButton)

        NSLayoutConstraint.activate([
            profileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.widthAnchor.constraint(equalToConstant: 100),
            profileButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }

    // MARK: - Profile Navigation
    @objc func profileButtonTapped() {
        print("Profile button tapped") // Debugging print
        guard let navigationController = navigationController else {
            print("NavigationController is nil. Ensure ViewController is embedded in a UINavigationController.")
            return
        }

        let profileVC = ProfileViewController()
        navigationController.pushViewController(profileVC, animated: true)
        print("Navigated to ProfileViewController") // Debugging print
    }



    // MARK: - Weather Fetching
    @objc func fetchWeatherButtonTapped() {
        guard let city = locationTextField.text, !city.isEmpty else {
            weatherLabel.text = "Please enter a valid city name."
            return
        }
        fetchWeatherData(for: city)
    }
    
    func fetchWeatherData(for city: String) {
        let apiKey = "09563acd37dd0b4e62a7488106de357d"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            weatherLabel.text = "Invalid URL for weather data."
            return
        }
        
        weatherLabel.text = "Fetching weather data for \(city)..."
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.weatherLabel.text = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.weatherLabel.text = "Error: No data received."
                }
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.updateWeatherLabel(weatherData, city: city)
                }
            } catch {
                DispatchQueue.main.async {
                    self.weatherLabel.text = "Error decoding weather data."
                }
            }
        }
        task.resume()
    }

    // MARK: - Weather Label Update
    func updateWeatherLabel(_ weatherData: WeatherResponse, city: String) {
        let temperature = weatherData.main.temp
        let description = weatherData.weather.first?.description.lowercased() ?? "N/A"
        weatherLabel.text = "City: \(city)\nTemperature: \(temperature)°C\nCondition: \(description)"
        
        removeWeatherEffect()
        applyWeatherEffect(description: description)
    }
    
    // MARK: - Weather Effects
    func applyWeatherEffect(description: String) {
        switch description {
        case let desc where desc.contains("rain"):
            addRainEffect()
        case let desc where desc.contains("thunderstorm"):
            addThunderEffect()
        case let desc where desc.contains("snow"):
            addSnowEffect()
        case let desc where desc.contains("cloud"):
            addCloudEffect()
        case let desc where desc.contains("fog"):
            addFogEffect()
        default:
            break
        }
    }

    func removeWeatherEffect() {
        weatherNode?.removeFromParentNode()
        weatherNode = nil
    }

    // MARK: - Effect Implementations
    private func playSound(fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Sound file not found: \(fileName).\(fileType)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }

    // Function to stop sound
    private func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // Updated Weather Effects with Sound

    func addRainEffect() {
        guard weatherNode == nil else { return }
        
        stopSound() // Stop any previous sound
        playSound(fileName: "Rain", fileType: "mp3") // Play rain sound

        let rain = SCNParticleSystem(named: "Rain.scnp", inDirectory: nil) ?? SCNParticleSystem()
        rain.birthRate = 200
        rain.particleSize = 0.01
        rain.speedFactor = 1.5
        rain.emitterShape = SCNCylinder(radius: 1, height: 1)
        
        let rainNode = SCNNode()
        rainNode.position = SCNVector3(0, 0, 0)
        rainNode.addParticleSystem(rain)
        sceneView.scene.rootNode.addChildNode(rainNode)
        weatherNode = rainNode
    }

    func addThunderEffect() {
        guard weatherNode == nil else { return }
        
        stopSound()
        playSound(fileName: "Thunder", fileType: "mp3") // Play thunder sound

        let thunder = SCNNode()
        let light = SCNLight()
        light.type = .omni
        light.intensity = 0
        thunder.light = light
        thunder.position = SCNVector3(0, 5, -2)
        
        sceneView.scene.rootNode.addChildNode(thunder)
        weatherNode = thunder
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        light.intensity = 5000
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            light.intensity = 0
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }

    func addCloudEffect() {
        guard weatherNode == nil else { return }
        
        stopSound()
        playSound(fileName: "Cloud", fileType: "mp3") // Play wind sound for cloudy weather

        let cloud = SCNParticleSystem(named: "Clouds.scnp", inDirectory: nil) ?? SCNParticleSystem()
        cloud.birthRate = 20
        cloud.particleSize = 0.5
        cloud.spreadingAngle = 10
        
        let cloudNode = SCNNode()
        cloudNode.position = SCNVector3(0, 3, -3)
        cloudNode.addParticleSystem(cloud)
        sceneView.scene.rootNode.addChildNode(cloudNode)
        weatherNode = cloudNode
    }

    func addSnowEffect() {
        guard weatherNode == nil else { return }
        
        stopSound()
        playSound(fileName: "Snow", fileType: "mp3") // Play snow sound

        let snow = SCNParticleSystem(named: "Snow.scnp", inDirectory: nil) ?? SCNParticleSystem()
        snow.birthRate = 50
        snow.particleSize = 0.02
        snow.speedFactor = 0.3
        snow.emitterShape = SCNSphere(radius: 2)
        
        let snowNode = SCNNode()
        snowNode.position = SCNVector3(0, 5, -2)
        snowNode.addParticleSystem(snow)
        sceneView.scene.rootNode.addChildNode(snowNode)
        weatherNode = snowNode
    }

    func addFogEffect() {
        guard weatherNode == nil else { return }
        
        stopSound()
        playSound(fileName: "Cloud", fileType: "mp3") // Play fog ambiance sound

        let fogNode = SCNNode()
        fogNode.geometry = SCNSphere(radius: 10)
        fogNode.geometry?.firstMaterial?.transparency = 0.5
        fogNode.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        fogNode.position = SCNVector3(0, 0, -2)
        
        sceneView.scene.rootNode.addChildNode(fogNode)
        weatherNode = fogNode
    }
    func animateShip() {
        // Find the ship node in the scene
        if let shipNode = sceneView.scene.rootNode.childNode(withName: "ship", recursively: true) {
            // Define the circular path
            let radius: CGFloat = 1.0 // Radius of the circle
            let duration: TimeInterval = 5.0 // Duration for one complete rotation

            // Circular movement using SCNAction
            let circularPath = SCNAction.customAction(duration: duration) { node, elapsedTime in
                let angle = CGFloat(elapsedTime / CGFloat(duration)) * 2 * .pi
                let x = radius * cos(angle)
                let z = radius * sin(angle)
                node.position = SCNVector3(x, 0, z)
            }

            // Rotation to face the direction of movement
            let lookAtCenter = SCNAction.customAction(duration: duration) { node, elapsedTime in
                let angle = CGFloat(elapsedTime / CGFloat(duration)) * 2 * .pi
                node.eulerAngles = SCNVector3(0, -angle, 0)
            }

            // Combine circular movement and rotation
            let combinedAction = SCNAction.group([circularPath, lookAtCenter])

            // Repeat the animation indefinitely
            let repeatAnimation = SCNAction.repeatForever(combinedAction)

            // Run the animation on the ship node
            shipNode.runAction(repeatAnimation)
        } else {
            print("Ship node not found in the scene.")
        }
    }

    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session Error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session Interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session Resumed")
    }
}

// MARK: - WeatherResponse Struct
struct WeatherResponse: Codable {
    struct Main: Codable {
        let temp: Double
    }
    struct Weather: Codable {
        let description: String
    }
    let main: Main
    let weather: [Weather]
}
