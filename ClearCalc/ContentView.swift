//
//  ContentView.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 07/04/25.
//

import SwiftUI
import Expression

struct ContentView: View {
    @State private var display = "0"
    @State private var currentInput: String = ""
    @State private var expressionShown = ""
    @State private var showMenu: Bool = false
    @State private var dragOffset: CGFloat = 0.0
    @State private var justEvaluated = false
    @State private var history: [String] = []
    @State private var showHistorySheet = false

    let buttons: [[String]] = [
        ["C", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color(.systemGray6).ignoresSafeArea()

                    VStack(spacing: 12) {
                        Spacer()

                        // History button
                        HStack {
                            Button(action: {
                                showHistorySheet = true
                            }) {
                                Label("History", systemImage: "clock.arrow.circlepath")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.leading)
                            Spacer()
                        }

                        // Display
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                Spacer()
                                Text(expressionShown)
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                    .padding(.trailing)
                            }

                            HStack {
                                Spacer()
                                Text(display)
                                    .font(.system(size: 64))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .padding(.trailing, 8)

                                Button(action: {
                                    backspace()
                                }) {
                                    Image(systemName: "delete.left")
                                        .font(.system(size: 28))
                                        .foregroundColor(.red)
                                        .padding(.trailing)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Buttons
                        ForEach(buttons, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(row, id: \.self) { label in
                                    Button(action: {
                                        self.handleTap(label)
                                    }) {
                                        Text(label)
                                            .font(.system(size: 32))
                                            .frame(width: self.buttonWidth(label: label), height: self.buttonHeight())
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .cornerRadius(self.buttonWidth(label: label) / 2)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .navigationBarTitle("ClearCalc", displayMode: .inline)
                    .navigationBarItems(leading:
                        Button(action: {
                            withAnimation {
                                showMenu = true
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                    )
                }
            }

            // Side Menu Slide-in with Drag
            ZStack {
                if showMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                                dragOffset = 0
                            }
                        }
                }

                HStack {
                    SideMenuView(showMenu: $showMenu)
                        .frame(width: 250)
                        .offset(x: showMenu ? dragOffset : -250 + dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.width >= 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.width < -100 {
                                        withAnimation {
                                            showMenu = false
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                    Spacer()
                }
            }
            .animation(.easeInOut, value: dragOffset)
        }
        .sheet(isPresented: $showHistorySheet) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Calculation History")
                    .font(.title2)
                    .padding()

                ScrollView {
                    ForEach(history, id: \.self) { item in
                        Text(item)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation {
                            showMenu = true
                        }
                    }
                }
        )
    }

    func handleTap(_ label: String) {
        switch label {
        case "C":
            display = "0"
            currentInput = ""
            expressionShown = ""
            history.removeAll()
        case "=":
            let expression = currentInput
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
                .replacingOccurrences(of: "%", with: "*0.01")
                .replacingOccurrences(of: "^", with: "**")

            if isValidExpression(expression) {
                let result = evaluateExpression(expression)
                display = result
                expressionShown = currentInput
                history.insert("\(currentInput) = \(result)", at: 0)
                currentInput = result
                justEvaluated = true
            }
        case "+", "-", "×", "÷":
            if justEvaluated {
                currentInput = display + label
                justEvaluated = false
            } else {
                currentInput += label
            }
            display = currentInput
        case "+/-":
            if currentInput.hasPrefix("-") {
                currentInput.removeFirst()
            } else {
                currentInput = "-" + currentInput
            }
            display = currentInput
        case ".":
            if let last = currentInput.split(whereSeparator: { "+-×÷*/".contains($0) }).last,
               last.contains(".") {
                return
            }
            currentInput += "."
            display = currentInput
        default:
            if justEvaluated {
                currentInput = label
                justEvaluated = false
            } else {
                currentInput += label
            }
            display = currentInput
        }
    }

    func isValidExpression(_ expression: String) -> Bool {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        let operators = "+-*/"
        if trimmed.isEmpty || operators.contains(trimmed.first!) || operators.contains(trimmed.last!) {
            return false
        }
        return true
    }

    func evaluateExpression(_ expression: String) -> String {
        let expr = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "%", with: "*0.01")
            .replacingOccurrences(of: "^", with: "**")

        do {
            let result = try Expression(expr).evaluate()
            return String(format: "%g", result)
        } catch {
            return "Error"
        }
    }

    func backspace() {
        guard !currentInput.isEmpty else { return }

        currentInput.removeLast()
        display = currentInput.isEmpty ? "0" : currentInput
    }

    func buttonWidth(label: String) -> CGFloat {
        if label == "0" {
            return (UIScreen.main.bounds.width - 5 * 12) / 2
        }
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }

    func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
