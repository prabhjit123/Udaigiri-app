import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AdminSection extends StatelessWidget {
  const AdminSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Admin Team Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.email),
              label: const Text('Contact All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAdminList(),
      ],
    );
  }

  Widget _buildAdminList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _adminProfile('Dr. S. Sharma', 'Warden', Icons.security),
          _adminProfile('Ms. R. Singh', 'Mess Manager', Icons.restaurant),
          _adminProfile('Mr. A. Kumar', 'Maintenance Head', Icons.build),
        ],
      ),
    );
  }

  Widget _adminProfile(String name, String role, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        role,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.message, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
