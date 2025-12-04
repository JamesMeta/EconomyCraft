import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/screens/stock_market/widgets/sell_order_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class OwnedSharesWidget extends StatelessWidget {
  final CompanyInfo selectedCompanyInfo;

  const OwnedSharesWidget({super.key, required this.selectedCompanyInfo});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.23,
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
              "Owned Shares",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          Divider(height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  selectedCompanyInfo.usersShares.isNotEmpty
                      ? Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Shares Owned: ${selectedCompanyInfo.usersShares.length}",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Shares not on Market: ${selectedCompanyInfo.usersShares.where((share) => share.purchasable == false).length}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    selectedCompanyInfo.usersShares.length,
                                itemBuilder: (context, index) {
                                  return _buildUserShares(
                                    selectedCompanyInfo.usersShares[index],
                                    context,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      : Expanded(
                        child: Text(
                          "No Shares Owned for ${selectedCompanyInfo.company.name}",
                        ),
                      ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SellOrderDialogWidget(
                              companyInfo: selectedCompanyInfo,
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        fixedSize: Size(double.infinity, screenHeight * 0.05),
                        backgroundColor: Color.fromARGB(255, 23, 221, 97),
                      ),
                      child: Text("Create Sell Order"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserShares(Share share, BuildContext context) {
    double percentChange =
        (((share.value - share.purchasePrice) / share.purchasePrice)) * 100;

    final isPositive = percentChange >= 0 ? true : false;
    final changeText =
        '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            context.go('/home/stock_market/sell_share', extra: share);
          },
          hoverColor: Color.fromARGB(255, 201, 249, 255),
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              ListTile(
                leading: ClipRRect(
                  child: Image.network(
                    share.company!.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        share.company?.name ?? 'Unknown Company',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (share.purchasable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 224, 255, 252),
                          border: Border.all(width: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "On Market",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                  ],
                ),

                subtitle: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: changeColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      changeText,
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currencyFormat.format(share.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "${(share.stake * 100).toStringAsFixed(3)}%",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
