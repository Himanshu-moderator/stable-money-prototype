import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Direct match for the "Profile details" edit screen from the
/// screenshots, pre-filled with whatever was captured during onboarding.
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late final _nameController =
      TextEditingController(text: widget.appState.profile.fullName);
  late final _emailController =
      TextEditingController(text: widget.appState.profile.email);
  late String? _gender = widget.appState.profile.gender;
  late String? _occupation = widget.appState.profile.occupation;
  late String? _income = widget.appState.profile.income;
  late final Set<String> _products = {
    ...widget.appState.profile.investmentInterests
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    widget.appState.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _gender,
      occupation: _occupation,
      income: _income,
      investmentInterests: _products,
    );
    showPrototypeNotice(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.appState.profile;
    final dob = (p.day != null && p.month != null && p.year != null)
        ? '${p.day.toString().padLeft(2, '0')} - ${p.month.toString().padLeft(2, '0')} - ${p.year}'
        : 'Not set';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            const _Label('BASIC DETAILS'),
            _Card(
              children: [
                _Row(
                  icon: Icons.person_outline,
                  label: 'Full name',
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(height: 1),
                _Row(
                  icon: Icons.mail_outline,
                  label: 'Email address',
                  trailing: Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.grey),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(height: 1),
                _Row(
                  icon: Icons.call_outlined,
                  label: 'Mobile number',
                  child: Text(
                    p.mobile.isEmpty ? '—' : p.mobile,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _Label('DATE OF BIRTH'),
            _Card(
              children: [
                _Row(
                  icon: Icons.calendar_today_outlined,
                  label: '',
                  child: Text(dob,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('You are seeing regular citizen FD rates as per your age',
                style: TextStyle(fontSize: 12, color: AppColors.grey)),
            const SizedBox(height: 22),
            const _Label('GENDER'),
            _ChipWrap(
              options: const ['Male', 'Female', 'Other'],
              selected: _gender == null ? {} : {_gender!},
              onTap: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 22),
            const _Label('OCCUPATION'),
            _ChipWrap(
              options: MockData.occupations,
              selected: _occupation == null ? {} : {_occupation!},
              onTap: (v) => setState(() => _occupation = v),
            ),
            const SizedBox(height: 22),
            const _Label('ANNUAL INCOME'),
            _ChipWrap(
              options: MockData.incomeBands,
              selected: _income == null ? {} : {_income!},
              onTap: (v) => setState(() => _income = v),
            ),
            const SizedBox(height: 22),
            const _Label('SELECT PRODUCTS YOU INVEST IN'),
            _ChipWrap(
              options: MockData.investmentProducts,
              selected: _products,
              onTap: (v) => setState(() {
                _products.contains(v)
                    ? _products.remove(v)
                    : _products.add(v);
              }),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SAVINGS BANK ACCOUNTS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey,
                        letterSpacing: 0.6)),
                OutlinedButton.icon(
                  onPressed: () => showPrototypeNotice(context, 'Edit bank accounts'),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: BorderSide(color: AppColors.hairline),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1F6FE0),
                  child: Text('S',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Text(p.linkedBank ?? 'SBI',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: BlackPillButton(label: 'Update my profile', onPressed: _save),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.grey,
                letterSpacing: 0.6)),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      );
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.icon,
      required this.label,
      required this.child,
      this.trailing});
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.ink, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(label,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.grey)),
                  if (label.isNotEmpty) const SizedBox(height: 2),
                  child,
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap(
      {required this.options, required this.selected, required this.onTap});
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((o) {
          final isSelected = selected.contains(o);
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onTap(o),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.ctaFill : AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isSelected ? AppColors.ctaFill : AppColors.hairline),
              ),
              child: Text(o,
                  style: TextStyle(
                      color: isSelected ? AppColors.onCta : AppColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          );
        }).toList(),
      );
}
