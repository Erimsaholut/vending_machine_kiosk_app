import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicePanelPage extends StatefulWidget {
  const ServicePanelPage({super.key});

  @override
  State<ServicePanelPage> createState() => _ServicePanelPageState();
}

class _ServicePanelPageState extends State<ServicePanelPage> {
  final machineRef =
  FirebaseFirestore.instance.collection('machines').doc('M-0001');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Paneli'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: machineRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Makine verisi bulunamadı.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final inventory = data['inventory'] ?? {};
          final levels = data['levels'] ?? {};
          final status = data['status'] ?? {};

          final largeCups = inventory['largeCups'] ?? 0;
          final smallCups = inventory['smallCups'] ?? 0;
          final liquid = levels['liquid'] ?? 0;
          final isActive = status['isActive'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cihaz Durumu',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildStockControl('Büyük Bardak Sayısı', largeCups, 'largeCups', 120),
                _buildStockControl('Küçük Bardak Sayısı', smallCups, 'smallCups', 150),
                _buildLiquidControl('İçecek Seviyesi (ml)', liquid, 20000),

                const SizedBox(height: 24),

                Center(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _toggleMachineStatus(!isActive),
                        icon: Icon(isActive ? Icons.pause_circle : Icons.play_circle),
                        label: Text(isActive ? 'Satışı Kapat' : 'Satışı Aç'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bakım bilgileri gönderilecek')),
                          );
                        },
                        icon: const Icon(Icons.build_circle_outlined),
                        label: const Text('Bakım Tamamlandı'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStockControl(String label, int value, String field, int maxVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / maxVal,
            color: Colors.orange,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text('$value adet', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _updateStock(field, -5, maxVal),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _updateStock(field, 5, maxVal),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _setStockFull(field, maxVal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: field == 'largeCups' ? const Text('Tam (120)') : field == 'smallCups' ? const Text('Tam (150)') : const Text('Tam (80)'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _enterManualValue(field, maxVal, false),
                child: const Text('Değer Gir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidControl(String label, int value, int maxVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / maxVal,
            color: Colors.teal,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text('$value ml', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _updateLiquid(-250, maxVal),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _updateLiquid(250, maxVal),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _setLiquidFull(maxVal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tam (20000)'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _enterManualValue('liquid', maxVal, true),
                child: const Text('Değer Gir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStock(String field, int delta, int maxVal) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(machineRef);
      final data = snap.data() as Map<String, dynamic>;
      final inv = Map<String, dynamic>.from(data['inventory'] ?? {});
      final current = inv[field] ?? 0;
      final updated = (current + delta).clamp(0, maxVal);
      inv[field] = updated;
      tx.update(machineRef, {'inventory': inv});
    });
  }

  Future<void> _setStockFull(String field, int maxVal) async {
    await machineRef.update({'inventory.$field': maxVal});
  }

  Future<void> _updateLiquid(int delta, int maxVal) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(machineRef);
      final data = snap.data() as Map<String, dynamic>;
      final levels = Map<String, dynamic>.from(data['levels'] ?? {});
      final current = levels['liquid'] ?? 0;
      final updated = (current + delta).clamp(0, maxVal);
      levels['liquid'] = updated;
      tx.update(machineRef, {'levels': levels});
    });
  }

  Future<void> _setLiquidFull(int maxVal) async {
    await machineRef.update({'levels.liquid': maxVal});
  }

  Future<void> _toggleMachineStatus(bool newStatus) async {
    await machineRef.update({'status.isActive': newStatus});
  }

  Future<void> _enterManualValue(String field, int maxVal, bool isLiquid) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Değer Gir'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Yeni değer girin'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 0 || value > maxVal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Değer 0 ile $maxVal arasında olmalı.')),
                );
                return;
              }
              if (isLiquid) {
                await machineRef.update({'levels.liquid': value});
              } else {
                await machineRef.update({'inventory.$field': value});
              }
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}