import 'package:custom_numeric_keyboard_demo/src/widgets/hs_number_keyboard.dart';
import 'package:flutter/material.dart';

class NumberKeyboardPage extends StatefulWidget {
  const NumberKeyboardPage({super.key});

  @override
  State<NumberKeyboardPage> createState() => _NumberKeyboardPageState();
}

class _NumberKeyboardPageState extends State<NumberKeyboardPage> {
  final TextEditingController _fieldController = TextEditingController();
  final FocusNode _fieldFocusNode = FocusNode();

  bool _showDecimal = true;
  String _confirmedValue = '';

  @override
  void initState() {
    super.initState();
    _fieldFocusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _fieldFocusNode.removeListener(_handleFocusChanged);
    _fieldController.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('数字键盘'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPreviewCard(theme),
          const SizedBox(height: 16),
          _buildFieldCard(),
          const SizedBox(height: 16),
          _buildActionCard(),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('显示小数点'),
            subtitle: Text(_showDecimal ? '当前允许输入 2 位小数' : '当前为纯数字输入'),
            value: _showDecimal,
            onChanged: (value) {
              setState(() {
                _showDecimal = value;
              });
            },
          ),
          const SizedBox(height: 8),
          const Text(
            '说明：点击输入框后会先获取焦点，再像系统键盘一样在页面底部出现自定义数字键盘。',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    final String currentValue = _fieldController.text;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '组件预览',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '当前输入',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentValue.isEmpty ? '--' : currentValue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fieldFocusNode.hasFocus ? '输入框状态：已获取焦点' : '输入框状态：未获取焦点',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _confirmedValue.isEmpty ? '最近一次确认：暂无' : '最近一次确认：$_confirmedValue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快捷操作',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => _setFieldValue('128.50'),
                child: const Text('填入 128.50'),
              ),
              OutlinedButton(
                onPressed: () => _setFieldValue('666'),
                child: const Text('填入 666'),
              ),
              OutlinedButton(
                onPressed: () => _setFieldValue(''),
                child: const Text('清空'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '点击输入框唤起',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          HsNumberKeyboardTextField(
            controller: _fieldController,
            focusNode: _fieldFocusNode,
            hintText: _showDecimal ? '点击输入金额' : '点击输入数量',
            showDecimal: _showDecimal,
            decimalDigits: _showDecimal ? 2 : 0,
            maxLength: 12,
            keyboardShowDisplay: false,
            decoration: InputDecoration(
              hintText: _showDecimal ? '点击输入金额' : '点击输入数量',
              filled: true,
              fillColor: const Color(0xFFF6F8FB),
              suffixIcon: const Icon(Icons.dialpad_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () => setState(() {}),
            onChanged: (_) => setState(() {}),
            onConfirm: (value) {
              setState(() {
                _confirmedValue = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value.isEmpty ? '当前没有可确认的内容' : '已确认：$value'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _setFieldValue(String value) {
    _fieldController.value = _fieldController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
    setState(() {});
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
