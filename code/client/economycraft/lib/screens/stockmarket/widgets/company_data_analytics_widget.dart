import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_2_widget.dart';
import 'package:flutter/material.dart';

class CompanyDataAnalyticsWidget extends StatefulWidget {
  final List<List<PriceVsTime>> data;
  final DateTime? lastDataRefreshed;

  const CompanyDataAnalyticsWidget({
    super.key,
    required this.data,
    required this.lastDataRefreshed,
  });

  @override
  State<CompanyDataAnalyticsWidget> createState() =>
      _CompanyDataAnalyticsWidgetState();
}

class _CompanyDataAnalyticsWidgetState
    extends State<CompanyDataAnalyticsWidget> {
  int _buttonState = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<String> labels = [
      "Stock Price",
      "Evaluation",
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
                      Expanded(child: _sectionButton(setState, labels[1], 1)),
                      Expanded(child: _sectionButton(setState, labels[0], 0)),

                      Expanded(child: _sectionButton(setState, labels[2], 2)),
                      Expanded(child: _sectionButton(setState, labels[3], 3)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Linegraph2Widget(
                        title: "",
                        data: widget.data[_buttonState],
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
}
