import SwiftUI

struct SideMenuView: View {
    @Binding var showMenu: Bool
    @State private var showSettings = false
    @State private var showComingSoonAlert = false
    @State private var comingSoonFeatureName = ""

    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button(action: {
                comingSoonFeatureName = "Scientific Calculator"
                showComingSoonAlert = true
            }) {
                Text("Scientific Calculator")
                    .font(.title3)
                    .foregroundColor(isDarkMode ? .yellow : .blue)
            }

            Button(action: {
                comingSoonFeatureName = "Converter"
                showComingSoonAlert = true
            }) {
                Text("Converter")
                    .font(.title3)
                    .foregroundColor(isDarkMode ? .yellow : .blue)
            }

            Button(action: {
                showSettings = true
                showMenu = false
            }) {
                Text("Settings")
                    .font(.title3)
                    .foregroundColor(isDarkMode ? .yellow : .blue)
            }

            Button(action: {
                // About page logic (future)
                showMenu = false
            }) {
                Text("About")
                    .font(.title3)
                    .foregroundColor(isDarkMode ? .yellow : .blue)
            }

            Spacer()

            Text("Version 1.0.0")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 250)
        .background(isDarkMode ? Color.black : Color.white)
        .edgesIgnoringSafeArea(.vertical)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert(isPresented: $showComingSoonAlert) {
            Alert(
                title: Text("Coming Soon"),
                message: Text("\(comingSoonFeatureName) is under development."),
                dismissButton: .default(Text("OK"), action: {
                    showMenu = false // Dismiss menu *after* alert
                })
            )
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(showMenu: .constant(true))
    }
}
