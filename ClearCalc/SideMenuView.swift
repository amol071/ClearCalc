//
//  SideMenuView.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 07/04/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var showMenu: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Theme Settings")
                .font(.title3)
                .foregroundColor(.blue)

            Text("Font Size")
                .font(.title3)
                .foregroundColor(.blue)

            Text("About ClearCalc")
                .font(.title3)
                .foregroundColor(.blue)

            Spacer()
        }
        .padding(.top, 60) // Below notch
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 250)
        .background(Color.white)
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(showMenu: .constant(true))
    }
}
