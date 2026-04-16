import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/car.dart';
import 'models/rental.dart';
import 'services/supabase_service.dart';
import 'models/queue_item.dart';

class AppStore extends ChangeNotifier {
  AppStore();

  List<Car> _cars = [];
  List<Rental> _rentals = [];
  bool _isLoading = false;

  final List<QueueItem> _queues = [];
  List<QueueItem> get queues => List.unmodifiable(_queues);

  List<Car> get cars => List.unmodifiable(_cars);
  List<Car> get availableCars => _cars.where((c) => c.isAvailable).toList();
  List<Rental> get rentals => List.unmodifiable(_rentals);
  List<Rental> get activeRentals =>
      _rentals.where((r) => r.status == 'active').toList();
  double get todayRevenue {
    final now = DateTime.now();
    return rentals.where((r) {
      return r.status == 'returned' && 
             r.startTime.year == now.year &&
             r.startTime.month == now.month &&
             r.startTime.day == now.day;
    }).fold(0, (sum, r) => sum + r.totalPrice);
  }

  bool get isLoading => _isLoading;


  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cars = await SupabaseService.fetchCars();
      _rentals = await SupabaseService.fetchRentals();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCars() async {
    _cars = await SupabaseService.fetchCars();
    notifyListeners();
  }

  Future<void> loadRentals() async {
    _rentals = await SupabaseService.fetchRentals();
    notifyListeners();
  }

  // Car CRUD
  Future<void> addCar(Car car) async {
    final newCar = await SupabaseService.addCar(car);
    _cars.add(newCar);
    notifyListeners();
  }

  Future<void> updateCar(Car updatedCar) async {
    final updated = await SupabaseService.updateCar(updatedCar);
    final index = _cars.indexWhere((c) => c.id == updatedCar.id);
    if (index != -1) {
      _cars[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteCar(String carId) async {
    await SupabaseService.deleteCar(carId);
    _cars.removeWhere((c) => c.id == carId);
    notifyListeners();
  }

  Future<void> toggleCarAvailability(String carId, bool isAvailable) async {
    try {

      await SupabaseService.setCarAvailability(carId, isAvailable);

      final index = _cars.indexWhere((c) => c.id == carId);
      if (index != -1) {
        _cars[index].isAvailable = isAvailable;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling car availability: $e');
      throw Exception('Gagal memperbarui status unit');
    }
  }

  Car? getCarById(String id) {
    try {
      return _cars.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Rental CRUD
  Future<void> addRental({
    required Car car,
    required String renterName,
    required String renterPhone,
    required String renterAddress,
    required int durationMinutes,
    bool isPaid = false,
  }) async {
    final rental = Rental(
      id: '',
      carId: car.id,
      carName: car.name,
      renterName: renterName,
      renterPhone: renterPhone,
      renterAddress: renterAddress,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      isPaid: isPaid,
    );

    final newRental = await SupabaseService.addRental(rental);
    _rentals.insert(0, newRental);
    await SupabaseService.setCarAvailability(car.id, false);
    final idx = _cars.indexWhere((c) => c.id == car.id);
    if (idx != -1) _cars[idx].isAvailable = false;
    notifyListeners();
  }

  Future<void> returnCar(String rentalId) async {
    await SupabaseService.updateRentalStatus(rentalId, 'returned');
    final idx = _rentals.indexWhere((r) => r.id == rentalId);
    if (idx != -1) {
      _rentals[idx].status = 'returned';
      await SupabaseService.setCarAvailability(_rentals[idx].carId, true);
      final carIdx = _cars.indexWhere((c) => c.id == _rentals[idx].carId);
      if (carIdx != -1) _cars[carIdx].isAvailable = true;
    }
    notifyListeners();
  }

  Future<void> deleteRental(String rentalId) async {
    final rental = getRentalById(rentalId);
    await SupabaseService.deleteRental(rentalId);
    if (rental != null && rental.status == 'active') {
      await SupabaseService.setCarAvailability(rental.carId, true);
      final carIdx = _cars.indexWhere((c) => c.id == rental.carId);
      if (carIdx != -1) _cars[carIdx].isAvailable = true;
    }
    _rentals.removeWhere((r) => r.id == rentalId);
    notifyListeners();
  }

  Rental? getRentalById(String id) {
    try {
      return _rentals.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addQueue(String renterName,
      {String? targetCarId, String? targetCarName}) async {
    final newQueue = QueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      renterName: renterName,
      queuedAt: DateTime.now(),
      targetCarId: targetCarId,
      targetCarName: targetCarName,
    );
    _queues.add(newQueue);
    notifyListeners();
  }
 
  Future<void> removeQueue(String queueId) async {
    _queues.removeWhere((q) => q.id == queueId);
    notifyListeners();
  }

  Future<void> extendRentalTime(String rentalId, int addMinutes, int addPrice) async {
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index >= 0) {
      final r = _rentals[index];
      
      final newDuration = r.durationMinutes + addMinutes;
      final newEndTime = r.endTime.add(Duration(minutes: addMinutes));
      final newTotalPrice = r.totalPrice + addPrice;

      try {
        await Supabase.instance.client
            .from('rentals')
            .update({
              'duration_minutes': newDuration,
              'end_time': newEndTime.toUtc().toIso8601String(), 
              'total_price': newTotalPrice,
            })
            .eq('id', rentalId);

        r.durationMinutes = newDuration;
        r.endTime = newEndTime;
        r.totalPrice = newTotalPrice;

        notifyListeners();
        
      } catch (e) {
        debugPrint('Gagal menambah waktu di Supabase: $e');
        throw Exception('Gagal menyimpan ke database'); 
      }
    }
  }

  Future<void> updatePaymentStatus(String rentalId, bool isPaid) async {
    try {
      await Supabase.instance.client
          .from('rentals')
          .update({'is_paid': isPaid})
          .eq('id', rentalId);

      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index >= 0) {
        _rentals[index].isPaid = isPaid;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal update status bayar: $e');
      throw Exception('Gagal menyimpan perubahan status');
    }
  }
}