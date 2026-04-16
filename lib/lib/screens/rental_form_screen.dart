import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../notification_service.dart'; 
import '../widgets/custom_app_bar.dart';
import '../main.dart'; 

class RentalFormScreen extends StatefulWidget {
  final String? carId;
  final String? initialName; 
  
  const RentalFormScreen({super.key, this.carId, this.initialName});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: '.');
  final _phoneCtrl = TextEditingController(text: '.');
  final _addressCtrl = TextEditingController(text: '.');
  Car? _selectedCar;
  int _durationMinutes = 15;
  bool _isSaving = false;
  bool _isPaid = false; 

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null && widget.initialName != '.') {
      _nameCtrl.text = widget.initialName!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.carId != null) {
        final store = context.read<AppStore>();
        final car = store.getCarById(widget.carId!);
        // FIX 3: hanya pre-select jika mobil memang tersedia
        if (car != null && car.isAvailable) {
          setState(() => _selectedCar = car);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  int get _totalPrice => _durationMinutes == 1 ? 0 : (_durationMinutes ~/ 15) * Car.pricePerSession;
  DateTime get _estimatedEnd => DateTime.now().add(Duration(minutes: _durationMinutes));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCar == null) {
      showSnackBarWithOK('Pilih mobil terlebih dahulu', backgroundColor: const Color(0xFFFFD180)); 
      return;
    }
    setState(() => _isSaving = true);

    final store = context.read<AppStore>();
    final navigator = Navigator.of(context);
    final carId = widget.carId;

    try {
      String namaPenyewa = _nameCtrl.text.trim().isEmpty || _nameCtrl.text.trim() == '.' ? 'Penyewa' : _nameCtrl.text.trim();

      await store.addRental(
        car: _selectedCar!,
        renterName: _nameCtrl.text.trim().isEmpty ? '.' : _nameCtrl.text.trim(),
        renterPhone: _phoneCtrl.text.trim().isEmpty ? '.' : _phoneCtrl.text.trim(),
        renterAddress: _addressCtrl.text.trim().isEmpty ? '.' : _addressCtrl.text.trim(),
        durationMinutes: _durationMinutes,
        isPaid: _isPaid, 
      );

      int alarmSeconds = _durationMinutes * 60;
      await NotificationService.scheduleNotification(
        id: _selectedCar!.id.hashCode,
        title: 'WAKTU HABIS! ⏰',
        body: 'Unit ${_selectedCar!.name} atas nama $namaPenyewa sudah selesai.',
        seconds: alarmSeconds,
      );
      
      if (mounted) {
        navigator.pop();
        if (carId != null) navigator.pop();
      }
      showSnackBarWithOK('Penyewaan berhasil & Alarm diatur!');

    } catch (e) {
      debugPrint("Eror: $e");
      showSnackBarWithOK('Gagal: $e', backgroundColor: const Color(0xFFFF8A80)); 
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _neoInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: Colors.white, 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID'); 
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'FORM PENYEWAAN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoDefault(),
              const SizedBox(height: 24),
              
              _label('PILIH MOBIL *', isDark),
              _buildCarSelector(),
              const SizedBox(height: 20),
              
              _label('NAMA PENYEWA', isDark),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\.]'))],
                decoration: _neoInputDecoration('Nama lengkap (opsional)', Icons.person),
              ),
              const SizedBox(height: 20),
              
              _label('NO. TELEPON', isDark),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                decoration: _neoInputDecoration('08xxxxxxxxxx (opsional)', Icons.phone),
              ),
              const SizedBox(height: 20),
              
              _label('DESKRIPSI ANAK YANG MENGENDARAI', isDark),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                decoration: _neoInputDecoration('Ciri-ciri anak (Cth: Baju merah)', Icons.child_care),
              ),
              const SizedBox(height: 24),
              
              _label('STATUS PEMBAYARAN', isDark),
              Container(
                decoration: BoxDecoration(
                  color: _isPaid ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                ),
                child: SwitchListTile(
                  title: const Text('SUDAH BAYAR?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: Text(_isPaid ? 'PEMBAYARAN LUNAS' : 'BAYAR NANTI (HUTANG)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12)),
                  value: _isPaid,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.black,
                  inactiveThumbColor: Colors.black,
                  inactiveTrackColor: Colors.white,
                  trackOutlineColor: WidgetStateProperty.all(Colors.black),
                  onChanged: (val) => setState(() => _isPaid = val),
                  secondary: Icon(_isPaid ? Icons.check_circle : Icons.warning_amber_rounded, color: Colors.black, size: 30),
                ),
              ),
              const SizedBox(height: 24),
              
              _label('DURASI PENYEWAAN', isDark),
              _buildDurationPicker(borderColor),
              const SizedBox(height: 24),
              
              _buildTimeSummary(timeFmt, borderColor),
              const SizedBox(height: 24),
              
              _buildPriceCard(currFmt, borderColor),
              const SizedBox(height: 32),
              
              _buildSubmitButton(borderColor),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDefault() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 2)), 
      child: const Row(children: [
          Icon(Icons.info_outline, color: Colors.black, size: 24), SizedBox(width: 12),
          Expanded(child: Text('Data penyewa diisi "." secara default. Isi jika sempat.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black))),
        ],
      ),
    );
  }

  Widget _buildCarSelector() {
    final store = context.read<AppStore>(); 
    // FIX 2 + FIX 3: hanya tampilkan mobil yang benar-benar tersedia
    List<Car> carList = List.from(store.availableCars);
    // Jika mobil yang sudah dipilih masih tersedia, pastikan ada di list
    if (_selectedCar != null && _selectedCar!.isAvailable && !carList.any((c) => c.id == _selectedCar!.id)) {
      carList.add(_selectedCar!);
    }
    Car? dropdownValue;
    if (_selectedCar != null) {
      try { dropdownValue = carList.firstWhere((c) => c.id == _selectedCar!.id); } catch (_) {}
    }
    return DropdownButtonFormField<Car>(
      value: dropdownValue,
      isExpanded: true, // FIX 2: mencegah teks keluar dari box di layar kecil
      dropdownColor: Colors.white,
      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16),
      hint: const Text('Pilih mobil...', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, fontSize: 16)),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 3)),
      ),
      items: carList.map((car) => DropdownMenuItem(
        value: car,
        child: Text(
          '${car.name.toUpperCase()} (${car.color.toUpperCase()})',
          style: const TextStyle(color: Colors.black),
          overflow: TextOverflow.ellipsis, // FIX 2: teks panjang dipotong dengan "..."
        ),
      )).toList(),
      onChanged: (car) => setState(() => _selectedCar = car),
      validator: (v) => v == null ? 'Pilih mobil terlebih dahulu' : null,
    );
  }

  Widget _buildDurationPicker(Color borderColor) => Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)]),
        child: Column(
          children: [
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [1, 15, 30, 45, 60, 90, 120].map((min) {
                final selected = _durationMinutes == min;
                return InkWell(
                  onTap: () => setState(() => _durationMinutes = min),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? (min == 1 ? const Color(0xFFFF8A80) : const Color(0xFF80DEEA)) : Colors.white,
                      border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(min == 1 ? '1M (TES)' : (min < 60 ? '${min}M' : '${min ~/ 60}J${min % 60 > 0 ? ' ${min % 60}M' : ''}'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(activeTrackColor: Colors.black, inactiveTrackColor: Colors.white, thumbColor: const Color(0xFFEA80FC), overlayColor: const Color(0xFFEA80FC).withOpacity(0.2), trackHeight: 6, valueIndicatorTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              child: Slider(
                value: _durationMinutes < 15 ? 15.0 : _durationMinutes.toDouble(),
                min: 15, max: 180, divisions: 11, label: '$_durationMinutes Menit',
                onChanged: (v) => setState(() => _durationMinutes = v.toInt()),
              ),
            ),
          ],
        ),
      );

  Widget _buildTimeSummary(DateFormat timeFmt, Color borderColor) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF80DEEA), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)]),
      child: Column(
        children: [
          Row(children: [const Icon(Icons.play_circle, color: Colors.black, size: 24), const SizedBox(width: 8), Text('MULAI: ${timeFmt.format(DateTime.now())}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.stop_circle, color: Colors.black, size: 24), const SizedBox(width: 8), Text('SELESAI: ${timeFmt.format(_estimatedEnd)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black))]),
        ],
      ),
    );
  }

  Widget _buildPriceCard(NumberFormat currFmt, Color borderColor) => Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFFEA80FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: 4), boxShadow: [BoxShadow(color: borderColor, offset: const Offset(6, 6), blurRadius: 0)]),
        child: Column(
          children: [
            const Text('TOTAL BIAYA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 4),
            Text(currFmt.format(_totalPrice), style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900)), const SizedBox(height: 4),
            Text('${_durationMinutes == 1 ? 0 : _durationMinutes ~/ 15} SESI × ${currFmt.format(20000)}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildSubmitButton(Color borderColor) => InkWell(
        onTap: _isSaving ? null : _save,
        child: Container(
          width: double.infinity, height: 64,
          decoration: BoxDecoration(color: _isSaving ? Colors.grey : const Color(0xFFB9F6CA), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 3), boxShadow: _isSaving ? null : [BoxShadow(color: borderColor, offset: const Offset(5, 5), blurRadius: 0)]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
              else const Icon(Icons.check_circle, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              const Text('KONFIRMASI SEWA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
            ],
          ),
        ),
      );

  Widget _label(String text, bool isDark) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? Colors.white : Colors.black87)));
}