import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../main.dart';
import '../services/profile_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import 'admin_screen.dart';

/// Profile page: the officer's details and progress. Admin is a quiet link at the very bottom.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _edit(BuildContext context, ProfileStore p) async {
    final l = context.l10n;
    final name = TextEditingController(text: p.name);
    final id = TextEditingController(text: p.employeeId);
    final area = TextEditingController(text: p.area);
    final phone = TextEditingController(text: p.phone);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.xs, AppSpace.xl, MediaQuery.of(ctx).viewInsets.bottom + AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.editProfile, style: AppText.title),
            const SizedBox(height: AppSpace.md),
            _field(name, l.fieldName, AppIcons.user),
            _field(id, l.fieldEmployeeId, AppIcons.badge),
            _field(area, l.fieldTerritory, AppIcons.pin),
            _field(phone, l.fieldMobileLong, AppIcons.phone, keyboard: TextInputType.phone),
            const SizedBox(height: AppSpace.sm),
            ChunkyButton(label: l.save, onPressed: () => Navigator.pop(ctx, true)),
          ],
        ),
      ),
    );
    if (ok == true) {
      await p.save(name: name.text, employeeId: id.text, area: area.text, phone: phone.text);
    }
  }

  static Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboard}) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.md),
        child: TextField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.watch<ProfileStore>();
    final attempts = context.watch<HistoryNotifier>().store.attempts;
    final totals = attempts.map((a) => a.result.total).toList();
    final avg = totals.isEmpty ? null : totals.reduce((a, b) => a + b) / totals.length;
    final best = totals.isEmpty ? null : totals.reduce((a, b) => a > b ? a : b);
    final shown = p.name.isEmpty ? l.yourName : p.name;

    return Scaffold(
      appBar: DsAppBar(
        title: l.profile,
        actions: [IconButton(tooltip: l.edit, icon: const Icon(AppIcons.edit), onPressed: () => _edit(context, p))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          DsCard(
            padding: const EdgeInsets.all(AppSpace.xl),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text(
                    p.name.isEmpty ? '?' : p.name.characters.first,
                    style: AppText.display.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shown, style: AppText.title),
                      Text(l.salesOfficer, style: AppText.caption),
                      if (p.name.isEmpty)
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          onPressed: () => _edit(context, p),
                          child: Text(l.completeProfile),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          DsCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _stat(l.attempts, localizeDigits('${attempts.length}', context), AppColors.primary),
                  const VerticalDivider(),
                  _stat(l.avgScore, avg == null ? '–' : localizeDigits(avg.toStringAsFixed(1), context), AppColors.successLight),
                  const VerticalDivider(),
                  _stat(l.bestScore, best == null ? '–' : localizeDigits(best.toStringAsFixed(1), context), AppColors.orangeLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          DsCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
            child: Column(
              children: [
                _info(context, AppIcons.badge, l.fieldEmployeeId, p.employeeId),
                _info(context, AppIcons.pin, l.fieldTerritory, p.area),
                _info(context, AppIcons.phone, l.fieldMobile, p.phone),
              ],
            ),
          ),
          const SizedBox(height: 56),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGate())),
              icon: const Icon(AppIcons.admin, size: 18),
              label: Text(l.admin),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _stat(String label, String value, Color color) => Expanded(
        child: Column(
          children: [
            Text(value, style: AppText.title.copyWith(color: color)),
            Text(label, style: AppText.caption),
          ],
        ),
      );

  static Widget _info(BuildContext context, IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(label, style: AppText.caption),
        subtitle: Text(
          value.isEmpty ? context.l10n.notProvided : value,
          style: value.isEmpty ? AppText.body.copyWith(color: AppColors.textMuted) : AppText.bodyStrong,
        ),
      );
}
