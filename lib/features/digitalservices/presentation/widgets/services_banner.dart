import 'package:flutter/material.dart';

class ServicesBanner extends StatelessWidget {
  const ServicesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0D3B66), Color(0xFF2D74B3)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              left: -15,
              bottom: -15,
              child: Icon(Icons.stars_rounded, size: 110, color: Colors.white.withOpacity(0.12)),
            ),
            const Padding(
              padding: EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "تفعيل فوري للاشتراكات",
                    style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "أدوات الذكاء الاصطناعي والتصميم في مكان واحد",
                    style: TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); ;
  }
}