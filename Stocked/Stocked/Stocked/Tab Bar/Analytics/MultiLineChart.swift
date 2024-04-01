//
//  smallChart.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-16.
//

import SwiftUI
import SwiftUICharts

struct MultiLineChart: View {
    var body: some View {
        
        VStack{
            MultiLineChartView(data: [([8,32,11,23,40,28], GradientColors.green), ([90,99,78,111,70,60,77], GradientColors.purple), ([34,56,72,38,43,100,50], GradientColors.orngPink)], title: "Financial Assets", style: Styles.custom_style, form: ChartForm.extraLarge)
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
            
        }
    }
}

struct smallGraph_Previews: PreviewProvider {
    static var previews: some View {
        MultiLineChart()
    }
}

