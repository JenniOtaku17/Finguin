import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'dart:developer' as developer;

class MyChart extends StatefulWidget {
  final List<Transaction>? transactions;
  final List<Category>? categories;

  const MyChart({Key? key, this.transactions, this.categories}) : super(key: key);

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  double maxCategoryAmount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      maxCategoryAmount = getMaxCategoryAmount();
    }
  }

  double getMaxCategoryAmount() {
    double maxAmount = 0;
    for (var category in widget.categories!) {
      
      double total = 0;
      for (var transaction in widget.transactions!) {
        if (transaction.category == category.categoryId) {
          if (transaction.amount.isNaN || transaction.amount.isInfinite) {
            developer.log('Invalid transaction amount: ${transaction.amount}');
          } else {
            total += transaction.amount;
          }
        }
      }

      if (category.maxAmount.isNaN || category.maxAmount.isInfinite) {
        developer.log('Invalid category max amount: ${category.maxAmount}');
      } else if (category.maxAmount > maxAmount && total > 0) {
        maxAmount = category.maxAmount;
      }
    }
    return maxAmount;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions == null || widget.categories == null) {
      return  Center(
        child: Image.asset(
          'assets/loading.gif',
            width: 300,
        ),
      );
    }

    if (widget.transactions!.isEmpty || widget.categories!.isEmpty) {
      return  Center(
        child: Image.asset(
          'assets/no-data.png',
          width: 500,
        )
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 16.0, 2.0, 8.0),
      child: SizedBox(
        height: 400, // Ensure the chart has a finite height
        child: BarChart(
          mainBarData(),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, double yTotal) {
    if (y.isNaN || y.isInfinite) {
      developer.log('Invalid y value for group $x: $y');
      y = 0;
    }
    if (yTotal.isNaN || yTotal.isInfinite) {
      developer.log('Invalid yTotal value for group $x: $yTotal');
      yTotal = 0;
    }
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Theme.of(context).colorScheme.outline,
          width: 7,
        ),
        BarChartRodData(
          toY: yTotal,
          color: Theme.of(context).colorScheme.primary,
          width: 7,
        ),
      ],
    );
  }

  List<BarChartGroupData> showingGroups() {
    List<BarChartGroupData> groups = [];
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      for (var i = 0; i < widget.categories!.length; i++) {
        double total = 0;
        for (var transaction in widget.transactions!) {
          if (transaction.category == widget.categories![i].categoryId) {
            if (transaction.amount.isNaN || transaction.amount.isInfinite) {
              developer.log('Invalid transaction amount: ${transaction.amount}');
            } else {
              total += transaction.amount;
            }
          }
        }

        if(total > 0){
          groups.add(makeGroupData(i, widget.categories![i].maxAmount, total));
        }
      }
    }
    return groups;
  }

  BarChartData mainBarData() {
    return BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: leftTitles,
            interval: 10000,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= widget.categories!.length) {
      return Container();
    }

    double total = 0;
    for (var transaction in widget.transactions!) {
      if (transaction.category == widget.categories![index].categoryId) {
        if (transaction.amount.isNaN || transaction.amount.isInfinite) {
          developer.log('Invalid transaction amount: ${transaction.amount}');
        } else {
          total += transaction.amount;
        }
      }
    }

    if(total > 0){
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Image.asset(
          'assets/${widget.categories![index].icon}.png',
          scale: 1,
          color: Color(widget.categories![index].color),
        ),
      );
    }else{
      return Container();
    }
  }


  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.w400,
      fontSize: 10,
    );

    // Define el intervalo deseado
    const double interval = 10000;
    String text;

    if (value.isNaN || value.isInfinite) {
      developer.log('Invalid value for left title: $value');
      return Container();
    }

    // Redondear el valor al intervalo más cercano
    if (value % interval == 0) {
      text = '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }
}