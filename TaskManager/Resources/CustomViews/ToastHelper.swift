//
//  ToastHelper.swift
//  TaskManager
//
//  Created by Janaina A on 27/02/2025.
//

import SwiftUI
import SimpleToast

struct ToastView: ViewModifier {
    @Binding var isPresented: Bool
    var message: String
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom,
        hideAfter: 5,
        modifierType: .scale
    )

    func body(content: Content) -> some View {
        content
            .simpleToast(isPresented: $isPresented, options: toastOptions) {
                Text(message)
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(Color.white)
                    .cornerRadius(25)
                    .padding(.bottom)
            }
    }
}

extension View {
    func showToast(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastView(isPresented: isPresented, message: message))
    }
}
