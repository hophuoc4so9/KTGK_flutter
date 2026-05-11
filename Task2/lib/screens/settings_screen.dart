import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotuanphuoc_2224802010872_lab4/common/common.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/user_service.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  XFile? imageFile;
  Uint8List? imageBytes;
  String photoUrl = "";
  bool isLoading = false;
  bool _saveSuccess = false;

  double get _completeness {
    int filled = 0;
    if (nicknameController.text.trim().isNotEmpty) filled++;
    if (aboutController.text.trim().isNotEmpty) filled++;
    if (photoUrl.isNotEmpty || imageBytes != null) filled++;
    return filled / 3;
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final data = await _userService.getUserInfo();
    if (data != null && mounted) {
      nicknameController.text = data['nickname'] ?? '';
      aboutController.text = data['aboutMe'] ?? '';
      setState(() => photoUrl = data['photoUrl'] ?? '');
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageFile = picked;
        imageBytes = bytes;
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);
    try {
      String imageUrl = photoUrl;
      if (imageFile != null) {
        imageUrl = await _userService.uploadAvatar(imageFile!);
      }
      await _userService.updateProfile(
        nickname: nicknameController.text.trim(),
        aboutMe: aboutController.text.trim(),
        photoUrl: imageUrl,
      );
      if (mounted) {
        setState(() {
          photoUrl = imageUrl;
          _saveSuccess = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _saveSuccess = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // Gradient header with avatar
        SliverToBoxAdapter(
          child: Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: AppTheme.settingsHeaderGradient,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes!) as ImageProvider
                          : (photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null),
                      child: (imageBytes == null && photoUrl.isEmpty)
                          ? const Icon(Icons.person,
                              size: 52, color: Colors.white)
                          : null,
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: AppTheme.kSlow,
                          curve: Curves.elasticOut,
                        ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: AppTheme.primary, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Form card
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Your Profile",
                    style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyDark)),
                const SizedBox(height: 20),

                // Profile completeness bar
                ListenableBuilder(
                  listenable:
                      Listenable.merge([nicknameController, aboutController]),
                  builder: (context, _) {
                    final c = _completeness;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Profile completeness",
                                style: AppTheme.caption),
                            Text(
                              "${(c * 100).round()}%",
                              style: AppTheme.caption.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: c,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                TextField(
                  controller: nicknameController,
                  decoration: AppTheme.inputDecoration(
                    label: "Nickname",
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: aboutController,
                  maxLines: 4,
                  decoration: AppTheme.inputDecoration(
                    label: "About Me",
                    icon: Icons.info_outline,
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: (isLoading || _saveSuccess) ? null : saveProfile,
                  style: _saveSuccess
                      ? ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.green,
                        )
                      : null,
                  child: AnimatedSwitcher(
                    duration: AppTheme.kFast,
                    child: isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : _saveSuccess
                            ? const Icon(Icons.check,
                                key: ValueKey('check'),
                                color: Colors.white)
                            : const Text("Save Profile",
                                key: ValueKey('text')),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () async {
                    await _userService.logout();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                  label: const Text("Logout",
                      style: TextStyle(color: AppTheme.errorRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Settings")),
      body: _buildBody(),
    );
  }
}
