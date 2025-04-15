//
//  AboutView.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 12/04/25.
//
import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("👋 Hello!")
                        .font(.title)
                        .bold()

                    Text("I'm Amol Vyavaharkar, creator of ClearCalc. This is a minimal, smooth calculator built with SwiftUI. Future features like scientific mode and unit conversion are coming soon!")

                    Divider()

                    Text("📱 Follow Me:")
                        .font(.headline)

                    HStack(spacing: 24) {
                        socialIcon(systemName: "f.circle.fill", color: .blue, url: "https://facebook.com")
                        socialIcon(systemName: "bird.fill", color: .cyan, url: "https://twitter.com")
                        socialIcon(systemName: "camera.circle.fill", color: .pink, url: "https://instagram.com")
                    }

                    Divider()

                    Text("🔗 My Links")
                        .font(.headline)

                    HStack(spacing: 24) {
                        socialIcon(systemName: "link.circle.fill", color: .black, url: "https://github.com/amolvyavaharkar")
                        socialIcon(systemName: "play.circle.fill", color: .red, url: "https://youtube.com/@yourchannel")
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("About ClearCalc")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func socialIcon(systemName: String, color: Color, url: String) -> some View {
        Button(action: {
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        }) {
            Image(systemName: systemName)
                .font(.system(size: 32))
                .foregroundColor(color)
                .contentShape(Rectangle()) // Ensures the entire area is tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
