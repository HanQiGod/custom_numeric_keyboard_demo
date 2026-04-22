import 'package:flutter/material.dart';

typedef HsNumberKeyboardDisplayBuilder = Widget Function(
  BuildContext context,
  String value,
);

typedef HsNumberKeyboardBuilder = Widget Function(
  BuildContext context,
  HsNumberKeyboardController controller,
  ValueChanged<String> onConfirm,
);

/// 数字键盘控制器。
class HsNumberKeyboardController extends ValueNotifier<String> {
  HsNumberKeyboardController([super.value = '']);

  void clear() {
    value = '';
  }

  void setValue(String nextValue) {
    value = nextValue;
  }
}

/// 底部数字键盘组件。
///
/// 支持数字、小数点、删除和确认操作，适合金额、验证码之外的数字输入场景。
class HsNumberKeyboard extends StatefulWidget {
  const HsNumberKeyboard({
    super.key,
    this.controller,
    this.initialValue = '',
    this.placeholder = '',
    this.maxLength,
    this.decimalDigits,
    this.showDecimal = true,
    this.confirmText = '确定',
    this.onChanged,
    this.onDelete,
    this.onConfirm,
    this.showDisplay = true,
    this.displayBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 12),
    this.spacing = 8,
    this.displayHeight = 52,
    this.keyHeight = 56,
    this.backgroundColor = const Color(0xFFF3F5F9),
    this.displayBackgroundColor = Colors.white,
    this.keyBackgroundColor = Colors.white,
    this.confirmBackgroundColor = const Color(0xFF0B3A5B),
    this.valueTextStyle,
    this.placeholderTextStyle,
    this.keyTextStyle,
    this.confirmTextStyle,
    this.deleteIcon,
    this.deleteIconColor = const Color(0xFF1F2937),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.displayAlignment = Alignment.centerRight,
  })  : assert(
          controller == null || initialValue == '',
          'controller 与 initialValue 不能同时使用',
        ),
        assert(maxLength == null || maxLength > 0, 'maxLength 必须大于 0'),
        assert(
          decimalDigits == null || decimalDigits >= 0,
          'decimalDigits 不能小于 0',
        ),
        assert(spacing >= 0, 'spacing 不能小于 0'),
        assert(displayHeight > 0, 'displayHeight 必须大于 0'),
        assert(keyHeight > 0, 'keyHeight 必须大于 0');

  /// 外部控制器，传入后由上层维护输入值。
  final HsNumberKeyboardController? controller;

  /// 初始值，仅在未传 [controller] 时生效。
  final String initialValue;

  /// 输入展示区占位文案。
  final String placeholder;

  /// 最大字符长度，包含小数点。
  final int? maxLength;

  /// 小数位数限制，`null` 表示不限制。
  final int? decimalDigits;

  /// 是否展示小数点按键。
  final bool showDecimal;

  /// 确认按钮文案。
  final String confirmText;

  /// 数值变化回调。
  final ValueChanged<String>? onChanged;

  /// 删除回调。
  final VoidCallback? onDelete;

  /// 点击确认回调。
  final ValueChanged<String>? onConfirm;

  /// 是否展示顶部输入展示区。
  final bool showDisplay;

  /// 自定义展示区。
  final HsNumberKeyboardDisplayBuilder? displayBuilder;

  /// 外层内边距。
  final EdgeInsetsGeometry padding;

  /// 按键间距。
  final double spacing;

  /// 展示区高度。
  final double displayHeight;

  /// 单个按键高度。
  final double keyHeight;

  /// 键盘背景色。
  final Color backgroundColor;

  /// 展示区背景色。
  final Color displayBackgroundColor;

  /// 普通按键背景色。
  final Color keyBackgroundColor;

  /// 确认按键背景色。
  final Color confirmBackgroundColor;

  /// 当前值文本样式。
  final TextStyle? valueTextStyle;

  /// 占位文本样式。
  final TextStyle? placeholderTextStyle;

  /// 普通按键文本样式。
  final TextStyle? keyTextStyle;

  /// 确认按钮文本样式。
  final TextStyle? confirmTextStyle;

  /// 删除图标，可自定义替换。
  final Widget? deleteIcon;

  /// 删除图标颜色。
  final Color deleteIconColor;

  /// 圆角样式。
  final BorderRadius borderRadius;

  /// 展示区内容对齐方式。
  final Alignment displayAlignment;

  @override
  State<HsNumberKeyboard> createState() => _HsNumberKeyboardState();
}

class _HsNumberKeyboardState extends State<HsNumberKeyboard> {
  static const String _decimalKey = '.';
  static const ValueKey<String> _displayTextKey =
      ValueKey<String>('hs-number-keyboard-display-text');

  late HsNumberKeyboardController _controller;
  late bool _ownsController;

  bool get _showDecimalKey => widget.showDecimal && widget.decimalDigits != 0;

  TextStyle get _valueTextStyle =>
      widget.valueTextStyle ??
      const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101828),
      );

  TextStyle get _placeholderTextStyle =>
      widget.placeholderTextStyle ??
      const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Color(0xFF98A2B3),
      );

  TextStyle get _keyTextStyle =>
      widget.keyTextStyle ??
      const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101828),
      );

  TextStyle get _confirmTextStyle =>
      widget.confirmTextStyle ??
      const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(covariant HsNumberKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _disposeOwnedController();
      _bindController();
      return;
    }

    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _controller.value) {
      _controller.value = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _disposeOwnedController();
    super.dispose();
  }

  void _bindController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? HsNumberKeyboardController(widget.initialValue);
  }

  void _disposeOwnedController() {
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _updateValue(String nextValue) {
    if (nextValue == _controller.value) {
      return;
    }
    _controller.value = nextValue;
    widget.onChanged?.call(nextValue);
  }

  void _handleInput(String input) {
    final String currentValue = _controller.value;
    late final String nextValue;

    if (input == _decimalKey) {
      nextValue = _appendDecimal(currentValue);
    } else {
      nextValue = _appendDigit(currentValue, input);
    }

    _updateValue(nextValue);
  }

  String _appendDigit(String currentValue, String digit) {
    final String nextValue = '$currentValue$digit';
    if (widget.maxLength != null && nextValue.length > widget.maxLength!) {
      return currentValue;
    }

    if (widget.decimalDigits != null && currentValue.contains(_decimalKey)) {
      final int decimalIndex = currentValue.indexOf(_decimalKey);
      final int currentDecimalLength =
          currentValue.length - decimalIndex - _decimalKey.length;
      if (currentDecimalLength >= widget.decimalDigits!) {
        return currentValue;
      }
    }
    return nextValue;
  }

  String _appendDecimal(String currentValue) {
    if (!_showDecimalKey || currentValue.contains(_decimalKey)) {
      return currentValue;
    }

    final String nextValue =
        currentValue.isEmpty ? '0$_decimalKey' : '$currentValue$_decimalKey';
    if (widget.maxLength != null && nextValue.length > widget.maxLength!) {
      return currentValue;
    }
    return nextValue;
  }

  void _handleDelete() {
    final String currentValue = _controller.value;
    if (currentValue.isEmpty) {
      return;
    }

    _updateValue(currentValue.substring(0, currentValue.length - 1));
    widget.onDelete?.call();
  }

  void _handleConfirm() {
    widget.onConfirm?.call(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDisplay) ...[
                _buildDisplay(),
                SizedBox(height: widget.spacing),
              ],
              _buildKeyboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return SizedBox(
      width: double.infinity,
      height: widget.displayHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.displayBackgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ValueListenableBuilder<String>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (widget.displayBuilder != null) {
                return widget.displayBuilder!(context, value);
              }

              final bool isEmpty = value.isEmpty;
              return Align(
                alignment: widget.displayAlignment,
                child: Text(
                  isEmpty ? widget.placeholder : value,
                  key: _displayTextKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isEmpty ? _placeholderTextStyle : _valueTextStyle,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.keyHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _buildRegularRow(const ['1', '2', '3']),
              ),
              SizedBox(width: widget.spacing),
              Expanded(
                child: _buildActionKey(
                  key: const ValueKey<String>(
                    'hs-number-keyboard-key-delete',
                  ),
                  onTap: _handleDelete,
                  child: widget.deleteIcon ??
                      Icon(
                        Icons.backspace_outlined,
                        color: widget.deleteIconColor,
                        size: 24,
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.spacing),
        SizedBox(
          height: widget.keyHeight * 3 + widget.spacing * 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(child: _buildRegularRow(const ['4', '5', '6'])),
                    SizedBox(height: widget.spacing),
                    Expanded(child: _buildRegularRow(const ['7', '8', '9'])),
                    SizedBox(height: widget.spacing),
                    Expanded(child: _buildBottomRow()),
                  ],
                ),
              ),
              SizedBox(width: widget.spacing),
              Expanded(
                child: _buildConfirmButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegularRow(List<String> values) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(values.length * 2 - 1, (int index) {
        if (index.isOdd) {
          return SizedBox(width: widget.spacing);
        }

        final String value = values[index ~/ 2];
        return Expanded(
          child: _buildTextKey(value),
        );
      }),
    );
  }

  Widget _buildBottomRow() {
    if (!_showDecimalKey) {
      return _buildTextKey('0');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: _buildTextKey('0'),
        ),
        SizedBox(width: widget.spacing),
        Expanded(
          child: _buildTextKey(_decimalKey),
        ),
      ],
    );
  }

  Widget _buildTextKey(String value) {
    return _buildActionKey(
      key: ValueKey<String>('hs-number-keyboard-key-$value'),
      onTap: () => _handleInput(value),
      child: Center(
        child: Text(value, style: _keyTextStyle),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return _buildActionKey(
      key: const ValueKey<String>('hs-number-keyboard-key-confirm'),
      backgroundColor: widget.confirmBackgroundColor,
      onTap: _handleConfirm,
      child: Center(
        child: Text(
          widget.confirmText,
          style: _confirmTextStyle,
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required Key key,
    required Widget child,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Material(
      key: key,
      color: backgroundColor ?? widget.keyBackgroundColor,
      borderRadius: widget.borderRadius,
      child: InkWell(
        borderRadius: widget.borderRadius,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// 点击输入框后获取焦点，并在页面底部显示 [HsNumberKeyboard] 的只读输入组件。
///
/// 输入框本身仍会保持焦点与光标展示，但不会调起系统键盘。
class HsNumberKeyboardTextField extends StatefulWidget {
  const HsNumberKeyboardTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue = '',
    this.enabled = true,
    this.hintText,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.showCursor = true,
    this.enableInteractiveSelection = false,
    this.maxLength,
    this.showDecimal = true,
    this.decimalDigits,
    this.confirmText = '确定',
    this.keyboardPlaceholder = '',
    this.keyboardShowDisplay = false,
    this.closeOnConfirm = true,
    this.onTap,
    this.onChanged,
    this.onDelete,
    this.onConfirm,
    this.keyboardBuilder,
  }) : assert(
          controller == null || initialValue == '',
          'controller 与 initialValue 不能同时使用',
        );

  /// 文本控制器，外部传入时以其值为准。
  final TextEditingController? controller;

  /// 焦点控制器。
  final FocusNode? focusNode;

  /// 初始值，仅在未传 [controller] 时生效。
  final String initialValue;

  /// 是否可用。
  final bool enabled;

  /// 输入框占位文案。
  final String? hintText;

  /// 输入框装饰。
  final InputDecoration? decoration;

  /// 输入框文本样式。
  final TextStyle? style;

  /// 文本对齐方式。
  final TextAlign textAlign;

  /// 是否显示光标。
  final bool showCursor;

  /// 是否允许长按选择文本。
  final bool enableInteractiveSelection;

  /// 最大字符长度，包含小数点。
  final int? maxLength;

  /// 是否展示小数点按键。
  final bool showDecimal;

  /// 小数位数限制。
  final int? decimalDigits;

  /// 确认按钮文案。
  final String confirmText;

  /// 键盘占位文案。
  final String keyboardPlaceholder;

  /// 键盘是否展示内部顶部展示区。
  final bool keyboardShowDisplay;

  /// 点击确认后是否自动收起自定义键盘。
  final bool closeOnConfirm;

  /// 点击输入框回调。
  final VoidCallback? onTap;

  /// 数值变化回调。
  final ValueChanged<String>? onChanged;

  /// 删除回调。
  final VoidCallback? onDelete;

  /// 点击确认回调。
  final ValueChanged<String>? onConfirm;

  /// 自定义键盘构建器。
  ///
  /// 未传时默认使用 [HsNumberKeyboard]。
  final HsNumberKeyboardBuilder? keyboardBuilder;

  @override
  State<HsNumberKeyboardTextField> createState() =>
      _HsNumberKeyboardTextFieldState();
}

class _HsNumberKeyboardTextFieldState extends State<HsNumberKeyboardTextField> {
  late TextEditingController _textController;
  late HsNumberKeyboardController _keyboardController;
  late FocusNode _focusNode;
  late bool _ownsTextController;
  late bool _ownsFocusNode;

  bool _syncingFromText = false;
  bool _syncingFromKeyboard = false;
  bool _overlayRebuildScheduled = false;
  OverlayEntry? _keyboardOverlayEntry;
  final Object _tapRegionGroupId = Object();

  @override
  void initState() {
    super.initState();
    _bindObjects();
  }

  @override
  void didUpdateWidget(covariant HsNumberKeyboardTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller ||
        oldWidget.focusNode != widget.focusNode) {
      _unbindObjects(
        disposeTextController: true,
        disposeKeyboard: true,
        disposeFocusNode: true,
      );
      _bindObjects();
      return;
    }

    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _textController.text) {
      _syncingFromText = true;
      _textController.text = widget.initialValue;
      _textController.selection = TextSelection.collapsed(
        offset: widget.initialValue.length,
      );
      _syncingFromText = false;
      _keyboardController.value = widget.initialValue;
    }

    _scheduleOverlayRebuild();
  }

  @override
  void dispose() {
    _unbindObjects(
      disposeTextController: true,
      disposeKeyboard: true,
      disposeFocusNode: true,
    );
    super.dispose();
  }

  void _bindObjects() {
    _ownsTextController = widget.controller == null;
    _textController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _keyboardController = HsNumberKeyboardController(_textController.text);

    _textController.addListener(_handleTextControllerChanged);
    _keyboardController.addListener(_handleKeyboardControllerChanged);
    _focusNode.addListener(_handleFocusChanged);

    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          _syncSelectionToEnd();
          _showKeyboardOverlay();
        }
      });
    }
  }

  void _unbindObjects({
    bool disposeTextController = false,
    bool disposeKeyboard = false,
    bool disposeFocusNode = false,
  }) {
    _textController.removeListener(_handleTextControllerChanged);
    _keyboardController.removeListener(_handleKeyboardControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _removeKeyboardOverlay();

    if (disposeTextController && _ownsTextController) {
      _textController.dispose();
    }
    if (disposeKeyboard) {
      _keyboardController.dispose();
    }
    if (disposeFocusNode && _ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleTextControllerChanged() {
    if (_syncingFromKeyboard) {
      return;
    }

    final String value = _textController.text;
    if (_keyboardController.value == value) {
      return;
    }

    _syncingFromText = true;
    _keyboardController.value = value;
    _syncingFromText = false;
  }

  void _handleKeyboardControllerChanged() {
    if (_syncingFromText) {
      return;
    }

    final String value = _keyboardController.value;
    if (_textController.text != value) {
      _syncingFromKeyboard = true;
      _textController.value = _textController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
        composing: TextRange.empty,
      );
      _syncingFromKeyboard = false;
    }

    widget.onChanged?.call(value);
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _syncSelectionToEnd();
      _showKeyboardOverlay();
      return;
    }
    _removeKeyboardOverlay();
  }

  void _syncSelectionToEnd() {
    final int offset = _textController.text.length;
    final TextSelection selection = TextSelection.collapsed(offset: offset);
    if (_textController.selection != selection) {
      _textController.selection = selection;
    }
  }

  void _handleTap() {
    widget.onTap?.call();
    _syncSelectionToEnd();
    if (_focusNode.hasFocus) {
      _showKeyboardOverlay();
      return;
    }
    _focusNode.requestFocus();
  }

  void _showKeyboardOverlay() {
    _keyboardController.setValue(_textController.text);
    if (_keyboardOverlayEntry != null) {
      _keyboardOverlayEntry!.markNeedsBuild();
      return;
    }

    final OverlayState overlay = Overlay.of(context);

    _keyboardOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: TapRegion(
            groupId: _tapRegionGroupId,
            child: Material(
              color: Colors.transparent,
              child: widget.keyboardBuilder?.call(
                    overlayContext,
                    _keyboardController,
                    _handleConfirm,
                  ) ??
                  HsNumberKeyboard(
                    controller: _keyboardController,
                    placeholder: widget.keyboardPlaceholder,
                    maxLength: widget.maxLength,
                    decimalDigits: widget.decimalDigits,
                    showDecimal: widget.showDecimal,
                    confirmText: widget.confirmText,
                    showDisplay: widget.keyboardShowDisplay,
                    onDelete: widget.onDelete,
                    onConfirm: _handleConfirm,
                  ),
            ),
          ),
        );
      },
    );
    overlay.insert(_keyboardOverlayEntry!);
  }

  void _removeKeyboardOverlay() {
    _keyboardOverlayEntry?.remove();
    _keyboardOverlayEntry = null;
    _overlayRebuildScheduled = false;
  }

  void _scheduleOverlayRebuild() {
    if (_keyboardOverlayEntry == null || _overlayRebuildScheduled || !mounted) {
      return;
    }

    _overlayRebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayRebuildScheduled = false;
      if (!mounted || _keyboardOverlayEntry == null) {
        return;
      }
      _keyboardOverlayEntry!.markNeedsBuild();
    });
  }

  void _handleConfirm(String value) {
    widget.onConfirm?.call(value);
    if (widget.closeOnConfirm && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  InputDecoration _buildDecoration() {
    final InputDecoration baseDecoration =
        widget.decoration ?? const InputDecoration();
    return baseDecoration.copyWith(
      hintText: baseDecoration.hintText ?? widget.hintText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapRegionGroupId,
      onTapOutside: (_) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: true,
        showCursor: widget.showCursor,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        keyboardType: TextInputType.none,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLength: widget.maxLength,
        decoration: _buildDecoration(),
        onTap: _handleTap,
      ),
    );
  }
}
