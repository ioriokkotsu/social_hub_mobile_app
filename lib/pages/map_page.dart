import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F0E6), 
      body: Stack(
        children: [
          
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPatternPainter(),
            ),
          ),

          
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.25,
            child: _buildMapPin('Tech Ed.', AppColors.primary),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            right: MediaQuery.of(context).size.width * 0.20,
            child: _buildMapPin('Clean Wells', AppColors.accent),
          ),

          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.0)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Explore Map',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: softShadow,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Filter by SDG or Location',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: softShadow,
                        ),
                        child: const Icon(Icons.tune, color: AppColors.primary),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            boxShadow: softShadow,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
        ),
        const SizedBox(height: 4),
        Icon(Icons.location_on, size: 40, color: color),
      ],
    );
  }
}


class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    const double radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}