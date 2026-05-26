// Syiva Qaila Natasa Sugama - 2311102106 - IF-11-05

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QEmail Monitoring Console',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep Royal Blue
          primary: const Color(0xFF0F172A),   // Dark Navy Blue
          secondary: const Color(0xFF2563EB), // Vibrant Blue
          surface: const Color(0xFFF8FAFC), // Slate White
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const EmailMonitorDashboard(),
    );
  }
}

class EmailMonitorDashboard extends StatefulWidget {
  const EmailMonitorDashboard({super.key});

  @override
  State<EmailMonitorDashboard> createState() => _EmailMonitorDashboardState();
}

class _EmailMonitorDashboardState extends State<EmailMonitorDashboard> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State flags and data
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _resultData;
  bool _isSimulationMode = true; // Enabled by default to show clean success states even when API is offline

  // Real REST API Fetch using package http
  Future<void> _checkEmailStatus(String email) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultData = null;
    });

    try {
      if (_isSimulationMode) {
        // Simulate a realistic API network request & response based on domain
        await Future.delayed(const Duration(milliseconds: 1500));
        
        final lowerEmail = email.toLowerCase().trim();
        if (lowerEmail.contains('error')) {
          throw Exception('Simulated Server Connection Timeout (504 Gateway Timeout).');
        }

        if (lowerEmail.endsWith('@gmail.com') || lowerEmail.endsWith('@outlook.com') || lowerEmail.endsWith('@yahoo.com')) {
          _resultData = {
            "email": email,
            "status": "valid",
            "domain": email.split('@').last,
            "disposable": false,
            "mailbox_exists": true,
            "mx_records": true,
            "message": "Mailbox is active and verified to receive messages.",
            "last_checked": DateTime.now().toIso8601String(),
          };
        } else if (lowerEmail.contains('temp') || lowerEmail.contains('mailinator')) {
          _resultData = {
            "email": email,
            "status": "disposable",
            "domain": email.split('@').last,
            "disposable": true,
            "mailbox_exists": true,
            "mx_records": true,
            "message": "Disposable or temporary email address detected.",
            "last_checked": DateTime.now().toIso8601String(),
          };
        } else {
          _resultData = {
            "email": email,
            "status": "invalid",
            "domain": email.split('@').last,
            "disposable": false,
            "mailbox_exists": false,
            "mx_records": false,
            "message": "The mailbox does not exist or has been disabled.",
            "last_checked": DateTime.now().toIso8601String(),
          };
        }
      } else {
        // ACTUAL REST API CALL to the endpoint
        final uri = Uri.parse('https://api.qemail.web.id/v1/email/check?email=$email');
        
        // GET method with timeout
        final response = await http.get(uri).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Connection timed out. Please check your network.');
          },
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            _resultData = decoded;
          } else {
            throw Exception('Unexpected API response format');
          }
        } else {
          // Handle error codes like 404, 500, etc.
          final errorBody = jsonDecode(response.body);
          final msg = errorBody['message'] ?? 'Server error status: ${response.statusCode}';
          throw Exception(msg);
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }
    // Simple email validation regex
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Dark Navy
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF38BDF8), size: 24), // Light blue accent icon
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QEMAIL CONSOLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'REST API Email Monitoring',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Simulation Mode Toggle Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _isSimulationMode ? Colors.amber.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isSimulationMode ? Colors.amber.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isSimulationMode ? Icons.widgets : Icons.cloud_done,
                  color: _isSimulationMode ? Colors.amber : Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  _isSimulationMode ? 'SIMULATOR' : 'LIVE API',
                  style: TextStyle(
                    color: _isSimulationMode ? Colors.amber.shade300 : Colors.green.shade300,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Toggle Live/Simulation API',
            icon: Icon(
              _isSimulationMode ? Icons.toggle_on_outlined : Icons.toggle_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSimulationMode = !_isSimulationMode;
                _resultData = null;
                _errorMessage = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSimulationMode
                      ? 'Switched to Simulation Mode (Demo UI)'
                      : 'Switched to Live API Mode'),
                  backgroundColor: const Color(0xFF1E293B),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark Header Panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A), // Dark Navy
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verification Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analyze real-time status of email accounts via RESTful SMTP handshake and MX domain records checker.',
                    style: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Layout
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Card
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  
                  // Title for Results Area
                  const Row(
                    children: [
                      Icon(Icons.dashboard_customize_outlined, size: 18, color: Color(0xFF475569)),
                      SizedBox(width: 8),
                      Text(
                        'MONITORING OUTPUT',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Output State Widget (Loading, Error, Idle, Result)
                  _buildOutputWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Email Check Form Card
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verify New Mailbox',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            
            // TextField for Email Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B)),
                hintText: 'e.g. employee@company.com',
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                suffixIcon: _emailController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          setState(() {
                            _emailController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (text) {
                setState(() {}); // refresh suffix clear icon
              },
            ),
            const SizedBox(height: 20),
            
            // Check button
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                if (_formKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus();
                  _checkEmailStatus(_emailController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Slate Blue accent
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.radar_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isLoading ? 'Analyzing...' : 'Check Status',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Displays Output base on state
  Widget _buildOutputWidget() {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
              SizedBox(height: 18),
              Text(
                'Connecting to Mail Server...',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Performing MX lookup and SMTP handshake',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Very soft red
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'API Request Failed',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            
            // Retry tips/simulation helper
            if (_errorMessage!.contains('Route not found'))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tip: The server returned 404 Route Not Found. Enable "Simulator" at the top right to mock the successful response design!',
                        style: TextStyle(color: Color(0xFF78350F), fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    if (_resultData != null) {
      return _buildResultCard();
    }

    // Default Idle View
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.query_stats_rounded, size: 54, color: Colors.blueGrey.shade200),
          const SizedBox(height: 16),
          const Text(
            'Console Ready',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter an email and execute the checker to query system telemetry.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade400,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Displays the verified result elegantly
  Widget _buildResultCard() {
    final status = _resultData!['status'] ?? 'unknown';
    final email = _resultData!['email'] ?? '';
    final domain = _resultData!['domain'] ?? '';
    final isDisposable = _resultData!['disposable'] == true;
    final mailboxExists = _resultData!['mailbox_exists'] == true;
    final mxRecords = _resultData!['mx_records'] == true;
    final message = _resultData!['message'] ?? 'No telemetry report message.';

    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    switch (status.toString().toLowerCase()) {
      case 'valid':
        statusColor = const Color(0xFF10B981); // Emerald Green
        statusIcon = Icons.verified_user_rounded;
        statusTitle = 'DELIVERABLE';
        break;
      case 'disposable':
        statusColor = const Color(0xFFF59E0B); // Amber Warning
        statusIcon = Icons.warning_rounded;
        statusTitle = 'DISPOSABLE';
        break;
      case 'invalid':
      default:
        statusColor = const Color(0xFFEF4444); // Bright Red
        statusIcon = Icons.cancel_rounded;
        statusTitle = 'UNDELIVERABLE';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            color: statusColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Details Padding
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telemetry Summary',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Details Grid
                _buildInfoRow('Domain Server', domain, Icons.dns_outlined),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildCheckRow('Mailbox Handshake', mailboxExists, 'SMTP Valid', 'No mailbox'),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildCheckRow('MX DNS Registry', mxRecords, 'Active Records', 'No MX records'),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildCheckRow('Deliverability Risk', !isDisposable, 'Safe Domain', 'Disposable Mail'),
                
                const SizedBox(height: 20),
                
                // Description/Recommendation Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF475569)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Server Report:',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Row for string outputs
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // Row with success/fail checklist look
  Widget _buildCheckRow(String label, bool checkValue, String successText, String failText) {
    return Row(
      children: [
        Icon(
          checkValue ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
          size: 18,
          color: checkValue ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: checkValue ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            checkValue ? successText : failText,
            style: TextStyle(
              color: checkValue ? const Color(0xFF047857) : const Color(0xFFB91C1C),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
