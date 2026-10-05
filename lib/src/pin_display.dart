import 'package:flutter/material.dart';

/// Visual style of each [PinDisplay] cell.
enum PinDisplayShape {
  /// Small circles that fill in as digits are entered.
  dot,

  /// Outlined boxes, one per digit.
  box,

  /// A line under each digit.
  underline,
}

/// Shows the progress of a PIN or OTP entered through a `NumberPad`.
///
/// Pass the same [controller] to both widgets; [PinDisplay] rebuilds as the
/// text changes and calls [onCompleted] once [length] digits are entered.
class PinDisplay extends StatefulWidget {
  /// The controller shared with the number pad.
  final TextEditingController controller;

  /// The number of digits in the PIN.
  final int length;

  /// The visual style of each cell.
  final PinDisplayShape shape;

  /// Whether to hide entered digits. Ignored for [PinDisplayShape.dot].
  final bool obscureText;

  /// The character shown in place of each digit when [obscureText] is true.
  final String obscuringCharacter;

  /// The width and height of each cell. Defaults to 16 for dots and 48
  /// otherwise.
  final double? size;

  /// The space between cells.
  final double spacing;

  /// The color of filled cells. Defaults to [ColorScheme.primary].
  final Color? filledColor;

  /// The color of empty cells. Defaults to [ColorScheme.outline].
  final Color? emptyColor;

  /// The border color of the next cell to be filled. Defaults to
  /// [ColorScheme.primary].
  final Color? activeColor;

  /// The color used for every cell while [hasError] is true. Defaults to
  /// [ColorScheme.error].
  final Color? errorColor;

  /// Whether to show the error state, e.g. after a wrong PIN.
  final bool hasError;

  /// The text style for digits in [PinDisplayShape.box] and
  /// [PinDisplayShape.underline].
  final TextStyle? textStyle;

  /// The corner radius of [PinDisplayShape.box] cells.
  final double borderRadius;

  /// The border width of [PinDisplayShape.box] and
  /// [PinDisplayShape.underline] cells.
  final double borderWidth;

  /// Called once each time the input reaches [length] digits.
  final ValueChanged<String>? onCompleted;

  /// The name screen readers announce before the progress, e.g. "PIN".
  final String semanticLabel;

  const PinDisplay({
    super.key,
    required this.controller,
    required this.length,
    this.shape = PinDisplayShape.dot,
    this.obscureText = true,
    this.obscuringCharacter = '•',
    this.size,
    this.spacing = 12,
    this.filledColor,
    this.emptyColor,
    this.activeColor,
    this.errorColor,
    this.hasError = false,
    this.textStyle,
    this.borderRadius = 8,
    this.borderWidth = 2,
    this.onCompleted,
    this.semanticLabel = 'PIN',
  }) : assert(length > 0);

  @override
  State<PinDisplay> createState() => _PinDisplayState();
}

class _PinDisplayState extends State<PinDisplay> {
  late int _previousLength = widget.controller.text.length;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(PinDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
      _previousLength = widget.controller.text.length;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    final completed =
        text.length >= widget.length && _previousLength < widget.length;
    _previousLength = text.length;
    setState(() {});
    if (completed) widget.onCompleted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = widget.controller.text;
    final entered = text.length.clamp(0, widget.length);

    return Semantics(
      label: widget.semanticLabel,
      value: '$entered of ${widget.length} digits entered',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              _buildCell(
                context,
                colorScheme,
                char: i < text.length ? text[i] : null,
                isActive: i == text.length,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    ColorScheme colorScheme, {
    required String? char,
    required bool isActive,
  }) {
    const duration = Duration(milliseconds: 150);
    final filled = char != null;
    final errorColor = widget.errorColor ?? colorScheme.error;
    final filledColor = widget.hasError
        ? errorColor
        : widget.filledColor ?? colorScheme.primary;
    final emptyColor = widget.hasError
        ? errorColor
        : widget.emptyColor ?? colorScheme.outline;
    final activeColor = widget.hasError
        ? errorColor
        : widget.activeColor ?? colorScheme.primary;

    if (widget.shape == PinDisplayShape.dot) {
      final size = widget.size ?? 16;
      return AnimatedContainer(
        duration: duration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? filledColor : Colors.transparent,
          border: Border.all(
            color: filled ? filledColor : emptyColor,
            width: 2,
          ),
        ),
      );
    }

    final size = widget.size ?? 48;
    final borderColor = filled
        ? filledColor
        : isActive
        ? activeColor
        : emptyColor;
    final side = BorderSide(color: borderColor, width: widget.borderWidth);
    final style =
        widget.textStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: widget.hasError ? errorColor : colorScheme.onSurface,
        );

    return AnimatedContainer(
      duration: duration,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: widget.shape == PinDisplayShape.box
          ? BoxDecoration(
              border: Border.fromBorderSide(side),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            )
          : BoxDecoration(border: Border(bottom: side)),
      child: char == null
          ? null
          : Text(
              widget.obscureText ? widget.obscuringCharacter : char,
              style: style,
            ),
    );
  }
}
