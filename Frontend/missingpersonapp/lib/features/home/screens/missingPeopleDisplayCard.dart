import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AutoScrollText extends StatefulWidget {
  final List<TextSpan> textSpans;
  final TextStyle style;

  const AutoScrollText({
    super.key,
    required this.textSpans,
    required this.style,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  final ScrollController _controller = ScrollController();
  Timer? _scrollTimer;
  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScrolling();
      _startAutoScrolling();
    });
  }

  void _checkIfNeedsScrolling() {
    if (_controller.position.maxScrollExtent > 0) {
      setState(() => _needsScrolling = true);
    }
  }

  void _startAutoScrolling() {
    if (!_needsScrolling) return;

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent) {
        _controller.jumpTo(0);
      } else {
        _controller.position.moveTo(
          _controller.position.pixels + 1,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.style.fontSize! * 1.2, // Approximate text height
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: RichText(
          text: TextSpan(
            children: widget.textSpans,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}

class MissingPeopleDisplay extends StatelessWidget {
  final MissingPerson missingPerson;
  final List<TextSpan> highlightedName;
  final List<TextSpan> highlightedSkinColor;
  final List<TextSpan> highlightedAge;

  const MissingPeopleDisplay({
    super.key,
    required this.missingPerson,
    required this.highlightedName,
    required this.highlightedSkinColor,
    required this.highlightedAge,
  });

  Future<void> _shareMissingPerson(BuildContext context) async {
    final String shareContent = '''
Missing Person Details:
Name: ${missingPerson.name}
Age: ${missingPerson.age}
Skin Color: ${missingPerson.skin_color}
    ''';

    List<XFile> files = [];

    if (missingPerson.photos.isNotEmpty) {
      Uint8List imageBytes = missingPerson.photos.first;
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/missing_person.png').create();
      await file.writeAsBytes(imageBytes);
      files.add(XFile(file.path));
    }

    await Share.shareXFiles(files, text: shareContent);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.1), // Glassmorphism effect
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MissingPersonDetails(
                missingPerson: missingPerson,
                header: "Missing Person Details",
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Gradient Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: missingPerson.photos.isNotEmpty
                        ? Image.memory(
                            missingPerson.photos[0],
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.white70,
                                size: 60,
                              ),
                            ),
                          ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Share Button
                Positioned(
                  bottom: -5,
                  right: 0,
                  child: GlassmorphismButton(
                    onPressed: () => _shareMissingPerson(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with auto-scroll
                  AutoScrollText(
                    textSpans: highlightedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Age
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: highlightedAge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Skin Color
                  Row(
                    children: [
                      const Icon(
                        Icons.palette_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: highlightedSkinColor,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
