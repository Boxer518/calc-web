import 'package:flutter/material.dart';

/// Держит форму по центру и не даёт ей растянуться шире [maxWidth].
///
/// На узком окне панель занимает доступную ширину и прокручивается,
/// если содержимое выше экрана.
class CenteredPanel extends StatelessWidget {
  const CenteredPanel({
    required this.child,
    this.maxWidth = 420,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
