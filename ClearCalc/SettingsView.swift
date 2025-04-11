import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showFeedback = false

    var body: some View {
        NavigationView {
            Form {
                // Appearance
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                }

                // Actions
                Section {
                    Button("Send Feedback") {
                        showFeedback = true
                    }

                    Button("Rate This App") {
                        rateApp()
                    }
                }

                // App Info
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light) // 🔥 Apply here!
    }

    func rateApp() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id0000000000?action=write-review") else { return }
        UIApplication.shared.open(writeReviewURL)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
