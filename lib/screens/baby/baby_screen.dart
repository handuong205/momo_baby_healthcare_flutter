import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_exception.dart';
import 'package:momo_baby_healthcare_flutter/models/baby/baby_models.dart';
import 'package:momo_baby_healthcare_flutter/repositories/baby/baby_repository.dart';
import 'package:momo_baby_healthcare_flutter/utils/who_data.dart';

const _allergies = ['Sữa bò', 'Trứng', 'Hải sản', 'Đậu phộng', 'Đậu nành', 'Lúa mì (gluten)'];

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
      MaterialPageRoute(builder: (_) => BabyProfileFormScreen(profile: profile)),
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
                              Text('Bé yêu', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              SizedBox(height: 4),
                              Text('Chăm bé lớn khôn', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openProfileForm(),
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryDark),
                          tooltip: 'Thêm hồ sơ bé',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const _StateCard(child: CircularProgressIndicator(color: AppColors.primaryDark))
                    else if (_error != null)
                      _StateCard(
                        child:                         _ErrorContent(message: _message(_error!), onRetry: _load),
                      )
                    else if (_profiles.isEmpty)
                      _EmptyBaby(onAdd: () => _openProfileForm())
                    else ...[
                      _BabyPicker(
                        profiles: _profiles,
                        selected: _selected!,
                        onChanged: (profile) => setState(() => _selected = profile),
                      ),
                      const SizedBox(height: 14),
                      _ProfileCard(profile: _selected!, onEdit: () => _openProfileForm(_selected)),
                      const SizedBox(height: 18),
                      _ActionGrid(
                        onGrowth: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GrowthScreen(profile: _selected!)),
                        ),
                        onDaily: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MenuScreen(profile: _selected!, weekly: false)),
                        ),
                        onWeekly: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MenuScreen(profile: _selected!, weekly: true)),
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

  String _message(Object error) => error is ApiException ? error.message : 'Đã xảy ra lỗi không xác định.';
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
      _show('Thiếu thông tin', name.isEmpty ? 'Mẹ nhập tên hoặc tên ở nhà của bé nhé.' : 'Mẹ chọn ngày sinh của bé nhé.');
      return;
    }
    if (_weight.text.trim().isNotEmpty && (weight == null || weight < 1 || weight > 40)) {
      _show('Kiểm tra lại', 'Cân nặng của bé cần nằm trong khoảng 1 - 40 kg.');
      return;
    }
    if (_height.text.trim().isNotEmpty && (height == null || height < 30 || height > 130)) {
      _show('Kiểm tra lại', 'Chiều cao của bé cần nằm trong khoảng 30 - 130 cm.');
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
        SnackBar(content: Text(widget.profile == null ? 'Đã tạo hồ sơ cho bé.' : 'Hồ sơ của bé đã được cập nhật.')),
      );
      Navigator.of(context).pop(profile);
    } catch (error) {
      if (mounted) _show('Chưa lưu được', error is ApiException ? error.message : 'Đã xảy ra lỗi không xác định.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String title, String message) => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
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
          const Text('Ngày sinh, cân nặng và dị ứng giúp Mom Ơi gợi ý thực đơn đúng độ tuổi của bé.', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 18),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Tên bé', hintText: 'VD: Bơ, Na, Minh Anh')),
          const SizedBox(height: 14),
          const Text('Giới tính', style: TextStyle(fontWeight: FontWeight.w700)),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Male', label: Text('Bé trai')),
              ButtonSegment(value: 'Female', label: Text('Bé gái')),
            ],
            selected: {_gender},
            onSelectionChanged: (value) => setState(() => _gender = value.first),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_dob == null ? 'Ngày sinh' : _formatDate(_dob!)),
            subtitle: const Text('Mẹ chọn ngày sinh của bé nhé.'),
            trailing: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryDark),
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
          Row(children: [
            Expanded(child: TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cân nặng (kg)', hintText: 'VD: 7.8'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Chiều cao (cm)', hintText: 'VD: 68'))),
          ]),
          const SizedBox(height: 22),
          const Text('Dị ứng thực phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Text('Thực đơn sẽ tránh các thực phẩm này', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies.map((item) => FilterChip(
              label: Text(item),
              selected: _allergyValues.contains(item),
              onSelected: (selected) => setState(() => selected ? _allergyValues.add(item) : _allergyValues.remove(item)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _customAllergy, decoration: const InputDecoration(labelText: 'Dị ứng khác', hintText: 'Nhập rồi bấm Thêm'))),
            IconButton(
              onPressed: () {
                final value = _customAllergy.text.trim();
                if (value.isNotEmpty && !_allergyValues.contains(value)) setState(() => _allergyValues.add(value));
                _customAllergy.clear();
              },
              icon: const Icon(Icons.add_circle, color: AppColors.primaryDark),
            ),
          ]),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white)) : Text(editing ? 'Lưu thay đổi' : 'Tạo hồ sơ bé'),
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
  void initState() { super.initState(); _profile = widget.profile; }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final profiles = await BabyRepository.getProfiles();
      final current = profiles.firstWhere((item) => item.id == _profile.id);
      if (mounted) setState(() => _profile = current);
    } catch (error) {
      if (mounted) _snack(error is ApiException ? error.message : 'Không thể tải dữ liệu.');
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await BabyRepository.deleteGrowth(_profile.id, record.id);
      if (mounted) { _snack('Xóa chỉ số tăng trưởng thành công.'); await _refresh(); }
    } catch (error) {
      if (mounted) _snack(error is ApiException ? error.message : 'Không thể xóa chỉ số.');
    }
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final records = [..._profile.growthRecords]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ tăng trưởng')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryDark,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const LinearProgressIndicator(color: AppColors.primaryDark),
            if (records.isEmpty)
              const _StateCard(child: Text('Chưa có mốc tăng trưởng. Hãy ghi nhận số đo đầu tiên của bé.', textAlign: TextAlign.center))
            else ...[
              _GrowthChart(metric: GrowthMetric.weight, profile: _profile, records: records),
              const SizedBox(height: 16),
              _GrowthChart(metric: GrowthMetric.height, profile: _profile, records: records),
              const SizedBox(height: 16),
              ...records.reversed.map((record) => Card(
                child: ListTile(
                  title: Text('${record.weightKg} kg · ${record.heightCm} cm'),
                  subtitle: Text(_formatDate(record.recordedAt.toLocal())),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.rose), onPressed: () => _delete(record)),
                ),
              )),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () async {
              final saved = await showDialog<bool>(context: context, builder: (_) => GrowthEntryDialog(profile: _profile));
              if (saved == true && mounted) await _refresh();
            }, icon: const Icon(Icons.add), label: const Text('Ghi số đo mới')),
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
  const _GrowthChart({required this.metric, required this.profile, required this.records});

  @override
  Widget build(BuildContext context) {
    final table = whoTable(metric, profile.isBoy);
    final values = [...table.map((row) => row.p3), ...table.map((row) => row.p97), ...records.map((record) => metric == GrowthMetric.weight ? record.weightKg : record.heightCm)];
    final step = metric == GrowthMetric.weight ? 2.0 : 10.0;
    final minY = (values.reduce((a, b) => a < b ? a : b) / step).floor() * step;
    final maxY = (values.reduce((a, b) => a > b ? a : b) / step).ceil() * step;
    final spots = records.map((record) => FlSpot(
      ageInMonths(profile.dateOfBirth, record.recordedAt).clamp(0, 24),
      metric == GrowthMetric.weight ? record.weightKg : record.heightCm,
    )).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(metric == GrowthMetric.weight ? 'Cân nặng theo tuổi' : 'Chiều cao theo tuổi', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: LineChart(LineChartData(
              minX: 0, maxX: 24, minY: minY, maxY: maxY,
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              betweenBarsData: [
                BetweenBarsData(
                  fromIndex: 0,
                  toIndex: 1,
                  color: AppColors.secondaryLight,
                ),
              ],
              lineBarsData: [
                LineChartBarData(spots: table.map((row) => FlSpot(row.month, row.p3)).toList(), isCurved: false, color: AppColors.secondaryLight, barWidth: 0, dotData: const FlDotData(show: false)),
                LineChartBarData(spots: table.map((row) => FlSpot(row.month, row.p97)).toList(), isCurved: false, color: AppColors.secondaryLight, barWidth: 0, dotData: const FlDotData(show: false)),
                LineChartBarData(spots: table.map((row) => FlSpot(row.month, row.p50)).toList(), isCurved: false, color: AppColors.secondaryDark, barWidth: 2, dashArray: [5, 4], dotData: const FlDotData(show: false)),
                LineChartBarData(spots: spots, isCurved: false, color: AppColors.primaryDark, barWidth: 3, dotData: const FlDotData(show: true)),
              ],
            )),
          ),
          const Text('Chuẩn WHO (P3–P97) · Trung vị · Bé', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text('Trục ngang: tháng tuổi · Trục dọc: ${metric == GrowthMetric.weight ? 'kg' : 'cm'}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
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
  void dispose() { _weight.dispose(); _height.dispose(); super.dispose(); }
  Future<void> _save() async {
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    final height = double.tryParse(_height.text.replaceAll(',', '.'));
    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mẹ nhập cân nặng và chiều cao hợp lệ nhé.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final evaluation = await BabyRepository.logGrowth(widget.profile.id, weightKg: weight, heightCm: height, recordedAt: _date);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(evaluation.feedback.isEmpty ? 'Ghi nhận chỉ số tăng trưởng và đánh giá thành công.' : evaluation.feedback)));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'Không thể ghi nhận chỉ số.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ghi số đo tăng trưởng'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cân nặng (kg)')),
      TextField(controller: _height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Chiều cao (cm)')),
      ListTile(contentPadding: EdgeInsets.zero, title: Text(_formatDate(_date)), trailing: const Icon(Icons.calendar_today_outlined), onTap: () async {
        final selected = await showDatePicker(context: context, initialDate: _date, firstDate: widget.profile.dateOfBirth, lastDate: DateTime.now());
        if (selected != null) setState(() => _date = selected);
      }),
    ]),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Hủy')),
      FilledButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.white)) : const Text('Lưu')),
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
  Object? _error;
  bool _loading = true;
  DailyMenu? _daily;
  WeeklyMenu? _weekly;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (widget.weekly) {
        _weekly = await BabyRepository.getWeeklyMenu(widget.profile.id);
      } else {
        _daily = await BabyRepository.getDailyMenu(widget.profile.id);
      }
    } catch (error) { _error = error; }
    if (mounted) setState(() => _loading = false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.weekly ? 'Thực đơn tuần' : 'Thực đơn hôm nay')),
    body: RefreshIndicator(
      onRefresh: _load, color: AppColors.primaryDark,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        if (_loading) const _StateCard(child: CircularProgressIndicator(color: AppColors.primaryDark))
        else if (_error != null) _StateCard(child: _ErrorContent(message: _error is ApiException ? (_error as ApiException).message : 'Không thể tải thực đơn.', onRetry: _load))
        else if (widget.weekly) ..._weekly!.days.asMap().entries.map((entry) => _DayMenu(index: entry.key, menu: entry.value))
        else ...[
          if (_daily!.meets80Pct) const Chip(label: Text('Đạt 80% mục tiêu dinh dưỡng')),
          ..._daily!.meals.entries.map((entry) => _MealCard(title: entry.key, meal: entry.value)),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Tạo lại thực đơn')),
      ]),
    ),
  );
}

class _DayMenu extends StatelessWidget {
  final int index; final DailyMenu menu;
  const _DayMenu({required this.index, required this.menu});
  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text('Ngày ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(menu.meets80Pct ? 'Đạt 80% mục tiêu' : 'Xem chi tiết thực đơn'),
    children: menu.meals.entries.map((entry) => _MealCard(title: entry.key, meal: entry.value)).toList(),
  );
}
class _MealCard extends StatelessWidget {
  final String title; final MealItem? meal;
  const _MealCard({required this.title, required this.meal});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      title: Text(_mealTitle(title), style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: meal == null ? const Text('Chưa có món') : Text('${meal!.name}\n${meal!.calories.toStringAsFixed(0)} kcal · ${meal!.prepTimeMin} phút'),
      isThreeLine: meal != null,
    ),
  );
}

class _ActionGrid extends StatelessWidget {
  final VoidCallback onGrowth, onDaily, onWeekly, onRecord;
  const _ActionGrid({required this.onGrowth, required this.onDaily, required this.onWeekly, required this.onRecord});
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.7,
    children: [
      _Action(label: 'Biểu đồ tăng trưởng', icon: Icons.show_chart, onTap: onGrowth),
      _Action(label: 'Ghi số đo', icon: Icons.add_chart, onTap: onRecord),
      _Action(label: 'Thực đơn ngày', icon: Icons.today_outlined, onTap: onDaily),
      _Action(label: 'Thực đơn tuần', icon: Icons.calendar_month_outlined, onTap: onWeekly),
    ],
  );
}
class _Action extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _Action({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppColors.primaryDark), const SizedBox(height: 5), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]))),
  );
}
class _BabyPicker extends StatelessWidget {
  final List<BabyProfile> profiles; final BabyProfile selected; final ValueChanged<BabyProfile> onChanged;
  const _BabyPicker({required this.profiles, required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: selected.id, decoration: const InputDecoration(labelText: 'Bé đang xem'), items: profiles.map((profile) => DropdownMenuItem(value: profile.id, child: Text(profile.babyName))).toList(), onChanged: (id) { if (id != null) onChanged(profiles.firstWhere((profile) => profile.id == id)); },
  );
}
class _ProfileCard extends StatelessWidget {
  final BabyProfile profile; final VoidCallback onEdit;
  const _ProfileCard({required this.profile, required this.onEdit});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
      const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.child_care, color: AppColors.primaryDark)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(profile.babyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('${profile.ageMonths} tháng · ${profile.isBoy ? 'Bé trai' : 'Bé gái'}', style: const TextStyle(color: AppColors.textMuted)), Text('${profile.currentWeightKg?.toStringAsFixed(1) ?? '--'} kg · ${profile.currentHeightCm?.toStringAsFixed(1) ?? '--'} cm', style: const TextStyle(color: AppColors.textMuted))])),
      IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark)),
    ])),
  );
}
class _EmptyBaby extends StatelessWidget {
  final VoidCallback onAdd; const _EmptyBaby({required this.onAdd});
  @override
  Widget build(BuildContext context) => _StateCard(child: Column(children: [const Icon(Icons.child_friendly, size: 48, color: AppColors.primaryDark), const SizedBox(height: 10), const Text('Chưa có hồ sơ bé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Mẹ tạo hồ sơ để theo dõi tăng trưởng và nhận gợi ý thực đơn.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)), const SizedBox(height: 14), FilledButton(onPressed: onAdd, child: const Text('Thêm hồ sơ bé'))]));
}
class _StateCard extends StatelessWidget {
  final Widget child; const _StateCard({required this.child});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Center(child: child)));
}
class _ErrorContent extends StatelessWidget {
  final String message; final VoidCallback onRetry; const _ErrorContent({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(children: [const Icon(Icons.error_outline, color: AppColors.error, size: 42), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center), TextButton(onPressed: onRetry, child: const Text('Thử lại'))]);
}
String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _mealTitle(String key) => {'breakfast': 'Bữa sáng', 'lunch': 'Bữa trưa', 'snack': 'Bữa phụ', 'dinner': 'Bữa tối', 'supplementary_snack': 'Bữa phụ bổ sung'}[key] ?? key;
