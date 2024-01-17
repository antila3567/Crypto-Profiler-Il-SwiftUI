//
//  ChartView.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 17.01.2024.
//

import SwiftUI

struct ChartView: View {
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startDate: Date
    private let endDate: Date
    
    @State private var percentage: CGFloat = 0
    
    init(coin: Coin) {
        self.data = coin.sparklineIn7D?.price ?? []
        self.maxY = data.max() ?? 0
        self.minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        
        endDate = Date(coinGeckoString: coin.lastUpdated ?? "")
        startDate = endDate.addingTimeInterval(-7*24*60*60)
    }
    
    var body: some View {
        VStack {
            Chart
              .frame(height: 200)
              .background(ChartBG)
              .overlay (ChartYAxis.padding(.horizontal, 10), alignment: .leading)
            
            ChartDateLabels
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .onAppear {
            withAnimation(.linear(duration: 2)) {
                percentage = 1.0
            }
        }
       
    }
}

extension ChartView {
    private var ChartDateLabels: some View {
        HStack {
            Text("Start: \(startDate.asShortDateString())")
                .bold()
            Spacer()
            Text("End: \(endDate.asShortDateString())")
                .bold()
        }
        .padding(10)
    }
    
    private var ChartYAxis: some View {
        VStack {
            Text(maxY.formattedWithAbbreviations())
            Spacer()
            Text(((maxY + minY) / 2).formattedWithAbbreviations())
            Spacer()
            Text(minY.formattedWithAbbreviations())
        }
    }
    
    private var ChartBG: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var Chart: some View {
        GeometryReader { geometry in
            
            Path { path in
                for index in data.indices {
                    
                    let xPos = geometry.size.width / CGFloat(data.count) * CGFloat(index) + 1
                    
                    let yAxis = maxY - minY
                    
                    let yPos = (1 - (CGFloat(data[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPos, y: yPos))
                    }
                    
                    path.addLine(to: CGPoint(x: xPos, y: yPos))
                    
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(
                lineColor,
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .round
                ))
            .shadow(color: lineColor, radius: 10, x: 0, y: 10)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x: 0, y: 20)
        }
    }
}


struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChartView(coin: dev.coin)
        }
    }
}
