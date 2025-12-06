import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tìm kiếm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Nghệ sĩ, bài hát, hoặc podcast',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Browse Categories
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 16 / 9,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 8, // Số lượng thể loại
                itemBuilder: (context, index) {
                  return _buildCategoryCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(int index) {
    final categories = [
      {'name': 'Pop', 'color': Colors.redAccent},
      {'name': 'Rock', 'color': Colors.blueAccent},
      {'name': 'Hip-Hop', 'color': Colors.orangeAccent},
      {'name': 'EDM', 'color': Colors.greenAccent},
      {'name': 'Acoustic', 'color': Colors.brown},
      {'name': 'Indie', 'color': Colors.teal},
      {'name': 'Cổ điển', 'color': Colors.indigo},
      {'name': 'R&B', 'color': Colors.pinkAccent},
    ];

    final category = categories[index];

    return Container(
      decoration: BoxDecoration(
        color: (category['color'] as Color).withAlpha(204),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          category['name'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
