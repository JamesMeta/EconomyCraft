import 'package:economycraft/classes/company.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyTileWidget extends StatelessWidget {
  final Company company;
  final Function()? onTap;

  const CompanyTileWidget({super.key, required this.company, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final reputationScore = company.reputation ~/ 100;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(255, 201, 201, 201),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 244, 244, 244),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Company Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(255, 201, 201, 201),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 220, 220, 220),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    company.avatarUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.business,
                          color: Colors.grey,
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Company Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          company.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                company.isPublic
                                    ? const Color.fromARGB(255, 229, 255, 238)
                                    : const Color.fromARGB(255, 255, 235, 235),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  company.isPublic
                                      ? const Color.fromARGB(255, 23, 221, 97)
                                      : Colors.red[300]!,
                            ),
                          ),
                          child: Text(
                            company.isPublic ? 'PUBLIC' : 'PRIVATE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  company.isPublic
                                      ? const Color.fromARGB(255, 23, 221, 97)
                                      : Colors.red[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.slogan,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        Text(
                          currencyFormat.format(company.evaluation),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Founded ${DateFormat('MMM yyyy').format(company.createdAt ?? DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Reputation Score
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getReputationColor(
                        reputationScore,
                      ).withOpacity(0.2),
                      border: Border.all(
                        color: _getReputationColor(reputationScore),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "$reputationScore",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getReputationColor(reputationScore),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "REPUTATION",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color.fromARGB(255, 74, 237, 217),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getReputationColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.amber;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }
}
