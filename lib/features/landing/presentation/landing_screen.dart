import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const cream = Color(0xFFFAF6F0);
  static const cream2 = Color(0xFFF5EFE6);
  static const roseDark = Color(0xFFC97A95);
  static const roseMid = Color(0xFFD4869C);
  static const pink = Color(0xFFF2D0DC);
  static const sage = Color(0xFF8AA898);
  static const sageDark = Color(0xFF5F7A6B);
  static const sageLight = Color(0xFFD8E8E0);
  static const beige = Color(0xFFE8DDD0);
  static const charcoal = Color(0xFF2C2118);
  static const charcoalMid = Color(0xFF4A3F35);
  static const muted = Color(0xFF7A6E65);

  void _go(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Widget _imageCard({
    required String image,
    required Widget child,
    required double height,
    double radius = 24,
  }) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Container(color: const Color.fromRGBO(30, 18, 10, 0.38)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String label, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: sage,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, height: 20 / 13, color: muted),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required String image,
    required String tag,
    required String title,
    required String description,
    required double height,
    Color tagColor = roseDark,
    double radius = 24,
    double titleSize = 16,
    double descriptionSize = 12,
    EdgeInsets contentPadding = const EdgeInsets.all(16),
  }) {
    return _imageCard(
      image: image,
      height: height,
      radius: radius,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleSize,
                  height: 21 / 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: descriptionSize,
                  height: 17 / 12,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    String text,
    String route, {
    bool primary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _go(context, route),
        style: ElevatedButton.styleFrom(
          elevation: primary ? 4 : 0,
          shadowColor: primary ? roseDark : Colors.transparent,
          backgroundColor: primary ? roseDark : Colors.white,
          foregroundColor: primary ? Colors.white : charcoalMid,
          padding: EdgeInsets.symmetric(vertical: primary ? 16 : 15),
          shape: const StadiumBorder(),
          side: primary ? null : const BorderSide(color: beige, width: 1.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: primary ? 15 : 14,
            fontWeight: primary ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: cream,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: cream,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: pink,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '🌸',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Mom Ơi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: charcoal,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () => _go(context, '/login'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: roseDark,
                        side: const BorderSide(color: roseDark, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          children: [
                            _imageCard(
                              image: 'assets/images/hero_mom.jpg',
                              height: 400,
                              radius: 28,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 16,
                                    bottom: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    '💛  Đồng hành cùng mẹ mỗi ngày',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: charcoalMid,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 24, 4, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ĐỒNG HÀNH CÙNG MẸ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                      color: roseDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Chăm mẹ khỏe,\nChăm bé vui.',
                                    style: TextStyle(
                                      fontSize: 34,
                                      height: 42 / 34,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                      color: charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Một nơi nhẹ nhàng để mẹ theo dõi thai kỳ, chăm sóc bé và tìm những thông tin hữu ích mỗi ngày.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 22 / 14,
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _button(
                                    context,
                                    'Bắt đầu cùng Mom Ơi',
                                    '/register',
                                  ),
                                  const SizedBox(height: 12),
                                  _button(
                                    context,
                                    'Đăng nhập',
                                    '/login',
                                    primary: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _sectionHeading(
                        'TÍNH NĂNG',
                        'Khám phá Mom Ơi',
                        'Mọi thứ mẹ cần, trong một ứng dụng',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _featureCard(
                          image: 'assets/images/pregnancy.jpg',
                          tag: 'Thai kỳ',
                          title: 'Theo dõi hành trình thai kỳ',
                          description: 'Ghi lại từng tuần, cân nặng, siêu âm và cột mốc đặc biệt',
                          height: 240,
                          radius: 20,
                          titleSize: 15,
                          descriptionSize: 11,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _featureCard(
                                image: 'assets/images/baby.jpg',
                                tag: 'Bé yêu',
                                title: 'Cột mốc của bé',
                                description: 'Ghi nhớ mọi khoảnh khắc',
                                height: 220,
                                radius: 20,
                                tagColor: roseMid,
                                titleSize: 14,
                                descriptionSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _featureCard(
                                image: 'assets/images/health.jpg',
                                tag: 'Sức khỏe',
                                title: 'Dinh dưỡng & Wellness',
                                description: 'Lời khuyên từ chuyên gia',
                                height: 220,
                                radius: 20,
                                tagColor: sageDark,
                                titleSize: 14,
                                descriptionSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: sageLight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '💬',
                                style: TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'TRỢ LÝ MOM ƠI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: sageDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hỏi mọi điều\nbạn muốn biết',
                              style: TextStyle(
                                fontSize: 22,
                                height: 28 / 22,
                                fontWeight: FontWeight.w800,
                                color: charcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Từ triệu chứng thai kỳ, dinh dưỡng, đến cách chăm sóc bé – Mom Ơi luôn sẵn sàng giải đáp.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 20 / 13,
                                color: charcoalMid,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  [
                                        'Triệu chứng thai kỳ',
                                        'Dinh dưỡng cho mẹ',
                                        'Chăm sóc sơ sinh',
                                      ]
                                      .map(
                                        (text) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(999),
                                            ),
                                          ),
                                          child: Text(
                                            text,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: sageDark,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeading(
                              'LIFESTYLE',
                              'Mỗi ngày cùng Mom Ơi',
                              'Đồng hành từ những buổi sáng bình yên đến khoảnh khắc ngọt ngào nhất',
                            ),
                            _imageCard(
                              image: 'assets/images/mom_baby.jpg',
                              height: 280,
                              child: const Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    '“Mỗi ngày của mẹ đều quan trọng.\nMỗi khoảnh khắc bên bé đều quý giá.”',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 23 / 15,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _trust('3', 'Giai đoạn làm mẹ'),
                            Container(width: 1, height: 36, color: beige),
                            _trust('WHO', 'Chuẩn tăng trưởng của bé'),
                            Container(width: 1, height: 36, color: beige),
                            _trust('EPDS', 'Sàng lọc tâm lý sau sinh'),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: cream2,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: beige),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '🌸 MOM ƠI',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: roseDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Sẵn sàng bắt đầu hành trình cùng bé yêu?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                height: 30 / 22,
                                fontWeight: FontWeight.w800,
                                color: charcoal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tham gia cùng hàng nghìn bà mẹ đang sử dụng Mom Ơi để theo dõi thai kỳ và chăm sóc bé.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 20 / 13,
                                color: muted,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _button(
                              context,
                              'Bắt đầu cùng Mom Ơi',
                              '/register',
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () => _go(context, '/login'),
                              child: const Text(
                                'Đã có tài khoản? Đăng nhập',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: roseDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        color: charcoal,
                        child: const Text(
                          'Mom Ơi · Chăm mẹ khỏe, chăm bé vui 🌸',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 0.55),
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
    );
  }

  Widget _trust(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: roseDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}
