//
//  SendView.swift
//  IOSBdkAppSample
//
//  Created by Sudarsan Balaji on 02/11/21.
//

import SwiftUI
import Combine

struct SendView: View {
    
    
    
    var onSend : (String, UInt64) -> ()
    @Environment(\.presentationMode) var presentationMode
    @State var to: String = ""
    @State var amount: String = "0.000"
    
    
    
    var body: some View {
        BackgroundWrapper {
            VStack {
                
            
            Form {
                Section(header: Text("Recipient").textStyle(BasicTextStyle(white: true))) {
                    TextField("Address", text: $to)
                        .modifier(BasicTextFieldStyle())
                }
                Section(header: Text("Amount (BTC)").textStyle(BasicTextStyle(white: true))) {
                    TextField("Amount", text: $amount)
                        .modifier(BasicTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onReceive(Just(amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.amount = filtered
                            }
                        }
                }
//                BasicButton(action: {
//                    onSend(to, UInt64((Double(amount) ?? 0) * Double(100000000)))
//                    presentationMode.wrappedValue.dismiss()
//                }, text: "Send")
//                    .disabled(to == "" || (Double(amount) ?? 0) == 0)
            }
            .onAppear {
                UITableView.appearance().backgroundColor = .clear }
                
                Spacer()
                BasicButton(action: {}, text: "Scan Address")
                BasicButton(action: {
                    onSend(to, UInt64((Double(amount) ?? 0) * Double(100000000)))
                    presentationMode.wrappedValue.dismiss()
                }, text: "Broadcast Transaction", color: "Red").disabled(to == "" || (Double(amount) ?? 0) == 0)
            }
        }
        .navigationTitle("Send")
        .modifier(BackButtonMod())
    }
}

struct SendView_Previews: PreviewProvider {
    static func onSend(to: String, amount: UInt64) {
        
    }
    static var previews: some View {
        SendView(onSend: self.onSend)
    }
}
