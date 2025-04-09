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
    @State private var currentInput = ""
    @State private var expressionShown = ""
    @State private var showMenu = false
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
                            withAnimation { showMenu = true }
                        }) {
                            Image(systemName: "line.horizontal.3").imageScale(.large)
                        }
                    )
                }
            }

            // Side menu
            ZStack {
                if showMenu {
                    Color.black.opacity(0.3).ignoresSafeArea().onTapGesture {
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
                                    withAnimation {
                                        if value.translation.width < -100 {
                                            showMenu = false
                                        }
                                        dragOffset = 0
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
                HStack {
                    Text("Calculation History")
                        .font(.title2)
                        .padding(.leading)
                    Spacer()
                    Button("Close") {
                        showHistorySheet = false
                    }
                    .padding(.trailing)
                }
                .padding(.top)

                ScrollView {
                    ForEach(history.indices, id: \.self) { index in
                        Text("\(index + 1). \(history[index])")
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 100 {
                    withAnimation {
                        showMenu = true
                    }
                }
            }
        )
    }

    // MARK: - Logic
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
                if result != "Error", expression != result {
                    let formatted = formatNumber(result)
                    display = formatted
                    expressionShown = currentInput
                    history.insert("\(currentInput) = \(formatted)", at: 0)
                    currentInput = result
                    justEvaluated = true
                } else {
                    display = formatNumber(result)
                    currentInput = result
                    justEvaluated = true
                }
            }

        case "+", "-", "×", "÷":
            if justEvaluated {
                currentInput = display.replacingOccurrences(of: ",", with: "") + label
                justEvaluated = false
            } else {
                if let last = currentInput.last, "+-×÷".contains(last) {
                    currentInput.removeLast()
                }
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
            if currentInput.isEmpty {
                currentInput = "0."
            } else if let last = currentInput.split(whereSeparator: { "+-×÷*/".contains($0) }).last,
                      last.contains(".") {
                return
            } else {
                currentInput += "."
            }
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

    // MARK: - Helpers

    func isValidExpression(_ expression: String) -> Bool {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        let operators = "+-*/"
        return !(trimmed.isEmpty || operators.contains(trimmed.first!) || operators.contains(trimmed.last!))
    }

    func evaluateExpression(_ expression: String) -> String {
        let expr = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "%", with: "*0.01")
            .replacingOccurrences(of: "^", with: "**")

        do {
            let result = try Expression(expr).evaluate()
            return String(result)
        } catch {
            return "Error"
        }
    }

    func formatNumber(_ string: String) -> String {
        guard let number = Double(string) else { return string }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        return formatter.string(from: NSNumber(value: number)) ?? string
    }

    func backspace() {
        guard !currentInput.isEmpty else { return }
        currentInput.removeLast()
        display = currentInput.isEmpty ? "0" : currentInput
    }

    func buttonWidth(label: String) -> CGFloat {
        label == "0"
        ? (UIScreen.main.bounds.width - 5 * 12) / 2
        : (UIScreen.main.bounds.width - 5 * 12) / 4
    }

    func buttonHeight() -> CGFloat {
        (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
