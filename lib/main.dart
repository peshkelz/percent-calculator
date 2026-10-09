import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const PercentageCalculatorApp());
}

class PercentageCalculatorApp extends StatelessWidget {
  const PercentageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محاسبه‌گر درصد و تخفیف',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const MainCalculatorScreen(),
    );
  }
}

class MainCalculatorScreen extends StatefulWidget {
  const MainCalculatorScreen({super.key});

  @override
  State<MainCalculatorScreen> createState() => _MainCalculatorScreenState();
}

class _MainCalculatorScreenState extends State<MainCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'محاسبه‌گر هوشمند درصد و قیمت',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey.shade700,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.discount_outlined), text: 'محاسبه تخفیف'),
            Tab(icon: Icon(Icons.trending_up), text: 'افزایش قیمت / سود'),
            Tab(icon: Icon(Icons.percent), text: 'درصد عمومی'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DiscountCalculatorTab(),
          PriceIncreaseCalculatorTab(),
          GeneralPercentageCalculatorTab(),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// فرمت‌کننده اعداد و مبالغ سه رقم سه رقم
// -------------------------------------------------------------
String formatAmount(double value) {
  final formatter = NumberFormat('#,###.##');
  return formatter.format(value);
}

// -------------------------------------------------------------
// تب ۱: محاسبه تخفیف و قیمت نهایی
// -------------------------------------------------------------
class DiscountCalculatorTab extends StatefulWidget {
  const DiscountCalculatorTab({super.key});

  @override
  State<DiscountCalculatorTab> createState() => _DiscountCalculatorTabState();
}

class _DiscountCalculatorTabState extends State<DiscountCalculatorTab> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();

  double _originalPrice = 0;
  double _discountPercent = 0;
  double _savedAmount = 0;
  double _finalPrice = 0;
  String _unit = 'تومان';

  final List<double> _quickPercents = [5, 10, 15, 20, 25, 30, 50, 70];

  void _calculate() {
    final price = double.tryParse(_priceController.text.replaceAll(',', '').trim()) ?? 0;
    final percent = double.tryParse(_percentController.text.trim()) ?? 0;

    setState(() {
      _originalPrice = price;
      _discountPercent = percent;
      _savedAmount = (price * percent) / 100;
      _finalPrice = price - _savedAmount;
      if (_finalPrice < 0) _finalPrice = 0;
    });
  }

  void _setPercent(double p) {
    _percentController.text = p.toStringAsFixed(p.truncateToDouble() == p ? 0 : 1);
    _calculate();
  }

  void _clear() {
    _priceController.clear();
    _percentController.clear();
    setState(() {
      _originalPrice = 0;
      _discountPercent = 0;
      _savedAmount = 0;
      _finalPrice = 0;
    });
  }

  void _copyResult() {
    if (_originalPrice <= 0) return;
    final text = 'قیمت اولیه: ${formatAmount(_originalPrice)} $_unit\n'
        'درصد تخفیف: $_discountPercent%\n'
        'میزان تخفیف (سود شما): ${formatAmount(_savedAmount)} $_unit\n'
        'قیمت نهایی قابل پرداخت: ${formatAmount(_finalPrice)} $_unit';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('نتیجه در حافظه کپی شد'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // واحد پول
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('واحد مبلغ:', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'تومان', label: Text('تومان')),
                    ButtonSegment(value: 'ریال', label: Text('ریال')),
                    ButtonSegment(value: '', label: Text('عددی')),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (newVal) {
                    setState(() => _unit = newVal.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // فیلد قیمت اصلی
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                labelText: 'قیمت اصلی کالا',
                hintText: 'مثلاً ۱,۰۰۰,۰۰۰',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: _unit,
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 14),

            // فیلد درصد تخفیف
            TextField(
              controller: _percentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'درصد تخفیف',
                hintText: 'مثلاً ۲۰',
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),

            // چیپ‌های درصد سریع
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _quickPercents.map((p) {
                final isSelected = _discountPercent == p;
                return ChoiceChip(
                  label: Text('${p.toInt()}%'),
                  selected: isSelected,
                  onSelected: (_) => _setPercent(p),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // کارت نتایج
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'قیمت نهایی پس از تخفیف:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'کپی نتیجه',
                          onPressed: _copyResult,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatAmount(_finalPrice)} $_unit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('میزان سود شما (مبلغ تخفیف):', style: TextStyle(color: Colors.black87)),
                        Text(
                          '${formatAmount(_savedAmount)} $_unit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('قیمت اولیه:', style: TextStyle(color: Colors.black54)),
                        Text(
                          '${formatAmount(_originalPrice)} $_unit',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // دکمه ریست
            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('پاک کردن اطلاعات'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// تب ۲: محاسبه افزایش قیمت و سود / مالیات
// -------------------------------------------------------------
class PriceIncreaseCalculatorTab extends StatefulWidget {
  const PriceIncreaseCalculatorTab({super.key});

  @override
  State<PriceIncreaseCalculatorTab> createState() => _PriceIncreaseCalculatorTabState();
}

class _PriceIncreaseCalculatorTabState extends State<PriceIncreaseCalculatorTab> {
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _increasePercentController = TextEditingController();

  double _basePrice = 0;
  double _increasePercent = 0;
  double _addedAmount = 0;
  double _newTotalPrice = 0;
  String _unit = 'تومان';

  final List<double> _quickPercents = [9, 10, 15, 20, 25, 30, 40, 50];

  void _calculate() {
    final price = double.tryParse(_basePriceController.text.replaceAll(',', '').trim()) ?? 0;
    final percent = double.tryParse(_increasePercentController.text.trim()) ?? 0;

    setState(() {
      _basePrice = price;
      _increasePercent = percent;
      _addedAmount = (price * percent) / 100;
      _newTotalPrice = price + _addedAmount;
    });
  }

  void _setPercent(double p) {
    _increasePercentController.text = p.toStringAsFixed(p.truncateToDouble() == p ? 0 : 1);
    _calculate();
  }

  void _clear() {
    _basePriceController.clear();
    _increasePercentController.clear();
    setState(() {
      _basePrice = 0;
      _increasePercent = 0;
      _addedAmount = 0;
      _newTotalPrice = 0;
    });
  }

  void _copyResult() {
    if (_basePrice <= 0) return;
    final text = 'قیمت پایه: ${formatAmount(_basePrice)} $_unit\n'
        'درصد افزایش: $_increasePercent%\n'
        'مقدار افزایش یافته (سود/مالیات): ${formatAmount(_addedAmount)} $_unit\n'
        'قیمت جدید: ${formatAmount(_newTotalPrice)} $_unit';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('نتیجه در حافظه کپی شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('واحد مبلغ:', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'تومان', label: Text('تومان')),
                    ButtonSegment(value: 'ریال', label: Text('ریال')),
                    ButtonSegment(value: '', label: Text('عددی')),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (newVal) {
                    setState(() => _unit = newVal.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _basePriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                labelText: 'قیمت پایه (خرید / هزینه)',
                hintText: 'مثلاً ۲,۰۰۰,۰۰۰',
                prefixIcon: const Icon(Icons.payments_outlined),
                suffixText: _unit,
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _increasePercentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'درصد افزایش یا حاشیه سود',
                hintText: 'مثلاً ۲۵ یا ۹ (مالیات)',
                prefixIcon: Icon(Icons.trending_up),
                suffixText: '%',
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _quickPercents.map((p) {
                final isTax = (p == 9);
                return ChoiceChip(
                  label: Text(isTax ? '۹٪ (مالیات ارزش‌افزوده)' : '${p.toInt()}%'),
                  selected: _increasePercent == p,
                  onSelected: (_) => _setPercent(p),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'قیمت نهایی جدید (با افزایش):',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'کپی نتیجه',
                          onPressed: _copyResult,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatAmount(_newTotalPrice)} $_unit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مقدار افزایش یافته (سود شما):', style: TextStyle(color: Colors.black87)),
                        Text(
                          '+ ${formatAmount(_addedAmount)} $_unit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('قیمت پایه اولیه:', style: TextStyle(color: Colors.black54)),
                        Text(
                          '${formatAmount(_basePrice)} $_unit',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('پاک کردن اطلاعات'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// تب ۳: درصد عمومی (X٪ از Y چقدر می‌شود؟)
// -------------------------------------------------------------
class GeneralPercentageCalculatorTab extends StatefulWidget {
  const GeneralPercentageCalculatorTab({super.key});

  @override
  State<GeneralPercentageCalculatorTab> createState() => _GeneralPercentageCalculatorTabState();
}

class _GeneralPercentageCalculatorTabState extends State<GeneralPercentageCalculatorTab> {
  // فرم ۱: X درصد از کل چقدر است؟
  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _total1Controller = TextEditingController();
  double _result1 = 0;

  // فرم ۲: جز چند درصد کل است؟
  final TextEditingController _part2Controller = TextEditingController();
  final TextEditingController _total2Controller = TextEditingController();
  double _result2 = 0;

  void _calc1() {
    final p = double.tryParse(_p1Controller.text.trim()) ?? 0;
    final total = double.tryParse(_total1Controller.text.replaceAll(',', '').trim()) ?? 0;
    setState(() {
      _result1 = (total * p) / 100;
    });
  }

  void _calc2() {
    final part = double.tryParse(_part2Controller.text.replaceAll(',', '').trim()) ?? 0;
    final total = double.tryParse(_total2Controller.text.replaceAll(',', '').trim()) ?? 0;
    setState(() {
      _result2 = total > 0 ? (part / total) * 100 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بخش ۱
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '۱) محاسبه مقدار درصد (X٪ از Y چقدر است؟)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _p1Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'درصد (%)'),
                            onChanged: (_) => _calc1(),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('از'),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _total1Controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                            decoration: const InputDecoration(labelText: 'کل مقدار'),
                            onChanged: (_) => _calc1(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('نتیجه مقدار:'),
                          Text(
                            formatAmount(_result1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // بخش ۲
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '۲) جزء چند درصد از کل است؟',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _part2Controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                            decoration: const InputDecoration(labelText: 'مقدار جزء'),
                            onChanged: (_) => _calc2(),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('از کل'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _total2Controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                            decoration: const InputDecoration(labelText: 'کل مقدار'),
                            onChanged: (_) => _calc2(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('معادل درصد:'),
                          Text(
                            '${formatAmount(_result2)} %',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// فرمت‌کننده سه رقم سه رقم ورودی هنگام تایپ
// -------------------------------------------------------------
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final cleanText = newValue.text.replaceAll(',', '');
    final number = int.tryParse(cleanText);

    if (number == null) {
      return oldValue;
    }

    final newFormatted = _formatter.format(number);

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(offset: newFormatted.length),
    );
  }
}
