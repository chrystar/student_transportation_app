import 'package:get_it/get_it.dart';
import 'base_service.dart';
import 'booking_service.dart';
import 'location_service.dart';
import 'message_service.dart';
import 'notification_service.dart';
import 'trip_service.dart';
import 'vehicle_service.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Register services
  locator.registerLazySingleton<BaseService>(() => BaseService());
  locator.registerLazySingleton<BookingService>(() => BookingService());
  locator.registerLazySingleton<LocationService>(() => LocationService());
  locator.registerLazySingleton<MessageService>(() => MessageService());
  locator
      .registerLazySingleton<NotificationService>(() => NotificationService());
  locator.registerLazySingleton<TripService>(() => TripService());
  locator.registerLazySingleton<VehicleService>(() => VehicleService());
}
