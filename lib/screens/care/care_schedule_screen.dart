import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/exceptions/api_error.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/mom_ui.dart';
import 'package:momo_baby_healthcare_flutter/repositories/care/care_schedule_repository.dart';
import 'package:momo_baby_healthcare_flutter/models/care/care_schedule.dart';
import 'package:momo_baby_healthcare_flutter/services/care_reminder_service.dart';

const _durations = [
  (days: 1, label: 'Một ngày'),
  (days: 7, label: '7 ngày'),
  (days: 30, label: '1 tháng'),
  (days: 90, label: '3 tháng'),
  (days: 180, label: '6 tháng'),
];

const _templates = [
  (name: 'Viên sắt', category: CareCategory.medicine, time: '08:00', days: 30),
  (name: 'Canxi', category: CareCategory.medicine, time: '14:00', days: 30),
  (name: 'Cho bé bú', category: CareCategory.feeding, time: '09:00', days: 30),
  (name: 'Tắm bé', category: CareCategory.bath, time: '10:00', days: 30),
  (
    name: 'Cho bé ngủ trưa',
    category: CareCategory.sleep,
    time: '12:30',
    days: 30,
  ),
  (name: 'Tiêm chủng', category: CareCategory.vaccine, time: '08:00', days: 1),
  (
    name: 'Khám thai định kỳ',
    category: CareCategory.checkup,
    time: '08:00',
    days: 1,
  ),
];

/// (13) Lịch chăm sóc — lịch nhắc lưu ở backend (`/api/medications`) kèm
/// chuông nhắc trên máy. Bố cục theo `MedicationScreen` của app Mobile.
class CareScheduleScreen extends StatefulWidget {
  const CareScheduleScreen({super.key});

  @override
  State<CareScheduleScreen> createState() => _CareScheduleScreenState();
}

class _CareScheduleScreenState extends State<CareScheduleScreen> {
  final reminders = CareReminderService.instance;

  List<CareSchedule>? schedules;
  String? error;
  int? busyId;

  bool showForm = false;
  bool saving = false;
  CareCategory category = CareCategory.medicine;
  final name = TextEditingController();
  final dosage = TextEditingController(text: '1 viên');
  final notes = TextEditingController();
  List<String> times = ['08:00'];
  DateTime startDate = startOfToday();
  int durationDays = 30;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    name.dispose();
    dosage.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final list = await CareScheduleRepository.list();
      if (!mounted) return;
      setState(() {
        schedules = list;
        error = null;
      });
      await reminders.sync(list);
    } catch (e) {
      if (mounted) setState(() => error = ApiError.getErrorMessage(e));
    }
  }

  void resetForm() {
    name.clear();
    dosage.text = '1 viên';
    notes.clear();
    category = CareCategory.medicine;
    times = ['08:00'];
    startDate = startOfToday();
    durationDays = 30;
  }

  void applyTemplate(
    ({String name, CareCategory category, String time, int days}) t,
  ) => setState(() {
    name.text = t.name;
    category = t.category;
    times = [t.time];
    durationDays = t.days;
  });

  Future<void> addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final value = formatTime(picked);
    setState(() {
      if (!times.contains(value)) times = [...times, value]..sort();
    });
  }

  Future<void> pickStartDate() async {
    final today = startOfToday();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> submit() async {
    final isMedicine = category == CareCategory.medicine;
    final problem = name.text.trim().isEmpty
        ? (isMedicine
              ? 'Mẹ nhập tên thuốc hoặc vitamin nhé (VD: Viên sắt, Canxi, Acid folic).'
              : 'Mẹ nhập việc cần nhắc nhé (VD: Cho bé bú, Tắm bé).')
        : isMedicine && dosage.text.trim().isEmpty
        ? 'Mẹ nhập liều dùng mỗi lần (VD: 1 viên).'
        : times.isEmpty
        ? 'Mẹ thêm ít nhất một giờ nhắc trong ngày.'
        : null;
    if (problem != null) {
      return showMomAlert(context, 'Thiếu thông tin', problem);
    }
    setState(() => saving = true);
    try {
      await CareScheduleRepository.add(
        name: name.text.trim(),
        dosage: isMedicine ? dosage.text.trim() : category.label,
        times: times,
        startDate: startDate,
        durationDays: durationDays,
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      );
      setState(() {
        resetForm();
        showForm = false;
      });
      final granted = await reminders.requestPermission();
      if (!granted && reminders.isSupported && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mẹ bật quyền thông báo để Mom Ơi đổ chuông nhắc đúng giờ nhé.',
            ),
          ),
        );
      }
      await load();
    } catch (e) {
      if (mounted) {
        await showMomAlert(context, 'Chưa thêm được', ApiError.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> mark(CareSchedule schedule, AdherenceStatus status) async {
    setState(() => busyId = schedule.id);
    try {
      await CareScheduleRepository.mark(schedule.id, startOfToday(), status);
      await load();
    } catch (e) {
      if (mounted) {
        await showMomAlert(context, 'Chưa cập nhật được', ApiError.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => busyId = null);
    }
  }

  Future<void> confirmDelete(CareSchedule schedule) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch chăm sóc'),
        content: Text('Mẹ muốn xóa lịch "${schedule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: MomTheme.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => busyId = schedule.id);
    try {
      await CareScheduleRepository.delete(schedule.id);
      await load();
    } catch (e) {
      if (mounted) {
        await showMomAlert(context, 'Chưa xóa được', ApiError.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => busyId = null);
    }
  }

  Future<void> testChime() async {
    await reminders.playChime();
    await reminders.requestPermission();
    await reminders.showTest();
  }

  @override
  Widget build(BuildContext context) {
    final list = schedules;
    final today = startOfToday();
    final todayList = list?.where((s) => s.activeOn(today)).toList() ?? [];
    final doneCount = todayList.where((s) => s.statusOn(today) != null).length;

    return MomScreen(
      eyebrow: 'Nhắc nhở',
      title: 'Lịch chăm sóc',
      subtitle:
          'Uống thuốc, cho bé bú, tắm bé, tiêm chủng… Mom Ơi đổ chuông nhắc '
          'đúng giờ, mẹ đánh dấu mỗi ngày khi đã làm.',
      right: _RoundIconButton(
        icon: LucideIcons.volume2,
        tooltip: 'Thử chuông nhắc',
        onTap: testChime,
      ),
      onRefresh: load,
      children: [
        if (showForm)
          _buildForm()
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MomPrimaryButton(
              label: 'Thêm lịch chăm sóc',
              icon: LucideIcons.plus,
              onPressed: () => setState(() => showForm = true),
            ),
          ),
        MomSectionTitle(
          title: 'Đang theo dõi',
          subtitle: todayList.isEmpty
              ? 'Trạng thái được tính cho hôm nay'
              : 'Hôm nay đã xong $doneCount/${todayList.length} việc',
        ),
        if (error != null)
          MomStateCard.error(error!, onRetry: load)
        else if (list == null)
          const MomLoadingView()
        else if (list.isEmpty)
          const MomStateCard(
            emoji: '⏰',
            title: 'Chưa có lịch chăm sóc',
            body: 'Thêm vitamin, giờ cho bé bú hay lịch tiêm để Mom Ơi nhắc mẹ mỗi ngày.',
          )
        else
          ...list.map(
            (s) => _ScheduleCard(
              schedule: s,
              status: s.activeOn(today) ? s.statusOn(today) : null,
              activeToday: s.activeOn(today),
              busy: busyId == s.id,
              onMark: (status) => mark(s, status),
              onDelete: () => confirmDelete(s),
            ),
          ),
      ],
    );
  }

  Widget _buildForm() {
    final isMedicine = category == CareCategory.medicine;
    return MomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Thêm lịch mới',
                  style: TextStyle(
                    color: MomTheme.charcoal,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Đóng',
                onPressed: () => setState(() => showForm = false),
                icon: const Icon(LucideIcons.x, size: 20),
                color: MomTheme.muted,
              ),
            ],
          ),
          const Text('Gợi ý nhanh', style: MomText.label),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => MomChip(
                label: _templates[i].name,
                icon: _templates[i].category.icon,
                iconColor: _templates[i].category.color,
                onTap: () => applyTemplate(_templates[i]),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Loại việc', style: MomText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CareCategory.values
                .map(
                  (c) => MomChip(
                    label: c.label,
                    icon: c.icon,
                    iconColor: c.color,
                    selected: c == category,
                    onTap: () => setState(() => category = c),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          MomField(
            label: isMedicine ? 'Tên thuốc / vitamin' : 'Việc cần nhắc',
            controller: name,
            hint: isMedicine ? 'VD: Viên sắt' : 'VD: Cho bé bú',
          ),
          if (isMedicine)
            MomField(
              label: 'Liều mỗi lần',
              controller: dosage,
              hint: 'VD: 1 viên',
            ),
          const Text('Giờ nhắc trong ngày', style: MomText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...times.map(
                (t) => _TimeChip(
                  time: t,
                  onRemove: () => setState(
                    () => times = times.where((x) => x != t).toList(),
                  ),
                ),
              ),
              MomChip(
                label: 'Thêm giờ',
                icon: LucideIcons.plus,
                onTap: addTime,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Bắt đầu từ', style: MomText.label),
          const SizedBox(height: 6),
          _DateBox(value: formatDate(startDate), onTap: pickStartDate),
          const SizedBox(height: 14),
          const Text('Nhắc trong', style: MomText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durations
                .map(
                  (d) => MomChip(
                    label: d.label,
                    selected: durationDays == d.days,
                    onTap: () => setState(() => durationDays = d.days),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          MomField(
            label: 'Ghi chú (không bắt buộc)',
            controller: notes,
            hint: isMedicine ? 'VD: uống sau ăn sáng' : 'VD: mang theo sổ tiêm',
          ),
          MomPrimaryButton(
            label: 'Lưu lịch nhắc',
            loading: saving,
            onPressed: submit,
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.status,
    required this.activeToday,
    required this.busy,
    required this.onMark,
    required this.onDelete,
  });

  final CareSchedule schedule;
  final AdherenceStatus? status;
  final bool activeToday;
  final bool busy;
  final ValueChanged<AdherenceStatus> onMark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = schedule.category;
    final isMedicine = category == CareCategory.medicine;
    return MomCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      shadow: AppShadows.sm,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, size: 18, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.name,
                      style: const TextStyle(
                        color: MomTheme.charcoal,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMedicine
                          ? schedule.meta
                          : '${category.label} · ${schedule.meta}',
                      style: const TextStyle(
                        color: MomTheme.charcoalMid,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.dateRange,
                      style: const TextStyle(
                        color: MomTheme.mutedLight,
                        fontSize: 12,
                      ),
                    ),
                    if (schedule.notes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          schedule.notes!,
                          style: const TextStyle(
                            color: MomTheme.muted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Xóa',
                onPressed: busy ? null : onDelete,
                icon: const Icon(LucideIcons.trash2, size: 18),
                color: MomTheme.mutedLight,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!activeToday)
            _StatusPill(
              text: 'Bắt đầu nhắc từ ${formatDate(schedule.startDate)}',
              background: MomTheme.beigeLight,
              color: MomTheme.muted,
            )
          else if (status != null)
            _StatusPill(
              text: status == AdherenceStatus.taken
                  ? (isMedicine ? '✓ Hôm nay đã uống' : '✓ Hôm nay đã làm')
                  : 'Hôm nay đã bỏ qua',
              background: status == AdherenceStatus.taken
                  ? MomTheme.sageLight
                  : MomTheme.beigeLight,
              color: status == AdherenceStatus.taken
                  ? MomTheme.sageDark
                  : MomTheme.muted,
              action: busy
                  ? null
                  : () => onMark(
                      status == AdherenceStatus.taken
                          ? AdherenceStatus.skipped
                          : AdherenceStatus.taken,
                    ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: MomPrimaryButton(
                    label: isMedicine ? 'Đã uống' : 'Đã làm',
                    icon: LucideIcons.check,
                    loading: busy,
                    onPressed: () => onMark(AdherenceStatus.taken),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MomSecondaryButton(
                    label: 'Bỏ qua',
                    icon: LucideIcons.skipForward,
                    onPressed: busy
                        ? null
                        : () => onMark(AdherenceStatus.skipped),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.background,
    required this.color,
    this.action,
  });

  final String text;
  final Color background;
  final Color color;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadii.control),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: action,
            child: const Text(
              'Đổi',
              style: TextStyle(
                color: MomTheme.roseDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    ),
  );
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.onRemove});

  final String time;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Material(
    color: MomTheme.pinkLight,
    shape: const StadiumBorder(side: BorderSide(color: MomTheme.pink)),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onRemove,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: const TextStyle(
                color: MomTheme.roseDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.x, size: 12, color: MomTheme.roseDeep),
          ],
        ),
      ),
    ),
  );
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: MomTheme.creamSoft,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.control),
      side: const BorderSide(color: MomTheme.border),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(AppRadii.control),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: MomTheme.charcoal, fontSize: 15),
              ),
            ),
            const Icon(
              LucideIcons.calendar,
              size: 18,
              color: MomTheme.roseDark,
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: MomTheme.white,
      shape: const CircleBorder(side: BorderSide(color: MomTheme.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 19, color: MomTheme.roseDark),
        ),
      ),
    ),
  );
}
