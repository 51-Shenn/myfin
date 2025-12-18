import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfin/features/admin/domain/entities/tax_rate.dart';
import 'package:uuid/uuid.dart';

class EditTaxRateScreen extends StatefulWidget {
  final List<TaxRate> rates;

  const EditTaxRateScreen({super.key, required this.rates});

  @override
  State<EditTaxRateScreen> createState() => _EditTaxRateScreenState();
}

class _EditTaxRateScreenState extends State<EditTaxRateScreen> {
  late List<TaxRate> _rates;
  int _currentIndex = 0;
  late TextEditingController _minIncomeController;
  late TextEditingController _maxIncomeController;
  late TextEditingController _percentageController;

  @override
  void initState() {
    super.initState();
    _rates = List.from(widget.rates);

    // If no rates exist, create a default one
    if (_rates.isEmpty) {
      _rates.add(
        TaxRate(
          id: const Uuid().v4(),
          minimumIncome: 0,
          maximumIncome: 0,
          percentage: 0,
        ),
      );
    }

    _loadCurrentRate();
  }

  void _loadCurrentRate() {
    final currentRate = _rates[_currentIndex];
    _minIncomeController = TextEditingController(
      text: currentRate.minimumIncome > 0
          ? currentRate.minimumIncome.toStringAsFixed(2)
          : '',
    );
    _maxIncomeController = TextEditingController(
      text: currentRate.maximumIncome > 0
          ? currentRate.maximumIncome.toStringAsFixed(2)
          : '',
    );
    _percentageController = TextEditingController(
      text: currentRate.percentage > 0
          ? currentRate.percentage.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _minIncomeController.dispose();
    _maxIncomeController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tax Rate'),
        centerTitle: true,
        actions: [
          if (_rates.length > 1)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCurrentRate,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_rates.length > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax Rate ${_currentIndex + 1} of ${_rates.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentIndex > 0 ? _previousRate : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentIndex < _rates.length - 1
                            ? _nextRate
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Minimum Income',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _minIncomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2B46F9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Maximum Income',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxIncomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2B46F9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tax Percentage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _percentageController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2B46F9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _addNewRate,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Rate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2B46F9),
                side: const BorderSide(color: Color(0xFF2B46F9)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B46F9),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCurrentRate() {
    final minIncome = double.tryParse(_minIncomeController.text) ?? 0;
    final maxIncome = double.tryParse(_maxIncomeController.text) ?? 0;
    final percentage = double.tryParse(_percentageController.text) ?? 0;

    _rates[_currentIndex] = _rates[_currentIndex].copyWith(
      minimumIncome: minIncome,
      maximumIncome: maxIncome,
      percentage: percentage,
    );
  }

  void _previousRate() {
    _saveCurrentRate();
    setState(() {
      _currentIndex--;
      _loadCurrentRate();
    });
  }

  void _nextRate() {
    _saveCurrentRate();
    setState(() {
      _currentIndex++;
      _loadCurrentRate();
    });
  }

  void _addNewRate() {
    _saveCurrentRate();
    setState(() {
      _rates.add(
        TaxRate(
          id: const Uuid().v4(),
          minimumIncome: 0,
          maximumIncome: 0,
          percentage: 0,
        ),
      );
      _currentIndex = _rates.length - 1;
      _loadCurrentRate();
    });
  }

  void _deleteCurrentRate() {
    if (_rates.length > 1) {
      setState(() {
        _rates.removeAt(_currentIndex);
        if (_currentIndex >= _rates.length) {
          _currentIndex = _rates.length - 1;
        }
        _loadCurrentRate();
      });
    }
  }

  void _saveChanges() {
    _saveCurrentRate();
    Navigator.pop(context, _rates);
  }
}
