import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/models/baby/baby_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/baby/baby_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/baby/camera_capture_screen.dart';
import 'package:momo_baby_healthcare_flutter/utils/who_data.dart';

const _allergies = [
  'Sữa bò',
  'Trứng',
  'Hải sản',
  'Đậu phộng',
  'Đậu nành',
  'Lúa mì (gluten)',
];

enum _PhotoAction { camera, gallery, delete }

class BabyScreen extends StatefulWidget {
  const BabyScreen({super.key});

  @override
  State<BabyScreen> createState() => _BabyScreenState();
}

class _BabyScreenState extends State<BabyScreen> {
  List<BabyProfile> _profiles = [];
  BabyProfile? _selected;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profiles = await BabyRepository.getProfiles();
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _selected = profiles.isEmpty
            ? null
            : profiles.firstWhere(
                (profile) => profile.id == _selected?.id,
                orElse: () => profiles.first,
              );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _openProfileForm([BabyProfile? profile]) async {
    final result = await Navigator.of(context).push<BabyProfile>(
      MaterialPageRoute(
        builder: (_) => BabyProfileFormScreen(profile: profile),
      ),
    );
    if (result != null && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bé yêu',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Chăm bé lớn khôn',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openProfileForm(),
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.primaryDark,
                          ),
                          tooltip: 'Thêm hồ sơ bé',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const _StateCard(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryDark,
                        ),
                      )
                    else if (_error != null)
                      _StateCard(
                        child: _ErrorContent(
                          message: _message(_error!),
                          onRetry: _load,
                        ),
                      )
                    else if (_profiles.isEmpty)
                      _EmptyBaby(onAdd: () => _openProfileForm())
                    else ...[
                      _BabyPicker(
                        profiles: _profiles,
                        selected: _selected!,
                        onChanged: (profile) =>
                            setState(() => _selected = profile),
                      ),
                      const SizedBox(height: 14),
                      _ProfileCard(
                        profile: _selected!,
                        onEdit: () => _openProfileForm(_selected),
                        onProfileChanged: (profile) => setState(() {
                          _profiles = _profiles
                              .map(
                                (item) =>
                                    item.id == profile.id ? profile : item,
                              )
                              .toList();
                          _selected = profile;
                        }),
                      ),
                      const SizedBox(height: 18),
                      _ActionGrid(
                        onGrowth: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GrowthScreen(profile: _selected!),
                          ),
                        ),
                        onDaily: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MenuScreen(profile: _selected!, weekly: false),
                          ),
                        ),
                        onWeekly: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MenuScreen(profile: _selected!, weekly: true),
                          ),
                        ),
                        onRecord: () => _showGrowthDialog(_selected!),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showGrowthDialog(BabyProfile profile) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => GrowthEntryDialog(profile: profile),
    );
    if (result == true && mounted) await _load();
  }

  String _message(Object error) =>
      error is ApiException ? error.message : 'Đã xảy ra lỗi không xác định.';
}

class BabyProfileFormScreen extends StatefulWidget {
  final BabyProfile? profile;
  const BabyProfileFormScreen({super.key, this.profile});

  @override
  State<BabyProfileFormScreen> createState() => _BabyProfileFormScreenState();
}

class _BabyProfileFormScreenState extends State<BabyProfileFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late DateTime? _dob;
  late String _gender;
  late List<String> _allergyValues;
  final _customAllergy = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _name = TextEditingController(text: profile?.babyName);
    _weight = TextEditingController(text: profile?.currentWeightKg?.toString());
    _height = TextEditingController(text: profile?.currentHeightCm?.toString());
    _dob = profile?.dateOfBirth;
    _gender = profile?.isBoy == false ? 'Female' : 'Male';
    _allergyValues = [...(profile?.allergies ?? const [])];
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _customAllergy.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final weight = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    final height = double.tryParse(_height.text.trim().replaceAll(',', '.'));
    if (name.isEmpty || _dob == null) {
      _show(
        'Thiếu thông tin',
        name.isEmpty
            ? 'Mẹ nhập tên hoặc tên ở nhà của bé nhé.'
            : 'Mẹ chọn ngày sinh của bé nhé.',
      );
      return;
    }
    if (_weight.text.trim().isNotEmpty &&
        (weight == null || weight < 1 || weight > 40)) {
      _show('Kiểm tra lại', 'Cân nặng của bé cần nằm trong khoảng 1 - 40 kg.');
      return;
    }
    if (_height.text.trim().isNotEmpty &&
        (height == null || height < 30 || height > 130)) {
      _show(
        'Kiểm tra lại',
        'Chiều cao của bé cần nằm trong khoảng 30 - 130 cm.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final profile = widget.profile == null
          ? await BabyRepository.createProfile(
              babyName: name,
              dateOfBirth: _dob!,
              gender: _gender,
              weightKg: weight,
              heightCm: height,
              allergies: _allergyValues,
            )
          : await BabyRepository.updateProfile(
              widget.profile!.id,
              babyName: name,
              dateOfBirth: _dob!,
              gender: _gender,
              weightKg: weight,
              heightCm: height,
              allergies: _allergyValues,
            );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.profile == null
                ? 'Đã tạo hồ sơ cho bé.'
                : 'Hồ sơ của bé đã được cập nhật.',
          ),
        ),
      );
      Navigator.of(context).pop(profile);
    } catch (error) {
      if (mounted)
        _show(
          'Chưa lưu được',
          error is ApiException
              ? error.message
              : 'Đã xảy ra lỗi không xác định.',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String title, String message) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final editing = widget.profile != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Sửa hồ sơ bé' : 'Thêm hồ sơ bé')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ngày sinh, cân nặng và dị ứng giúp Mom Ơi gợi ý thực đơn đúng độ tuổi của bé.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Tên bé',
              hintText: 'VD: Bơ, Na, Minh Anh',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Giới tính',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Male', label: Text('Bé trai')),
              ButtonSegment(value: 'Female', label: Text('Bé gái')),
            ],
            selected: {_gender},
            onSelectionChanged: (value) =>
                setState(() => _gender = value.first),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_dob == null ? 'Ngày sinh' : _formatDate(_dob!)),
            subtitle: const Text('Mẹ chọn ngày sinh của bé nhé.'),
            trailing: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryDark,
            ),
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: _dob ?? DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 6),
                lastDate: DateTime.now(),
              );
              if (value != null) setState(() => _dob = value);
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Cân nặng (kg)',
                    hintText: 'VD: 7.8',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Chiều cao (cm)',
                    hintText: 'VD: 68',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Dị ứng thực phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Text(
            'Thực đơn sẽ tránh các thực phẩm này',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies
                .map(
                  (item) => FilterChip(
                    label: Text(item),
                    selected: _allergyValues.contains(item),
                    onSelected: (selected) => setState(
                      () => selected
                          ? _allergyValues.add(item)
                          : _allergyValues.remove(item),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customAllergy,
                  decoration: const InputDecoration(
                    labelText: 'Dị ứng khác',
                    hintText: 'Nhập rồi bấm Thêm',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final value = _customAllergy.text.trim();
                  if (value.isNotEmpty && !_allergyValues.contains(value))
                    setState(() => _allergyValues.add(value));
                  _customAllergy.clear();
                },
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.white),
                  )
                : Text(editing ? 'Lưu thay đổi' : 'Tạo hồ sơ bé'),
          ),
        ],
      ),
    );
  }
}

class GrowthScreen extends StatefulWidget {
  final BabyProfile profile;
  const GrowthScreen({super.key, required this.profile});
  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  late BabyProfile _profile;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final profiles = await BabyRepository.getProfiles();
      final current = profiles.firstWhere((item) => item.id == _profile.id);
      if (mounted) setState(() => _profile = current);
    } catch (error) {
      if (mounted)
        _snack(
          error is ApiException ? error.message : 'Không thể tải dữ liệu.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(GrowthRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa mốc tăng trưởng?'),
        content: const Text('Mốc đo này sẽ được xóa khỏi hồ sơ của bé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await BabyRepository.deleteGrowth(_profile.id, record.id);
      if (mounted) {
        _snack('Xóa chỉ số tăng trưởng thành công.');
        await _refresh();
      }
    } catch (error) {
      if (mounted)
        _snack(error is ApiException ? error.message : 'Không thể xóa chỉ số.');
    }
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final records = [..._profile.growthRecords]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ tăng trưởng')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryDark,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading)
              const LinearProgressIndicator(color: AppColors.primaryDark),
            if (records.isEmpty)
              const _StateCard(
                child: Text(
                  'Chưa có mốc tăng trưởng. Hãy ghi nhận số đo đầu tiên của bé.',
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              _GrowthChart(
                metric: GrowthMetric.weight,
                profile: _profile,
                records: records,
              ),
              const SizedBox(height: 16),
              _GrowthChart(
                metric: GrowthMetric.height,
                profile: _profile,
                records: records,
              ),
              const SizedBox(height: 16),
              ...records.reversed.map(
                (record) => Card(
                  child: ListTile(
                    title: Text(
                      '${record.weightKg} kg · ${record.heightCm} cm',
                    ),
                    subtitle: Text(_formatDate(record.recordedAt.toLocal())),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.rose,
                      ),
                      onPressed: () => _delete(record),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final saved = await showDialog<bool>(
                  context: context,
                  builder: (_) => GrowthEntryDialog(profile: _profile),
                );
                if (saved == true && mounted) await _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('Ghi số đo mới'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthChart extends StatelessWidget {
  final GrowthMetric metric;
  final BabyProfile profile;
  final List<GrowthRecord> records;
  const _GrowthChart({
    required this.metric,
    required this.profile,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final table = whoTable(metric, profile.isBoy);
    final values = [
      ...table.map((row) => row.p3),
      ...table.map((row) => row.p97),
      ...records.map(
        (record) =>
            metric == GrowthMetric.weight ? record.weightKg : record.heightCm,
      ),
    ];
    final step = metric == GrowthMetric.weight ? 2.0 : 10.0;
    final minY = (values.reduce((a, b) => a < b ? a : b) / step).floor() * step;
    final maxY = (values.reduce((a, b) => a > b ? a : b) / step).ceil() * step;
    final spots = records
        .map(
          (record) => FlSpot(
            ageInMonths(profile.dateOfBirth, record.recordedAt).clamp(0, 24),
            metric == GrowthMetric.weight ? record.weightKg : record.heightCm,
          ),
        )
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric == GrowthMetric.weight
                  ? 'Cân nặng theo tuổi'
                  : 'Chiều cao theo tuổi',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 24,
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  betweenBarsData: [
                    BetweenBarsData(
                      fromIndex: 0,
                      toIndex: 1,
                      color: AppColors.secondaryLight,
                    ),
                  ],
                  lineBarsData: [
                    LineChartBarData(
                      spots: table
                          .map((row) => FlSpot(row.month, row.p3))
                          .toList(),
                      isCurved: false,
                      color: AppColors.secondaryLight,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: table
                          .map((row) => FlSpot(row.month, row.p97))
                          .toList(),
                      isCurved: false,
                      color: AppColors.secondaryLight,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: table
                          .map((row) => FlSpot(row.month, row.p50))
                          .toList(),
                      isCurved: false,
                      color: AppColors.secondaryDark,
                      barWidth: 2,
                      dashArray: [5, 4],
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: AppColors.primaryDark,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Chuẩn WHO (P3–P97) · Trung vị · Bé',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            Text(
              'Trục ngang: tháng tuổi · Trục dọc: ${metric == GrowthMetric.weight ? 'kg' : 'cm'}',
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

class GrowthEntryDialog extends StatefulWidget {
  final BabyProfile profile;
  const GrowthEntryDialog({super.key, required this.profile});
  @override
  State<GrowthEntryDialog> createState() => _GrowthEntryDialogState();
}

class _GrowthEntryDialogState extends State<GrowthEntryDialog> {
  late final TextEditingController _weight;
  late final TextEditingController _height;
  DateTime _date = DateTime.now();
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _weight = TextEditingController();
    _height = TextEditingController();
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    final height = double.tryParse(_height.text.replaceAll(',', '.'));
    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mẹ nhập cân nặng và chiều cao hợp lệ nhé.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final evaluation = await BabyRepository.logGrowth(
        widget.profile.id,
        weightKg: weight,
        heightCm: height,
        recordedAt: _date,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            evaluation.feedback.isEmpty
                ? 'Ghi nhận chỉ số tăng trưởng và đánh giá thành công.'
                : evaluation.feedback,
          ),
        ),
      );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.message
                  : 'Không thể ghi nhận chỉ số.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ghi số đo tăng trưởng'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
        ),
        TextField(
          controller: _height,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_formatDate(_date)),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: widget.profile.dateOfBirth,
              lastDate: DateTime.now(),
            );
            if (selected != null) setState(() => _date = selected);
          },
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: AppColors.white),
              )
            : const Text('Lưu'),
      ),
    ],
  );
}

class MenuScreen extends StatefulWidget {
  final BabyProfile profile;
  final bool weekly;
  const MenuScreen({super.key, required this.profile, required this.weekly});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FlutterTts _tts = FlutterTts();
  Object? _error;
  bool _loading = true;
  bool _ttsReady = false;
  bool _speaking = false;
  double _speechRate = 0.45;
  DailyMenu? _daily;
  WeeklyMenu? _weekly;
  @override
  void initState() {
    super.initState();
    _configureTts();
    _load();
  }

  Future<void> _configureTts() async {
    try {
      final languages = await _tts.getLanguages;
      if (languages is! List ||
          !languages.any((item) => '$item'.toLowerCase().contains('vi')))
        return;
      await _tts.setLanguage('vi-VN');
      await _tts.setSpeechRate(_speechRate);
      _tts.setStartHandler(() {
        if (mounted) setState(() => _speaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _speaking = false);
      });
      if (mounted) setState(() => _ttsReady = true);
    } catch (_) {
      if (mounted) setState(() => _ttsReady = false);
    }
  }

  Future<void> _speak() async {
    if (!_ttsReady) {
      _snack('Thiết bị chưa có giọng đọc tiếng Việt.');
      return;
    }
    final text = widget.weekly
        ? _weekly!.days
              .asMap()
              .entries
              .map(
                (entry) => 'Ngày ${entry.key + 1}. ${_menuText(entry.value)}',
              )
              .join('. ')
        : _menuText(_daily!);
    try {
      await _tts.speak(text);
    } catch (_) {
      if (mounted) _snack('Không thể phát giọng đọc tiếng Việt.');
    }
  }

  String _menuText(DailyMenu menu) => menu.meals.entries
      .map(
        (entry) =>
            '${_mealTitle(entry.key)}: ${entry.value?.name ?? 'Chưa có món'}',
      )
      .join('. ');
  Future<void> _pause() async {
    try {
      await _tts.pause();
    } catch (_) {
      if (mounted) _snack('Không thể tạm dừng giọng đọc.');
    }
  }

  Future<void> _stop() async {
    await _tts.stop();
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _changeRate(double value) async {
    setState(() => _speechRate = value);
    await _tts.setSpeechRate(value);
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.weekly) {
        _weekly = await BabyRepository.getWeeklyMenu(widget.profile.id);
      } else {
        _daily = await BabyRepository.getDailyMenu(widget.profile.id);
      }
    } catch (error) {
      _error = error;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.weekly ? 'Thực đơn tuần' : 'Thực đơn hôm nay'),
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primaryDark,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_loading)
            const _StateCard(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            )
          else if (_error != null)
            _StateCard(
              child: _ErrorContent(
                message: _error is ApiException
                    ? (_error as ApiException).message
                    : 'Không thể tải thực đơn.',
                onRetry: _load,
              ),
            )
          else if (widget.weekly) ...[
            _SpeechControls(
              ready: _ttsReady,
              speaking: _speaking,
              rate: _speechRate,
              onSpeak: _speak,
              onPause: _pause,
              onStop: _stop,
              onRateChanged: _changeRate,
            ),
            ..._weekly!.days.asMap().entries.map(
              (entry) => _DayMenu(index: entry.key, menu: entry.value),
            ),
          ] else ...[
            _SpeechControls(
              ready: _ttsReady,
              speaking: _speaking,
              rate: _speechRate,
              onSpeak: _speak,
              onPause: _pause,
              onStop: _stop,
              onRateChanged: _changeRate,
            ),
            if (_daily!.meets80Pct)
              const Chip(label: Text('Đạt 80% mục tiêu dinh dưỡng')),
            ..._daily!.meals.entries.map(
              (entry) => _MealCard(title: entry.key, meal: entry.value),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Tạo lại thực đơn'),
          ),
        ],
      ),
    ),
  );
}

class _SpeechControls extends StatelessWidget {
  final bool ready, speaking;
  final double rate;
  final VoidCallback onSpeak, onPause, onStop;
  final ValueChanged<double> onRateChanged;
  const _SpeechControls({
    required this.ready,
    required this.speaking,
    required this.rate,
    required this.onSpeak,
    required this.onPause,
    required this.onStop,
    required this.onRateChanged,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up_outlined,
                color: ready ? AppColors.primaryDark : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Đọc thực đơn',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: onSpeak,
                icon: const Icon(
                  Icons.play_arrow,
                  color: AppColors.primaryDark,
                ),
                tooltip: 'Phát',
              ),
              IconButton(
                onPressed: speaking ? onPause : null,
                icon: const Icon(Icons.pause, color: AppColors.primaryDark),
                tooltip: 'Tạm dừng',
              ),
              IconButton(
                onPressed: onStop,
                icon: const Icon(Icons.stop, color: AppColors.primaryDark),
                tooltip: 'Dừng',
              ),
            ],
          ),
          Row(
            children: [
              const Text('Tốc độ'),
              Expanded(
                child: Slider(
                  value: rate,
                  min: 0.25,
                  max: 0.8,
                  divisions: 11,
                  label: rate.toStringAsFixed(2),
                  onChanged: onRateChanged,
                ),
              ),
              Text(rate.toStringAsFixed(2)),
            ],
          ),
          if (!ready)
            const Text(
              'Chưa phát hiện giọng tiếng Việt trên thiết bị.',
              style: TextStyle(color: AppColors.textMuted),
            ),
        ],
      ),
    ),
  );
}

class _DayMenu extends StatelessWidget {
  final int index;
  final DailyMenu menu;
  const _DayMenu({required this.index, required this.menu});
  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(
      'Ngày ${index + 1}',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    subtitle: Text(
      menu.meets80Pct ? 'Đạt 80% mục tiêu' : 'Xem chi tiết thực đơn',
    ),
    children: menu.meals.entries
        .map((entry) => _MealCard(title: entry.key, meal: entry.value))
        .toList(),
  );
}

class _MealCard extends StatelessWidget {
  final String title;
  final MealItem? meal;
  const _MealCard({required this.title, required this.meal});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      title: Text(
        _mealTitle(title),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: meal == null
          ? const Text('Chưa có món')
          : Text(
              '${meal!.name}\n${meal!.calories.toStringAsFixed(0)} kcal · ${meal!.prepTimeMin} phút',
            ),
      isThreeLine: meal != null,
    ),
  );
}

class _ActionGrid extends StatelessWidget {
  final VoidCallback onGrowth, onDaily, onWeekly, onRecord;
  const _ActionGrid({
    required this.onGrowth,
    required this.onDaily,
    required this.onWeekly,
    required this.onRecord,
  });
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1.7,
    children: [
      _Action(
        label: 'Biểu đồ tăng trưởng',
        icon: Icons.show_chart,
        onTap: onGrowth,
      ),
      _Action(label: 'Ghi số đo', icon: Icons.add_chart, onTap: onRecord),
      _Action(
        label: 'Thực đơn ngày',
        icon: Icons.today_outlined,
        onTap: onDaily,
      ),
      _Action(
        label: 'Thực đơn tuần',
        icon: Icons.calendar_month_outlined,
        onTap: onWeekly,
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Action({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryDark),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BabyPicker extends StatelessWidget {
  final List<BabyProfile> profiles;
  final BabyProfile selected;
  final ValueChanged<BabyProfile> onChanged;
  const _BabyPicker({
    required this.profiles,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: selected.id,
    decoration: const InputDecoration(labelText: 'Bé đang xem'),
    items: profiles
        .map(
          (profile) => DropdownMenuItem(
            value: profile.id,
            child: Text(profile.babyName),
          ),
        )
        .toList(),
    onChanged: (id) {
      if (id != null)
        onChanged(profiles.firstWhere((profile) => profile.id == id));
    },
  );
}

class _ProfileCard extends StatelessWidget {
  final BabyProfile profile;
  final VoidCallback onEdit;
  final ValueChanged<BabyProfile> onProfileChanged;
  const _ProfileCard({
    required this.profile,
    required this.onEdit,
    required this.onProfileChanged,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _BabyPhotoAvatar(
            profile: profile,
            onProfileChanged: onProfileChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.babyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${profile.ageMonths} tháng · ${profile.isBoy ? 'Bé trai' : 'Bé gái'}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                Text(
                  '${profile.currentWeightKg?.toStringAsFixed(1) ?? '--'} kg · ${profile.currentHeightCm?.toStringAsFixed(1) ?? '--'} cm',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark),
          ),
        ],
      ),
    ),
  );
}

class _BabyPhotoAvatar extends StatefulWidget {
  final BabyProfile profile;
  final ValueChanged<BabyProfile> onProfileChanged;
  const _BabyPhotoAvatar({
    required this.profile,
    required this.onProfileChanged,
  });
  @override
  State<_BabyPhotoAvatar> createState() => _BabyPhotoAvatarState();
}

class _BabyPhotoAvatarState extends State<_BabyPhotoAvatar> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;
  bool _loading = false;

  bool get _cameraAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  @override
  void didUpdateWidget(covariant _BabyPhotoAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id ||
        oldWidget.profile.hasPhoto != widget.profile.hasPhoto) {
      _bytes = null;
      _loadPhoto();
    }
  }

  Future<void> _loadPhoto() async {
    if (!widget.profile.hasPhoto) return;
    try {
      final bytes = await BabyRepository.getPhoto(widget.profile.id);
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {
      if (mounted) setState(() => _bytes = null);
    }
  }

  Future<void> _openPicker() async {
    if (_loading) return;
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_cameraAvailable)
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primaryDark,
                ),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, _PhotoAction.camera),
              ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryDark,
              ),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, _PhotoAction.gallery),
            ),
            if (widget.profile.hasPhoto)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.rose,
                ),
                title: const Text('Xóa ảnh'),
                onTap: () => Navigator.pop(context, _PhotoAction.delete),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == _PhotoAction.delete) {
      await _deletePhoto();
    } else if (action == _PhotoAction.camera) {
      await _capturePhoto();
    } else if (action == _PhotoAction.gallery) {
      await _pickPhoto(ImageSource.gallery);
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final result = await Navigator.of(context).push<CameraCaptureResult>(
        MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
      );
      if (!mounted || result == null) return;
      if (result.useFallback) {
        await _pickPhoto(ImageSource.camera);
      } else if (result.file != null) {
        await _uploadPhoto(result.file!);
      }
    } catch (_) {
      if (mounted) await _pickPhoto(ImageSource.camera);
    }
  }

  Future<XFile?> _pickPhotoFile(ImageSource source) {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (mobile || kIsWeb) {
      return _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
    }
    const group = XTypeGroup(
      label: 'Ảnh',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
    );
    return openFile(acceptedTypeGroups: <XTypeGroup>[group]);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _pickPhotoFile(source);
      if (file == null) return;
      await _uploadPhoto(file);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show(
        error is ApiException
            ? error.message
            : 'Không thể tải ảnh lên. Mẹ thử lại nhé.',
      );
    }
  }

  Future<void> _uploadPhoto(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (_photoType(bytes) == null) {
        _show('Mẹ chọn ảnh JPEG, PNG hoặc WebP nhé.');
        return;
      }
      if (bytes.length > 5 * 1024 * 1024) {
        _show('Ảnh không được vượt quá 5 MB.');
        return;
      }
      setState(() => _loading = true);
      await BabyRepository.uploadPhoto(widget.profile.id, file);
      final uploaded = await BabyRepository.getPhoto(widget.profile.id);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _bytes = uploaded;
      });
      widget.onProfileChanged(widget.profile.copyWith(hasPhoto: true));
      _show('Đã cập nhật ảnh đại diện cho bé.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show(
        error is ApiException
            ? error.message
            : 'Không thể tải ảnh lên. Mẹ thử lại nhé.',
      );
    }
  }

  Future<void> _deletePhoto() async {
    setState(() => _loading = true);
    try {
      await BabyRepository.deletePhoto(widget.profile.id);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _bytes = null;
      });
      widget.onProfileChanged(widget.profile.copyWith(hasPhoto: false));
      _show('Đã xóa ảnh đại diện của bé.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show(
        error is ApiException
            ? error.message
            : 'Không thể xóa ảnh. Mẹ thử lại nhé.',
      );
    }
  }

  String? _photoType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF)
      return 'image/jpeg';
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A)
      return 'image/png';
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50)
      return 'image/webp';
    return null;
  }

  void _show(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _openPicker,
    child: Stack(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: _bytes == null ? null : MemoryImage(_bytes!),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryDark,
                  ),
                )
              : _bytes == null
              ? const Icon(Icons.child_care, color: AppColors.primaryDark)
              : null,
        ),
        if (!_loading)
          const Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primaryDark,
              child: Icon(Icons.camera_alt, size: 12, color: AppColors.white),
            ),
          ),
      ],
    ),
  );
}

class _EmptyBaby extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBaby({required this.onAdd});
  @override
  Widget build(BuildContext context) => _StateCard(
    child: Column(
      children: [
        const Icon(
          Icons.child_friendly,
          size: 48,
          color: AppColors.primaryDark,
        ),
        const SizedBox(height: 10),
        const Text(
          'Chưa có hồ sơ bé',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Mẹ tạo hồ sơ để theo dõi tăng trưởng và nhận gợi ý thực đơn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        FilledButton(onPressed: onAdd, child: const Text('Thêm hồ sơ bé')),
      ],
    ),
  );
}

class _StateCard extends StatelessWidget {
  final Widget child;
  const _StateCard({required this.child});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Center(child: child),
    ),
  );
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorContent({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Icon(Icons.error_outline, color: AppColors.error, size: 42),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center),
      TextButton(onPressed: onRetry, child: const Text('Thử lại')),
    ],
  );
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _mealTitle(String key) =>
    {
      'breakfast': 'Bữa sáng',
      'lunch': 'Bữa trưa',
      'snack': 'Bữa phụ',
      'dinner': 'Bữa tối',
      'supplementary_snack': 'Bữa phụ bổ sung',
    }[key] ??
    key;
