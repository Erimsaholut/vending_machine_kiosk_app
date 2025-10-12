import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int bigCupStock = 40;
  int smallCupStock = 60;
  int syrupLevel = 80;
  int waterLevel = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stok Durumu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressTile('Büyük İçecek', bigCupStock, Colors.orange),
            _buildProgressTile('Küçük İçecek', smallCupStock, Colors.blue),
            _buildProgressTile('Şurup Seviyesi', syrupLevel, Colors.purple),
            _buildProgressTile('Su Seviyesi', waterLevel, Colors.teal),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Firebase bağlantısı yapıldıktan sonra veriler Firestore’dan çekilecek.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veriler güncellenecek')),
                  );
                },
                child: const Text('Verileri Güncelle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTile(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / 100,
            color: color,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
          ),
          Text('%$value', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}