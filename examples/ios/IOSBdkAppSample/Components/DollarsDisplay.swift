//
//  DollarsDisplay.swift
//  IOSBdkAppSample
//
//  Created by Konjo on 12/7/21.
//

import SwiftUI

struct DollarsDisplay: View {
    var dollars: String
    var body: some View {
        Text("~ $\(dollars)")
            .font(.system(size: 16, design: .monospaced))
            .fontWeight(.semibold)
            .foregroundColor(Color.white)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color("Shadow"))
    }
}

struct DollarsDisplay_Previews: PreviewProvider {
    static var previews: some View {
        DollarsDisplay(dollars: "0.00")
    }
}
