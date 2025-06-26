import 'dart:ui';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3],
            ),
          ),
        ),
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUserProfile;

            if (authProvider.currentUser != null && user == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (user == null) {
              return const Scaffold(
                body: Center(child: Text("غير مسجل الدخول")),
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 320,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(40),
                                    bottomRight: Radius.circular(40),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 55,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            user.profileImageUrl != null
                                                ? NetworkImage(
                                                    user.profileImageUrl!)
                                                : null,
                                        child: user.profileImageUrl == null
                                            ? const Icon(Icons.person,
                                                size: 60, color: Colors.grey)
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () async {
                                            await authProvider
                                                .pickAndUploadProfileImage();
                                          },
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.white,
                                            child: const Icon(Icons.camera_alt,
                                                size: 18, color: kPrimaryColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                        color: Color.fromARGB(179, 0, 0, 0)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.phone,
                                    style: const TextStyle(
                                        color: Color.fromARGB(179, 0, 0, 0)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "مرحباً بك في تطبيق كيور! نحن سعداء بخدمتك ❤️",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _GlassButton(
                        icon: Icons.edit_note,
                        label: "تعديل البيانات",
                        color: kPrimaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, editProfileRoute);
                        },
                      ),
                      _GlassButton(
                        icon: Icons.history,
                        label: "سجل الطلبات",
                        color: kPrimaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, ordersRoute);
                        },
                      ),
                      _GlassButton(
                        icon: Icons.logout,
                        label: "تسجيل الخروج",
                        color: Colors.red.shade600,
                        onTap: () async {
                          await authProvider.signOut(context);
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, loginRoute, (route) => false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlassButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
