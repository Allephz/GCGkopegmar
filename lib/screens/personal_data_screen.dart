// lib/screens/personal_data_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/responses.dart';
import 'edit_profile_screen.dart';

class PersonalDataScreen extends StatefulWidget {
  final String initialSection;
  const PersonalDataScreen({Key? key, this.initialSection = 'all'}) : super(key: key);

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _apiService = ApiService();
  PersonalData? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _apiService.memberId ?? 'CANDRA';
      final response = await _apiService.getPersonalData(userId);
      setState(() {
        _userData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);

    String titleText = 'Detail Data';
    if (widget.initialSection == 'pribadi') titleText = 'Data Pribadi';
    if (widget.initialSection == 'pekerjaan') titleText = 'Data Pekerjaan';
    if (widget.initialSection == 'alamat') titleText = 'Alamat';
    if (widget.initialSection == 'bank') titleText = 'Data Bank';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identitas Section
                  if (widget.initialSection == 'all' || widget.initialSection == 'pribadi') ...[
                    _DataSection(
                      title: 'Identitas',
                      items: [
                        _DataItem('Nama', _userData?.name ?? '-'),
                        _DataItem('Jenis Kelamin', _userData?.gender ?? '-'),
                        _DataItem('Tempat Lahir', _userData?.birthPlace ?? '-'),
                        _DataItem('Tanggal Lahir', _userData?.birthDate ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Kontak Section
                  if (widget.initialSection == 'all' || widget.initialSection == 'pribadi') ...[
                    _DataSection(
                      title: 'Kontak',
                      items: [
                        _DataItem('Email', _userData?.email ?? '-'),
                        _DataItem('Telepon', _userData?.phone ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Alamat Section
                  if (widget.initialSection == 'all' || widget.initialSection == 'alamat') ...[
                    _DataSection(
                      title: 'Alamat',
                      items: [
                        _DataItem('Alamat', _userData?.address ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Pekerjaan Section
                  if (widget.initialSection == 'all' || widget.initialSection == 'pekerjaan') ...[
                    _DataSection(
                      title: 'Pekerjaan',
                      items: [
                        _DataItem('Perusahaan', _userData?.company ?? '-'),
                        _DataItem('NIP', _userData?.employeeNumber ?? '-'),
                        _DataItem('Golongan', _userData?.memberGroup ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bank Section
                  if (widget.initialSection == 'all' || widget.initialSection == 'bank') ...[
                    _DataSection(
                      title: 'Rekening Bank',
                      items: [
                        _DataItem('Bank', _userData?.bank ?? '-'),
                        _DataItem('No. Rekening', _userData?.bankAccount ?? '-'),
                        _DataItem('Atas Nama', _userData?.bankAccountName ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Edit Button (Only show if viewing all or personal profile section)
                  if (widget.initialSection == 'all' || widget.initialSection == 'pribadi')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Data'),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _DataSection extends StatelessWidget {
  final String title;
  final List<_DataItem> items;

  const _DataSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) {
                final item = items[index];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.black45,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.value,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (index < items.length - 1) const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DataItem {
  final String label;
  final String value;

  _DataItem(this.label, this.value);
}
