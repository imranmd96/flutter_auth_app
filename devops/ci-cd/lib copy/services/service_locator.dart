import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/config/api_config.dart';

import '../auth/login/services/token_service.dart';
import '../auth/registration/services/registration_repository.dart';
import '../repositories/admin_repository.dart';
import '../repositories/home_repository.dart';
import '../services/restaurant_service.dart';
import '../services/user_service.dart';
import 'base_api_service.dart';

final serviceLocatorProvider = Provider<ServiceLocator>((ref) => ServiceLocator(ref));

class ServiceLocator {
  final Ref ref;
  late final BaseApiService _apiService;
  late final TokenService _tokenService;
  late final UserService _userService;
  late final RestaurantService _restaurantService;
  late final HomeRepository _homeRepository;
  late final AdminRepository _adminRepository;
  late final RegistrationRepository _registrationRepository;
  

  ServiceLocator(this.ref) {
    _apiService = BaseApiService(baseUrl: '${ApiConfig.devBaseUrl}/api', ref: ref);
    _tokenService = TokenService();
    _userService = UserService(ref);
    _restaurantService = RestaurantService(ref);
    _homeRepository = HomeRepository(ref);
    _adminRepository = AdminRepository(ref);
    _registrationRepository = RegistrationRepository(ref);
  }

  BaseApiService get apiService => _apiService;
  TokenService get tokenService => _tokenService;
  UserService get userService => _userService;
  RestaurantService get restaurantService => _restaurantService;
  HomeRepository get homeRepository => _homeRepository;
  AdminRepository get adminRepository => _adminRepository;
  RegistrationRepository get registrationRepository => _registrationRepository;
}