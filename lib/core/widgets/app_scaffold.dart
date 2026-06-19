import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Breakpoint above which content is constrained and centered (web/desktop).
const double kContentMaxWidth = 480;

/// A responsive scaffold used by every page.
///
/// Responsibilities:
///  - Constrains body width on large screens (web/desktop) so a mobile-first
///    layout stays readable, while filling the screen on phones.
///  - Renders the "UAT Ver 1" banner under the AppBar when running in UAT.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.showAppBar = true,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.padding,
  });

  final Widget body;
  final String? title;

  /// Optional fully custom AppBar. If null and [showAppBar] is true, a default
  /// AppBar is built from [title]/[actions].
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  /// Persistent bottom bar (e.g. a primary action button).
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showAppBar;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final showBanner = appState.isUat && appState.bannerText.isNotEmpty;

    PreferredSizeWidget? effectiveAppBar;
    if (appBar != null) {
      effectiveAppBar = appBar;
    } else if (showAppBar) {
      effectiveAppBar = AppBar(
        title: title != null ? Text(title!) : null,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
      );
    }

    Widget content = body;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Constrain width on large screens for a clean responsive layout.
    content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
        child: content,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: effectiveAppBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          if (showBanner) const _UatBanner(),
          Expanded(child: content),
          if (bottomBar != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: kContentMaxWidth),
                    child: bottomBar,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UatBanner extends StatelessWidget {
  const _UatBanner();

  @override
  Widget build(BuildContext context) {
    final text = context.read<AppState>().bannerText;
    return Material(
      color: AppColors.uatBanner,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
