import 'dart:async';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors_extension.dart';
import '../../../../../core/router/route_arguments.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isRegistration;
  final String? email;
  final String? fullName;
  final String? ccpNumber;
  final String? nin;
  final String? wilaya;
  final String? dob;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.isRegistration = false,
    this.email,
    this.fullName,
    this.ccpNumber,
    this.nin,
    this.wilaya,
    this.dob,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  // BUG #8 FIX: Pre-allocate nodes for KeyboardListener to prevent leaks
  final List<FocusNode> _keyListenerNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 90; // 1:30
  bool _canResend = false;
  bool _isVerifying = false;
  String? _errorMessage;
  Timer? _timer; // BUG #9 FIX: Use a managed Timer instead of Future.doWhile

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var node in _keyListenerNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    final allFilled = _controllers.every((c) => c.text.isNotEmpty);
    if (allFilled) {
      _verifyCode();
    }
  }

  void _onKeyPress(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    setState(() => _isVerifying = true);
    _errorMessage = null;

    // DEMO VERIFICATION: Bypasses real Firebase Auth for showcase purposes
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() => _isVerifying = false);
      _navigateToNextStep();
    }
  }

  void _navigateToNextStep() {
    if (widget.isRegistration) {
      context.push(
        '/register/step2',
        extra: RegisterStep2Args(
          email: widget.email ?? '',
          fullName: widget.fullName ?? '',
          phoneNumber: widget.phoneNumber,
          ccpNumber: widget.ccpNumber ?? '',
          nin: widget.nin,
          wilaya: widget.wilaya,
          dob: widget.dob,
        ),
      );
    } else {
      context.go('/client');
    }
  }

  void _resendCode() async {
    setState(() => _isVerifying = true);
    
    // DUMMY RESEND
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isVerifying = false;
        _secondsRemaining = 90;
        _canResend = false;
        _errorMessage = null;
      });
      _startTimer();
      
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.otpSentTo)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.otpVerification,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            size: 24,
          ),
          onPressed: () {
            if (widget.isRegistration) {
              context.go('/register/step1');
            } else {
              context.go('/client/login');
            }
          },
        ),
      ),
      body: PageEntryAnimation(child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BUG #24 FIX: Stepper order [1, 2, 3]
              if (widget.isRegistration) ...[
                _buildStepper(l10n),
                const SizedBox(height: 32),
              ],
              _buildOtpCard(l10n),
              const SizedBox(height: 32),
              _buildVerifyButton(),
              const SizedBox(height: 16),
              
              // Demo Skip Button - Always available as requested
              TextButton(
                onPressed: _navigateToNextStep,
                child: Text(
                  l10n.skipForDemo,
                  style: TextStyle(
                    color: context.colors.slate400,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(number: '1', title: l10n.information, state: _StepState.completed),
        _buildStepDivider(),
        _buildStepNode(number: '2', title: l10n.verification, state: _StepState.active),
        _buildStepDivider(),
        _buildStepNode(number: '3', title: l10n.documents, state: _StepState.upcoming),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 2,
        color: context.colors.slate200,
      ),
    );
  }

  Widget _buildStepNode({
    required String number,
    required String title,
    required _StepState state,
  }) {
    Color circleColor;
    Color borderColor;
    Widget content;
    Color textColor;

    switch (state) {
      case _StepState.completed:
        circleColor = AppColors.goldAccent;
        borderColor = AppColors.goldAccent;
        content = const Icon(Icons.check, color: Colors.white, size: 16);
        textColor = AppColors.goldAccent;
        break;
      case _StepState.active:
        circleColor = Colors.white;
        borderColor = AppColors.goldAccent;
        content = Text(
          number,
          style: TextStyle(
            color: AppColors.goldAccent,
            fontWeight: FontWeight.bold,
          ),
        );
        textColor = AppColors.goldAccent;
        break;
      case _StepState.upcoming:
        circleColor = Colors.transparent;
        borderColor = context.colors.slate300;
        content = Text(
          number,
          style: TextStyle(
            color: context.colors.slate400,
            fontWeight: FontWeight.bold,
          ),
        );
        textColor = context.colors.slate400;
        break;
    }

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(color: borderColor, width: 2),
            ),
            alignment: Alignment.center,
            child: content,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontFamily: 'Cairo',
              fontWeight:
                  state == _StepState.active
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(AppLocalizations l10n) {
    String hiddenPhone = widget.phoneNumber;
    if (hiddenPhone.length > 4) {
      hiddenPhone =
          '*** *** ${hiddenPhone.substring(0, 4)} ${hiddenPhone.substring(hiddenPhone.length - 2)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.amber,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.enterOtpCode,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.colors.darkText,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.otpSentSubtitle(hiddenPhone),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.slate500,
              height: 1.5,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) => _buildOtpBox(index)),
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 14, fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            l10n.resendAfter(_formattedTime),
            style: TextStyle(color: context.colors.slate500, fontSize: 14, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _canResend && !_isVerifying ? _resendCode : null,
            child: Text(
              l10n.resendCode,
              style: TextStyle(
                color:
                    _canResend
                        ? AppColors.primaryGreen
                        : context.colors.slate300,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 40,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _focusNodes[index].hasFocus
                  ? Colors
                      .blue // Blue border on focus as per design
                  : context.colors.slate200,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: KeyboardListener(
        focusNode: _keyListenerNodes[index], // FIXED: Use pre-allocated node
        onKeyEvent: (event) => _onKeyPress(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onDigitChanged(index, value),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isVerifying ? null : _verifyCode,
        child:
            _isVerifying
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: context.colors.surface,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  l10n.verify,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
      ),
    );
  }
}

enum _StepState { completed, active, upcoming }
