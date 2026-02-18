import 'package:economycraft/classes/company.dart';
import 'package:flutter/material.dart';

class CompanyDropdownWidget extends StatelessWidget {
  final Company selectedCompany;
  final List<Company> userCompanies;
  final void Function(Company? newCompany) modifySelectedCompany;

  const CompanyDropdownWidget({
    super.key,
    required this.selectedCompany,
    required this.userCompanies,
    required this.modifySelectedCompany,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 229, 255, 252),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Company>(
          isExpanded: true,
          value: selectedCompany,
          icon: const Icon(Icons.arrow_drop_down),
          items:
              userCompanies.map((Company company) {
                return DropdownMenuItem<Company>(
                  value: company,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(company.avatarUrl),
                            fit: BoxFit.cover,
                            onError:
                                (obj, stack) => const AssetImage(
                                  'assets/images/background_images/quartz_background.png',
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          company.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (Company? newValue) {
            modifySelectedCompany(newValue);
          },
        ),
      ),
    );
  }
}
