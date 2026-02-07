import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const GoatGuruApp());
}

/* ================= THEME & APP CONFIG ================= */

class GoatGuruApp extends StatelessWidget {
  const GoatGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoatGuru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F9F6), // Very light green-white
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF66BB6A),
          surface: Colors.white, // Replaces deprecated 'background'
          // 'surface' now handles background roles in Material 3
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

/* ================= MAIN NAVIGATION ================= */

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ScanPage(),
    const DiseasesPage(),
    const AboutPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE8F5E9),
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF2E7D32)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_rounded),
              selectedIcon:
                  Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2E7D32)),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon:
                  Icon(Icons.medical_services_rounded, color: Color(0xFF2E7D32)),
              label: 'Diseases',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline_rounded),
              selectedIcon: Icon(Icons.info_rounded, color: Color(0xFF2E7D32)),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= 1. HOME PAGE ================= */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Breeder!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'GoatGuru',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green.withValues(alpha: 0.2),
                              blurRadius: 10)
                        ]),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: Color(0xFF2E7D32)),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // How to Use Section
              Text(
                'How to Use',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 5))
                    ]),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InstructionStep(
                        icon: Icons.camera_alt_outlined, label: '1. Tap Scan'),
                    _InstructionStep(
                        icon: Icons.center_focus_weak_rounded, label: '2. Focus'),
                    _InstructionStep(
                        icon: Icons.analytics_outlined, label: '3. Analyse'),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Common Diseases Header
              Text(
                'Monitor These Diseases',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Dynamic Asset Cards (400x300 representation)
              const _DiseaseAssetCard(
                imagePath: 'assets/foot_rot.png',
                title: 'Foot Rot',
                subtitle: 'Hoof Infection',
              ),
              const _DiseaseAssetCard(
                imagePath: 'assets/mastitis.png',
                title: 'Mastitis',
                subtitle: 'Udder Inflammation',
              ),
              const _DiseaseAssetCard(
                imagePath: 'assets/pink_eye.png',
                title: 'Pink Eye',
                subtitle: 'Ocular Infection',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InstructionStep({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class _DiseaseAssetCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const _DiseaseAssetCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey)),
                ),
              ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7)
                  ],
                ),
              ),
            ),
          ),
          // Text Info
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style:
                      GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/* ================= 2. BOMBASTIC SCAN PAGE ================= */

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();
  Interpreter? _interpreter;

  // Animation Controllers
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  bool _isAnalyzing = false;
  bool _showResult = false;
  String _resultLabel = "";
  double _confidence = 0.0;

  final List<String> _labels = ['Foot Rot', 'Healthy', 'Mastitis', 'Pink Eye'];

  @override
  void initState() {
    super.initState();
    _loadModel();

    // Setup Laser Scanner Animation
    _scannerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scannerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/best_float32.tflite');
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _showResult = false;
        _isAnalyzing = true;
      });

      // Start "Bombastic" Scanning Effect
      _scannerController.repeat(reverse: true);

      // Artificial delay to show off the animation (2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      await _runInference();
    }
  }

  Future<void> _runInference() async {
    if (_interpreter == null || _image == null) return;

    try {
      // Image Processing Logic
      var imageBytes = _image!.readAsBytesSync();
      var imgOriginal = img.decodeImage(imageBytes);
      var imgResized = img.copyResize(imgOriginal!, width: 224, height: 224);

      var input = Float32List(1 * 224 * 224 * 3);
      int pixelIndex = 0;
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          var pixel = imgResized.getPixel(x, y);
          input[pixelIndex++] = pixel.r / 255.0;
          input[pixelIndex++] = pixel.g / 255.0;
          input[pixelIndex++] = pixel.b / 255.0;
        }
      }

      var output = Float32List(1 * 4).reshape([1, 4]);
      var inputBuffer = input.reshape([1, 224, 224, 3]);
      _interpreter!.run(inputBuffer, output);

      var result = output[0] as List<double>;
      double maxScore = -1;
      int maxIndex = -1;
      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxScore) {
          maxScore = result[i];
          maxIndex = i;
        }
      }

      // Stop Animation and Show Result
      _scannerController.stop();
      _scannerController.reset();

      setState(() {
        _resultLabel = _labels[maxIndex];
        _confidence = maxScore;
        _isAnalyzing = false;
        _showResult = true;
      });
    } catch (e) {
      _scannerController.stop();
      setState(() {
        _isAnalyzing = false;
      });
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _scannerController.dispose();
    super.dispose();
  }

  void _resetScan() {
    setState(() {
      _showResult = false;
      _image = null;
      _resultLabel = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background makes the image pop
      body: Stack(
        fit: StackFit.expand,
        children: [
          /* --- LAYER 1: IMAGE DISPLAY --- */
          _buildImageLayer(),

          /* --- LAYER 2: SCANNING LASER EFFECT --- */
          if (_isAnalyzing)
            AnimatedBuilder(
              animation: _scannerAnimation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height *
                      0.8 *
                      _scannerAnimation.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 5,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.greenAccent,
                            blurRadius: 20,
                            spreadRadius: 2)
                      ],
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.greenAccent,
                        Colors.transparent
                      ]),
                    ),
                  ),
                );
              },
            ),

          /* --- LAYER 3: RESULT SHEET (SLIDE UP) --- */
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            bottom: _showResult ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height:
                MediaQuery.of(context).size.height * 0.65, // Takes up 65% of screen
            child: _BombasticResultSheet(
              label: _resultLabel,
              confidence: _confidence,
              onClose: _resetScan,
            ),
          ),

          /* --- LAYER 4: BOMBASTIC FLOATING MENU --- */
          // Only show menu if we are NOT analyzing and NOT showing results
          if (!_isAnalyzing && !_showResult)
            Positioned(
              bottom: 30,
              right: 0,
              left: 0,
              child: Center(
                child: _BombasticMenu(
                  onCameraTap: () => _pickImage(ImageSource.camera),
                  onGalleryTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ),

          /* --- LAYER 5: BACK BUTTON (If Result is Open) --- */
          if (_showResult)
            Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _resetScan,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageLayer() {
    if (_image == null) {
      return Container(
        color: const Color(0xFFF5F9F6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/mascot_300x300.png', width: 150),
            const SizedBox(height: 20),
            Text(
              "Ready to Scan?",
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32)),
            ),
            Text(
              "Use the button below to start",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return Image.file(
      _image!,
      fit: BoxFit.cover,
    );
  }
}

/* ================= FIXED WIDGET: BOMBASTIC FLOATING MENU ================= */

class _BombasticMenu extends StatefulWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _BombasticMenu({required this.onCameraTap, required this.onGalleryTap});

  @override
  State<_BombasticMenu> createState() => _BombasticMenuState();
}

class _BombasticMenuState extends State<_BombasticMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation; // For movement (Bounce allowed)
  late Animation<double> _fadeAnimation;   // For opacity (Strictly 0.0 - 1.0)
  late Animation<double> _rotateAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    
    // 1. Elastic Curve for Movement (Bouncing)
    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
        
    // 2. Safe Curve for Opacity (No bouncing > 1.0)
    _fadeAnimation = 
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Camera Button (Left)
          _buildOptionBtn(
              angle: -0.8,
              icon: Icons.camera_alt,
              label: "Camera",
              color: Colors.blueAccent,
              onTap: widget.onCameraTap),
          // Gallery Button (Right)
          _buildOptionBtn(
              angle: 0.8,
              icon: Icons.photo_library,
              label: "Gallery",
              color: Colors.purpleAccent,
              onTap: widget.onGalleryTap),

          // Main Toggle Button
          GestureDetector(
            onTap: _toggleMenu,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 4)
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(
      {required double angle,
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    final double rad = 100.0; // Radius of expansion
    
    // Use AnimatedBuilder to listen to the controller updates
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double x = _expandAnimation.value *
            rad *
            -1 *
            (angle < 0 ? 1 : -1); 
        final double y = _expandAnimation.value * rad * -1; 

        return Transform.translate(
          offset: Offset(x, y * 0.6), 
          child: Opacity(
            // FIX: Use _fadeAnimation instead of _expandAnimation for opacity
            opacity: _fadeAnimation.value, 
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10)
                      ],
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 
/* ================= WIDGET: REDESIGNED RESULT SHEET ================= */

class _BombasticResultSheet extends StatelessWidget {
  final String label;
  final double confidence;
  final VoidCallback onClose;

  const _BombasticResultSheet({
    required this.label,
    required this.confidence,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    bool isHealthy = label == 'Healthy';
    Color statusColor = isHealthy ? const Color(0xFF2E7D32) : Colors.redAccent;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 30, spreadRadius: 5)
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 15, bottom: 20),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),

          // Main Content Scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Row (Status + Confidence Ring)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Diagnosis",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey, fontSize: 14)),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: confidence,
                              backgroundColor: Colors.grey[100],
                              color: statusColor,
                              strokeWidth: 8,
                            ),
                          ),
                          Text(
                            "${(confidence * 100).toInt()}%",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),

                  // 2. Action Plan Section
                  Text("Treatment Plan",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  ..._getSuggestions(label)
                      .map((text) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.check,
                                      size: 14, color: statusColor),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(text,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.grey[800],
                                          height: 1.5)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 30),

                  // 3. Bottom CTA
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: Text("Done",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getSuggestions(String label) {
    switch (label) {
      case 'Foot Rot':
        return [
          "Isolate the infected goat immediately.",
          "Trim the hoof to remove necrotic tissue.",
          "Apply a zinc sulphate foot bath twice daily.",
          "Keep the goat in a dry environment.",
        ];
      case 'Mastitis':
        return [
          "Perform frequent milking to drain the udder.",
          "Apply warm compresses to reduce pain.",
          "Consult vet for intramammary antibiotics.",
          "Separate from nursing kids.",
        ];
      case 'Pink Eye':
        return [
          "Move goat to a shaded, dark area.",
          "Clean eye with saline solution.",
          "Apply antibiotic eye spray or ointment.",
          "Use a patch to protect from flies.",
        ];
      case 'Healthy':
        return [
          "No immediate action required.",
          "Continue regular monitoring.",
          "Maintain good hygiene and nutrition.",
        ];
      default:
        return ["Please consult a professional veterinarian."];
    }
  }
}

/* ================= 3. DISEASES PAGE ================= */

class DiseasesPage extends StatelessWidget {
  const DiseasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diseases = [
      {
        'name': 'Foot Rot',
        'desc':
            'A contagious bacterial infection of the hooves causing lameness and foul odour.',
        'image': 'assets/foot_rot.png',
      },
      {
        'name': 'Mastitis',
        'desc':
            'Inflammation of the mammary gland/udder usually caused by bacterial infection.',
        'image': 'assets/mastitis.png',
      },
      {
        'name': 'Pink Eye',
        'desc':
            'Infectious Keratoconjunctivitis causing redness, weeping eyes, and temporary blindness.',
        'image': 'assets/pink_eye.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Library',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.green.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    diseases[index]['image']!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child:
                          const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diseases[index]['name']!,
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        diseases[index]['desc']!,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700], height: 1.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

/* ================= 4. ABOUT PAGE ================= */

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[100]!, width: 3),
                    image: const DecorationImage(
                        image: AssetImage('assets/mascot_300x300.png'),
                        fit: BoxFit.contain)),
              ),
              const SizedBox(height: 20),
              Text('GoatGuru',
                  style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32))),
              Text('Version 1.0.0',
                  style: GoogleFonts.poppins(color: Colors.grey)),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20)
                  ],
                ),
                child: Column(
                  children: [
                    Text('Created by',
                        style: GoogleFonts.poppins(
                            color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 5),
                    Text('Aiman Zakuwan Ismail',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87)),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Powered By',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 15),

              const Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  _TechChip(label: 'YOLOv8', icon: Icons.radar),
                  _TechChip(label: 'CNN', icon: Icons.layers),
                  _TechChip(label: 'TensorFlow Lite', icon: Icons.bolt),
                  _TechChip(label: 'Flutter', icon: Icons.flutter_dash),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TechChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withValues(alpha: 0.05), blurRadius: 5)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32))),
        ],
      ),
    );
  }
}