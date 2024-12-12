import SwiftUI

struct SettingsView: View {
    @State private var selectedUnit: String = "Celsius"
    @State private var selectedTheme: String = "Light"
    @State private var notificationsEnabled: Bool = true
    @State private var isResetAlertPresented: Bool = false
    @State private var isReportAlertPresented: Bool = false

    let units = ["Celsius", "Fahrenheit"]
    let themes = ["Light", "Dark", "System Default"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 30)

            // Unit Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Select Unit")
                    .font(.headline)
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.5), radius: 5)
            }

            // Theme Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Select Theme")
                    .font(.headline)
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.5), radius: 5)
            }

            // Notifications Toggle
            VStack(alignment: .leading, spacing: 10) {
                Text("Notifications")
                    .font(.headline)
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.5), radius: 5)
            }

            // Report an Issue Button
            Button(action: {
                isReportAlertPresented = true
            }) {
                Text("Report an Issue")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.5), radius: 5)
            }
            .alert(isPresented: $isReportAlertPresented) {
                Alert(
                    title: Text("Report an Issue"),
                    message: Text("Please contact support@weathertv.com to report any issues."),
                    dismissButton: .default(Text("OK"))
                )
            }

            // Reset Settings Button
            Button(action: {
                isResetAlertPresented = true
            }) {
                Text("Reset Settings")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.5), radius: 5)
            }
            .alert(isPresented: $isResetAlertPresented) {
                Alert(
                    title: Text("Reset Settings"),
                    message: Text("Are you sure you want to reset all settings?"),
                    primaryButton: .destructive(Text("Reset")) {
                        resetSettings()
                    },
                    secondaryButton: .cancel()
                )
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Settings")
    }

    // Reset Settings Function
    func resetSettings() {
        selectedUnit = "Celsius"
        selectedTheme = "Light"
        notificationsEnabled = true
    }
}

#Preview {
    SettingsView()
}
