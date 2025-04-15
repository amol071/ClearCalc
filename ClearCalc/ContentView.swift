//
//  ContentView.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 07/04/25.
//

//  ContentView.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 07/04/25.

import SwiftUI
import Expression

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var display = "0"
    @State private var rawInput = ""
    @State private var expressionShown = ""
    @State private var showMenu = false
    @State private var dragOffset: CGFloat = 0.0
    @State private var justEvaluated = false
    @State private var history: [String] = []
    @State private var showHistorySheet = false
    @State private var showCharLimitAlert = false

    let characterLimit = 40

    let buttons: [[String]] = [
        ["+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var currentInput: String {
        rawInput.formatExpression()
    }

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color(.systemGray6).ignoresSafeArea()

                    VStack(spacing: 12) {
                        Spacer()

                        VStack(alignment: .trailing, spacing: 8) {
                            if !expressionShown.isEmpty {
                                Text(expressionShown)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(isDarkMode ? .yellow : .gray)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal)
                            }

                            Text(display)
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(isDarkMode ? .yellow : .black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 8)
                        }

                        HStack {
                            Spacer()
                            Button(action: {
                                showHistorySheet = true
                            }) {
                                Label("History", systemImage: "clock.arrow.circlepath")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)

                        HStack(spacing: 12) {
                            Button(action: {
                                if rawInput.isEmpty {
                                    display = "0"
                                    expressionShown = ""
                                    history.removeAll()
                                } else {
                                    backspace()
                                }
                            }) {
                                Group {
                                    if rawInput.isEmpty {
                                        Text("C").font(.system(size: 28, weight: .semibold))
                                    } else {
                                        Image(systemName: "delete.left.fill").font(.system(size: 28))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(width: buttonWidth(label: "C"), height: buttonHeight())
                                .background(rawInput.isEmpty ? Color.orange : Color.red)
                                .cornerRadius(buttonWidth(label: "C") / 2)
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                                    rawInput = ""
                                    display = "0"
                                    expressionShown = ""
                                    history.removeAll()
                                }
                            )

                            ForEach(buttons[0], id: \.self) { label in
                                Button(action: {
                                    self.handleTap(label)
                                }) {
                                    Text(label)
                                        .font(.system(size: 32))
                                        .frame(width: buttonWidth(label: label), height: buttonHeight())
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(buttonWidth(label: label) / 2)
                                }
                            }
                        }

                        ForEach(buttons.dropFirst(), id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(row, id: \.self) { label in
                                    Button(action: {
                                        self.handleTap(label)
                                    }) {
                                        Text(label)
                                            .font(.system(size: 32))
                                            .frame(width: buttonWidth(label: label), height: buttonHeight())
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .cornerRadius(buttonWidth(label: label) / 2)
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
            .animation(.easeInOut, value: dragOffset)
        }
        .alert(isPresented: $showCharLimitAlert) {
            Alert(title: Text("Limit Reached"), message: Text("Character limit exceeded."), dismissButton: .default(Text("OK")))
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
        if rawInput.count >= characterLimit && label != "=" {
            showCharLimitAlert = true
            return
        }

        switch label {
        case "=":
            let expression = rawInput
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
                .replacingOccurrences(of: "%", with: "*0.01")
                .replacingOccurrences(of: ",", with: "")

            if isValidExpression(expression) {
                let result = evaluateExpression(expression)
                if result != "Error", let _ = Double(result) {
                    let formatted = formatNumber(result)
                    display = formatted
                    if expression.rangeOfCharacter(from: CharacterSet(charactersIn: "+-*/")) != nil {
                        expressionShown = currentInput
                        history.insert("\(currentInput) = \(formatted)", at: 0)
                    } else {
                        expressionShown = ""
                    }
                    rawInput = result
                    justEvaluated = true
                }
            }

        case "+", "-", "×", "÷":
            if justEvaluated {
                rawInput = display.replacingOccurrences(of: ",", with: "")
                justEvaluated = false
            }
            if rawInput.hasSuffix(".") { rawInput.removeLast() }
            if let last = rawInput.last, "+-×÷".contains(last) {
                rawInput.removeLast()
            }
            rawInput += label
            display = currentInput

        case "+/-":
            if rawInput.isEmpty { return }
            rawInput = "(-\(rawInput))"
            display = currentInput

        case ".":
            if rawInput.isEmpty {
                rawInput = "0."
            } else if let last = rawInput.split(whereSeparator: { "+-×÷*/".contains($0) }).last, last.contains(".") {
                return
            } else {
                rawInput += "."
            }
            display = currentInput

        default:
            if justEvaluated {
                rawInput = label
                justEvaluated = false
            } else {
                rawInput += label
            }
            display = currentInput
        }
    }

    func isValidExpression(_ expression: String) -> Bool {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        let operators = "+-*/"
        return !(trimmed.isEmpty || operators.contains(trimmed.first!) || operators.contains(trimmed.last!))
    }

    func evaluateExpression(_ expression: String) -> String {
        do {
            let result = try Expression(expression).evaluate()
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
        guard !rawInput.isEmpty else { return }
        rawInput.removeLast()
        display = rawInput.isEmpty ? "0" : currentInput
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

extension String {
    func formatExpression() -> String {
        var formatted = ""
        var currentNumber = ""
        var trailingDot = false

        for char in self {
            if char.isWholeNumber || char == "." {
                if char == "." && currentNumber.contains(".") == false {
                    trailingDot = true
                }
                currentNumber.append(char)
            } else {
                if !currentNumber.isEmpty {
                    formatted += formatNumber(currentNumber, trailingDot: trailingDot)
                    currentNumber = ""
                    trailingDot = false
                }
                formatted.append(char)
            }
        }

        if !currentNumber.isEmpty {
            formatted += formatNumber(currentNumber, trailingDot: trailingDot)
        }

        return formatted
    }

    private func formatNumber(_ part: String, trailingDot: Bool) -> String {
        guard let number = Double(part) else { return part }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        var result = formatter.string(from: NSNumber(value: number)) ?? part
        if trailingDot && !result.contains(".") {
            result += "."
        }
        return result
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
