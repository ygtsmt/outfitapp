import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/core/services/wrapped_data_service.dart';
import 'package:comby/core/services/gemini_wrapper_service.dart';
import 'package:comby/app/features/wrapped/models/wrapped_result.dart';
import 'package:comby/app/features/wrapped/ui/widgets/wrapped_loading_screen.dart';

class StyleWrappedScreen extends StatefulWidget {
  final WrappedResult? existingResult;
  final Map<String, String>? existingImages;

  const StyleWrappedScreen({
    super.key,
    this.existingResult,
    this.existingImages,
  });

  @override
  State<StyleWrappedScreen> createState() => _StyleWrappedScreenState();
}

class _StyleWrappedScreenState extends State<StyleWrappedScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _tokensProcessed = 0;
  int _totalTokens = 1000000;
  String _rawResponse = '';
  WrappedResult? _result;
  Map<String, String> _itemImages = {}; // ID -> imageUrl mapping
  late ConfettiController _confettiController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _pageController = PageController();
    if (widget.existingResult != null) {
      _result = widget.existingResult;
      _itemImages = widget.existingImages ?? {};
      _isLoading = false;
      _tokensProcessed = 1000000;
    } else {
      _generateWrapped();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _generateWrapped() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Step 1: Collect data
      final dataService = GetIt.I<WrappedDataService>();
      final userData = await dataService.collectUserData();

      // Build image map from wardrobe items
      final wardrobe = userData['wardrobe'] as Map<String, dynamic>;
      final items = wardrobe['items'] as List;
      final imageMap = <String, String>{};
      for (final item in items) {
        final id = item['id'] as String?;
        final imageUrl = item['imageUrl'] as String?;
        if (id != null && imageUrl != null && imageUrl.isNotEmpty) {
          imageMap[id] = imageUrl;
        }
      }

      setState(() {
        _totalTokens = userData['estimatedTokens'] as int? ?? 1000000;
        _itemImages = imageMap;
      });

      // Step 2: Generate with Gemini
      final geminiService = GetIt.I<GeminiWrapperService>();
      final stream = geminiService.generateWrapped(userData);

      await for (final chunk in stream) {
        if (!mounted) return;
        setState(() {
          _rawResponse += chunk;
          // Progress simulation
          _tokensProcessed = (_tokensProcessed + 500).clamp(0, _totalTokens);
        });
      }

      // Step 3: Parse response
      final cleanJson = _extractJson(_rawResponse);
      final decodedJson = jsonDecode(cleanJson);
      final result = WrappedResult.fromJson(decodedJson);

      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
        _tokensProcessed = _totalTokens;
      });

      // Save result for history
      GetIt.I<WrappedDataService>()
          .saveWrappedResult(decodedJson, DateTime.now().year);
    } catch (e) {
      print('Error generating wrapped: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().contains('Null')
            ? 'A parsing error occurred. Please try again.'
            : e.toString();
      });
    }
  }

  String _extractJson(String response) {
    // Extract JSON from markdown code blocks if present
    final jsonMatch =
        RegExp(r'```json\s*(\{[\s\S]*\})\s*```').firstMatch(response);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!;
    }

    // Try to find JSON object directly
    final objectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (objectMatch != null) {
      return objectMatch.group(0)!;
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WrappedLoadingScreen(
        tokensProcessed: _tokensProcessed,
        totalTokens: _totalTokens,
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80.sp,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Analysis Interrupted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  ElevatedButton(
                    onPressed: () => context.router.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.w, vertical: 16.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Go Back',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => context.router.pop(),
                        ),
                        // Share Button
                        if (!_isLoading && !_hasError)
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: _shareWrapped,
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        if (index == 6) {
                          _confettiController.play();
                        }
                      },
                      children: [
                        _buildYearInNumbersCard(),
                        _buildStyleEvolutionCard(),
                        _buildTopPiecesCard(), // Changed from _buildPowerPiecesCard to match existing method
                        _buildColorStoryCard(),
                        _buildAIInsightsCard(),
                        _buildFuturePredictCard(),
                        _buildGeminiPoweredCard(),
                      ],
                    ),
                  ),

                  // Progress Indicator
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h, top: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        7,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 8.h,
                          width: _currentPage == index ? 24.w : 8.w,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti Widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareWrapped() {
    if (_result == null) return;
    final r = _result!;
    final text = '''
🎨 My Style Wrapped ${DateTime.now().year} by Comby!

📊 ${r.yearInNumbers.headline}
👗 ${r.yearInNumbers.totalItems} items, ${r.yearInNumbers.totalOutfits} outfits
🔥 Top Vibe: ${r.styleEvolution.title}
🌈 Color Personality: ${r.colorStory.colorPersonality}

Powered by Gemini 3 Flash via Comby App 
#StyleWrapped #CombyApp
''';
    Share.share(text);
  }

  Widget _buildYearInNumbersCard() {
    final data = _result?.yearInNumbers;
    if (data == null) return const SizedBox();

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B46C1), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'STYLE WRAPPED ${DateTime.now().year}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'Your Year in Numbers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              _buildStat('Items added to closet', data.totalItems.toString()),
              SizedBox(height: 16.h),
              _buildStat('Outfits generated', data.totalOutfits.toString()),
              SizedBox(height: 16.h),
              _buildStat('Daily streaks', data.daysActive.toString()),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  data.headline,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Swipe to explore',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14.sp,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.arrow_forward,
                      color: Colors.white60, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 56.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStyleEvolutionCard() {
    final data = _result?.styleEvolution;
    if (data == null) return const SizedBox();

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                data.description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.7,
                ),
              ),
              SizedBox(height: 40.h),
              ...data.keyMoments.map((moment) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.amberAccent, size: 20),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            moment,
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPiecesCard() {
    final pieces = _result?.topPowerPieces ?? [];
    if (pieces.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Text(
                'Your Power Pieces',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'The items that defined your year',
                style: TextStyle(color: Colors.white70, fontSize: 16.sp),
              ),
              SizedBox(height: 32.h),
              ...pieces.take(3).map((piece) {
                final imageUrl = _itemImages[piece.id];
                return Container(
                  margin: EdgeInsets.only(bottom: 24.h),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      // Show actual item image or emoji fallback
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 60.w,
                            height: 60.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              piece.icon,
                              style: TextStyle(fontSize: 40.sp),
                            ),
                          ),
                        )
                      else
                        Text(piece.icon, style: TextStyle(fontSize: 40.sp)),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              piece.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              piece.reason,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorStoryCard() {
    final data = _result?.colorStory;
    if (data == null) return const SizedBox();

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFF0F172A),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Color Story',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                height: 120.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data.hexCodes.map((hex) {
                    Color color;
                    try {
                      color = Color(int.parse(hex.replaceAll('#', '0xFF')));
                    } catch (_) {
                      color = Colors.grey;
                    }
                    return Container(
                      width: 60.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                data.colorPersonality,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              if (data.dominantColors.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: data.dominantColors
                      .map((color) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsightsCard() {
    final data = _result?.aiInsights;
    if (data == null) return const SizedBox();

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111827), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 80.sp, color: Colors.purpleAccent),
              SizedBox(height: 24.h),
              Text(
                data.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              ...data.discoveries.map((discovery) => Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.2)),
                    ),
                    child: Text(
                      discovery,
                      style: TextStyle(
                          color: Colors.white, fontSize: 16.sp, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturePredictCard() {
    final data = _result?.futurePredict;
    if (data == null) return const SizedBox();

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF831843), Color(0xFF9D174D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              ...data.predictions.map((p) => Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
              SizedBox(height: 40.h),
              // Button to next specific Gemini card
              IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.white70),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeminiPoweredCard() {
    final gemini = _result?.geminiPowered;
    if (gemini == null) return const SizedBox();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Background Tech Effect (Static for now, could be animated later)
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 80.sp, color: Colors.blueAccent),
                SizedBox(height: 24.h),
                Text(
                  'Powered by\n${gemini.model}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    '${gemini.contextWindow} Context Window',
                    style: TextStyle(
                      color: Colors.blueAccent.shade100,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Analyzed ${gemini.tokensProcessed} tokens\nof your fashion history.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60.h),
                // Final Great Button
                ElevatedButton(
                  onPressed: () => context.router.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding:
                        EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Great!',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.celebration, size: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const step = 40.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
