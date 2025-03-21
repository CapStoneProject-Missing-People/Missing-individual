import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';


Future<void> deleteMessageFromAPI(UserProvider userProvider, String messageId) async {
  final userToken = await AuthService().getTokens();

    final accessToken = userToken['accessToken'];

  final response = await http.delete(
    Uri.parse('${Constants.postUri}/api/chat/$messageId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete message');
  }
}


