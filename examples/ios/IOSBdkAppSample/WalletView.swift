//
//  WalletView.swift
//  IOSBdkAppSample
//
//  Created by Sudarsan Balaji on 29/10/21.
//
import SwiftUI
import Combine

class Progress : BdkProgress {
    func update(progress: Float, message: String?) {
        print("progress", progress, message as Any)
    }
}

struct WalletView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    
    @State private var goToIntro = false
    @State private var goToTxs = false
    
    @State var balance: UInt64 = 0
    @State var dollars: Double = 0.00
    @State var btcprice: Double = 0
    @State var transactions: [Transaction] = []
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.monospacedSystemFont(ofSize: 28, weight: .bold), .foregroundColor: UIColor.white]
        }
    func sync() {
        struct Price: Codable {
            let bitcoin: Bitcoin
        }
        struct Bitcoin: Codable {
            let usd: Int
        }
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
        switch viewModel.state {
        case .loaded(let wallet):
            do {
                try wallet.sync(progressUpdate: Progress(), maxAddressParam: nil)
                balance = try wallet.getBalance()
                let wallet_transactions = try wallet.getTransactions()
                transactions = wallet_transactions.sorted(by: {
                    switch $0 {
                    case .confirmed(_, let confirmation_a):
                        switch $1 {
                        case .confirmed(_, let confirmation_b): return confirmation_a.timestamp > confirmation_b.timestamp
                        default: return false
                        }
                    default:
                        switch $1 {
                        case .unconfirmed(_): return true
                        default: return false
                        }
                    } })
            } catch let error {
                print(error)
            }
        default: do { }
        }
        print(Double(balance))
        let prettybal = Double(balance) / Double(100000000)
        print(Double(btcprice))
        dollars = Double(prettybal) * Double(btcprice)
    }
    var body: some View {
        NavigationView {
            switch viewModel.state {
            case .empty:
                Color.clear
                    .onAppear(perform: viewModel.load)
            case .loading:
                ProgressView()
            case .failed(_):
                Text("Failed to load wallet")
            case .loaded(let wallet):
                BackgroundWrapper {
                    VStack {
                        Button(action: {() in goToIntro = true}) {
                            HStack() {
                                Spacer()
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(Color.white)
                            }
                        }
                        NavigationLink(destination: SettingsView(), isActive: $goToIntro) { EmptyView() }
                    }
                    Spacer().frame(minHeight: 40)
                                        BalanceDisplay(balance: String(format: "%.8f", Double(balance) / Double(100000000))).padding(.leading, -10).padding(.trailing, -10)
                                        DollarsDisplay(dollars: String(format: "%.2f", Double(dollars))).padding(.leading, -10).padding(.trailing, -10)
                                        Spacer().frame(minHeight: 10)
                    VStack() {
                        BasicButton(action: self.sync, text: "sync wallet").padding(.bottom, 10)
                        NavigationLink(destination: TransactionsView(transactions: transactions), isActive: $goToTxs) { EmptyView() }
                        BasicButton(action: { goToTxs = true}, text: "transaction history")
                    }.padding(.bottom, 10)
                    SendReceiveButtons(wallet: wallet)
                    Spacer().frame(minHeight: 40)
                }.navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
