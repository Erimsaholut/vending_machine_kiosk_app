import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool get _hasLowLevel {
    return bigCupStock < 20 || smallCupStock < 20 || syrupLevel < 20 || waterLevel < 20;
  }

  Future<void> _logMaintenance() async {
    await FirebaseFirestore.instance.collection('maintenance_logs').add({
      'timestamp': Timestamp.now(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bakım kaydı başarıyla eklendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasLowLevel)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠️ Düşük Seviye Tespiti: Kontrol Edin',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Text(
              'Stok Durumu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStockCard('Büyük İçecek', bigCupStock, Colors.orange),
            _buildStockCard('Küçük İçecek', smallCupStock, Colors.blue),
            _buildStockCard('Şurup Seviyesi', syrupLevel, Colors.purple),
            _buildStockCard('Su Seviyesi', waterLevel, Colors.teal),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Firebase bağlantısı yapıldıktan sonra veriler Firestore’dan çekilecek.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veriler güncellenecek')),
                      );
                    },
                    child: const Text('Verileri Güncelle'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _logMaintenance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Bakım Tamamlandı'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(String label, int value, Color color) {
    Color progressColor = value < 20 ? Colors.red : color;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: value / 100,
              color: progressColor,
              backgroundColor: Colors.grey[300],
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text('%$value', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}