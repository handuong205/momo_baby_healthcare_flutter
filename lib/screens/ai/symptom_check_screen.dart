import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/symptom/symptom_analysis.dart';
import 'package:momo_baby_healthcare_flutter/repositories/symptom/symptom_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/mom_ai_menu_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/symptom_result_screen.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/ai_ui.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/urgency_style.dart';

/// Màn 10 — Kiểm tra triệu chứng bằng AI (tab "AI").
///
/// Linh kiện ngoại vi:
/// - Micro: nói để nhập triệu chứng (speech_to_text, tiếng Việt).
/// - Camera: chụp ảnh vùng da/triệu chứng gửi kèm cho AI (image_picker).
class SymptomCheckScreen extends StatefulWidget {
  const SymptomCheckScreen({super.key});

  @override
  State<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends State<SymptomCheckScreen> {
  static const int _maxLength = 1000;

  final _textController = TextEditingController();
  final _speech = SpeechToText();
  final _picker = ImagePicker();

  bool _speechReady = false;
  bool _listening = false;
  String _textBeforeListening = '';

  Uint8List? _imageBytes;
  String _imageMime = 'image/jpeg';

  bool _analyzing = false;

  List<SymptomAnalysis> _history = [];
  bool _historyLoading = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
    _loadHistory();
  }

  @override
  void dispose() {
    _speech.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _historyLoading = true;
      _historyError = null;
    });
    try {
      final items = await SymptomRepository.history();
      if (!mounted) return;
      setState(() => _history = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _historyError = aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  // ---------------------------------------------------------------- Micro
  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && mounted) {
            setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    }

    if (!_speechReady) {
      _showSnack('Máy chưa cho phép dùng micro hoặc không hỗ trợ nhận giọng nói.');
      return;
    }

    _textBeforeListening = _textController.text.trim();
    setState(() => _listening = true);

    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'vi_VN',
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
      onResult: (result) {
        final spoken = result.recognizedWords;
        final merged = [_textBeforeListening, spoken].where((s) => s.isNotEmpty).join(' ');
        final text = merged.length > _maxLength ? merged.substring(0, _maxLength) : merged;
        _textController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    );
  }

  // --------------------------------------------------------------- Camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Nén trước khi gửi (giống bản web) để request nhẹ, AI vẫn đọc rõ
      final file = await _picker.pickImage(source: source, maxWidth: 1280, imageQuality: 75);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageMime = file.mimeType ?? 'image/jpeg';
      });
    } catch (_) {
      _showSnack(source == ImageSource.camera
          ? 'Không mở được camera. Mẹ kiểm tra quyền camera nhé.'
          : 'Không mở được thư viện ảnh.');
    }
  }

  // --------------------------------------------------------------- Submit
  bool get _canSubmit =>
      !_analyzing && _textController.text.trim().length >= SymptomRepository.minDescriptionLength;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_listening) {
      await _speech.stop();
      _listening = false;
    }
    setState(() => _analyzing = true);

    try {
      final result = await SymptomRepository.analyze(
        description: _textController.text,
        imageBytes: _imageBytes,
        imageMimeType: _imageMime,
      );
      if (!mounted) return;

      _textController.clear();
      setState(() => _imageBytes = null);
      _loadHistory();

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SymptomResultScreen(analysis: result)),
      );
    } catch (e) {
      _showSnack(aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _openResult(SymptomAnalysis item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SymptomResultScreen(analysis: item)),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: MomTheme.roseDark,
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const Text('Kiểm tra triệu chứng', style: AiText.title),
            const SizedBox(height: 4),
            const Text(
              'Kể cho Mom Ơi! nghe mẹ đang thấy thế nào, AI sẽ gợi ý mẹ nên làm gì.',
              style: AiText.muted,
            ),
            const SizedBox(height: 16),
            const DoctorCard(compact: true),
            const SizedBox(height: 16),
            _buildInputCard(),
            const SizedBox(height: 16),
            _MenuShortcut(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MomAiMenuScreen()),
              ),
            ),
            const SizedBox(height: 24),
            _buildHistory(),
            const SizedBox(height: 16),
            const MedicalDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    final length = _textController.text.trim().length;
    final tooShort = length > 0 && length < SymptomRepository.minDescriptionLength;

    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(icon: Icons.edit_note_rounded, title: 'Mẹ đang thấy thế nào?'),
          const SizedBox(height: 14),
          TextField(
            controller: _textController,
            maxLength: _maxLength,
            minLines: 4,
            maxLines: 8,
            enabled: !_analyzing,
            style: AiText.body,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Từ sáng em bị đau đầu, hoa mắt, chân hơi phù...',
              hintStyle: AiText.muted.copyWith(fontSize: 15),
              errorText: tooShort ? 'Mẹ mô tả thêm một chút (ít nhất 10 ký tự) nhé.' : null,
            ),
          ),
          const SizedBox(height: 6),

          // Micro
          _MicButton(listening: _listening, onTap: _analyzing ? null : _toggleListening),
          const SizedBox(height: 12),

          // Camera
          if (_imageBytes == null)
            Row(
              children: [
                Expanded(
                  child: _OutlineAction(
                    icon: Icons.photo_camera_rounded,
                    label: 'Chụp ảnh',
                    onTap: _analyzing ? null : () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OutlineAction(
                    icon: Icons.photo_library_rounded,
                    label: 'Chọn ảnh',
                    onTap: _analyzing ? null : () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            )
          else
            _ImagePreview(
              bytes: _imageBytes!,
              onRemove: _analyzing ? null : () => setState(() => _imageBytes = null),
            ),
          const SizedBox(height: 6),
          const Text('Ảnh không bắt buộc. Chụp rõ vùng da, vết phát ban... để AI xem kỹ hơn.',
              style: AiText.muted),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _canSubmit ? _submit : null,
              icon: _analyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: MomTheme.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_analyzing ? 'AI đang phân tích...' : 'Phân tích triệu chứng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MomTheme.roseDark,
                disabledBackgroundColor: MomTheme.beige,
                textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_analyzing) ...[
            const SizedBox(height: 8),
            const Center(
              child: Text('Thường mất khoảng 10–30 giây, mẹ chờ chút nhé.', style: AiText.muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lần kiểm tra trước', style: AiText.section),
        const SizedBox(height: 10),
        if (_historyLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: MomTheme.roseDark)),
          )
        else if (_historyError != null)
          AiErrorBox(message: _historyError!, onRetry: _loadHistory)
        else if (_history.isEmpty)
          const AiCard(
            child: Text('Mẹ chưa kiểm tra triệu chứng lần nào.', style: AiText.muted),
          )
        else
          for (final item in _history.take(10))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryTile(item: item, onTap: () => _openResult(item)),
            ),
      ],
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool listening;
  final VoidCallback? onTap;

  const _MicButton({required this.listening, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = listening ? AppColors.rose : MomTheme.roseDark;
    return Material(
      color: listening ? AppColors.roseLight : MomTheme.pinkLight,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(listening ? Icons.stop_circle_rounded : Icons.mic_rounded, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  listening ? 'Đang nghe... bấm để dừng' : 'Bấm để nói thay vì gõ',
                  style: AiText.label.copyWith(color: color, fontSize: 16),
                ),
              ),
              if (listening) const _PulseDot(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _OutlineAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        foregroundColor: MomTheme.charcoalMid,
        side: const BorderSide(color: MomTheme.beige),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback? onRemove;

  const _ImagePreview({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: Image.memory(bytes, height: 180, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Bỏ ảnh',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuShortcut extends StatelessWidget {
  final VoidCallback onTap;

  const _MenuShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amberLight,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: MomTheme.white, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.restaurant_menu_rounded, color: MomTheme.amberDark, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thực đơn AI cho mẹ', style: AiText.section),
                    Text('Gợi ý món theo sức khỏe, chỉnh theo ý mẹ', style: AiText.muted),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: MomTheme.muted, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final SymptomAnalysis item;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MomTheme.white,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: MomTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UrgencyChip(level: item.aiAvailable ? item.urgencyLevel : UrgencyLevel.unknown),
                        if (item.imageUrl != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.image_rounded, size: 18, color: MomTheme.mutedLight),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.textDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AiText.body.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(formatViDateTime(item.createdAt), style: AiText.muted.copyWith(fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: MomTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
