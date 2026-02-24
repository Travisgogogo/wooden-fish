import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const WoodenFishApp());
}

class WoodenFishApp extends StatelessWidget {
  const WoodenFishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '电子木鱼',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const WoodenFishPage(),
    );
  }
}

class WoodenFishPage extends StatefulWidget {
  const WoodenFishPage({super.key});

  @override
  State<WoodenFishPage> createState() => _WoodenFishPageState();
}

class _WoodenFishPageState extends State<WoodenFishPage>
    with SingleTickerProviderStateMixin {
  int merit = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadMerit();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadMerit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      merit = prefs.getInt('merit') ?? 0;
    });
  }

  Future<void> _saveMerit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('merit', merit);
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _tapWoodenFish() {
    _controller.forward().then((_) => _controller.reverse());
    setState(() {
      merit++;
    });
    _saveMerit();
    _vibrate();
  }

  void _resetMerit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置功德'),
        content: const Text('确定要清零累计的功德吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                merit = 0;
              });
              _saveMerit();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '电子木鱼',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _resetMerit,
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.orange.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '累计功德',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    merit.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _tapWoodenFish,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.brown.shade400,
                            Colors.brown.shade700,
                            Colors.brown.shade900,
                          ],
                          center: Alignment.topLeft,
                          radius: 1.2,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.shade900.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade800,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.brown.shade600,
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '佛',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '点击木鱼 积累功德',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '心静自然凉 · 功德自然来',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}