import 'package:equatable/equatable.dart';

enum RideStatus {
  pending, // Passenger posted, waiting for drivers
  negotiating, // Drivers are sending offers
  accepted, // Passenger accepted a driver
  driverEnRoute, // Driver heading to pickup
  inProgress, // Ride started
  completed,
  cancelled,
}

/// Ride model — mirrors the Supabase `rides` table.
class RideModel extends Equatable {
  final String id;
  final String passengerId;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String dropoffAddress;
  final double passengerOffer;
  final RideStatus status;
  final String? acceptedDriverId;
  final String paymentMethod;
  final double? distanceKm;
  final int? estimatedMinutes;
  final DateTime createdAt;

  const RideModel({
    required this.id,
    required this.passengerId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.dropoffAddress,
    required this.passengerOffer,
    required this.status,
    this.acceptedDriverId,
    this.paymentMethod = 'cash',
    this.distanceKm,
    this.estimatedMinutes,
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      passengerId: json['passenger_id'] as String,
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffLat: (json['dropoff_lat'] as num).toDouble(),
      dropoffLng: (json['dropoff_lng'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      passengerOffer: (json['passenger_offer'] as num).toDouble(),
      status: RideStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RideStatus.pending,
      ),
      acceptedDriverId: json['accepted_driver_id'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      estimatedMinutes: json['estimated_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'passenger_id': passengerId,
    'pickup_lat': pickupLat,
    'pickup_lng': pickupLng,
    'pickup_address': pickupAddress,
    'dropoff_lat': dropoffLat,
    'dropoff_lng': dropoffLng,
    'dropoff_address': dropoffAddress,
    'passenger_offer': passengerOffer,
    'status': status.name,
    'accepted_driver_id': acceptedDriverId,
    'payment_method': paymentMethod,
    'distance_km': distanceKm,
    'estimated_minutes': estimatedMinutes,
  };

  RideModel copyWith({RideStatus? status, String? acceptedDriverId}) {
    return RideModel(
      id: id,
      passengerId: passengerId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupAddress: pickupAddress,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      dropoffAddress: dropoffAddress,
      passengerOffer: passengerOffer,
      status: status ?? this.status,
      acceptedDriverId: acceptedDriverId ?? this.acceptedDriverId,
      paymentMethod: paymentMethod,
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, passengerId, status, passengerOffer];
}

/// Driver offer model — mirrors `ride_offers` table.
class DriverOfferModel extends Equatable {
  final String id;
  final String rideId;
  final String driverId;
  final String driverName;
  final String? driverAvatarUrl;
  final double driverRating;
  final int totalRides;
  final double offeredPrice;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final bool isVerified;
  final bool isPremium;
  final OfferStatus status;

  const DriverOfferModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.driverName,
    this.driverAvatarUrl,
    required this.driverRating,
    required this.totalRides,
    required this.offeredPrice,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehiclePlate,
    this.isVerified = false,
    this.isPremium = false,
    this.status = OfferStatus.pending,
  });

  factory DriverOfferModel.fromJson(Map<String, dynamic> json) {
    return DriverOfferModel(
      id: json['id'] as String,
      rideId: json['ride_id'] as String,
      driverId: json['driver_id'] as String,
      driverName: json['driver_name'] as String,
      driverAvatarUrl: json['driver_avatar_url'] as String?,
      driverRating: (json['driver_rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: json['total_rides'] as int? ?? 0,
      offeredPrice: (json['offered_price'] as num).toDouble(),
      vehicleMake: json['vehicle_make'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleColor: json['vehicle_color'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      status: OfferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OfferStatus.pending,
      ),
    );
  }

  @override
  List<Object?> get props => [id, driverId, offeredPrice, status];
}

enum OfferStatus { pending, accepted, rejected }
