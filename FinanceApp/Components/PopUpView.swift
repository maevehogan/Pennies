//
//  PopUpView.swift
//  FinanceApp
//

import SwiftUI

struct PopUpView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let buttonAction: () -> ()
    let closeAction: () -> ()

    @State private var offsetY: CGFloat = 1000

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { close() }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { close() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.7))

                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.electricBlue, Color.neonPurple],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
            .glassCard(cornerRadius: 20, accent: .electricBlue)
            .shadow(color: Color.electricBlue.opacity(0.2), radius: 24, y: 8)
            .padding(.horizontal, 28)
            .offset(y: offsetY)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    offsetY = 0
                }
            }
        }
    }

    func close() {
        withAnimation(.spring()) { offsetY = 1000 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { closeAction() }
    }
}

#Preview {
    ZStack {
        AppBackground()
        PopUpView(
            title: "Move Transaction",
            message: "Are you sure you want to move this transaction?",
            buttonTitle: "Confirm",
            buttonAction: {},
            closeAction: {}
        )
    }
}
