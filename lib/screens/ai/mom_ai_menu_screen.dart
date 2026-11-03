import 'package:flutter/material.dart';

import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';
import 'package:momo_baby_healthcare_flutter/core/theme/app_styles.dart';
import 'package:momo_baby_healthcare_flutter/models/recipe/mom_recipe.dart';
import 'package:momo_baby_healthcare_flutter/repositories/recipe/recipe_repository.dart';
import 'package:momo_baby_healthcare_flutter/screens/ai/widgets/ai_ui.dart';

/// Màn 12 — Thực đơn AI cho mẹ: chọn sở thích -> AI gợi ý món -> lưu món.
/// Món AI tạo được gửi chuyên gia duyệt (trạng thái hiển thị trên thẻ món).
class MomAiMenuScreen extends StatefulWidget {
  const MomAiMenuScreen({super.key});

  @override
  State<MomAiMenuScreen> createState() => _MomAiMenuScreenState();
}

enum _RecipeTab { recent, saved }

class _MomAiMenuScreenState extends State<MomAiMenuScreen> {
  static const _dietTypes = ['Thường', 'Ăn chay', 'Ít đường', 'Ít muối', 'Giàu sắt & canxi'];
  static const _cookTimes = [15, 30, 45, 60];

  final _allergyController = TextEditingController();
  final _ingredientController = TextEditingController();

  String _dietType = _dietTypes.first;
  int _maxCookTime = 30;

  NutritionProfile? _profile;

  _RecipeTab _tab = _RecipeTab.recent;
  List<MomRecipe> _recipes = [];
  bool _loading = true;
  String? _error;

  bool _generating = false;
  final Set<int> _savingIds = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRecipes();
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await RecipeRepository.currentProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {
      // Không có hồ sơ thì ẩn khung giai đoạn, không chặn mẹ dùng tính năng
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await RecipeRepository.myRecipes(isSaved: _tab == _RecipeTab.saved ? true : null);
      if (mounted) setState(() => _recipes = items);
    } catch (e) {
      if (mounted) setState(() => _error = aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();
    setState(() => _generating = true);
    try {
      final created = await RecipeRepository.generate(
        RecipePreferences(
          dietType: _dietType,
          maxCookTime: _maxCookTime,
          allergies: _allergyController.text,
          availableIngredients: _ingredientController.text,
        ),
      );
      if (!mounted) return;
      _snack(created.isEmpty
          ? 'AI chưa gợi ý được món phù hợp, mẹ thử đổi lựa chọn nhé.'
          : 'AI đã gợi ý ${created.length} món cho mẹ.');
      setState(() => _tab = _RecipeTab.recent);
      await _loadRecipes();
    } catch (e) {
      _snack(aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _toggleSave(MomRecipe recipe) async {
    final id = recipe.id;
    if (id == null || _savingIds.contains(id)) return;
    setState(() => _savingIds.add(id));
    try {
      final saved = await RecipeRepository.toggleSave(id);
      if (!mounted) return;
      setState(() {
        if (_tab == _RecipeTab.saved && !saved) {
          _recipes.removeWhere((r) => r.id == id);
        } else {
          _recipes = [for (final r in _recipes) r.id == id ? r.copyWith(isSaved: saved) : r];
        }
      });
      _snack(saved ? 'Đã lưu món vào sổ tay.' : 'Đã bỏ lưu món.');
    } catch (e) {
      _snack(aiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _savingIds.remove(id));
    }
  }

  void _switchTab(_RecipeTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    _loadRecipes();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MomTheme.cream,
      appBar: AppBar(
        backgroundColor: MomTheme.cream,
        title: const Text('Thực đơn AI cho mẹ', style: AiText.section),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: MomTheme.roseDark,
          onRefresh: _loadRecipes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (_profile != null) ...[
                _ProfileBadge(profile: _profile!),
                const SizedBox(height: 14),
              ],
              _buildPreferences(),
              const SizedBox(height: 20),
              _TabSwitch(current: _tab, onChanged: _switchTab),
              const SizedBox(height: 12),
              _buildRecipeList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            icon: Icons.tune_rounded,
            title: 'Mẹ muốn ăn gì hôm nay?',
            color: MomTheme.amberDark,
            background: AppColors.amberLight,
          ),
          const SizedBox(height: 16),
          const Text('Chế độ ăn', style: AiText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in _dietTypes)
                _Choice(label: d, selected: _dietType == d, onTap: () => setState(() => _dietType = d)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Thời gian nấu tối đa', style: AiText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _cookTimes)
                _Choice(label: '$t phút', selected: _maxCookTime == t, onTap: () => setState(() => _maxCookTime = t)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Nguyên liệu nhà đang có (không bắt buộc)', style: AiText.label),
          const SizedBox(height: 8),
          TextField(
            controller: _ingredientController,
            enabled: !_generating,
            style: AiText.body,
            decoration: const InputDecoration(hintText: 'Ví dụ: ức gà, bí đỏ, đậu phụ'),
          ),
          const SizedBox(height: 16),
          const Text('Mẹ bị dị ứng món gì? (không bắt buộc)', style: AiText.label),
          const SizedBox(height: 8),
          TextField(
            controller: _allergyController,
            enabled: !_generating,
            style: AiText.body,
            decoration: const InputDecoration(hintText: 'Ví dụ: tôm, cua, đậu phộng'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: MomTheme.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_generating ? 'AI đang nghĩ món...' : 'Nhờ AI gợi ý món'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MomTheme.roseDark,
                disabledBackgroundColor: MomTheme.beige,
                textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_generating) ...[
            const SizedBox(height: 8),
            const Center(child: Text('Thường mất khoảng 10–30 giây.', style: AiText.muted)),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: MomTheme.roseDark)),
      );
    }
    if (_error != null) return AiErrorBox(message: _error!, onRetry: _loadRecipes);
    if (_recipes.isEmpty) {
      return AiCard(
        child: Text(
          _tab == _RecipeTab.saved
              ? 'Mẹ chưa lưu món nào. Bấm ♡ trên món mẹ thích để lưu lại.'
              : 'Chưa có món nào. Mẹ chọn sở thích ở trên rồi bấm "Nhờ AI gợi ý món" nhé.',
          style: AiText.muted,
        ),
      );
    }
    return Column(
      children: [
        for (final r in _recipes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecipeCard(
              recipe: r,
              saving: r.id != null && _savingIds.contains(r.id),
              onSave: r.id == null ? null : () => _toggleSave(r),
              onTap: () => _showDetail(r),
            ),
          ),
      ],
    );
  }

  void _showDetail(MomRecipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MomTheme.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero))),
      builder: (_) => _RecipeDetailSheet(recipe: recipe),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final NutritionProfile profile;

  const _ProfileBadge({required this.profile});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      color: MomTheme.pinkLight,
      borderColor: MomTheme.pink,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_rounded, color: MomTheme.roseDark, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Giai đoạn: ${profile.stageLabel}', style: AiText.label.copyWith(fontSize: 16)),
                if (profile.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(profile.description, style: AiText.body.copyWith(fontSize: 15)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Choice({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: selected ? MomTheme.white : MomTheme.charcoalMid,
      ),
      selectedColor: MomTheme.roseDark,
      backgroundColor: MomTheme.creamSoft,
      side: BorderSide(color: selected ? MomTheme.roseDark : MomTheme.beige),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }
}

class _TabSwitch extends StatelessWidget {
  final _RecipeTab current;
  final ValueChanged<_RecipeTab> onChanged;

  const _TabSwitch({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(_RecipeTab t, String label, IconData icon) {
      final active = current == t;
      return Expanded(
        child: Material(
          color: active ? MomTheme.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            onTap: () => onChanged(t),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: active ? MomTheme.roseDark : MomTheme.muted),
                  const SizedBox(width: 6),
                  Text(label,
                      style: AiText.label.copyWith(color: active ? MomTheme.roseDark : MomTheme.muted)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: MomTheme.cream2, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        children: [
          tab(_RecipeTab.recent, 'Món gợi ý', Icons.auto_awesome_rounded),
          tab(_RecipeTab.saved, 'Đã lưu', Icons.favorite_rounded),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RecipeReviewStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      RecipeReviewStatus.approved => ('Chuyên gia đã duyệt', MomTheme.sageDark, MomTheme.sageLight),
      RecipeReviewStatus.rejected => ('Chuyên gia không khuyên dùng', AppColors.rose, AppColors.roseLight),
      RecipeReviewStatus.pending => ('Chờ chuyên gia duyệt', MomTheme.amberDark, AppColors.amberLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label,
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final MomRecipe recipe;
  final bool saving;
  final VoidCallback? onSave;
  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.saving, required this.onSave, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MomTheme.white,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: MomTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusChip(status: recipe.status),
                    const SizedBox(height: 8),
                    Text(recipe.title, style: AiText.section.copyWith(fontSize: 17)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _Meta(icon: Icons.local_fire_department_rounded, text: '${recipe.calories} kcal'),
                        if (recipe.prepTimeMinutes > 0)
                          _Meta(icon: Icons.schedule_rounded, text: '${recipe.prepTimeMinutes} phút'),
                        _Meta(icon: Icons.signal_cellular_alt_rounded, text: recipe.difficulty),
                      ],
                    ),
                  ],
                ),
              ),
              if (onSave != null)
                IconButton(
                  tooltip: recipe.isSaved ? 'Bỏ lưu' : 'Lưu món',
                  iconSize: 28,
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: MomTheme.roseDark),
                        )
                      : Icon(
                          recipe.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: MomTheme.roseDark,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: MomTheme.muted),
        const SizedBox(width: 4),
        Text(text, style: AiText.muted.copyWith(fontSize: 14, color: MomTheme.charcoalMid)),
      ],
    );
  }
}

class _RecipeDetailSheet extends StatelessWidget {
  final MomRecipe recipe;

  const _RecipeDetailSheet({required this.recipe});

  String _g(double v) => v == v.roundToDouble() ? '${v.round()}g' : '${v.toStringAsFixed(1)}g';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: MomTheme.beige, borderRadius: BorderRadius.circular(9)),
            ),
          ),
          const SizedBox(height: 16),
          _StatusChip(status: recipe.status),
          const SizedBox(height: 8),
          Text(recipe.title, style: AiText.title),
          const SizedBox(height: 14),
          Row(
            children: [
              _Nutrient(label: 'Năng lượng', value: '${recipe.calories}', unit: 'kcal'),
              _Nutrient(label: 'Chất đạm', value: _g(recipe.protein)),
              _Nutrient(label: 'Tinh bột', value: _g(recipe.carbs)),
              _Nutrient(label: 'Chất béo', value: _g(recipe.fat)),
            ],
          ),
          if (recipe.ingredients.isNotEmpty) ...[
            const SizedBox(height: 20),
            const AiSectionHeader(icon: Icons.shopping_basket_rounded, title: 'Nguyên liệu'),
            AiBulletList(items: recipe.ingredients),
          ],
          if (recipe.steps.isNotEmpty) ...[
            const SizedBox(height: 20),
            const AiSectionHeader(
              icon: Icons.soup_kitchen_rounded,
              title: 'Cách làm',
              color: MomTheme.sageDark,
              background: MomTheme.sageLight,
            ),
            for (var i = 0; i < recipe.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: MomTheme.sageLight, shape: BoxShape.circle),
                      child: Text('${i + 1}', style: AiText.label.copyWith(color: MomTheme.sageDark)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(recipe.steps[i], style: AiText.body)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Món do AI gợi ý. Mẹ đang mang thai hoặc có bệnh lý nên hỏi bác sĩ trước khi đổi chế độ ăn.',
            style: AiText.muted,
          ),
        ],
      ),
    );
  }
}

class _Nutrient extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const _Nutrient({required this.label, required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: MomTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MomTheme.border),
        ),
        child: Column(
          children: [
            Text(value, style: AiText.label.copyWith(fontSize: 17)),
            if (unit != null) Text(unit!, style: AiText.muted.copyWith(fontSize: 12)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: AiText.muted.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
