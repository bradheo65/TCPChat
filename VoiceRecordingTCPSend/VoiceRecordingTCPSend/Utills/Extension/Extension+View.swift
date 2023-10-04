//
//  Extension+View.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/27.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func showErrorMessage(showAlert: Binding<Bool>, message: String) -> some View {
          self.modifier(ErrorAlertModifier(isPresented: showAlert, message: message))
      }
}
struct ErrorAlertModifier: ViewModifier {
    var isPresented: Binding<Bool>
    let message: String

    func body(content: Content) -> some View {
        content.alert(isPresented: isPresented) {
            Alert(title: Text("Error"),
                  message: Text(message),
                  dismissButton: .cancel(Text("OK")))
        }
    }
}

