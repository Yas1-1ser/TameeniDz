import 'package:flutter/material.dart';

/// Tameeni Elite — Single source of truth for all brand colors.
/// Import this from core/theme/app_colors.dart everywhere.
class AppColors {
  // ── Primary Brand (Tameeni Green) ────────────────────────────────
  static const Color primaryGreen = Color(0xFF1B6B45);
  static const Color primaryLight = Color(0xFF7EA47A);
  static const Color primaryDark = Color(0xFF005231);
  static const Color primaryContainer = Color(0xFFE8F3ED);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF002111);
  static const Color inversePrimary = Color(0xFF8AD7A8);
  static const Color primaryTint = Color(0x0D1B6B45);
  static const Color primaryTintLight = Color(0x051B6B45);
  static const Color primaryOverlay = Color(0x1A1B6B45);
  static const Color onPrimaryContainerSoft = Color(0xFF9BE9B9);

  // ── Green Brand Dark ──
  static const Color primaryGreenDark = Color(0xFF8AD7A8); // light text on dark bg

  // ── Gold Accent ──────────────────────────────────────────────────
  static const Color goldAccent = Color(0xFFC9A84C);
  static const Color accentGold = goldAccent;
  static const Color gold = goldAccent;
  static const Color goldContainer = Color(0xFFFFF9E6);
  static const Color goldLight = Color(0xFFFFF3D0);
  static const Color goldDeep = Color(0xFFB8973A);
  static const Color onSecondaryContainer = Color(0xFF785D00);

  // ── Al-Ittihad Brand ────────────────────────────────────────────
  static const Color alIttihadGreen = Color(0xFF0D5235);

  // ── Beige / warm background (light mode) ──
  static const Color beigeBg = Color(0xFFFDF8F0);
  static const Color backgroundBeige = beigeBg;
  static const Color beigeCard = Color(0xFFFFFBF5);
  static const Color surfaceBeige = beigeCard;
  static const Color beigeDeep = Color(0xFFF5F0E8);
  static const Color warmDivider = Color(0xFFE8E0D0);
  static const Color warmBackground = Color(0xFFF5F3EE);

  // ── Dark mode backgrounds ──
  static const Color backgroundDark = Color(0xFF101411);
  static const Color surfaceDark = Color(0xFF1A211C);
  static const Color surfaceCardDark = Color(0xFF1F2920);
  static const Color surfaceContainerDark = Color(0xFF253329);
  static const Color dividerDark = Color(0xFF2E3D31);
  static const Color onSurfaceDark = Color(0xFFF4F7F1);
  static const Color onSurfaceVariantDark = Color(0xFFB8C6BA);
  static const Color outlineDark = Color(0xFF435448);

  // ── Light Mode Neutrals ──────────────────────────────────────────
  static const Color background = Color(0xFFFBFBFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F2EC);
  static const Color softSlate = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F4F2);
  static const Color surfaceContainerHigh = Color(0xFFE8EBE9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F5);
  static const Color outlineVariant = Color(0xFFDDE2DF);
  static const Color sidebarBg = Color(0xFFF8FAFB);
  static const Color bootButtonBg = Color(0xFFE8F0EC);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color darkText = Color(0xFF1B1B1D);
  static const Color textPrimary = darkText;
  static const Color textDark = darkText;
  static const Color onSurface = Color(0xFF1B1B1D);
  static const Color onSurfaceVariant = Color(0xFF3F4942);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textSecondary = textMuted;
  static const Color subText = textMuted;
  static const Color ctaText = offWhite;

  // ── Slate Scale ──────────────────────────────────────────────────
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);

  // ── Status Badges (Decree 21-81 workflow) ────────────────────────
  static const Color pending = Color(0xFFF59E0B);
  static const Color accepted = Color(0xFF10B981);
  static const Color rejected = Color(0xFFEF4444);
  static const Color modRequested = Color(0xFFF97316);
  static const Color error = Color(0xFFBA1A1A);

  // ── Fund Separation ──────────────────────────────────────────────
  static const Color subscriberFund = Color(0xFF0D9488);
  static const Color shareholderFund = primaryGreen;

  // ── Renewal Alerts ───────────────────────────────────────────────
  static const Color alert30d = Color(0xFFFBBF24);
  static const Color alert7d = Color(0xFFF97316);
  static const Color alert24h = Color(0xFFEF4444);

  // ── Input / Border ───────────────────────────────────────────────
  static const Color inputBorderLight = Color(0xFFE0E0E0);
  static const Color inputBg = slate100;

  // ── Aliases for backward compatibility ───────────────────────────
  static const Color primary = primaryGreen;
  static const Color secondary = goldAccent;
  static const Color border = slate200;
  static const Color outline = slate200;
  static const Color success = accepted;
  static const Color takafulGreen = primaryGreen;
  static const Color primaryGreenLight = primaryLight;
  static const Color primaryGreenContainer = primaryContainer;
  static const Color primaryGreenTint = primaryTint;
  static const Color primaryGreenTintLight = primaryTintLight;
  static const Color primaryGreenOverlay = primaryOverlay;

  // ── offWhite container aliases (backward compat) ─────────────────
  static const Color offWhiteContainer = offWhite;
  static const Color offWhiteContainerHigh = Color(0xFFF0F4F8);
  static const Color offWhiteContainerLowest = Color(0xFFFCFDFE);
  static const Color offWhiteContainerLow = Color(0xFFF0F4F8);

  // ── Beige Premium Theme ──────────────────────────────────────────
  static const Color bgPage        = Color(0xFFF5F0E8);  // warm beige page
  static const Color bgCard        = Color(0xFFFFFFFF);  // pure white cards
  static const Color bgCardSurface = Color(0xFFF5F0E8);  // inner surfaces
  static const Color borderLight   = Color(0xFFE5DDD0);  // card borders
  static const Color beigeGold     = Color(0xFFC9A96E);  // primary gold accent
  static const Color darkBrown     = Color(0xFF2D1F0E);  // hero bg, deep text
  static const Color midBrown      = Color(0xFF8B7355);  // secondary text
  static const Color deepBrown     = Color(0xFF4A3520);  // hero gradient end
  static const Color statusGreenBg = Color(0xFFE8F5EC);
  static const Color statusGreenFg = Color(0xFF3A7D4E);
  static const Color statusAmberBg = Color(0xFFFDF3E0);
  static const Color statusAmberFg = Color(0xFFA07020);
  static const Color statusRedBg   = Color(0xFFFBE9E9);
  static const Color statusRedFg   = Color(0xFFA03030);
}
