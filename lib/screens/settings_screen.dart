import 'package:flutter/material.dart';
import 'package:flutter_application_gameshub/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _currentUser = _authService.currentUser;

      if (_currentUser != null) {
        DocumentSnapshot userDoc = await _authService.getUserData(
          _currentUser!.uid,
        );
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D022F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B2E7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section with real data
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData?['username'] ??
                                      _currentUser?.displayName ??
                                      'Player',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userData?['accountType'] ?? 'Free Member',
                                  style: TextStyle(
                                    color:
                                        (_userData?['accountType'] == 'Pro' ||
                                            _userData?['accountType'] ==
                                                'Premium')
                                        ? const Color(0xFF00B894)
                                        : Colors.yellow,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentUser?.email ?? 'No email',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Settings Options Section
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Column(
                        children: [
                          // Edit Profile
                          _buildSettingsOption(
                            icon: Icons.edit,
                            title: 'Edit Profile',
                            subtitle:
                                'Change username, email, or profile picture',
                            onTap: () {
                              _showEditProfileDialog();
                            },
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),

                          // Sound Settings
                          _buildSettingsOption(
                            icon: Icons.volume_up,
                            title: 'Sound & Music',
                            subtitle: 'Adjust game sounds and background music',
                            onTap: () {
                              _showSoundSettingsDialog();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About & Legal Section
                    const Text(
                      'About & Legal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Column(
                        children: [
                          // About Us
                          _buildSettingsOption(
                            icon: Icons.info,
                            title: 'About Us',
                            subtitle: 'Learn more about Games Hub',
                            onTap: () {
                              _showAboutUsDialog();
                            },
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),

                          // Privacy Policy
                          _buildSettingsOption(
                            icon: Icons.privacy_tip,
                            title: 'Privacy Policy',
                            subtitle: 'Read our privacy policy',
                            onTap: () {
                              _showPrivacyPolicy();
                            },
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),

                          // Terms of Service
                          _buildSettingsOption(
                            icon: Icons.description,
                            title: 'Terms of Service',
                            subtitle: 'Read our terms and conditions',
                            onTap: () {
                              _showTermsOfService();
                            },
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),

                          // Help & Support
                          _buildSettingsOption(
                            icon: Icons.help_center,
                            title: 'Help & Support',
                            subtitle: 'Get help or contact support',
                            onTap: () {
                              _showHelpSupport();
                            },
                          ),

                          // Show Cancel Subscription ONLY if Pro user
                          if (_userData?['accountType'] == "Pro") ...[
                            const Divider(
                              color: Colors.white24,
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),

                            _buildSettingsOption(
                              icon: Icons.cancel,
                              title: 'Cancel Subscription',
                              subtitle: 'Downgrade to Free plan',
                              onTap: () {
                                _showCancelSubscriptionDialog();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _handleLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App Version
                    Center(
                      child: Text(
                        'Games Hub v1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Developer Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Colors.white, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/me.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Developer Name
                const Text(
                  'Kshitij Gupta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Developer & Founder',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Why I Built This App Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why I Built This App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'I created Games Hub to solve a common problem I faced as a gamer - the fragmentation of gaming content across multiple platforms. As a passionate gamer myself, I wanted to build a unified platform where players can discover, track, and enjoy games all in one place.\n\n'
                        'My vision was to create an app that not only helps gamers find their next favorite game but also helps developers showcase their creations to the right audience. Games Hub is built with love for the gaming community, with features designed to enhance your gaming journey.\n\n'
                        'Whether you\'re a casual player or a hardcore enthusiast, I hope Games Hub becomes your go-to companion for all things gaming!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // App Info
                const Row(
                  children: [
                    Icon(Icons.email, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'kshitij.gupta9137@gmail.com',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const Row(
                  children: [
                    Icon(Icons.language, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'www.gameshub.app',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Updated: December 2023',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '1. Information We Collect\n'
                        '• Account Information: Username, email, profile picture\n'
                        '• Game Data: Your game preferences, play history, and achievements\n'
                        '• Device Information: Device type, operating system, and app usage data\n'
                        '• Payment Information: For Pro subscriptions (handled securely via payment processors)\n\n'
                        '2. How We Use Your Information\n'
                        '• To provide and improve our gaming services\n'
                        '• To personalize your gaming experience\n'
                        '• To send important updates and notifications\n'
                        '• To analyze app usage for improvements\n\n'
                        '3. Data Security\n'
                        'We implement industry-standard security measures to protect your data. '
                        'Your information is encrypted and stored securely on Firebase servers.\n\n'
                        '4. Third-Party Services\n'
                        'We use Firebase for authentication and data storage, and payment processors '
                        'for subscription handling. These services have their own privacy policies.\n\n'
                        '5. Your Rights\n'
                        'You can request to view, update, or delete your personal data at any time '
                        'by contacting us at privacy@gameshub.app',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'By using Games Hub, you agree to these terms:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1. Account Responsibility\n'
                        '• You are responsible for maintaining the confidentiality of your account\n'
                        '• You must provide accurate information when creating an account\n'
                        '• You must be at least 13 years old to use this service\n\n'
                        '2. Acceptable Use\n'
                        '• Use Games Hub only for lawful purposes\n'
                        '• Do not attempt to hack, disrupt, or overload our services\n'
                        '• Respect other users and do not harass or threaten anyone\n'
                        '• Do not share inappropriate or offensive content\n\n'
                        '3. Subscription Terms\n'
                        '• Pro subscriptions are billed monthly or annually\n'
                        '• You can cancel anytime, with access continuing until the end of your billing period\n'
                        '• No refunds for partial subscription periods\n'
                        '• We reserve the right to change subscription prices with 30 days notice\n\n'
                        '4. Intellectual Property\n'
                        '• All content, logos, and designs are property of Games Hub\n'
                        '• You may not copy, modify, or distribute our content without permission\n'
                        '• Game content shown in the app belongs to their respective owners\n\n'
                        '5. Limitation of Liability\n'
                        '• Games Hub is provided "as is" without warranties\n'
                        '• We are not liable for any damages resulting from app use\n'
                        '• We reserve the right to modify or discontinue services at any time\n\n'
                        '6. Changes to Terms\n'
                        'We may update these terms periodically. Continued use after changes constitutes acceptance.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Help & Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // FAQ Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      Text(
                        'Q: How do I upgrade to Pro?\n'
                        'A: Go to your profile, tap "Upgrade to Pro", and follow the payment instructions.\n\n'
                        'Q: Can I cancel my subscription?\n'
                        'A: Yes, go to Settings > Account > Cancel Subscription.\n\n'
                        'Q: How do I reset my password?\n'
                        'A: On the login screen, tap "Forgot Password".\n\n'
                        'Q: Is my payment information secure?\n'
                        'A: Yes, we use secure payment processors and never store your card details.\n\n'
                        'Q: How do I report a bug?\n'
                        'A: Contact us at support@gameshub.app with details.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Contact Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'vvaarungupta@gmail.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(Icons.language, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'kshitij.gupta9137@gmail.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Support Hours: Mon-Fri,9AM-6PM',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text(
                            '9473879437',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Response Time
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'We typically respond within 24 hours on weekdays',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text(
          'Cancel Subscription',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel your Pro subscription? You will lose access to Pro features at the end of your billing period.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );

              try {
                await _authService.cancelSubscription();

                // Refresh user data from Firestore
                await _loadUserData();

                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context); // close loading
                }

                if (mounted) {
                  _showSnackBar(
                    'Subscription cancelled successfully!',
                    Colors.green,
                  );
                }
              } catch (e) {
                print('Error cancelling subscription: $e');

                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context); // close loading
                }

                if (mounted) {
                  _showSnackBar(
                    'Failed to cancel subscription. Please try again.',
                    Colors.red,
                  );
                }
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      try {
        String? result = await _authService.signOut();

        // Check if widget is still mounted before popping
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }

        if (mounted) {
          if (result == "Success") {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
            _showSnackBar('Logout failed: $result', Colors.red);
          }
        }
      } catch (e) {
        // Check if widget is still mounted before popping
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          print('Error during logout: $e');
          _showSnackBar('Error during logout: $e', Colors.red);
        }
      }
    }
  }

  // ADD THIS HELPER METHOD - it was missing from your code
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: _userData?['username'] ?? '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: _currentUser?.email ?? '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement profile update
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showSoundSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text(
          'Sound Settings',
          style: TextStyle(color: Colors.white),
        ),
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sound settings coming soon!',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
