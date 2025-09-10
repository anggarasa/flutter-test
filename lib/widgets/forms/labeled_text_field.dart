import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertest/configs/theme/app_colors.dart';

class LabeledTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? focusColor;
  final Color? borderColor;
  final Color? errorColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool showFloatingLabel;
  final bool showCounter;
  final Duration animationDuration;

  const LabeledTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.fillColor,
    this.focusColor,
    this.borderColor,
    this.errorColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.showFloatingLabel = true,
    this.showCounter = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _fillColorAnimation;

  bool _isFocused = false;
  bool _hasError = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _borderColorAnimation =
        ColorTween(
          begin: widget.borderColor ?? AppColors.lightGrey,
          end: widget.focusColor ?? AppColors.primary,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _fillColorAnimation =
        ColorTween(
          begin: widget.fillColor ?? AppColors.surface,
          end: (widget.fillColor ?? AppColors.surface).withValues(alpha: 0.8),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _setupListeners() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        setState(() {
          _currentText = widget.controller!.text;
        });
      });
    }
  }

  @override
  void didUpdateWidget(LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Color get _getCurrentBorderColor {
    if (_hasError) {
      return widget.errorColor ?? AppColors.error;
    }
    return _borderColorAnimation.value ?? AppColors.lightGrey;
  }

  Color get _getCurrentFillColor {
    if (_hasError) {
      return (widget.errorColor ?? AppColors.error).withValues(alpha: 0.05);
    }
    return _fillColorAnimation.value ?? AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main TextField Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color:
                              (_hasError
                                      ? (widget.errorColor ?? AppColors.error)
                                      : (widget.focusColor ??
                                            AppColors.primary))
                                  .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                validator: widget.validator,
                inputFormatters: widget.inputFormatters,
                textInputAction: widget.textInputAction,
                textCapitalization: widget.textCapitalization,
                autofocus: widget.autofocus,
                style:
                    widget.textStyle ??
                    TextStyle(
                      color: widget.enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                decoration: InputDecoration(
                  labelText: widget.showFloatingLabel ? widget.labelText : null,
                  hintText: widget.hintText,
                  helperText: widget.helperText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon != null
                      ? AnimatedContainer(
                          duration: widget.animationDuration,
                          child: Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? (_hasError
                                      ? (widget.errorColor ?? AppColors.error)
                                      : (widget.focusColor ??
                                            AppColors.primary))
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? AnimatedContainer(
                          duration: widget.animationDuration,
                          child: widget.suffixIcon,
                        )
                      : null,
                  filled: true,
                  fillColor: _getCurrentFillColor,
                  contentPadding:
                      widget.contentPadding ??
                      EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: widget.maxLines == 1 ? 16 : 12,
                      ),
                  border: _buildBorder(),
                  enabledBorder: _buildBorder(),
                  focusedBorder: _buildFocusedBorder(),
                  errorBorder: _buildErrorBorder(),
                  focusedErrorBorder: _buildErrorBorder(),
                  disabledBorder: _buildDisabledBorder(),
                  labelStyle:
                      widget.labelStyle ??
                      TextStyle(
                        color: _isFocused
                            ? (_hasError
                                  ? (widget.errorColor ?? AppColors.error)
                                  : (widget.focusColor ?? AppColors.primary))
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                  hintStyle:
                      widget.hintStyle ??
                      TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                  errorStyle: TextStyle(
                    color: widget.errorColor ?? AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  helperStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  counterStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  counterText: widget.showCounter ? null : '',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: widget.borderColor ?? AppColors.lightGrey,
        width: 1.5,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: _getCurrentBorderColor, width: 2.0),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: widget.errorColor ?? AppColors.error,
        width: 2.0,
      ),
    );
  }

  OutlineInputBorder _buildDisabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: AppColors.lightGrey.withValues(alpha: 0.5),
        width: 1.0,
      ),
    );
  }
}

// Extension untuk kemudahan penggunaan
extension LabeledTextFieldExtension on LabeledTextField {
  // Preset untuk email field
  static LabeledTextField email({
    Key? key,
    String? labelText = 'Email',
    String? hintText = 'Enter your email',
    TextEditingController? controller,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return LabeledTextField(
      key: key,
      labelText: labelText,
      hintText: hintText,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      validator: validator,
      textInputAction: TextInputAction.next,
    );
  }

  // Preset untuk password field
  static LabeledTextField password({
    Key? key,
    String? labelText = 'Password',
    String? hintText = 'Enter your password',
    TextEditingController? controller,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool obscureText = true,
    Widget? suffixIcon,
  }) {
    return LabeledTextField(
      key: key,
      labelText: labelText,
      hintText: hintText,
      controller: controller,
      obscureText: obscureText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      validator: validator,
      textInputAction: TextInputAction.done,
    );
  }

  // Preset untuk search field
  static LabeledTextField search({
    Key? key,
    String? hintText = 'Search...',
    TextEditingController? controller,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
  }) {
    return LabeledTextField(
      key: key,
      hintText: hintText,
      controller: controller,
      keyboardType: TextInputType.text,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      showFloatingLabel: false,
      borderRadius: 25.0,
    );
  }

  // Preset untuk textarea/multiline
  static LabeledTextField textarea({
    Key? key,
    String? labelText,
    String? hintText,
    TextEditingController? controller,
    Function(String)? onChanged,
    int maxLines = 4,
    int? maxLength,
  }) {
    return LabeledTextField(
      key: key,
      labelText: labelText,
      hintText: hintText,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
    );
  }
}
