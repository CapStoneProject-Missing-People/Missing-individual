import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:missingpersonapp/common/widget/image_display.dart';
import 'package:missingpersonapp/features/matchedCase/screens/imageMatch/match_display.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';

class MissingPersonImageMatch extends StatefulWidget {
  const MissingPersonImageMatch({super.key});

  @override
  State<MissingPersonImageMatch> createState() => _MissingPersonImageMatchState();
}

class _MissingPersonImageMatchState extends State<MissingPersonImageMatch> with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  late AnimationController _animationController;
  double _horizontalDragOffset = 0.0;
  double _targetHorizontalOffset = 0.0;
  double _scale = 1.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _horizontalDragOffset = _animationController.value * _targetHorizontalOffset;
          _scale = 1.0;
        });
      });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _isAnimating = true;
      } else if (status == AnimationStatus.completed) {
        _isAnimating = false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void _handleHorizontalSwipe(bool isRight) {
    if (_isAnimating) return;
    final newIndex = isRight ? _currentIndex.value + 1 : _currentIndex.value - 1;
    final provider = Provider.of<MatchedCaseProvider>(context, listen: false);
    if (newIndex < 0 || newIndex >= provider.matchedCases.length) {
      HapticFeedback.lightImpact();
      _resetCardPosition();
      return;
    }
    _currentIndex.value = newIndex;
    _resetCardPosition();
  }

  void _resetCardPosition() {
    _targetHorizontalOffset = 0.0;
    _scale = 1.0;
    _animationController.forward(from: 0.0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _horizontalDragOffset += details.delta.dx;
      _horizontalDragOffset = _horizontalDragOffset.clamp(-200.0, 200.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    
    final velocity = details.velocity;
    const swipeThreshold = 120.0;
    const fastSwipeThreshold = 800.0;
    
    if (velocity.pixelsPerSecond.dx > fastSwipeThreshold) {
      _targetHorizontalOffset = MediaQuery.of(context).size.width;
      _animationController.forward(from: 0.0).then((_) => _handleHorizontalSwipe(true));
    } else if (velocity.pixelsPerSecond.dx < -fastSwipeThreshold) {
      _targetHorizontalOffset = -MediaQuery.of(context).size.width;
      _animationController.forward(from: 0.0).then((_) => _handleHorizontalSwipe(false));
    } else if (_horizontalDragOffset > swipeThreshold) {
      _targetHorizontalOffset = MediaQuery.of(context).size.width;
      _animationController.forward(from: 0.0).then((_) => _handleHorizontalSwipe(true));
    } else if (_horizontalDragOffset < -swipeThreshold) {
      _targetHorizontalOffset = -MediaQuery.of(context).size.width;
      _animationController.forward(from: 0.0).then((_) => _handleHorizontalSwipe(false));
    } else {
      _resetCardPosition();
    }
  }

  Widget _buildCardStack(MatchedCaseProvider matchedCaseProvider) {
    final cardCount = min(3, matchedCaseProvider.matchedCases.length - _currentIndex.value);
    final isSingleCard = matchedCaseProvider.matchedCases.length == 1;

    return SizedBox(
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: List.generate(cardCount, (stackIndex) {
          final index = _currentIndex.value + stackIndex;
          final person = matchedCaseProvider.matchedCases[index];
          
          return Positioned(
            top: stackIndex * 10.0,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(stackIndex == 0 ? _horizontalDragOffset / 1000 : stackIndex * 0.03)
                ..scale(stackIndex == 0 ? _scale : 1.0 - (stackIndex * 0.1)),
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: stackIndex == 0 
                  ? _buildTopCard(person, isSingleCard)
                  : _buildBackgroundCard(person, stackIndex),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopCard(dynamic person, bool isSingleCard) {
    return GestureDetector(
      onPanUpdate: isSingleCard ? null : _onPanUpdate,
      onPanEnd: isSingleCard ? null : _onPanEnd,
      onTap: () => _showDetailsBottomSheet(person),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade800.withOpacity(0.7),
                Colors.grey.shade900.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageDisplay(
                  imageBytes: person.imageBuffers[0],
                  fit: BoxFit.cover,
                  height: 140,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ID: ${person.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(person.status).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(person.status),
                      style: TextStyle(
                        color: _getStatusColor(person.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Matches: ${person.matches.length}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundCard(dynamic person, int stackIndex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.05),
      child: Container(
        width: double.infinity,
        height: 280 - (stackIndex * 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageDisplay(
                imageBytes: person.imageBuffers[0],
                fit: BoxFit.cover,
                height: 140 - (stackIndex * 15),
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'found':
        return Colors.green;
      case 'missing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Potential';
      case 'found':
        return 'Found';
      case 'missing':
        return 'Missing';
      default:
        return status;
    }
  }

  void _showDetailsBottomSheet(dynamic person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      'Match Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MatchesDisplay(
                      matches: person.matches,
                      personImage: person.imageBuffers,
                      id: person.id,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder(
            future: Provider.of<MatchedCaseProvider>(context, listen: false).fetchMatchedCases(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                );
              } else {
                return Consumer<MatchedCaseProvider>(
                  builder: (context, matchedCaseProvider, child) {
                    if (matchedCaseProvider.matchedCases.isEmpty) {
                      return Center(
                        child: Text(
                          'No matched cases found.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildCardStack(matchedCaseProvider),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: ValueListenableBuilder<int>(
                            valueListenable: _currentIndex,
                            builder: (context, currentIndex, child) {
                              return Column(
                                children: [
                                  LinearProgressIndicator(
                                    value: (currentIndex + 1) / matchedCaseProvider.matchedCases.length,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    color: Colors.blue,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${currentIndex + 1} of ${matchedCaseProvider.matchedCases.length}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}