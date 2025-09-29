import 'package:flutter/material.dart';
import '../core/sales_data.dart';

class AdminKeypadDialog extends StatefulWidget {
  final int length;
  const AdminKeypadDialog({super.key, this.length = 8});

  @override
  State<AdminKeypadDialog> createState() => _AdminKeypadDialogState();
}

class _AdminKeypadDialogState extends State<AdminKeypadDialog> {
  String _input = '';

  void _addDigit(String d) {
    if (_input.length >= widget.length) return;
    setState(() => _input += d);
  }

  void _clear() => setState(() => _input = '');

  void _submit() {
    if (_input.length == widget.length) {
      if (_input == '11111111') {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminPanelPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parola yanlış')),
        );
        _clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 250,
          height: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PIN girin', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final d in ['1','2','3','4','5','6','7','8','9'])
                      ElevatedButton(
                        onPressed: () => _addDigit(d),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(d, style: const TextStyle(fontSize: 18)),
                      ),
                    ElevatedButton(
                      onPressed: _clear,
                      child: const Text('C', style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () => _addDigit('0'),
                      child: const Text('0', style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('OK', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: SalesData.instance,
          builder: (context, _) {
            final data = SalesData.instance;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Küçük içecek satıldı: ${data.smallSold}'),
                Text('Büyük içecek satıldı: ${data.largeSold}'),
                Text('Kalan stok: ${data.totalStockMl} ml'),
                if (data.totalStockMl < 1000)
                  const Text(
                    'UYARI: Stok 1 litreden az!',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                Text('Toplam hasılat: ${data.revenue} ₺'),
                Text('300ml bardak stoğu: ${data.smallCups}'),
                Text('400ml bardak stoğu: ${data.largeCups}'),
                if (data.smallCups <= 0)
                  const Text(
                    'UYARI: 300ml bardak stoğu tükenmiştir!',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                if (data.largeCups <= 0)
                  const Text(
                    'UYARI: 400ml bardak stoğu tükenmiştir!',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => SalesData.instance.addStock(),
                      child: const Text('Stok Yenilendi (+5L)'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => SalesData.instance.reset(),
                      child: const Text('Sıfırla'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => SalesData.instance.resetCups(),
                      child: const Text('Bardak Stok Yenile'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'İade Bilgileri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Toplam iade edilen ücret: ${data.totalRefundAmount} ₺'),
                Text('Toplam iade sayısı: ${data.totalRefunds}'),
                Text('300ml ürün iadeleri: ${data.smallRefunds}'),
                Text('400ml ürün iadeleri: ${data.largeRefunds}'),
                const Text('İade nedenleri:'),
                Text(' - Overfreeze: ${data.overfreezeRefunds}'),
                Text(' - Bardak düşme sorunu: ${data.cupDropRefunds}'),
                Text(' - Diğer: ${data.otherRefunds}'),
              ],
            );
          },
        ),
      ),
    );
  }
}