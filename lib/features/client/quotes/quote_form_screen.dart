import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/router/route_arguments.dart';
import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import 'package:tameenidz/features/shared/domain/models/plan_model.dart';
import 'package:tameenidz/features/shared/widgets/smart_quote_form.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../shared/data/policy_repository.dart';
import '../../shared/data/plan_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quote Form Screen — Beautiful beige service cards with icons + animations
// ─────────────────────────────────────────────────────────────────────────────

class QuoteFormScreen extends ConsumerStatefulWidget {
  final Object? extra;
  const QuoteFormScreen({super.key, this.extra});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends ConsumerState<QuoteFormScreen> {
  bool _isSubmitting = false;
  PlanModel? _selectedPlan;
  String? _lockedOperatorId;
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, dynamic>{};
  bool _showForm = false; // step 1 = service picker, step 2 = form

  @override
  void initState() {
    super.initState();
    final extra = widget.extra;
    if (extra is PlanModel) {
      _selectedPlan = extra;
      _lockedOperatorId = extra.operatorId;
      _showForm = true; // skip picker if plan already chosen
    } else if (extra is QuoteFormArgs) {
      _selectedPlan = extra.plan;
      _lockedOperatorId = extra.plan.operatorId;
      _showForm = true;
    } else if (extra is String) {
      _lockedOperatorId = extra;
    }
  }

  Future<void> _submitRequest(AppLocalizations l10n, PlanModel plan, Map<String, dynamic> data) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User session not found.');

      final supabase = Supabase.instance.client;
      final userProfile = await supabase
          .from('users')
          .select('national_id_url, proof_of_address_url')
          .eq('id', user.id)
          .maybeSingle();

      final nationalIdUrl = userProfile?['national_id_url'] as String?;
      final proofUrl = userProfile?['proof_of_address_url'] as String?;

      final policyData = {
        'client_id': user.id,
        'plan_id': plan.id,
        'operator_id': plan.operatorId,
        'status': 'pending',
        'amount': plan.premium,
        'submitted_at': DateTime.now().toIso8601String(),
        'plan_name': plan.companyName,
        'metadata': {
          ...data,
          if (nationalIdUrl != null) 'national_id_url': nationalIdUrl,
          if (proofUrl != null) 'proof_of_address_url': proofUrl,
        },
      };

      await ref.read(policyRepositoryProvider).createPolicy(policyData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.ticketSuccessMessage),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        context.go(AppRoutes.myPolicies);
      }
    } catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AuthExceptionHandler.handle(e, locale)),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final operatorId = _lockedOperatorId ?? 'algeria_takaful';
    final isTakaful = operatorId == 'algeria_takaful';
    final operatorColor = isTakaful ? colors.primaryGreen : colors.alIttihadGreen;
    final plansAsync = ref.watch(plansByOperatorProvider(operatorId));

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: operatorColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          _showForm ? l10n.quoteRequestDetails : l10n.chooseService,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            if (_showForm) {
              setState(() { _showForm = false; _formData.clear(); });
            } else {
              context.pop();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              isTakaful ? l10n.algeriaTakaful : l10n.alIttihadTakaful,
              style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: plansAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: operatorColor)),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(child: Text(l10n.noPlansAvailable,
                style: GoogleFonts.ibmPlexSansArabic(color: colors.onSurface)));
          }
          if (_selectedPlan == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedPlan = plans.first);
            });
            return Center(child: CircularProgressIndicator(color: operatorColor));
          }
          return AnimatedSwitcher(
            duration: 400.ms,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: _showForm
                ? _buildForm(context, l10n, colors, plans, operatorColor, isTakaful)
                : _buildServicePicker(context, l10n, colors, plans, operatorColor, isTakaful),
          );
        },
      ),
    );
  }

  // ── Step 1: Service Cards ────────────────────────────────────────────────
  Widget _buildServicePicker(BuildContext context, AppLocalizations l10n,
      AppColorsExtension colors, List<PlanModel> plans, Color operatorColor, bool isTakaful) {
    return PageEntryAnimation(
      key: const ValueKey('picker'),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                l10n.chooseService,
                style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primaryText),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, idx) => _ServiceCard(
                  plan: plans[idx],
                  operatorColor: operatorColor,
                  isTakaful: isTakaful,
                  delay: Duration(milliseconds: 80 + idx * 60),
                  onTap: () => context.push(AppRoutes.quoteForm, extra: plans[idx]),
                ),
                childCount: plans.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Styled Form ──────────────────────────────────────────────────
  Widget _buildForm(BuildContext context, AppLocalizations l10n,
      AppColorsExtension colors, List<PlanModel> plans, Color operatorColor, bool isTakaful) {
    return Form(
      key: _formKey,
      child: PageEntryAnimation(
        key: const ValueKey('form'),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Selected Service Summary ─────────────────────────────
              _SelectedServiceBanner(plan: _selectedPlan!, operatorColor: operatorColor,
                onChangePlan: () => setState(() { _showForm = false; _formData.clear(); }),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              // ── Plan Features ────────────────────────────────────────
              _PlanFeatureRow(plan: _selectedPlan!, operatorColor: operatorColor)
                .animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 28),

              // ── Form Section Header ──────────────────────────────────
              Row(children: [
                Container(
                  width: 4, height: 22,
                  decoration: BoxDecoration(color: operatorColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 10),
                Text(l10n.requestData, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primaryText)),
              ]).animate().fadeIn(duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 16),

              SmartQuoteForm(
                plan: _selectedPlan!,
                formKey: _formKey,
                formData: _formData,
                onDataChanged: (updated) {},
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 32),

              // ── Submit Button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: SpringButton(
                  onTap: () => _submitRequest(l10n, _selectedPlan!, _formData),
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: operatorColor,
                      disabledBackgroundColor: operatorColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(l10n.submitQuoteRequest,
                                style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          ]),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Service Card Widget ──────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final PlanModel plan;
  final Color operatorColor;
  final bool isTakaful;
  final Duration delay;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.plan,
    required this.operatorColor,
    required this.isTakaful,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: colors.beigeCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: operatorColor.withValues(alpha: 0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: operatorColor.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [operatorColor.withValues(alpha: 0.15), operatorColor.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: operatorColor.withValues(alpha: 0.2)),
                    ),
                    child: Icon(plan.resolvedIcon, color: operatorColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.companyName,
                            style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 17, color: colors.primaryText)),
                        const SizedBox(height: 4),
                        Text(plan.coverage,
                            style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: colors.slate500, height: 1.4)),
                        const SizedBox(height: 8),
                        // Feature pills
                        Wrap(spacing: 6, runSpacing: 4, children: [
                          _FeaturePill(label: '${plan.premium} دج', icon: Icons.payments_outlined, color: operatorColor),
                          _FeaturePill(label: plan.claimsDuration, icon: Icons.timer_outlined, color: operatorColor),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: operatorColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: operatorColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    .animate(delay: delay)
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _FeaturePill({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.ibmPlexSansArabic(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Selected Service Banner ──────────────────────────────────────────────────
class _SelectedServiceBanner extends StatelessWidget {
  final PlanModel plan;
  final Color operatorColor;
  final VoidCallback onChangePlan;

  const _SelectedServiceBanner({required this.plan, required this.operatorColor, required this.onChangePlan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [operatorColor.withValues(alpha: 0.12), operatorColor.withValues(alpha: 0.04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: operatorColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: operatorColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(plan.resolvedIcon, color: operatorColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.serviceChosen, style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: operatorColor)),
              Text(plan.companyName, style: GoogleFonts.amiri(fontSize: 17, fontWeight: FontWeight.bold, color: colors.primaryText)),
              Text(plan.coverage, style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: colors.slate500)),
            ]),
          ),
          TextButton(
            onPressed: onChangePlan,
            child: Text(l10n.change, style: GoogleFonts.ibmPlexSansArabic(color: operatorColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Plan Feature Row ─────────────────────────────────────────────────────────
class _PlanFeatureRow extends StatelessWidget {
  final PlanModel plan;
  final Color operatorColor;
  const _PlanFeatureRow({required this.plan, required this.operatorColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.warmDivider),
      ),
      child: Row(
        children: [
          _FeatureStat(label: l10n.annualPremium, value: '${plan.premium} دج', icon: Icons.payments_outlined, color: operatorColor),
          _Divider(),
          _FeatureStat(label: l10n.donationRate, value: plan.tabarruRate, icon: Icons.volunteer_activism_outlined, color: operatorColor),
          _Divider(),
          _FeatureStat(label: l10n.settlement, value: plan.claimsDuration, icon: Icons.timer_outlined, color: operatorColor),
        ],
      ),
    );
  }
}

class _FeatureStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _FeatureStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 12, color: colors.primaryText), textAlign: TextAlign.center),
      Text(label, style: GoogleFonts.ibmPlexSansArabic(fontSize: 10, color: colors.slate500), textAlign: TextAlign.center),
    ]));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: context.colors.warmDivider);
}
