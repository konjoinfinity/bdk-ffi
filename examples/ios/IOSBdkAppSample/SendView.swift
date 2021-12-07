//
//  SendView.swift
//  IOSBdkAppSample
//
//  Created by Sudarsan Balaji on 02/11/21.
//

import SwiftUI
import Combine
import CodeScanner

struct SendView: View {
    @State var to: String = ""
    @State var amount: String = "0.000"
    @State private var usd = 0.00
    @State var btcusd: Double = 50500
    @State private var usdamnt = 0
    @State private var isShowingScanner = false
    @Environment(\.presentationMode) var presentationMode
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        switch result {
        case .success(let code):
            self.to = code
        case .failure(let error):
            print(error)
        }
    }
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    var onSend : (String, UInt64) -> ()
    var body: some View {
        BackgroundWrapper {
            VStack {
                
            
            Form {
                Section(header: Text("Recipient").textStyle(BasicTextStyle(white: true))) {
                    TextField("Address", text: $to)
                        .modifier(BasicTextFieldStyle())
                }
                Section(header: Text("₿ Amount (BTC)").textStyle(BasicTextStyle(white: true))) {
                    TextField("Amount", text: $amount)
                        .modifier(BasicTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onReceive(Just(amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.amount = filtered
                            }
//                            usd = self.amount
                        }
                }
                Section(header: Text("$ Amount (USD)").textStyle(BasicTextStyle(white: true))) {
                    TextField("$ Amount", value: $usd, formatter: formatter)
                        .modifier(BasicTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onReceive(Just(String(usd))) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.usd = (filtered as NSString).doubleValue
                            }
//                            amount = String(Int(usd / btcusd))
//                            print(amount)
                        }
                }
            }
            .onAppear {
                UITableView.appearance().backgroundColor = .clear }
                
                Spacer()
                BasicButton(action: { self.isShowingScanner = true}, text: "Scan Address")
                BasicButton(action: {
                    onSend(to, UInt64((Double(amount) ?? 0) * Double(100000000)))
                    presentationMode.wrappedValue.dismiss()
                }, text: "Broadcast Transaction", color: "Red").disabled(to == "" || (Double(amount) ?? 0) == 0)
            }
        }
        .navigationTitle("Send")
        .modifier(BackButtonMod())
        .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Testing1234", completion: self.handleScan)}
    }
}

struct SendView_Previews: PreviewProvider {
    static func onSend(to: String, amount: UInt64) {
        
    }
    static var previews: some View {
        SendView(onSend: self.onSend)
    }
}
