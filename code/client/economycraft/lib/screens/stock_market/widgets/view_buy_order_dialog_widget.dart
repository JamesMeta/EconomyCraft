import 'package:economycraft/classes/buy_order.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:flutter/material.dart';

class ViewBuyOrderDialogWidget extends StatefulWidget {
  final Map<String, CompanyInfo> companyInfoMap;
  final List<BuyOrder> userBuyOrders;

  const ViewBuyOrderDialogWidget({
    super.key,
    required this.companyInfoMap,
    required this.userBuyOrders,
  });

  @override
  State<ViewBuyOrderDialogWidget> createState() =>
      _ViewBuyOrderDialogWidgetState();
}

class _ViewBuyOrderDialogWidgetState extends State<ViewBuyOrderDialogWidget> {
  late final List<BuyOrder> _userBuyOrders;

  @override
  void initState() {
    _userBuyOrders = widget.userBuyOrders;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      content: SizedBox(
        width: screenWidth * (1 / 3),
        height: screenHeight * (3 / 4),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Currently Active Buy Orders",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _userBuyOrders.length,
                      itemBuilder: (context, index) {
                        return _buyOrderListItem(_userBuyOrders[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buyOrderListItem(BuyOrder buyOrder) {
    CompanyInfo? companyInfo;

    widget.companyInfoMap.forEach((key, value) {
      if (value.share.companyShareId == buyOrder.companyShareId) {
        companyInfo = value;
      }
    });

    if (companyInfo == null) {
      return ListTile();
    } else {
      return ListTile(
        leading: Image(
          height: 40,
          width: 40,
          image: NetworkImage(companyInfo!.company.avatarUrl),
        ),
        title: Text(companyInfo!.company.name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Target Price: \$${buyOrder.maximumSharePrice.toString()}"),
            SizedBox(width: 16),
            Text("Remaining Quantity: ${buyOrder.orderQuality.toString()}"),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            SupabaseHelper.share.deleteBuyOrder(buyOrder.id);
            setState(() {
              _userBuyOrders.remove(buyOrder);
            });
          },
          icon: Icon(Icons.delete),
        ),
      );
    }
  }
}
