import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../widgets/custom_app_bar.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final todayRevenue = store.todayRevenue;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: const CustomAppBar(title: 'Dasboard Rental', showLogout: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RINGKASAN HARI INI',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.0,
              )
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _NeoStatCard(icon: Icons.directions_car, label: 'TOTAL MOBIL', value: store.cars.length.toString(), color: const Color(0xFF80DEEA), isDark: isDark)),
                const SizedBox(width: 16),
                Expanded(child: _NeoStatCard(icon: Icons.check_circle, label: 'TERSEDIA', value: store.availableCars.length.toString(), color: const Color(0xFFB9F6CA), isDark: isDark)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _NeoStatCard(icon: Icons.receipt_long, label: 'AKTIF DISEWA', value: store.activeRentals.length.toString(), color: const Color(0xFFFFD180), isDark: isDark)),
                const SizedBox(width: 16),
                Expanded(child: _NeoStatCard(icon: Icons.account_balance_wallet, label: 'PENDAPATAN', value: currFmt.format(todayRevenue), color: const Color(0xFFEA80FC), isDark: isDark)), 
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'PENYEWAAN TERBARU',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.0,
              )
            ),
            const SizedBox(height: 16),
            if (store.rentals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                ),
                child: Center(
                  child: Text('BELUM ADA PENYEWAAN', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            else
              ...store.rentals.reversed.take(5).map((r) => _NeoRecentRentalCard(rental: r, isDark: isDark)),
          ],
        ),
      ),
    );
  }
}

class _NeoStatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color; final bool isDark;
  const _NeoStatCard({required this.icon, required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: borderColor, width: 3), 
        boxShadow: [BoxShadow(color: borderColor, offset: const Offset(5, 5), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 2))), 
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 12),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black))),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _NeoRecentRentalCard extends StatelessWidget {
  final dynamic rental;
  final bool isDark;
  const _NeoRecentRentalCard({required this.rental, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final carData = store.getCarById(rental.carId);
    final imageUrl = carData?.imageUrl;

    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final dateFmt = DateFormat('dd MMM', 'id_ID');
    final cfmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    Color statusBgColor = rental.status == 'active' ? Colors.yellowAccent : rental.status == 'returned' ? Colors.greenAccent : Colors.redAccent;
    String statusText = rental.status == 'active' ? 'AKTIF' : rental.status == 'returned' ? 'SELESAI' : 'BATAL';
    
    final borderColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: borderColor, width: 3), 
        boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 60,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: (imageUrl != null && imageUrl.trim().isNotEmpty)
                  ? Image.network(imageUrl, fit: BoxFit.cover, width: 80, height: 60, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.black)))
                  : const Center(child: Icon(Icons.directions_car, color: Colors.black, size: 36)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rental.carName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${rental.renterName}\n${dateFmt.format(rental.startTime)} • ${timeFmt.format(rental.startTime)}–${timeFmt.format(rental.endTime)}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cfmt.format(rental.totalPrice), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(6)),
                child: Text(statusText, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}