import 'package:flutter/material.dart';

class AnimatedMedicalIcons extends StatefulWidget {
  const AnimatedMedicalIcons({Key? key}) : super(key: key);

  @override
  State<AnimatedMedicalIcons> createState() => _AnimatedMedicalIconsState();
}

class _AnimatedMedicalIconsState extends State<AnimatedMedicalIcons>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Animation<Offset>> _slideAnimations;

  final List<IconData> _medicalIcons = [
    Icons.medical_services_rounded,
    Icons.health_and_safety_rounded,
    Icons.local_hospital_rounded,
    Icons.medication_rounded,
    Icons.monitor_heart_rounded,
    Icons.psychology_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _medicalIcons.length,
          (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 150));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top left
        Positioned(
          top: 100,
          left: 50,
          child: _buildAnimatedIcon(0, 30),
        ),
        // Top right
        Positioned(
          top: 150,
          right: 80,
          child: _buildAnimatedIcon(1, 25),
        ),
        // Middle left
        Positioned(
          top: 300,
          left: 30,
          child: _buildAnimatedIcon(2, 35),
        ),
        // Middle right
        Positioned(
          top: 350,
          right: 60,
          child: _buildAnimatedIcon(3, 28),
        ),
        // Bottom left
        Positioned(
          bottom: 200,
          left: 70,
          child: _buildAnimatedIcon(4, 32),
        ),
        // Bottom right
        Positioned(
          bottom: 250,
          right: 40,
          child: _buildAnimatedIcon(5, 26),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon(int index, double size) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimations[index],
          child: FadeTransition(
            opacity: _animations[index],
            child: Transform.scale(
              scale: _animations[index].value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _medicalIcons[index],
                  size: size,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
