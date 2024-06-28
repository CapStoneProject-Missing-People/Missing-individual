import 'dart:io';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/home/provider/check_face_provider.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/home/screens/match_detail.dart';

class CheckFace extends StatelessWidget {
  final String imagePath;

  const CheckFace({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckFaceProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Check Face Recognition'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Consumer<CheckFaceProvider>(
                builder: (context, provider, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          provider.setLoading(true);
                          final String? result =
                              await provider.sendImageToAPI(imagePath);
                          provider.setLoading(false);
                          if (result != null) {
                            provider.handleApiResponse(result);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[200],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Search Me', style: TextStyle(color: Colors.white),),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(File(imagePath), fit: BoxFit.cover),
                        ),
                      ),
                     
                      
                      if (provider.loading) const CircularProgressIndicator(),
                      if (provider.apiResult != null)
                        
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                               TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonDetailsScreen(
                                  personId: provider.personId!),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Click to See Missing Person...', style: TextStyle(color: Colors.blue),),
                      ),
                      const SizedBox(height: 40),
                              Text(
                                provider.apiResult!,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              if (provider.personId != null)
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () => provider.shareLocation(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                        
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Share Location Your location',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (provider.shareLocationValue != null)
                                              const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                                size: 26,
                                                shadows: [BoxShadow(color: Colors.blue, blurRadius: 10),],
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: provider.contactController,
                                      decoration: InputDecoration(
                                        labelText: 'Contact Information',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              const BorderSide(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.updateMatch(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        backgroundColor: Colors.blue[300],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Add Information', style: TextStyle(color: Colors.white),),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
