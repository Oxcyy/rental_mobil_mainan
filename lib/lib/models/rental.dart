class Rental {
  final String id;
  final String carId;
  final String carName;
  final String renterName;
  final String renterPhone;
  final String renterAddress;
  final DateTime startTime;

  int durationMinutes;
  late DateTime endTime;
  
  late int totalPrice; 

  bool isPaid;
  String status;

  Rental({
    required this.id,
    required this.carId,
    required this.carName,
    required this.renterName,
    required this.renterPhone,
    required this.renterAddress,
    required this.startTime,
    required this.durationMinutes,
    this.isPaid = false,
    this.status = 'active',
    DateTime? endTime,
    int? totalPrice,
  }) {
    this.endTime = endTime ?? startTime.add(Duration(minutes: durationMinutes));
    
    this.totalPrice = totalPrice ?? ((durationMinutes ~/ 15) * 20000);
  }

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'].toString(),
      carId: json['car_id'].toString(),
      carName: json['car_name'],
      renterName: json['renter_name'],
      renterPhone: json['renter_phone'] ?? '',
      renterAddress: json['renter_address'] ?? '',
      startTime: DateTime.parse(json['start_time']).toLocal(),
      durationMinutes: json['duration_minutes'],
      isPaid: json['is_paid'] ?? false,
      status: json['status'] ?? 'active',
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']).toLocal() 
          : null,
          
      totalPrice: json['total_price'] != null 
          ? int.parse(json['total_price'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_id': carId,
      'car_name': carName,
      'renter_name': renterName,
      'renter_phone': renterPhone,
      'renter_address': renterAddress,
      'start_time': startTime.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'end_time': endTime.toUtc().toIso8601String(),
      
      'total_price': totalPrice, 
      
      'is_paid': isPaid,
      'status': status,
    };
  }
}