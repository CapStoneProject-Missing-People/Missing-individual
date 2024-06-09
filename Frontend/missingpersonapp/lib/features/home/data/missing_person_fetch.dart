import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

// Placeholder image (Base64 encoded)
final Uint8List placeholderImage = base64Decode(
    '/9j/4AAQSkZJRgABAQAASABIAAD/4QCIRXhpZgAATU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAABJKGAAcAAAAvAAAAUKABAAMAAAABAAEAAKACAAQAAAABAAACAKADAAQAAAABAAACAAAAAABBU0NJSQAAADEuODYuMC01Ukc3WTRNRUhZM00zQlNLSklKUkJCNVBORS4wLjEtNAD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAAA4QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/8AAEQgCAAIAAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/bAEMAAgICAgICAwICAwQDAwMEBQQEBAQFBwUFBQUFBwgHBwcHBwcICAgICAgICAoKCgoKCgsLCwsLDQ0NDQ0NDQ0NDf/bAEMBAgICAwMDBgMDBg0JBwkNDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDf/dAAQAIP/aAAwDAQACEQMRAD8A+e6KKK/Gz/SwKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/Q+e6KKK/Gz/SwKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/R+e6KKK/Gz/SwKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAopGZV+8Qv1OKj8+Dp5if99Cmk3sRKpCLs2S0UgIb7pB+nNLSLWqugooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/9T57ooor8bP9LAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiisvVNXsdIh827f5j9yNeXb6D+vStKVKdSShBXbOXG47D4OhLE4qahCOrbdkjUrntR8UaTpxKNJ50o/gi+Y59z0H515xq/ijUdULRq32e3P/LNDyR/tN1P8q5uvrsDwvdc2KfyX6v/AC+8/nXirx55ZSoZBTuv55r/ANJjp8nJ+sTt7zxzqEpK2USQL2LfO368fpXOXGt6vdE+ddykHsGKj8hisuivpaGW4Wiv3dNfm/vep+IZtxtn2ZNvGYubT6J8sf8AwGNl+A5ndzl2LH3JNNwKKK7VpsfLyk5O8iRJZozmORkPqrEfyrWtvEOtWuPKu5CB2c7x/wCPZrForKpQpVFapFP1R34LNsdg5c+ErSg/7smvyaPQLLx3OpC6hbrIP70R2n8jkH9K7XTtd0zVOLWYb/8Anm/yv+R6/hmvCqUEqQwOCOhHUV4mL4cwtVXp+6/Lb7v8rH6jw94159gJKGNar0+0tJfKS/8AblI+i6K8m0fxjeWZWHUM3MPTd/y0UfX+L8fzr0+zvbXUIBc2kgkjbuOoPoR2NfG4/Kq+Ef7xad1sf0twjx9lPEVO+Dnaot4S0kv815q/nZ6FqiiivNPtQooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD//V+e6KKK/Gz/SwKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiisDxBrkejWm5cNcS5ESH9WPsP1rahQnWqKlTV2zz82zXC5bhKmOxkuWnBXb/Rd23ol1ZB4g8RQ6PH5UWJLpxlU7KP7zf0HevIbq6uL2drm6cySP1Y/wAh6D2pk00txK887F5HO5mPUk1FX6VleVU8HCy1k93/AF0P4h474/xvEmK5ptxoRfuQ6LzfeT79Nl5lFFFeofAhRXUaZ4S1TUAJJFFtEf4pPvEey9fzxXa2fgvR7cA3G+5b/aO1fyXH868fF57hKD5XK77LX/gfifpHD/hRxFm0FVhS9nB7SqPlv6Kzk/W1vM8ioyK97h0jS4BiG0hX/gAP881Z+yWh4MEX/fC/4V5UuLKd9Kb+/wD4B+gUvo94xxvUxsU/KDf43X5Hz3RXu8+h6PcD97Zwn3ChT+YxXPXvgfTpgWs5Ht27A/Ov68/rXTQ4ows3aonH8V+H+R4uaeA+e4eLnhKkKvkm4y/8mVv/ACY8pord1Pw7qmlZeaPzIh/y1j+Zfx7j8awq9+jXp1o89KV15H5DmWVYzL67w2OpOE10krf8OvNaBWjpmqXmk3AuLR8f3kP3XHoR/XtWdRVVKcakXCaumYYPGV8JXjicNNxnF3TTs0z3bR9Z');

Future<List<MissingPerson>> fetchMissingPeople() async {
  try {
    final response = await http.get(
      Uri.parse("${Constants.postUri}/api/features/getAll"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print("Raw JSON data: $jsonData");

      List<MissingPerson> missingPeople = jsonData.map((data) {
        try {
          print("Current data item: $data");

          List<Uint8List> imageBuffers = [];
          if (data['missing_case_id'] != null && data['missing_case_id']['imageBuffers'] != null) {
            imageBuffers = (data['missing_case_id']['imageBuffers'] as List<dynamic>).map((imageUrl) {
              try {
                return base64Decode(imageUrl);
              } catch (e) {
                print('Invalid image data, using placeholder: $e');
                return placeholderImage;
              }
            }).toList();
          }

          return MissingPerson(
            id: data['_id'] as String,
            userId: data['user_id'] as String,
            name: Name.fromJson(data['name'] != null ? data['name'] as Map<String, dynamic> : {}),
            gender: data['gender'] as String? ?? 'Unknown',
            age: data['age'] as int? ?? 0,
            photos: imageBuffers,
            skinColor: data['skin_color'] as String? ?? 'Unknown',
            clothing: data['clothing'] != null ? Clothing.fromJson(data['clothing'] as Map<String, dynamic>) : Clothing(),
            bodySize: data['body_size'] as String? ?? 'Unknown',
            description: data['description'] as String? ?? 'No description available',
            timeSinceDisappearance: data['timeSinceDisappearance'] as int? ?? 0,
            inputHash: data['inputHash'] as String? ?? '',
            version: data['__v'] as int? ?? 0,
            missingCaseId: data['missing_case_id'] != null ? MissingCaseId.fromJson(data['missing_case_id'] as Map<String, dynamic>) : MissingCaseId(),
          );
        } catch (e) {
          print("Error mapping data item: $e");
          throw e;
        }
      }).toList();

      return missingPeople;
    } else {
      print('Failed to fetch missing people. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch missing people');
    }
  } catch (e) {
    print("Exception caught in fetchMissingPeople: $e");
    throw e;
  }
}
