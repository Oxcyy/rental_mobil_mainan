import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import 'car_form_screen.dart';
import 'rental_form_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final car = store.getCarById(carId);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final appBarBg = isDark ? Colors.black : const Color(0xFFFFEB3B);

    if (car == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('DETAIL MOBIL', style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
          backgroundColor: appBarBg,
          iconTheme: IconThemeData(color: textColor),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(4.0), child: Container(color: borderColor, height: 4.0)),
        ),
        body: Center(child: Text('Mobil tidak ditemukan', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
      );
    }
    
    final cfmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final carRentals = store.rentals.where((r) => r.carId == carId).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(car.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: textColor, letterSpacing: 1.0)),
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(4.0), child: Container(color: borderColor, height: 4.0)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarFormScreen(car: car))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 4),
                  boxShadow: [BoxShadow(color: borderColor, offset: const Offset(6, 6), blurRadius: 0)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (car.imageUrl != null && car.imageUrl!.trim().isNotEmpty)
                      ? Image.network(
                          car.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.black, size: 60),
                        )
                      : const Icon(Icons.directions_car, color: Colors.black, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: car.isAvailable ? const Color(0xFFB9F6CA) : const Color(0xFFFFD180),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                ),
                child: Text(
                  car.isAvailable ? 'TERSEDIA UNTUK DISEWA' : 'SEDANG DISEWA',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF59D), 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [BoxShadow(color: borderColor, offset: const Offset(6, 6), blurRadius: 0)],
              ),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.label, label: 'NAMA', value: car.name.toUpperCase()),
                  _InfoRow(icon: Icons.palette, label: 'WARNA', value: car.color.toUpperCase()),
                  _InfoRow(icon: Icons.attach_money, label: 'HARGA', value: '${cfmt.format(20000)} / 15 MNT'),
                  if (car.note.isNotEmpty) _InfoRow(icon: Icons.notes, label: 'INFO', value: car.note.toUpperCase()),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('RIWAYAT PENYEWAAN (${carRentals.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 16),
            if (carRentals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                ),
                child: Center(child: Text('BELUM PERNAH DISEWA', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
              )
            else
              ...carRentals.reversed.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222222) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFFEA80FC), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                        child: const Icon(Icons.person, color: Colors.black, size: 20),
                      ),
                      title: Text(r.renterName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
                      subtitle: Text('${r.durationMinutes} MNT • ${timeFmt.format(r.startTime)}–${timeFmt.format(r.endTime)}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                      trailing: Text(cfmt.format(r.totalPrice), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)),
                    ),
                  )),
          ],
        ),
      ),
      bottomNavigationBar: car.isAvailable
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentalFormScreen(carId: carId))),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9F6CA), 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, color: Colors.black),
                      SizedBox(width: 8),
                      Text('SEWAKAN MOBIL INI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black, width: 2)),
            child: Icon(icon, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black))),
        ],
      ),
    );
  }
}