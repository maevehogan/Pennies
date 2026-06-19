//
//  Modal.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/19/26.
//

import SwiftUI

struct Modal<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
        
    let content: Content
    
    var body: some View {
        ZStack {
            content
            
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.title)
                            .foregroundColor(.blue.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

// THIS IS FOR PREVIEW TESTING ONLY - NOT FOR PRODUCTION
struct Test: View {
    @State private var showingSheet = false
    
    var body: some View {
        Button("Press to show modal") {
            showingSheet.toggle()
        }
        .padding()
        Text("This is a modal view")
            .font(.title)
            .foregroundColor(.blue)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.pink.opacity(0.3)))
            .sheet(isPresented: $showingSheet) {
                Modal(content:
                            Text("This is the content of the modal")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.indigo.opacity(0.3)))
                )
            }
    }
}

#Preview {
    Test()
}
