import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/app_footer.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sent = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white),
        const SizedBox(width: 10),
        Text('تم إرسال رسالتك بنجاح ✓',
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, color: Colors.white)),
      ]),
      backgroundColor: AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    _nameCtrl.clear(); _emailCtrl.clear(); _messageCtrl.clear();
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _sent = false); });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.beigeBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 170,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF154729), AppColors.primaryGreen],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.contact_support_outlined, color: Colors.white, size: 38)
                        .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 8),
                    Text(l10n.contactUs, style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                        .animate().fadeIn(duration: 400.ms, delay: 150.ms),
                    Text('نحن هنا للمساعدة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: Colors.white70))
                        .animate().fadeIn(duration: 400.ms, delay: 280.ms),
                  ]),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Contact info cards
                ...[
                  (Icons.phone_outlined,       '+213 XX XX XX XX',             'اتصل بنا'),
                  (Icons.email_outlined,        'support@tameenielite.dz',      'راسلنا'),
                  (Icons.location_on_outlined,  'الجزائر العاصمة، الجزائر',    'موقعنا'),
                  (Icons.access_time_outlined,  'من الأحد إلى الخميس 9:00—17:00', 'ساعات العمل'),
                ].asMap().entries.map((e) => _ContactCard(
                  icon: e.value.$1, text: e.value.$2, label: e.value.$3,
                  delay: e.key * 60, colors: colors,
                )),

                const SizedBox(height: 24),

                // Divider with label
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('أرسل رسالة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, color: colors.slate500)),
                  ),
                  const Expanded(child: Divider()),
                ]).animate(delay: 260.ms).fadeIn(),

                const SizedBox(height: 16),

                // Form
                Form(
                  key: _formKey,
                  child: Column(children: [
                    _Field(ctrl: _nameCtrl,    hint: l10n.fullName,    icon: Icons.person_outline_rounded,  delay: 300),
                    const SizedBox(height: 14),
                    _Field(ctrl: _emailCtrl,   hint: l10n.email,       icon: Icons.email_outlined,          delay: 360, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _Field(ctrl: _messageCtrl, hint: l10n.yourMessage, icon: Icons.message_outlined,        delay: 420, maxLines: 5,
                      validator: (v) => (v == null || v.trim().length < 10) ? 'أدخل رسالة لا تقل عن 10 أحرف' : null),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: SpringButton(
                        onTap: _submit,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _sent ? Colors.green.shade600 : AppColors.primaryGreen,
                            disabledBackgroundColor: _sent ? Colors.green.shade600 : AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(_sent ? Icons.check_rounded : Icons.send_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(_sent ? 'تم الإرسال ✓' : l10n.sendMessage,
                                style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ]),
                        ),
                      ),
                    ).animate(delay: 480.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),
                  ]),
                ),

                const SizedBox(height: 16),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: AppFooter()),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String text, label;
  final int delay;
  final AppColorsExtension colors;
  const _ContactCard({required this.icon, required this.text, required this.label, required this.delay, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.warmDivider),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,  style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: colors.slate500)),
          Text(text,   style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w600, color: colors.primaryText)),
        ])),
      ]),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 350.ms).slideX(begin: 0.05, end: 0);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final int delay;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl, required this.hint, required this.icon, required this.delay,
    this.maxLines = 1, this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: GoogleFonts.ibmPlexSansArabic(color: colors.slate500, fontSize: 13),
        filled: true, fillColor: colors.beigeCard,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.warmDivider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.warmDivider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}
