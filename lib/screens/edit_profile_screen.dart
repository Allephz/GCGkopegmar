// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Abdur Rahman');
    _emailController = TextEditingController(text: 'abdur@kopegmar.com');
    _phoneController = TextEditingController(text: '0812345678');
    _addressController =
        TextEditingController(text: 'Jl. Merdeka No. 123, Jakarta');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color warningOrange = Color(0xFFF59E0B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: warningOrange,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Beberapa data hanya bisa diubah oleh admin',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: warningOrange,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name
            Text(
              'Nama Lengkap',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Nama lengkap',
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            Text(
              'Email',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            Text(
              'Nomor Telepon',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Nomor telepon',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            Text(
              'Alamat',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Alamat lengkap',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Simpan Perubahan'),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
