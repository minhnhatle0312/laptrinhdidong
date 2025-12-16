import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueBarChart extends StatelessWidget {
  final List<double> monthlyRevenue;
  final List<String> months;
  const RevenueBarChart({super.key, required this.monthlyRevenue, required this.months});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (monthlyRevenue.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100, double.infinity),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  return idx >= 0 && idx < months.length
                      ? Text(months[idx], style: const TextStyle(fontSize: 10))
                      : const SizedBox();
                },
                reservedSize: 28,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < monthlyRevenue.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: monthlyRevenue[i], color: Colors.indigo, width: 18),
              ])
          ],
        ),
      ),
    );
  }
}
