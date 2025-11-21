import 'package:flutter/material.dart';

class PaySchoolFeesPage extends StatefulWidget {
  const PaySchoolFeesPage({super.key});

  @override
  State<PaySchoolFeesPage> createState() => _PaySchoolFeesPageState();
}

class _PaySchoolFeesPageState extends State<PaySchoolFeesPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allSchools = [
    {"name": "Catholic University Institute Buea", "logo": "assets/images/OnwaPay_logo.jpg"},
    {"name": "University of Buea", "logo": "assets/images/MTN_logo.jpg"},
    {"name": "National Polytechnic Bambui", "logo": "assets/images/Orange_logo.jpg"},
    {"name": "EcoBank Partner Schools", "logo": "assets/images/EcoBank.jpg"},
  ];

  String query = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final filteredSchools = allSchools
        .where((school) => school["name"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.textTheme.bodyLarge!.color;
    final iconColor = const Color(0xFF42A5F5); // bluish-golden accent
    final appBarColor = LinearGradient(
      colors: [Colors.blue.shade400, Colors.amber.shade200],
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Pay School Fees", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.amber.shade200]),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => query = value),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search your school...",
                hintStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: iconColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of schools
            Expanded(
              child: filteredSchools.isEmpty
                  ? Center(
                child: Text(
                  "No school found",
                  style: TextStyle(fontSize: 16, color: textColor?.withOpacity(0.6)),
                ),
              )
                  : ListView.separated(
                itemCount: filteredSchools.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final school = filteredSchools[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchStudentPage(
                            schoolName: school["name"]!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.amber.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              school["logo"]!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              school["name"]!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 18, color: iconColor),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchStudentPage extends StatelessWidget {
  final String schoolName;

  const SearchStudentPage({super.key, required this.schoolName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final TextEditingController matriculeController = TextEditingController();
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.textTheme.bodyLarge!.color;
    final buttonColor = LinearGradient(colors: [Colors.blue.shade400, Colors.amber.shade200]);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Search Student - $schoolName"),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.amber.shade200]),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Enter student matricule or full name:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: matriculeController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "e.g. CUIB2025/001",
                hintStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.school, color: Colors.blue),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Searching for ${matriculeController.text} in $schoolName...",
                        style: TextStyle(color: textColor),
                      ),
                      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.green[100],
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text("Search"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: Colors.amber.shade200.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
