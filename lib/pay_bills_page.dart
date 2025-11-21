import 'package:flutter/material.dart';
import 'electricity_page.dart';
import 'water_page.dart';
import 'tv_bills_page.dart';
import 'internet_page.dart';

class PayBillsPage extends StatelessWidget {
  final String language;
  const PayBillsPage({super.key, this.language = 'en'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;

    String t(String en, String fr) => language == 'en' ? en : fr;

    final List<Map<String, dynamic>> bills = [
      {
        "name": t("Electricity (ENEO)", "Électricité (ENEO)"),
        "icon": Icons.lightbulb,
        "page": ElectricityPage(language: language),
        "gradient": [Colors.green.shade400, Colors.green.shade700],
        "description": t("Pay your electricity bill instantly", "Payez votre facture d'électricité immédiatement")
      },
      {
        "name": t("Water (CAMWATER)", "Eau (CAMWATER)"),
        "icon": Icons.water_drop,
        "page": WaterPage(language: language),
        "gradient": [Colors.blue.shade300, Colors.blue.shade700],
        "description": t("Never run out of water service", "Ne manquez jamais d'eau")
      },
      {
        "name": t("TV Bills (DStv / GOtv / Canal+)", "Factures TV (DStv / GOtv / Canal+)"),
        "icon": Icons.tv,
        "page": TvBillsPage(language: language),
        "gradient": [Colors.purple.shade300, Colors.purple.shade700],
        "description": t("Pay for your TV subscriptions easily", "Payez facilement vos abonnements TV")
      },
      {
        "name": t("Internet", "Internet"),
        "icon": Icons.wifi,
        "page": InternetPage(language: language),
        "gradient": [Colors.orange.shade300, Colors.orange.shade700],
        "description": t("Stay connected online", "Restez connecté en ligne")
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(t("Pay Bills", "Payer les factures")),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: bills
              .map((bill) => _buildPremiumBillCard(context, bill, isDarkMode))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPremiumBillCard(
      BuildContext context, Map<String, dynamic> bill, bool isDarkMode) {
    final List<Color> gradient = bill["gradient"];
    final shadowColor =
    isDarkMode ? Colors.black45 : gradient.last.withOpacity(0.4);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => bill["page"]),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                bill["icon"],
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill["name"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bill["description"],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 20),
            )
          ],
        ),
      ),
    );
  }
}
