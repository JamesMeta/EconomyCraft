import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_2_widget.dart';
import 'package:economycraft/screens/stock_market/classes/time_button_state.dart';
import 'package:flutter/material.dart';

class CompanyDataAnalyticsWidget extends StatefulWidget {
  final List<List<PriceVsTime>> data;
  final DateTime? lastDataRefreshed;
  final Company? selectedCompany;

  const CompanyDataAnalyticsWidget({
    super.key,
    required this.data,
    required this.lastDataRefreshed,
    required this.selectedCompany,
  });

  @override
  State<CompanyDataAnalyticsWidget> createState() =>
      _CompanyDataAnalyticsWidgetState();
}

class _CompanyDataAnalyticsWidgetState
    extends State<CompanyDataAnalyticsWidget> {
  // Starts at Stock Price Screen
  int _buttonState = 1;
  int _timeButtonState = 2;

  // Starts at 1 Month Button

  final _timeButtonStates = [
    TimeButtonState(daysAgoRange: 1, dataPointsPerDay: 24),
    TimeButtonState(daysAgoRange: 7, dataPointsPerDay: 12),
    TimeButtonState(daysAgoRange: 30, dataPointsPerDay: 3),
    TimeButtonState(daysAgoRange: 90, dataPointsPerDay: 2),
    TimeButtonState(daysAgoRange: 180, dataPointsPerDay: 1),
    TimeButtonState(daysAgoRange: 365, dataPointsPerDay: 1),
    TimeButtonState(daysAgoRange: 1825, dataPointsPerDay: 1),
  ];

  late List<List<PriceVsTime>> filteredData;

  @override
  void initState() {
    _setDataSelection(days: 28, dataPointsPerDay: 3);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CompanyDataAnalyticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedCompany?.id != oldWidget.selectedCompany?.id) {
      setState(() {
        _setDataSelection(
          days: _timeButtonStates[_timeButtonState].daysAgoRange,
          dataPointsPerDay:
              _timeButtonStates[_timeButtonState].dataPointsPerDay,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<String> labels = [
      "Evaluation",
      "Stock Price",
      "Sales",
      "Reputation",
    ];

    return Container(
      width: screenWidth * 0.485,
      height: screenHeight * 0.80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: screenHeight * 0.08,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 229, 255, 252),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "Company Data Analytics",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _sectionButton(setState, labels[0], 0)),
                      Expanded(child: _sectionButton(setState, labels[1], 1)),

                      Expanded(child: _sectionButton(setState, labels[2], 2)),
                      Expanded(child: _sectionButton(setState, labels[3], 3)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 4, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _timeframeButton(
                                  "1D",
                                  0,

                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                _timeframeButton("7D", 1),
                                _timeframeButton("1M", 2),
                                _timeframeButton("3M", 3),
                                _timeframeButton("6M", 4),
                                _timeframeButton("1Y", 5),
                                _timeframeButton(
                                  "All",
                                  6,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Linegraph2Widget(
                              title: "",
                              data: filteredData[_buttonState],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Data Last Updated:"),
                      Text(widget.lastDataRefreshed!.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionButton(
    void Function(void Function()) localSetState,
    label,
    buttonStateIndex,
  ) {
    return TextButton(
      onPressed: () {
        if (_buttonState != buttonStateIndex) {
          localSetState(() {
            _buttonState = buttonStateIndex;
          });
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor:
            _buttonState == buttonStateIndex
                ? Colors.black
                : Colors.grey[600], // text color
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  _buttonState == buttonStateIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          // underline effect
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: _buttonState == buttonStateIndex ? 120 : 60,
            color:
                _buttonState == buttonStateIndex
                    ? const Color(0xFF00BCD4)
                    : const Color.fromARGB(255, 196, 196, 196),
          ),
        ],
      ),
    );
  }

  Widget _timeframeButton(
    String label,
    int buttonStateIndex, {
    BorderRadius? borderRadius,
  }) {
    return ElevatedButton(
      onPressed: () => _updateTimeButtonStates(buttonStateIndex),
      style: ButtonStyle(
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStatePropertyAll(
          buttonStateIndex == _timeButtonState
              ? Colors.grey[400]
              : Colors.transparent,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: Colors.grey[400]!)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.zero,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  void _updateTimeButtonStates(int buttonIndex) {
    setState(() {
      for (int i = 0; i < _timeButtonStates.length; i++) {
        _timeButtonState = buttonIndex;
      }

      _setDataSelection(
        days: _timeButtonStates[buttonIndex].daysAgoRange,
        dataPointsPerDay: _timeButtonStates[buttonIndex].dataPointsPerDay,
      );
    });
  }

  void _setDataSelection({required int days, int dataPointsPerDay = 1}) {
    final now = DateTime.now();
    final DateTime xDaysAgo = now.subtract(Duration(days: days));
    final int dataPointEveryXHours = (24 / dataPointsPerDay).round();

    filteredData =
        widget.data.map<List<PriceVsTime>>((dataList) {
          final filteredDataList =
              dataList
                  .where((dataPoint) => dataPoint.time.isAfter(xDaysAgo))
                  .toList();

          final daySum = <Record, List<PriceVsTime>>{};
          for (final dataPoint in filteredDataList) {
            final dataPointRecord = (
              dataPoint.time.year,
              dataPoint.time.month,
              dataPoint.time.day,
            );

            final nowRecord = (now.year, now.month, now.day);

            const oneHour = 1;

            final containsKey = daySum.containsKey(dataPointRecord);
            final dataPointExistsOnInterval =
                dataPoint.time.hour % dataPointEveryXHours == 0;
            final dataPointIsToday = dataPointRecord == nowRecord;
            final dataPointIsThisOrPreviousHour =
                dataPoint.time.hour >= now.hour - oneHour;

            if (!containsKey) {
              daySum[dataPointRecord] = [dataPoint];
            } else if ((containsKey && dataPointExistsOnInterval) ||
                (dataPointIsToday && dataPointIsThisOrPreviousHour)) {
              daySum[dataPointRecord]!.add(dataPoint);
            }
          }

          return daySum.values.expand((element) => element).toList();
        }).toList();
  }
}
