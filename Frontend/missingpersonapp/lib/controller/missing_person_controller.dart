class MissingPersonController {
  static Future<List<Map<String, dynamic>>> fetchUserData() async {
    // Simulate fetching user data from a backend server
    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
    return [
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": 'missing',
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      },
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": "missing",
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      },
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": "missing",
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      },
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": "found",
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      },
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": "missing",
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      },
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": "found",
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      },
      {
        "id": "4387687364873",
        "name": 'Johnny Doe',
        "status": "missing",
        "image": 'C:/Users/HP/Desktop/courses/CapStone/missingpersonapp/images/monkey.jpeg',
      }
    ];
  }

  
}
