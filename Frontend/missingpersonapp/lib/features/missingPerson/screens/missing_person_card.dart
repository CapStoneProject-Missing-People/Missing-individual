import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/missingPerson/models/missing_person_model.dart';
import 'package:missingpersonapp/features/missingPerson/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/missingPerson/screens/missing_person_detail.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';

// AutoScrollText widget for smooth, infinite horizontal scrolling
class AutoScrollText extends StatefulWidget {
  final List<TextSpan> textSpans;
  final TextStyle style;
  final double scrollSpeed; // Pixels per second

  const AutoScrollText({
    super.key,
    required this.textSpans,
    required this.style,
    this.scrollSpeed = 50.0, // Default scroll speed
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
    if (_controller.hasClients && _controller.position.maxScrollExtent > 0) {
      setState(() => _needsScrolling = true);
    }
  }

  void _startAutoScrolling() {
    if (!_needsScrolling) return;

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_controller.hasClients) return;
      if (_controller.position.pixels >= _controller.position.maxScrollExtent) {
        _controller.jumpTo(0);
      } else {
        _controller.position.moveTo(
          _controller.position.pixels + (widget.scrollSpeed * 0.016),
          duration: const Duration(milliseconds: 16),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void didUpdateWidget(AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScrolling();
      _startAutoScrolling();
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
      height: widget.style.fontSize! * 1.2,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: RichText(
            text: TextSpan(
              children: widget.textSpans,
              style: widget.style,
            ),
          ),
        ),
      ),
    );
  }
}

// GlassmorphismButton widget for consistent button styling
class GlassmorphismButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GlassmorphismButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: child,
    );
  }
}

class MissingPersonCard extends StatelessWidget {
  final MissingPersonSpecific missingPerson;
  final String searchText; // For search term highlighting
  final Map<String, dynamic>? filters; // For filter support

  const MissingPersonCard({
    super.key,
    required this.missingPerson,
    this.searchText = '',
    this.filters,
  });

  // Highlight text with search term
  List<TextSpan> _highlightOccurrences(String source, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: source, style: const TextStyle(color: Colors.white))];
    }

    final matches = <Match>[];
    for (int i = 0; i <= source.length - query.length; i++) {
      if (source.substring(i, i + query.length).toLowerCase() == query.toLowerCase()) {
        matches.add(Match(i, i + query.length));
      }
    }

    if (matches.isEmpty) {
      return [TextSpan(text: source, style: const TextStyle(color: Colors.white))];
    }

    final List<TextSpan> spans = [];
    int start = 0;

    for (var match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: source.substring(start, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }
      spans.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = match.end;
    }

    if (start < source.length) {
      spans.add(TextSpan(
        text: source.substring(start),
        style: const TextStyle(color: Colors.white),
      ));
    }

    return spans;
  }

  Future<void> _shareMissingPerson(BuildContext context) async {
    final String shareContent = '''
Missing Person Details:
First Name: ${missingPerson.name.firstName}
Last Name: ${missingPerson.name.lastName}
Age: ${missingPerson.age}
Last Seen Location: ${missingPerson.lastSeenLocation}
Status: ${missingPerson.missingCase.status}
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
    final name = '${missingPerson.name.firstName} ${missingPerson.name.lastName}';
    final highlightedName = _highlightOccurrences(name, searchText);
    final highlightedLocation = _highlightOccurrences(missingPerson.lastSeenLocation, searchText);
    final highlightedStatus = _highlightOccurrences(missingPerson.missingCase.status, searchText);
    final highlightedAge = _highlightOccurrences(missingPerson.age.toString(), searchText);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: 300,
      ),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.grey.shade800],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MissingPersonDetails(missingPerson: missingPerson),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Section with Gradient Overlay
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: missingPerson.photos.isNotEmpty
                            ? Image.memory(
                                missingPerson.photos.first,
                                fit: BoxFit.cover,
                                height: 180,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey.shade800,
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Colors.white70,
                                      size: 80,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade800,
                                child: const Center(
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Colors.white70,
                                    size: 80,
                                  ),
                                ),
                              ),
                      ),
                      // Gradient Overlay
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Share Button
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GlassmorphismButton(
                          onPressed: () => _shareMissingPerson(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details Section
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name with auto-scroll
                        Flexible(
                          child: AutoScrollText(
                            textSpans: highlightedName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            scrollSpeed: 50.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Age
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AutoScrollText(
                                textSpans: highlightedAge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                scrollSpeed: 50.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Last Seen Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AutoScrollText(
                                textSpans: highlightedLocation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                scrollSpeed: 50.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Status
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AutoScrollText(
                                textSpans: highlightedStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                scrollSpeed: 50.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Delete Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: GlassmorphismButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                  content: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 24,
                                                  semanticLabel: 'Delete',
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Text(
                                                    'Confirm Delete',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    semanticsLabel: 'Confirm Delete',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Are you sure you want to delete this post?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,
                                                    ),
                                                    semanticsLabel: 'Cancel',
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    minimumSize: const Size(48, 48),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                GlassmorphismButton(
                                                  onPressed: () async {
                                                    try {
                                                      await Provider.of<MissingPersonProvider>(
                                                              context,
                                                              listen: false)
                                                          .removeMissingPerson(
                                                              missingPerson, context);
                                                      Navigator.of(context).pop();
                                                    } catch (error) {
                                                      print(
                                                          'Failed to delete the missing person: $error');
                                                      showToast(
                                                          context, error.toString(), Colors.red);
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    semanticsLabel: 'Delete',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Match {
  final int start;
  final int end;

  Match(this.start, this.end);
}