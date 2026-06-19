//
//  PopUpView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/19/26.
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
            Color.blue.opacity(0.4).ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    close()
                }
            VStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                
                Button {
                    buttonAction()
                } label: {
                    Text(buttonTitle)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(Color.black.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                VStack {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            close()
                        }) {
                            Image(systemName: "x.circle")
                                .font(.title2)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                    }
                    Spacer()
                }
                    .padding(10)
            )
            .shadow(color: .white, radius: 10)
            .padding(30)
            .offset(x: 0, y: offsetY)
            .onAppear {
                withAnimation(.spring()) {
                    offsetY = 0
                }
            }
        }
    }
    
    func close() {
        withAnimation(.spring()) {
            offsetY = 1000
        }
        // Notify parent to hide popup and/or dismiss sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            closeAction()
        }
    }
}

#Preview {
    PopUpView(title: "Add transaction to Sub-Budget?", message: "Are you sure you want to add this transaction to this sub-budget?", buttonTitle: "OK", buttonAction: {
        print("Button tapped")
    }, closeAction: { })
}
