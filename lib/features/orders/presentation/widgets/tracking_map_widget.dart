import 'package:flutter/material.dart';

class TrackingMapWidget extends StatelessWidget {
  const TrackingMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      
      
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        
       image: const DecorationImage(
          image: AssetImage("assets/images/map_placeholder.png"),
          
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
        
     
          
        
      
        
    );
  }
}