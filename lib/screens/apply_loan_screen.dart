// lib/screens/apply_loan_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/responses.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({Key? key}) : super(key: key);

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final _apiService = ApiService();

  int _currentStep = 0;

  // Step 1
  String _selectedLoanType = 'Pinjaman Biasa'; // 'Pinjaman Biasa' or 'Pinjaman Lainnya'
  String _selectedSubLoanType = 'RUMAH'; // RUMAH, MOBIL, MOTOR, BRANG, JAPEN

  // Step 2 inputs
  final _amountController = TextEditingController();
  int? _selectedTenor;
  final _gajiController = TextEditingController();
  final _potPribadiController = TextEditingController();
  final _noAtasanController = TextEditingController();

  // Pinjaman Lainnya specific inputs
  final _jasaController = TextEditingController();
  final _angsuranBlnController = TextEditingController(); // Manual input for pinjaman lainnya calculation

  // Dropdown list for Tipe Potongan fetched from API
  List<String> _tipePotonganOptions = [];
  String? _selectedTipePotongan;
  bool _isLoadingPotongan = false;

  // Simulation result from API
  LoanCalculation? _calculation;
  bool _isCalculating = false;
  String? _calcError;

  // Step 3 — submit
  bool _isSubmitting = false;
  String? _submitError;

  final List<int> _tenorOptions = [12, 24, 36, 48, 60];

  final Map<String, String> _subLoanTypes = {
    'RUMAH': 'Rumah',
    'MOBIL': 'Mobil',
    'MOTOR': 'Motor',
    'BRANG': 'Kredit Barang',
    'JAPEN': 'Jangka Pendek',
  };

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color bgGray = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _fetchTipePotongan();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _gajiController.dispose();
    _potPribadiController.dispose();
    _noAtasanController.dispose();
    _jasaController.dispose();
    _angsuranBlnController.dispose();
    super.dispose();
  }

  // ── Fetch Tipe Potongan dynamically based on loan type ────────────────────
  Future<void> _fetchTipePotongan() async {
    final loanTypeCode = _selectedLoanType == 'Pinjaman Biasa' 
        ? 'JAPAN' 
        : _selectedSubLoanType;
    setState(() {
      _isLoadingPotongan = true;
      _tipePotonganOptions = [];
      _selectedTipePotongan = null;
    });
    try {
      final res = await _apiService.getTipePotongan(loanTypeCode);
      if (res['code'] == 200 && res['data'] is List) {
        final list = res['data'] as List;
        final pitcodes = list
            .map((item) => item['pitcode']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        setState(() {
          _tipePotonganOptions = pitcodes;
          if (pitcodes.isNotEmpty) {
            _selectedTipePotongan = pitcodes.first;
          }
        });
      }
    } catch (e) {
      print('Error fetching tipe potongan: $e');
    } finally {
      setState(() => _isLoadingPotongan = false);
    }
  }

  // ── Format angka dengan titik ribuan ──────────────────────────────────────
  String _formatRupiah(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      counter++;
    }
    return buffer.toString().split('').reversed.join();
  }

  // ── Step navigation ───────────────────────────────────────────────────────
  void _nextStep() async {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      // Step 2 → 3: validasi input lalu hitung simulasi dari API
      final amountText = _amountController.text.replaceAll('.', '').trim();
      if (amountText.isEmpty || double.tryParse(amountText) == null) {
        _showSnackBar('Masukkan nominal pinjaman yang valid');
        return;
      }
      if (_selectedTenor == null) {
        _showSnackBar('Pilih tenor pinjaman terlebih dahulu');
        return;
      }
      if (_selectedTipePotongan == null) {
        _showSnackBar('Tipe Potongan tidak boleh kosong. Harap tunggu/ulangi pemuatan data.');
        return;
      }
      if (_gajiController.text.isEmpty) {
        _showSnackBar('Masukkan Gaji / Nominal Potongan');
        return;
      }
      if (_potPribadiController.text.isEmpty) {
        _showSnackBar('Masukkan Potongan Pribadi');
        return;
      }
      if (_noAtasanController.text.isEmpty) {
        _showSnackBar('Masukkan No. HP Atasan');
        return;
      }

      if (_selectedLoanType == 'Pinjaman Lainnya') {
        if (_jasaController.text.isEmpty) {
          _showSnackBar('Masukkan nominal Jasa (Bunga)');
          return;
        }
        if (_angsuranBlnController.text.isEmpty) {
          _showSnackBar('Masukkan nominal Angsuran per Bulan');
          return;
        }
      }

      await _calculateInstallment();
      if (_calcError == null) {
        setState(() => _currentStep = 2);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _calcError = null;
        _submitError = null;
      });
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // ── Panggil API hitung angsuran ───────────────────────────────────────────
  Future<void> _calculateInstallment() async {
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final amount = double.parse(amountText);
    final tenor = _selectedTenor!;
    final memberId = _apiService.memberId ?? '';
    final loanTypeCode = _selectedLoanType == 'Pinjaman Biasa' 
        ? 'JAPAN' 
        : _selectedSubLoanType;

    final salary = _gajiController.text.replaceAll('.', '').trim();
    final personalCut = _potPribadiController.text.replaceAll('.', '').trim();

    setState(() {
      _isCalculating = true;
      _calcError = null;
      _calculation = null;
    });

    try {
      LoanCalculationResponse result;
      if (_selectedLoanType == 'Pinjaman Biasa') {
        result = await _apiService.calculateLoanInstallment(
          amount: amount,
          tenor: tenor,
          loanType: loanTypeCode,
          memberId: memberId,
          salary: salary,
          personalCut: personalCut,
        );
      } else {
        // Pinjaman Lainnya — hitung simulasi
        final interest = _jasaController.text.replaceAll('.', '').trim();
        result = await _apiService.calculateLoanInstallmentLain(
          amount: amount,
          tenor: tenor,
          loanType: loanTypeCode,
          interest: interest,
          memberId: memberId,
        );
      }

      if (result.data != null) {
        setState(() => _calculation = result.data);
      } else {
        setState(() => _calcError =
            result.message.isNotEmpty ? result.message : 'Gagal menghitung simulasi');
      }
    } catch (e) {
      setState(() => _calcError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  // ── Panggil API ajukan pinjaman ───────────────────────────────────────────
  Future<void> _submitApplication() async {
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final amount = double.parse(amountText);
    final tenor = _selectedTenor!;
    final memberId = _apiService.memberId ?? '';
    final loanTypeCode = _selectedLoanType == 'Pinjaman Biasa' 
        ? 'JAPAN' 
        : _selectedSubLoanType;

    final salary = _gajiController.text.replaceAll('.', '').trim();
    final personalCut = _potPribadiController.text.replaceAll('.', '').trim();
    final noAtasan = _noAtasanController.text.trim();

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      LoanApplicationResponse result;
      if (_selectedLoanType == 'Pinjaman Biasa') {
        result = await _apiService.applyLoan(
          memberId: memberId,
          amount: amount,
          tenor: tenor,
          loanType: loanTypeCode, // loancode = pjm_code = loanType
          pjmCode: _selectedTipePotongan!, // loancode = pjmCode
          calculation: _calculation!,
          gaji: salary,
          potPribadi: personalCut,
          noAtasan: noAtasan,
        );
      } else {
        // Untuk Pinjaman Lainnya
        result = await _apiService.applyLoanLain(
          memberId: memberId,
          amount: amount,
          tenor: tenor,
          loanType: loanTypeCode, // loancode = loanType
          pjmCode: _selectedTipePotongan!, // pjm_code = pjmCode
          calculation: _calculation!,
          gaji: salary,
          potPribadi: personalCut,
          noAtasan: noAtasan,
        );
      }

      if (!mounted) return;

      if (result.code == 200 ||
          result.message.toLowerCase().contains('success')) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Color(0xFF059669), size: 36),
                ),
                const SizedBox(height: 16),
                Text('Pengajuan Berhasil!',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (result.docNumber != null)
                  Text('No. Dokumen: ${result.docNumber}',
                      style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Pinjaman Anda sedang diproses oleh admin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to previous screen
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      } else {
        setState(() => _submitError =
            result.message.isNotEmpty ? result.message : 'Pengajuan gagal');
      }
    } catch (e) {
      setState(() =>
          _submitError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        title: const Text('Ajukan Pinjaman'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ── Step Indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final labels = ['Tipe', 'Nominal', 'Review'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(3, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? primaryBlue
                            : const Color(0xFFE5E7EB),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      isCurrent ? Colors.white : Colors.black45,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          color: isCompleted
                              ? primaryBlue
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrent ? primaryBlue : Colors.black45,
                    fontWeight:
                        isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step Content ──────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  // Step 1: Pilih Tipe
  Widget _buildStep1() {
    final types = ['Pinjaman Biasa', 'Pinjaman Lainnya'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Tipe Pinjaman',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...types.map((type) {
          final isSelected = _selectedLoanType == type;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedLoanType = type;
                });
                _fetchTipePotongan();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryBlue
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? primaryBlue
                                  : const Color(0xFFD1D5DB),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryBlue,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(type,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(
                                type == 'Pinjaman Biasa'
                                    ? 'Pinjaman Jangka Panjang Koperasi'
                                    : 'Pinjaman khusus seperti Rumah, Kendaraan, dll.',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (type == 'Pinjaman Lainnya' && isSelected) ...[
                      const Divider(height: 24),
                      const Text('Pilih Kategori Pinjaman Lainnya:',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSubLoanType,
                        items: _subLoanTypes.entries.map((e) {
                          return DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          fillColor: bgGray,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSubLoanType = val;
                            });
                            _fetchTipePotongan();
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Step 2: Nominal & Tenor & Extra Inputs
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nominal & Tenor',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Tipe: $_selectedLoanType' + 
          (_selectedLoanType == 'Pinjaman Lainnya' ? ' (${_subLoanTypes[_selectedSubSubLoanTypeCode()]} )' : ''),
          style: const TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 16),

        // Jumlah Pinjaman
        const Text('Jumlah Pinjaman',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            prefixText: 'Rp ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
          ),
          onChanged: (_) => _resetCalculation(),
        ),

        const SizedBox(height: 16),
        // Tenor Select
        const Text('Tenor (Lama Cicilan)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: _tenorOptions.map((tenor) {
            final isSelected = _selectedTenor == tenor;
            return InkWell(
              onTap: () => setState(() {
                _selectedTenor = tenor;
                _resetCalculation();
              }),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? primaryBlue : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$tenor bln',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        const Text('Data Keuangan & Atasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(height: 16),

        // Tipe Potongan (Deduction Spinner)
        const Text('Tipe Potongan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        _isLoadingPotongan
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : DropdownButtonFormField<String>(
                value: _selectedTipePotongan,
                items: _tipePotonganOptions.map((pitcode) {
                  return DropdownMenuItem<String>(
                    value: pitcode,
                    child: Text(pitcode),
                  );
                }).toList(),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedTipePotongan = val;
                  });
                },
              ),

        const SizedBox(height: 16),
        // Nominal Gaji / Potongan
        const Text('Gaji / Nominal Potongan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _gajiController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            prefixText: 'Rp ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Potongan Pribadi
        const Text('Potongan Pribadi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _potPribadiController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            prefixText: 'Rp ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 16),
        // No HP Atasan
        const Text('No. HP Atasan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noAtasanController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '081xxxxxxxxx',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Pinjaman Lainnya inputs: Jasa & Angsuran per bulan (Manual Input)
        if (_selectedLoanType == 'Pinjaman Lainnya') ...[
          const SizedBox(height: 24),
          const Text('Rincian Pinjaman Lainnya',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 16),

          const Text('Jasa (Bunga)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _jasaController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0',
              prefixText: 'Rp ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (_) => _resetCalculation(),
          ),

          const SizedBox(height: 16),
          const Text('Estimasi Angsuran per Bulan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _angsuranBlnController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0',
              prefixText: 'Rp ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],

        // Error kalkulasi
        if (_calcError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_calcError!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                ),
              ],
            ),
          ),
        ],

        // Loading simulasi
        if (_isCalculating) ...[
          const SizedBox(height: 24),
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Menghitung simulasi angsuran...',
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Step 3: Review
  Widget _buildStep3() {
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final amount = amountText.isNotEmpty ? double.tryParse(amountText) ?? 0 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Pengajuan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Info dari server
        if (_calculation != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate_outlined, color: primaryBlue, size: 18),
                    SizedBox(width: 6),
                    Text('Simulasi dari Server Kopegmar',
                        style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
                const Divider(height: 16),
                _reviewRow('Biaya Admin', 'Rp ${_formatRupiah(_calculation!.adminFee)}'),
                const SizedBox(height: 6),
                _reviewRow('Biaya Provisi', 'Rp ${_formatRupiah(_calculation!.provision)}'),
                const SizedBox(height: 6),
                _reviewRow('Asuransi', 'Rp ${_formatRupiah(_calculation!.asuransi)}'),
                const SizedBox(height: 6),
                _reviewRow('Simpanan Khusus', 'Rp ${_formatRupiah(_calculation!.simpKhusus)}'),
                const SizedBox(height: 6),
                _reviewRow('Dana Bersih Diterima', 'Rp ${_formatRupiah(_calculation!.netAmount)}',
                    bold: true),
                const Divider(height: 16),
                _reviewRow('Angsuran / Bulan', 'Rp ${_formatRupiah(_calculation!.monthlyInstallment)}',
                    bold: true, color: primaryBlue),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Ringkasan pengajuan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _reviewRow('Tipe Pinjaman', 
                  _selectedLoanType == 'Pinjaman Biasa' 
                      ? 'Pinjaman Biasa (JAPAN)' 
                      : 'Pinjaman Lainnya (${_subLoanTypes[_selectedSubLoanType]})'),
              const SizedBox(height: 10),
              _reviewRow('Nominal Diajukan', 'Rp ${_formatRupiah(amount)}'),
              const SizedBox(height: 10),
              _reviewRow('Tenor', '$_selectedTenor bulan'),
              const SizedBox(height: 10),
              _reviewRow('Tipe Potongan', _selectedTipePotongan ?? '-'),
              const SizedBox(height: 10),
              _reviewRow('No. HP Atasan', _noAtasanController.text),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pastikan data yang diisi sudah benar. Pengajuan akan langsung dikirim ke server Kopegmar.',
                  style: TextStyle(color: Color(0xFFB45309), fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // Error submit
        if (_submitError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_submitError!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _reviewRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: color ?? Colors.black87,
            )),
      ],
    );
  }

  // ── Bottom Buttons ────────────────────────────────────────────────────────
  Widget _buildBottomButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: (_isCalculating || _isSubmitting) ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_isCalculating || _isSubmitting)
                  ? null
                  : (_currentStep < 2 ? _nextStep : _submitApplication),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: (_isCalculating || _isSubmitting)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentStep < 1
                          ? 'Lanjut'
                          : _currentStep < 2
                              ? 'Hitung & Lanjut'
                              : 'Ajukan Pinjaman',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _selectedSubSubLoanTypeCode() {
    return _selectedSubLoanType;
  }

  void _resetCalculation() {
    setState(() {
      _calculation = null;
      _calcError = null;
    });
  }
}
