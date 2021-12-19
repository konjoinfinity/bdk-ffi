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
    @State var btcprice: Double = 0.00
    @State var usdsendamt: Double = 0.00
    @State private var keyboardOffset: CGFloat = 0
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
                Section(header: Text("₿ Amount (BTC)"), footer:  Text("Amount USD: ~" + "$\(round(usdsendamt * 100) / 100.0)").textStyle(BasicTextStyle(white: true))) {
                    TextField("Amount", text: $amount)
                        .modifier(BasicTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onReceive(Just(amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.amount = filtered
                            }
                            struct Price: Codable {
                                let bitcoin: Bitcoin
                            }
                            struct Bitcoin: Codable {
                                let usd: Int
                            }
                            if btcprice == 0 {
                            let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")!
                            var request = URLRequest(url: url)
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                if let data = data {
                                    if let price = try? JSONDecoder().decode(Price.self, from: data) {
                                        print(price.bitcoin.usd)
                                        btcprice = Double(price.bitcoin.usd)
                                    } else {
                                        print("Invalid Response")
                                    }
                                } else if let error = error {
                                    print("HTTP Request Failed \(error)")
                                }
                            }
                            task.resume()
                            }
                            usdsendamt = (amount as NSString).doubleValue * btcprice
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
