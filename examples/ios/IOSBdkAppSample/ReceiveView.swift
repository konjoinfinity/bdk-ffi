//
//  ReceiveView.swift
//  IOSBdkAppSample
//
//  Created by Sudarsan Balaji on 02/11/21.
//

import SwiftUI

struct ReceiveView: View {
    var address: String;
    
    var body: some View {
        BackgroundWrapper {
            Spacer()
            VStack {
                Rectangle().fill(.white).cornerRadius(5).frame(width: 200, height: 200)
                Text(address).textStyle(BasicTextStyle(white: true))
            }.contextMenu {
                Button(action: {
                    UIPasteboard.general.string = address}) {
                        Text("Copy to clipboard")
                    }
            }
            Spacer()
            BasicButton(action: {}, text: "Generate new address", color: "Green")
        }
        .navigationTitle("Receive Address")
        .modifier(BackButtonMod())
    }
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView(address: "some-random-address")
    }
}
