//
//  HomeStatisticView.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import SwiftUI

struct HomeStatisticView: View {
    @EnvironmentObject private var vm: HomeViewModel
    
    @Binding var showPortfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(vm.statistic) { stat in
                StatisticView(statistic: stat)
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(width: UIScreen.main.bounds.width, alignment: showPortfolio ? .trailing : .leading)
    }
}


struct HomeStatisticView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatisticView(showPortfolio: .constant(true))
            .environmentObject(dev.homeVM)
    }
}
