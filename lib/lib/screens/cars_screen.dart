import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../widgets/custom_app_bar.dart';
import 'car_form_screen.dart';
import 'car_detail_screen.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool _fabVisible = true;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    final sortedCars = store.cars.toList();
    sortedCars.sort((a, b) {
      final isRentedA = store.activeRentals.any((r) => r.carId == a.id);
      final isRentedB = store.activeRentals.any((r) => r.carId == b.id);
      
      int getPriority(Car car, bool isRented) {
        if (car.isAvailable && !isRented) return 1; 
        if (isRented) return 2; 
        return 3; 
      }

      int priorityA = getPriority(a, isRentedA);
      int priorityB = getPriority(b, isRentedB);
      
      if (priorityA == priorityB) {
        return a.name.compareTo(b.name);
      }
      return priorityA.compareTo(priorityB);
    });

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'DAFTAR MOBIL'),
      body: store.isLoading
          ? Center(child: CircularProgressIndicator(color: textColor))
          : store.cars.isEmpty
              ? _buildEmptyState(isDark)
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification && notification.scrollDelta != null) {
                      if (notification.scrollDelta! > 0 && _fabVisible) {
                        setState(() => _fabVisible = false);
                      } else if (notification.scrollDelta! < 0 && !_fabVisible) {
                        setState(() => _fabVisible = true);
                      }
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    color: Colors.black,
                    onRefresh: () => store.loadCars(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: sortedCars.length,
                      itemBuilder: (ctx, i) {
                        final car = sortedCars[i];
                        final isRented = store.activeRentals.any((r) => r.carId == car.id);
                        
                        final cardColor = isRented 
                            ? const Color(0xFFFFD180) 
                            : (car.isAvailable ? const Color(0xFFB9F6CA) : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)));
                        
                        final statusText = isRented ? 'SEDANG DISEWA' : (car.isAvailable ? 'TERSEDIA' : 'NONAKTIF');

                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(carId: car.id))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 3),
                              boxShadow: [BoxShadow(color: borderColor, offset: const Offset(5, 5), blurRadius: 0)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70, height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: (car.imageUrl != null && car.imageUrl!.trim().isNotEmpty)
                                        ? Image.network(car.imageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.black, size: 30))
                                        : const Icon(Icons.directions_car, color: Colors.black, size: 34),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        car.name.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 18, color: (!car.isAvailable && !isRented && isDark) ? Colors.white : Colors.black,
                                          decoration: (!car.isAvailable && !isRented) ? TextDecoration.lineThrough : TextDecoration.none,
                                        )
                                      ),
                                      Text('WARNA: ${car.color.toUpperCase()}', style: TextStyle(color: (!car.isAvailable && !isRented && isDark) ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isRented ? Colors.orangeAccent : (car.isAvailable ? Colors.white : Colors.grey.shade400),
                                          border: Border.all(color: Colors.black, width: 2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(statusText, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (isRented)
                                      Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), shape: BoxShape.circle), child: const Icon(Icons.lock_clock, color: Colors.black, size: 20))
                                    else
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Switch(
                                          value: car.isAvailable, activeColor: Colors.white, activeTrackColor: Colors.black, inactiveThumbColor: Colors.black, inactiveTrackColor: Colors.white, trackOutlineColor: WidgetStateProperty.all(Colors.black),
                                          onChanged: (bool newValue) async {
                                            try { await store.toggleCarAvailability(car.id, newValue); } catch (e) { debugPrint(e.toString()); }
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _NeoIconButton(icon: Icons.edit, color: const Color(0xFF80D8FF), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarFormScreen(car: car)))),
                                        const SizedBox(width: 8),
                                        _NeoIconButton(icon: Icons.delete, color: const Color(0xFFFF8A80), onTap: () => _confirmDelete(context, store, car, isDark)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _fabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _fabVisible ? 1.0 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFEA80FC), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              onPressed: _fabVisible ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarFormScreen())) : null,
              icon: const Icon(Icons.add, color: Colors.black, size: 24),
              label: const Text('TAMBAH MOBIL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final borderColor = isDark ? Colors.white : Colors.black;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32), padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF59D), border: Border.all(color: borderColor, width: 3), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(6, 6), blurRadius: 0)],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 80, color: Colors.black), SizedBox(height: 16),
            Text('BELUM ADA MOBIL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)), SizedBox(height: 8),
            Text('Tap tombol tambah di bawah', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppStore store, Car car, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF222222) : Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 3)),
        title: Text('HAPUS MOBIL?', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
        content: Text('Yakin ingin menghapus "${car.name}"?', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('BATAL', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () async { Navigator.pop(ctx); await store.deleteCar(car.id); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A80), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
            child: const Text('HAPUS', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _NeoIconButton extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _NeoIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)]),
        child: Icon(icon, color: Colors.black, size: 18),
      ),
    );
  }
}