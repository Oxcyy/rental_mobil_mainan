import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../models/rental.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart'; 

class RentalDetailScreen extends StatelessWidget {
  final String rentalId;
  const RentalDetailScreen({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final rental = store.getRentalById(rentalId);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    if (rental == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: const CustomAppBar(title: 'DETAIL PENYEWAAN'),
        body: Center(child: Text('Data penyewaan tidak ditemukan', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
      );
    }

    final carData = store.getCarById(rental.carId);
    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    final statusColor = rental.status == 'active'
        ? const Color(0xFFFFD180) 
        : rental.status == 'returned'
            ? const Color(0xFFB9F6CA) 
            : const Color(0xFFFF8A80); 
            
    final statusText = rental.status == 'active' ? 'AKTIF' : rental.status == 'returned' ? 'SELESAI' : 'DIBATALKAN';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'DETAIL PENYEWAAN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU INFO MOBIL
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF80DEEA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 4), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(6, 6), blurRadius: 0)]),
              child: Column(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 3)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (carData?.imageUrl != null && carData!.imageUrl!.trim().isNotEmpty)
                          ? Image.network(carData.imageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.black, size: 50))
                          : const Icon(Icons.directions_car, color: Colors.black, size: 60),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(rental.carName.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  Text('WARNA: ${carData?.color.toUpperCase() ?? '-'}', style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: statusColor, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                    child: Text(statusText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('INFORMASI PENYEWA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            // KARTU PENYEWA
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)]),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.person, label: 'NAMA', value: rental.renterName.toUpperCase(), textColor: Colors.black),
                  _InfoRow(icon: Icons.phone, label: 'TELEPON', value: rental.renterPhone.toUpperCase(), textColor: Colors.black),
                  _InfoRow(icon: Icons.child_care, label: 'ANAK', value: rental.renterAddress.toUpperCase(), textColor: Colors.black),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('INFORMASI PENYEWAAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            // KARTU PENYEWAAN
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF222222) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)]),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.calendar_today, label: 'TANGGAL', value: dateFmt.format(rental.startTime).toUpperCase(), textColor: textColor),
                  _InfoRow(icon: Icons.play_circle, label: 'MULAI', value: timeFmt.format(rental.startTime), textColor: textColor),
                  _InfoRow(icon: Icons.stop_circle, label: 'SELESAI', value: timeFmt.format(rental.endTime), textColor: textColor),
                  _InfoRow(icon: Icons.schedule, label: 'DURASI', value: '${rental.durationMinutes} MENIT', textColor: textColor),
                  Divider(color: borderColor, thickness: 2, height: 32),
                  _InfoRow(icon: Icons.attach_money, label: 'TOTAL HARGA', value: currFmt.format(rental.totalPrice), highlight: true, textColor: textColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: rental.isPaid ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black, width: 2)),
                        child: Icon(rental.isPaid ? Icons.check : Icons.close, color: Colors.black, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text('PEMBAYARAN: ', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white70 : Colors.black54)),
                      Text(rental.isPaid ? 'LUNAS' : 'BELUM BAYAR', style: TextStyle(fontWeight: FontWeight.w900, color: rental.isPaid ? (isDark ? Colors.greenAccent : Colors.green.shade700) : (isDark ? Colors.redAccent : Colors.red.shade700))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            if (rental.status == 'active') ...[
              InkWell(
                onTap: () => _confirmReturn(context, store, rental, isDark),
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFFB9F6CA), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.black), SizedBox(width: 8), Text('TANDAI SELESAI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0))]),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _confirmDelete(context, store, rental, isDark),
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFFFF8A80), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cancel, color: Colors.black), SizedBox(width: 8), Text('BATALKAN PENYEWAAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0))]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmReturn(BuildContext context, AppStore store, Rental rental, bool isDark) {
    final borderColor = isDark ? Colors.white : Colors.black;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF222222) : Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 3)),
        title: Text('KONFIRMASI SELESAI', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tandai "${rental.carName.toUpperCase()}" sebagai sudah selesai disewa?', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
            if (!rental.isPaid) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFF8A80), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.black), SizedBox(width: 8),
                    Expanded(child: Text('BELUM BAYAR!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
                  ],
                ),
              ),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('BATAL', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900))),
          
          if (!rental.isPaid)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await store.returnCar(rental.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
              child: const Text('TETAP NGUTANG', style: TextStyle(fontWeight: FontWeight.w900)),
            ),

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (!rental.isPaid) await store.updatePaymentStatus(rental.id, true); 
              await store.returnCar(rental.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB9F6CA), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: Text(!rental.isPaid ? 'LUNAS & SELESAI' : 'YA, SELESAI', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppStore store, Rental rental, bool isDark) {
    final borderColor = isDark ? Colors.white : Colors.black;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF222222) : Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 3)),
        title: Text('HAPUS PENYEWAAN?', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
        content: Text('Data penyewaan ini akan dihapus permanen.', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('BATAL', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await store.deleteRental(rental.id);
              showSnackBarWithOK('Penyewaan berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A80), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: const Text('HAPUS', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon; 
  final String label; 
  final String value; 
  final bool highlight;
  final Color textColor;
  
  const _InfoRow({required this.icon, required this.label, required this.value, this.highlight = false, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final isDarkText = textColor == Colors.white;
    final iconBg = highlight ? const Color(0xFFEA80FC) : (isDarkText ? const Color(0xFF333333) : Colors.white);
    final iconBorder = isDarkText && !highlight ? Colors.white : Colors.black;
    final iconColor = isDarkText && !highlight ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: iconBorder, width: 2)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w900, color: isDarkText ? Colors.white70 : Colors.black54)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: highlight ? 20 : 14, color: textColor))),
        ],
      ),
    );
  }
}