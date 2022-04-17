import SwiftUI
import Charts

struct WeightChartView: UIViewRepresentable {
    @EnvironmentObject var app: HomeViewModel
    @Binding var entries: [ChartDataEntry]
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()}
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        
        let set = LineChartDataSet(entries: entries)
        let data = LineChartData(dataSet: set)
        formatXaxis(xAxis: uiView.xAxis)
        uiView.data = data
        uiView.setScaleEnabled(true)
        LineChartView().data = data

    }
    
    func formatXaxis(xAxis: XAxis) {
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: app.sortedDateArray )
        xAxis.labelPosition = .bottom
        xAxis.granularityEnabled = true
        xAxis.granularity = 1.0
        xAxis.spaceMin = 1

    }
    
}


