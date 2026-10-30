// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/responses.dart';
import 'edit_profile_screen.dart';
import 'personal_data_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color errorRed = Color(0xFFEF4444);
    const Color bgGray = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar & Name
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue.withOpacity(0.1),
                          border: Border.all(
                            color: primaryBlue,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userData?.name ?? 'Member',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 20,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData?.company ?? '-',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Edit Profile Button
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
                      label: const Text('Edit Profil'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Items
                  _profileMenuItem(
                    icon: Icons.person_outline,
                    label: 'Data Pribadi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalDataScreen(initialSection: 'pribadi'),
                        ),
                      );
                    },
                  ),
                  _profileMenuItem(
                    icon: Icons.assignment_outlined,
                    label: 'Data Pekerjaan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalDataScreen(initialSection: 'pekerjaan'),
                        ),
                      );
                    },
                  ),
                  _profileMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalDataScreen(initialSection: 'alamat'),
                        ),
                      );
                    },
                  ),
                  _profileMenuItem(
                    icon: Icons.account_balance,
                    label: 'Data Bank',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalDataScreen(initialSection: 'bank'),
                        ),
                      );
                    },
                  ),
                  _profileMenuItem(
                    icon: Icons.security_outlined,
                    label: 'Keamanan & Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Keamanan & Password dapat dikelola melalui web portal Kopegmar.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Danger Zone
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: errorRed.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: errorRed.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zona Berbahaya',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: errorRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Keluar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: errorRed,
                              side: BorderSide(color: errorRed),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Delete account
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Akun?'),
                                  content: const Text(
                                    'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Akun dihapus',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: errorRed,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Hapus Akun'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: errorRed,
                              side: BorderSide(color: errorRed),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Version
                  Text(
                    'GCG Akor Kopegmar v1.0.0',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _profileMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Icon(icon, size: 24, color: const Color(0xFF2563EB)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 24, color: Colors.black45),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
