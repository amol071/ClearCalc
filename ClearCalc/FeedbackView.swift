//
//  FeedbackView.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 12/04/25.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Send us your feedback")
                .font(.title2)
                .padding()

            Text("We're always happy to hear your suggestions, issues, or compliments!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                if let url = URL(string: "mailto:support@clearcalc.com?subject=App Feedback") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Send Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
