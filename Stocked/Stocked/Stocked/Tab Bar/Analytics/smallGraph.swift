//
//  smallChart.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-16.
//

import SwiftUI
import SwiftUICharts

struct smallGraph: View {
    var body: some View {
        
        VStack{
            LineChartView(data:[2,3,4,5,10,20,42,100], title: " Total Position Value", style: Styles.barChartStyleNeonBlueDark, form: ChartForm.large)
            
        }
    }
}

struct smallGraph_Previews: PreviewProvider {
    static var previews: some View {
        smallGraph()
    }
}

