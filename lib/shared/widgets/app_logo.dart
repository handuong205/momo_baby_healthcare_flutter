import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

/// Logo Mom Ơi trong khung tròn (cùng file ảnh với icon app, giống bản RN).
class AppLogo extends StatelessWidget {
  final double size;
  final double borderWidth;

  /// Ảnh gốc có nhiều lề trắng nên phóng to để phần hình nằm vừa khung.
  final double zoom;

  const AppLogo({
    super.key,
    this.size = 46,
    this.borderWidth = 2,
    this.zoom = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MomTheme.white,
        shape: BoxShape.circle,
        border: Border.all(color: MomTheme.pink, width: borderWidth),
      ),
      child: ClipOval(
        child: Transform.scale(
          scale: zoom,
          child: Image.asset(
            'assets/images/logo/icon.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Center(
              child: Text('🌸', style: TextStyle(fontSize: size * 0.48)),
            ),
          ),
        ),
      ),
    );
  }
}
