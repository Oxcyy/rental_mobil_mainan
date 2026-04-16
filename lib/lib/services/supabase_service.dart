import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';
import '../models/rental.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  //  FITUR UPLOAD GAMBAR 
  static Future<String> uploadCarImage(File imageFile) async {
    final fileName = 'car_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('car_images').upload(fileName, imageFile);
    final imageUrl = _client.storage.from('car_images').getPublicUrl(fileName);
    return imageUrl;
  }

  // CAR
  static Future<List<Car>> fetchCars() async {
    final res = await _client
        .from('cars')
        .select()
        .order('created_at', ascending: true);
    return (res as List).map((e) => Car.fromJson(e)).toList();
  }

  static Future<Car> addCar(Car car) async {
    final res = await _client
        .from('cars').insert(car.toJson()).select().single();
    return Car.fromJson(res);
  }

  static Future<Car> updateCar(Car car) async {
    final res = await _client
        .from('cars').update(car.toJson()).eq('id', car.id).select().single();
    return Car.fromJson(res);
  }

  static Future<void> deleteCar(String id) async {
    await _client.from('cars').delete().eq('id', id);
  }

  static Future<void> setCarAvailability(String id, bool isAvailable) async {
    await _client.from('cars')
        .update({'is_available': isAvailable}).eq('id', id);
  }

  // RENTAL
  static Future<List<Rental>> fetchRentals() async {
    final res = await _client
        .from('rentals')
        .select()
        .order('created_at', ascending: false);
    return (res as List).map((e) => Rental.fromJson(e)).toList();
  }

  static Future<Rental> addRental(Rental rental) async {
    final res = await _client
        .from('rentals').insert(rental.toJson()).select().single();
    return Rental.fromJson(res);
  }

  static Future<Rental> updateRentalStatus(String id, String status) async {
    final res = await _client
        .from('rentals').update({'status': status})
        .eq('id', id).select().single();
    return Rental.fromJson(res);
  }

  static Future<void> deleteRental(String id) async {
    await _client.from('rentals').delete().eq('id', id);
  }

  //  FITUR AUTENTIKASI 
  static Future<void> signIn(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}