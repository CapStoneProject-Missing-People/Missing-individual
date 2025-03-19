import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:missingpersonapp/common/services/fcm-service.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/login_page.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'package:missingpersonapp/features/home/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FcmService _fcmService = FcmService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Check network connectivity
  Future<bool> _checkNetworkConnectivity(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showToast(context, 'No internet connection', Colors.red);
      return false;
    }
    return true;
  }

  // Store tokens in Secure Storage
  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    await _secureStorage.write(
        key: Constants.accessTokenKey, value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'isLoggedIn', value: 'true');
    await _secureStorage.write(
        key: 'lastLogin', value: DateTime.now().toIso8601String());
  }

  // Clear tokens from Secure Storage
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'isLoggedIn');
    await _secureStorage.delete(key: 'lastLogin');
  }

  // Get tokens from Secure Storage
  Future<Map<String, String?>> getTokens() async {
    return {
      'accessToken': await _secureStorage.read(key: 'accessToken'),
      'refreshToken': await _secureStorage.read(key: 'refreshToken'),
      'email': await _secureStorage.read(key: 'email'),
      'isLoggedIn': await _secureStorage.read(key: 'isLoggedIn'),
      'lastLogin': await _secureStorage.read(key: 'lastLogin'),
    };
  }

  // Check if token needs refresh
  // Future<bool> shouldRefreshToken() async {
  //   final tokens = await getTokens();
  //   final lastLoginStr = tokens['lastLogin'];

  //   if (lastLoginStr == null) return true;

  //   final lastLogin = DateTime.parse(lastLoginStr);
  //   final now = DateTime.now();
  //   final difference = now.difference(lastLogin).inMinutes;

  //   return difference >=
  //       (Constants.accessTokenExpiryMinutes - Constants.tokenRefreshThreshold);
  // }

  // Sign up user
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String phoneNo,
  }) async {
    try {
      // Check network connectivity
      if (!await _checkNetworkConnectivity(context)) return;

      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        phoneNo: phoneNo,
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.postUri}/api/users/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showToast(
            context,
            'Account created! Login with the same credentials!',
            Colors.green,
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (route) => false,
          );
        },
      );
    } on SocketException catch (e) {
      showToast(context, 'No internet connection', Colors.red);
      print('SocketException: $e');
    } on TimeoutException catch (e) {
      showToast(context, 'Request timed out', Colors.red);
      print('TimeoutException: $e');
    } on http.ClientException catch (e) {
      showToast(context, 'Failed to connect to the server', Colors.red);
      print('ClientException: $e');
    } catch (e, stackTrace) {
      showToast(context, 'An unexpected error occurred', Colors.red);
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<String?> getValidAccessToken(BuildContext context) async {
    try {
      print('Getting valid access token...');

      final tokens = await getTokens();
      print('Tokens retrieved: $tokens');

      final accessToken = tokens['accessToken'];
      final refreshToken = tokens['refreshToken'];

      if (accessToken == null || refreshToken == null) {
        print('Access token or refresh token is missing.');
        await _clearTokens();
        return null;
      }

      // Check if the access token is valid
      final isTokenValid = await _validateToken(accessToken);
      print('Is token valid: $isTokenValid');

      if (isTokenValid) {
        print('Access token is valid.');
        return accessToken;
      } else {
        print('Access token is invalid. Attempting to refresh...');

        // Token is invalid, try to refresh it
        final refreshed = await refreshExpToken(context);
        print('Token refresh result: $refreshed');

        if (refreshed) {
          final newTokens = await getTokens();
          print('New tokens after refresh: $newTokens');
          return newTokens['accessToken'];
        } else {
          print('Token refresh failed. Clearing tokens and logging out...');

          // Refresh failed, clear tokens and log out
          await _clearTokens();
          Provider.of<UserProvider>(context, listen: false).clearUser();
          return null;
        }
      }
    } catch (e) {
      print('Error in getValidAccessToken: $e');
      return null;
    }
  }

  // Refresh token
  Future<bool> refreshExpToken(BuildContext context) async {
    try {
      print('Refreshing token...');

      final tokens = await getTokens();
      print('Tokens retrieved: $tokens');

      final refreshToken = tokens['refreshToken'];

      if (refreshToken == null) {
        print('Refresh token is missing.');
        return false;
      }

      final response = await http.post(
        Uri.parse('${Constants.postUri}/api/users/refresh-token'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      print('Refresh token response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('New tokens received: $data');

        await _storeTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          email: tokens['email'] ?? '',
        );

        print('Token refresh successful.');
        return true;
      } else if (response.statusCode == 401) {
        // Refresh token is invalid or expired
        print('Refresh token is invalid or expired.');
        await _clearTokens();
        return false;
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Sign in user
  Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Check network connectivity
      if (!await _checkNetworkConnectivity(context)) {
        showToast(context, 'No internet connection', Colors.red);
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);

      // Make the login request
      final response = await http.post(
        Uri.parse('${Constants.postUri}/api/users/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // Handle the response
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        print('Login response: $userData');

        // Validate the response
        if (userData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        // Ensure required fields are present
        if (userData['token'] == null) {
          throw Exception('No access token received');
        }

        // Update the user provider
        userProvider.setUserFromJson(response.body);

        // Extract the refresh token from the cookie header
        String? refreshToken;
        if (response.headers['set-cookie'] != null) {
          final cookies = response.headers['set-cookie']!.split(';');
          for (var cookie in cookies) {
            if (cookie.trim().startsWith('jwt=')) {
              refreshToken = cookie.trim().substring(4);
              break;
            }
          }
        }

        // Use the token from the response body as fallback
        final accessToken = userData['token'];
        print('Access token: $accessToken');
        print('Refresh token: $refreshToken');

        if (accessToken != null && refreshToken != null) {
          // Store tokens securely
          await _storeTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            email: email,
          );

          // Send FCM token to the backend (if available)
          String? fcmToken = await _fcmService.getToken();
          if (fcmToken != null) {
            await _fcmService.sendTokenToBackend(fcmToken);
          }

          // Navigate to the home page
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else {
          throw Exception('No tokens received from server');
        }
      } else if (response.statusCode == 401) {
        // Handle invalid credentials
        showToast(context, 'Invalid email or password', Colors.red);
      } else if (response.statusCode == 400) {
        // Handle bad request (e.g., missing fields)
        showToast(context, 'Invalid request. Please try again.', Colors.red);
      } else {
        // Handle other errors
        showToast(
            context, 'Something went wrong. Please try again.', Colors.red);
        throw Exception('Failed to sign in: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during sign-in: $e');
      handleAuthError(context, e);
    }
  }

  // Get user data
  Future<void> getUserData(BuildContext context) async {
    try {
      print('Fetching user data...');

      // Check network connectivity
      if (!await _checkNetworkConnectivity(context)) {
        print('No internet connection.');
        showToast(context, 'No internet connection', Colors.red);
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Validate access token
      final validAccessToken = await getValidAccessToken(context);
      if (validAccessToken == null) {
        print('Access token is missing or invalid.');
        await _clearTokens();
        showToast(context, 'Session expired. Please log in again.', Colors.red);
        return;
      }

      // Log the full URL being used
      final url = '${Constants.postUri}/api/users/getUser';
      print('Fetching user data from: $url');

      // Fetch user data
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': "Bearer $validAccessToken",
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body); // Parse response as Map
        print('User data received: $userData');

        // Validate the response data
        if (userData is! Map<String, dynamic>) {
          throw Exception('Invalid user data format');
        }

        // Ensure required fields are present
        if (userData['id'] == null ||
            userData['name'] == null ||
            userData['email'] == null) {
          throw Exception('Incomplete user data');
        }

        // Update the UserProvider
        userProvider.setUser(userData);

        // Check if FCM token has changed
        String? fcmToken = await _fcmService.getToken();
        final storedFcmToken = await _secureStorage.read(key: 'fcmToken');

        if (fcmToken != null && fcmToken != storedFcmToken) {
          await _fcmService.sendTokenToBackend(fcmToken);
          await _secureStorage.write(key: 'fcmToken', value: fcmToken);
        }

        print('User data updated successfully.');
      } else if (response.statusCode == 404) {
        print('Endpoint not found: $url');
        showToast(context, 'Failed to fetch user data: Endpoint not found',
            Colors.red);
      } else if (response.statusCode == 401) {
        print('Unauthorized: Invalid or expired token');
        await _clearTokens();
        showToast(context, 'Session expired. Please log in again.', Colors.red);
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      handleAuthError(context, e);
    }
  }

  // Helper method to fetch and update user data
  Future<void> _fetchAndUpdateUserData(
      BuildContext context, String token, UserProvider userProvider) async {
    try {
      print('Fetching and updating user data...');

      final response = await http.get(
        Uri.parse('${Constants.postUri}/api/users/getUser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': "Bearer $token",
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        print('User data received: $userData');

        userProvider.setUser(userData);

        // Check if FCM token has changed
        String? fcmToken = await _fcmService.getToken();
        final storedFcmToken = await _secureStorage.read(key: 'fcmToken');

        if (fcmToken != null && fcmToken != storedFcmToken) {
          await _fcmService.sendTokenToBackend(fcmToken);
          await _secureStorage.write(key: 'fcmToken', value: fcmToken);
        }

        print('User data updated successfully.');
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw e;
    }
  }

  // Sign out user
  Future<void> signOut(BuildContext context) async {
    try {
      if (!await _checkNetworkConnectivity(context)) return;

      final navigator = Navigator.of(context);
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];

      if (accessToken != null) {
        try {
          await http.post(
            Uri.parse('${Constants.postUri}/api/users/logout'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
          );
        } catch (e) {
          print('Error logging out on server: $e');
        }
      }

      // Clear tokens and user data
      await _clearTokens();
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // Clear FCM token
      String? fcmToken = await _fcmService.getToken();
      if (fcmToken != null) {
        await _fcmService.sendTokenToBackend(fcmToken);
        await _secureStorage.delete(key: 'fcmToken');
      }

      // Navigate to home page
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      print('Error during sign out: $e');
      handleAuthError(context, e);
    }
  }

  // Auto login check
  Future<bool> tryAutoLogin(BuildContext context) async {
    try {
      print('Attempting auto login...');

      // Check if the user is logged in
      final tokens = await getTokens();
      print('Tokens retrieved: $tokens');

      final isLoggedIn = tokens['isLoggedIn'] == 'true';
      print('isLoggedIn: $isLoggedIn');

      if (!isLoggedIn) {
        print('User not logged in.');
        return false;
      }

      // Get a valid access token
      final validAccessToken = await getValidAccessToken(context);
      print('Valid access token: $validAccessToken');

      if (validAccessToken != null) {
        print('Valid access token found. Fetching user data...');

        // Fetch user data
        await getUserData(context);
        print('Auto login successful.');
        return true;
      } else {
        print('No valid access token. Clearing tokens and logging out...');

        // Clear tokens and log out
        await _clearTokens();
        Provider.of<UserProvider>(context, listen: false).clearUser();
        return false;
      }
    } catch (e) {
      print('Error during auto login: $e');

      // Clear tokens and log out on error
      await _clearTokens();
      Provider.of<UserProvider>(context, listen: false).clearUser();
      return false;
    }
  }

// helper method to validate token
  Future<bool> _validateToken(String accessToken) async {
    try {
      print('Validating token...');
      print('Token: $accessToken');

      // Check if the token is expired using jwt_decoder
      final isExpired = JwtDecoder.isExpired(accessToken);
      print('Is token expired: $isExpired');

      if (isExpired) {
        print('Token is expired.');
        return false;
      }

      print('Token is valid.');
      return true;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  // Helper method to handle auth errors
  void handleAuthError(BuildContext context, dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is SocketException) {
      errorMessage = 'No internet connection';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timed out';
    } else if (error is http.ClientException) {
      errorMessage = 'Failed to connect to the server';
    } else if (error is FormatException) {
      errorMessage = 'Invalid token or server response';
    }

    showToast(context, errorMessage, Colors.red);
    print('Error: $error');
  }
}
