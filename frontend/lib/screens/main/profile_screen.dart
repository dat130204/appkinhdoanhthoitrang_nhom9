import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'wishlist_screen.dart';
import '../profile/profile_edit_screen.dart';
import '../profile/address_list_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/help_screen.dart';
import 'package:badges/badges.dart' as badges;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 100,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.pleaseLoginToContinue,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(l10n.login),
                  ),
                ],
              ),
            );
          }

          final user = authProvider.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppColors.primary,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Wishlist Section
                Consumer<WishlistProvider>(
                  builder: (context, wishlistProvider, child) {
                    return ListTile(
                      leading: const Icon(
                        Icons.favorite_border,
                        color: AppColors.error,
                      ),
                      title: Text(l10n.myWishlist),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (wishlistProvider.itemCount > 0)
                            badges.Badge(
                              badgeContent: Text(
                                wishlistProvider.itemCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              child: const Icon(Icons.chevron_right),
                            )
                          else
                            const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(l10n.myOrders),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/order_history');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.personalInfo),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileEditScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(l10n.shippingAddress),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressListScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.password),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      title: Text(l10n.darkMode),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: AppColors.primary,
                      ),
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
                const Divider(),
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.language),
                      subtitle: Text(
                        languageProvider.isVietnamese
                            ? l10n.vietnamese
                            : l10n.english,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showLanguageSelector(context, languageProvider);
                      },
                    );
                  },
                ),
                const Divider(),

                // Admin Panel Access (only for admin users)
                if (user?.role == 'admin') ...[
                  ListTile(
                    leading: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.purple,
                    ),
                    title: const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.purple,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin');
                    },
                  ),
                  const Divider(),
                ],

                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(l10n.help),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    l10n.logout,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _showLanguageSelector(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectLanguage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text('🇻🇳', style: TextStyle(fontSize: 32)),
                title: Text(l10n.vietnamese),
                trailing: languageProvider.isVietnamese
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await languageProvider.setLanguage('vi');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.languageChanged),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 32)),
                title: Text(l10n.english),
                trailing: languageProvider.isEnglish
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await languageProvider.setLanguage('en');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.languageChanged),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
