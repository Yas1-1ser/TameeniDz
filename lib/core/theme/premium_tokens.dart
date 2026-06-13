// lib/core/theme/premium_tokens.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

// ── PALETTE MAPPINGS (BEIGE-GOLD PREMIUM DESIGN SYSTEM) ─────────────────────
// Backgrounds
const Color kIvory         = AppColors.beigeBg;       // scaffold background (0xFFFDF8F0)
const Color kCream         = AppColors.beigeCard;     // card surface (0xFFFFFBF5)
const Color kParchment     = AppColors.beigeDeep;     // inner surfaces / chip bg (0xFFF5F0E8)
const Color kDivider       = AppColors.warmDivider;   // dividers / borders (0xFFE8E0D0)

// Gold spectrum
const Color kGoldDeep      = AppColors.goldDeep;      // deep gold (0xFFB8973A)
const Color kGoldMid       = AppColors.beigeGold;     // primary gold accent (0xFFC9A96E)
const Color kGoldLight     = AppColors.goldAccent;    // secondary gold (0xFFC9A84C)
const Color kGoldShimmer   = AppColors.goldLight;     // gold wash (0xFFFFF3D0)

// Typography
const Color kInk           = AppColors.darkBrown;     // primary text / headings (0xFF2D1F0E)
const Color kInkMuted      = AppColors.midBrown;      // secondary / muted text (0xFF8B7355)
const Color kInkFaint      = AppColors.deepBrown;     // caption / disabled (0xFF4A3520)

// Status (warm palette)
const Color kStatusPending  = AppColors.statusAmberFg; // pending (0xFFA07020)
const Color kStatusAccepted = AppColors.statusGreenFg; // accepted (0xFF3A7D4E)
const Color kStatusPaid     = AppColors.statusGreenFg; // paid (0xFF3A7D4E)
const Color kStatusRejected = AppColors.statusRedFg;   // rejected (0xFFA03030)
const Color kStatusMod      = AppColors.goldDeep;      // modification requested

// ── ELEVATION / SHADOW ─────────────────────────────────────────────────────
final BoxShadow kCardShadow = BoxShadow(
  color: kGoldMid.withValues(alpha: 0.10),
  blurRadius: 16,
  spreadRadius: 0,
  offset: const Offset(0, 5),
);

final BoxShadow kCardShadowHover = BoxShadow(
  color: kGoldMid.withValues(alpha: 0.18),
  blurRadius: 24,
  offset: const Offset(0, 8),
);

// ── BORDER RADIUS ──────────────────────────────────────────────────────────
const double kRadiusSm  = 10;
const double kRadiusMd  = 16;
const double kRadiusLg  = 24;
const double kRadiusXl  = 32;

// ── GRADIENTS ──────────────────────────────────────────────────────────────
const LinearGradient kGoldGradient = LinearGradient(
  colors: [kGoldDeep, kGoldMid],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kCardGradient = LinearGradient(
  colors: [kCream, kParchment],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
