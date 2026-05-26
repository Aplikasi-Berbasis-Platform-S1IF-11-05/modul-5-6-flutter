import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const Color _telkomRed = Color(0xFFB1112F);
const Color _telkomDeepRed = Color(0xFF7A1025);
const Color _telkomInk = Color(0xFF15151A);
const Color _telkomGold = Color(0xFFFFC400);
const Color _telkomCyan = Color(0xFF18A7B5);
const Color _canvas = Color(0xFFF6F7FB);
const Color _line = Color(0xFFE4E7EF);

class MyApp extends StatelessWidget {
  const MyApp({super.key, QEmailApi? api}) : _api = api;

  final QEmailApi? _api;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _telkomRed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QEmail',
      theme: ThemeData(
        colorScheme: colorScheme.copyWith(
          primary: _telkomRed,
          secondary: _telkomGold,
          tertiary: _telkomCyan,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: _canvas,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _telkomInk,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: _line),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _telkomRed, width: 1.4),
          ),
        ),
      ),
      home: QEmailHomePage(api: _api),
    );
  }
}

class QEmailHomePage extends StatefulWidget {
  const QEmailHomePage({super.key, QEmailApi? api}) : _api = api;

  final QEmailApi? _api;

  @override
  State<QEmailHomePage> createState() => _QEmailHomePageState();
}

class _QEmailHomePageState extends State<QEmailHomePage> {
  late final QEmailApi _api;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forwardController = TextEditingController();

  List<EmailDomain> _domains = const [];
  List<InboxMessage> _messages = const [];
  EmailDomain? _selectedDomain;
  GeneratedEmail? _generatedEmail;
  bool _loadingDomains = true;
  bool _generatingEmail = false;
  bool _loadingInbox = false;
  String? _domainError;
  String? _emailError;
  String? _inboxError;

  @override
  void initState() {
    super.initState();
    _api = widget._api ?? QEmailApi();
    _loadDomains();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _forwardController.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _loadDomains() async {
    setState(() {
      _loadingDomains = true;
      _domainError = null;
    });

    try {
      final domains = await _api.fetchDomains();
      if (!mounted) return;
      setState(() {
        _domains = domains;
        _selectedDomain = domains.contains(_selectedDomain)
            ? _selectedDomain
            : domains.firstOrNull;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _domainError = _readableError(error));
    } finally {
      if (mounted) {
        setState(() => _loadingDomains = false);
      }
    }
  }

  Future<void> _generateEmail() async {
    final domain = _selectedDomain;
    if (domain == null || _generatingEmail) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final forwardTo = _forwardController.text.trim();

    if (username.isNotEmpty && !_isValidUsername(username)) {
      setState(() {
        _emailError =
            'Username 3-30 karakter dan hanya huruf, angka, titik, garis bawah, atau strip.';
      });
      return;
    }

    if (password.isNotEmpty && password.length < 8) {
      setState(() => _emailError = 'Password minimal 8 karakter.');
      return;
    }

    if (forwardTo.isNotEmpty && !_isValidEmail(forwardTo)) {
      setState(() => _emailError = 'Format email forward belum valid.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _generatingEmail = true;
      _emailError = null;
      _inboxError = null;
      _messages = const [];
    });

    try {
      final generated = await _api.generateEmail(
        domainId: domain.id,
        username: username.isEmpty ? null : username,
        password: password.isEmpty ? null : password,
        forwardTo: forwardTo.isEmpty ? null : forwardTo,
      );

      if (!mounted) return;
      setState(() => _generatedEmail = generated);
      await _refreshInbox();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _emailError = _readableError(error));
    } finally {
      if (mounted) {
        setState(() => _generatingEmail = false);
      }
    }
  }

  Future<void> _refreshInbox() async {
    final token = _generatedEmail?.sessionToken;
    if (token == null || token.isEmpty || _loadingInbox) return;

    setState(() {
      _loadingInbox = true;
      _inboxError = null;
    });

    try {
      final messages = await _api.fetchInbox(token);
      if (!mounted) return;
      setState(() => _messages = messages);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _inboxError = _readableError(error));
    } finally {
      if (mounted) {
        setState(() => _loadingInbox = false);
      }
    }
  }

  Future<void> _refreshAll() async {
    await _loadDomains();
    if (_generatedEmail != null) {
      await _refreshInbox();
    }
  }

  bool _isValidUsername(String value) {
    final pattern = RegExp(r'^[a-zA-Z0-9._-]{3,30}$');
    return pattern.hasMatch(value);
  }

  bool _isValidEmail(String value) {
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return pattern.hasMatch(value);
  }

  String _readableError(Object error) {
    if (error is QEmailException) return error.message;
    return 'Terjadi kendala saat menghubungi API.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: _telkomRed,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                domainCount: _domains.length,
                email: _generatedEmail?.email,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 860;
                        final formPanel = _CreateEmailPanel(
                          domains: _domains,
                          selectedDomain: _selectedDomain,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          forwardController: _forwardController,
                          generatedEmail: _generatedEmail,
                          loading: _generatingEmail,
                          error: _emailError,
                          onDomainChanged: (domain) {
                            setState(() => _selectedDomain = domain);
                          },
                          onGenerate: _generateEmail,
                          onCopyEmail: _generatedEmail == null
                              ? null
                              : () => _copyToClipboard(_generatedEmail!.email),
                        );

                        final domainPanel = _DomainPanel(
                          domains: _domains,
                          selectedDomain: _selectedDomain,
                          loading: _loadingDomains,
                          error: _domainError,
                          onRefresh: _loadDomains,
                          onSelected: (domain) {
                            setState(() => _selectedDomain = domain);
                          },
                        );

                        final inboxPanel = _InboxPanel(
                          email: _generatedEmail,
                          messages: _messages,
                          loading: _loadingInbox,
                          error: _inboxError,
                          onRefresh: _refreshInbox,
                        );

                        if (!wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              formPanel,
                              const SizedBox(height: 14),
                              domainPanel,
                              const SizedBox(height: 14),
                              inboxPanel,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  formPanel,
                                  const SizedBox(height: 14),
                                  inboxPanel,
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(flex: 4, child: domainPanel),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Email disalin')));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.domainCount, required this.email});

  final int domainCount;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _telkomInk,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: _telkomRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.alternate_email_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QEmail',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Temporary Email Console',
                              style: TextStyle(
                                color: Color(0xFFB9BFCA),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MetricPill(
                        icon: Icons.dns_rounded,
                        label: '$domainCount domain',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      const _StatusChip(
                        icon: Icons.cloud_done_rounded,
                        label: 'API QEmail',
                        color: _telkomCyan,
                      ),
                      const _StatusChip(
                        icon: Icons.school_rounded,
                        color: _telkomGold,
                      ),
                      if (email != null)
                        _StatusChip(
                          icon: Icons.mark_email_read_rounded,
                          label: email!,
                          color: _telkomRed,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _telkomGold, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    this.label,
    required this.color,
  });

  final IconData icon;
  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          if (hasLabel) const SizedBox(width: 8),
          if (hasLabel)
            Text(
              label!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateEmailPanel extends StatelessWidget {
  const _CreateEmailPanel({
    required this.domains,
    required this.selectedDomain,
    required this.usernameController,
    required this.passwordController,
    required this.forwardController,
    required this.generatedEmail,
    required this.loading,
    required this.error,
    required this.onDomainChanged,
    required this.onGenerate,
    required this.onCopyEmail,
  });

  final List<EmailDomain> domains;
  final EmailDomain? selectedDomain;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController forwardController;
  final GeneratedEmail? generatedEmail;
  final bool loading;
  final String? error;
  final ValueChanged<EmailDomain?> onDomainChanged;
  final VoidCallback onGenerate;
  final VoidCallback? onCopyEmail;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.send_rounded,
            title: 'Buat Email',
            accent: _telkomRed,
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<EmailDomain>(
            key: ValueKey(selectedDomain?.id),
            initialValue: selectedDomain,
            items: domains
                .map(
                  (domain) => DropdownMenuItem(
                    value: domain,
                    child: Text('${domain.name}  #${domain.id}'),
                  ),
                )
                .toList(),
            onChanged: loading ? null : onDomainChanged,
            decoration: const InputDecoration(
              labelText: 'Domain',
              prefixIcon: Icon(Icons.public_rounded),
            ),
            isExpanded: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: usernameController,
            textInputAction: TextInputAction.next,
            enabled: !loading,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'kosongkan untuk random',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            enabled: !loading,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'opsional',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: forwardController,
            enabled: !loading,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Forward to',
              hintText: 'opsional',
              prefixIcon: Icon(Icons.forward_to_inbox_rounded),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: error!),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: selectedDomain == null || loading ? null : onGenerate,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bolt_rounded),
              label: Text(loading ? 'Membuat email' : 'Generate Email'),
              style: FilledButton.styleFrom(
                backgroundColor: _telkomRed,
                disabledBackgroundColor: _line,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (generatedEmail != null) ...[
            const SizedBox(height: 18),
            _GeneratedEmailCard(
              generatedEmail: generatedEmail!,
              onCopyEmail: onCopyEmail,
            ),
          ],
        ],
      ),
    );
  }
}

class _GeneratedEmailCard extends StatelessWidget {
  const _GeneratedEmailCard({
    required this.generatedEmail,
    required this.onCopyEmail,
  });

  final GeneratedEmail generatedEmail;
  final VoidCallback? onCopyEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD7DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mark_email_unread_rounded, color: _telkomRed),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Email Aktif',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _telkomInk,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Salin email',
                onPressed: onCopyEmail,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            generatedEmail.email,
            style: const TextStyle(
              color: _telkomDeepRed,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(
                icon: Icons.schedule_rounded,
                text: generatedEmail.expiryLabel,
              ),
              _InfoBadge(
                icon: Icons.vpn_key_rounded,
                text: '${generatedEmail.sessionToken.length} token',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DomainPanel extends StatelessWidget {
  const _DomainPanel({
    required this.domains,
    required this.selectedDomain,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onSelected,
  });

  final List<EmailDomain> domains;
  final EmailDomain? selectedDomain;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;
  final ValueChanged<EmailDomain> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator(color: _telkomRed)),
      );
    } else if (error != null) {
      content = Column(
        children: [
          _InlineError(message: error!),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Muat ulang'),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          for (final domain in domains) ...[
            _DomainTile(
              domain: domain,
              selected: domain == selectedDomain,
              onTap: () => onSelected(domain),
            ),
            if (domain != domains.last) const SizedBox(height: 8),
          ],
        ],
      );
    }

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.dns_rounded,
            title: 'Domain API',
            accent: _telkomCyan,
            action: IconButton(
              tooltip: 'Refresh domain',
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

class _DomainTile extends StatelessWidget {
  const _DomainTile({
    required this.domain,
    required this.selected,
    required this.onTap,
  });

  final EmailDomain domain;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _telkomRed : _line,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: selected ? _telkomRed : const Color(0xFFEAF8FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language_rounded,
                color: selected ? Colors.white : _telkomCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _telkomInk,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'id: ${domain.id}',
                    style: const TextStyle(
                      color: Color(0xFF687080),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected ? _telkomRed : const Color(0xFFBBC2CE),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxPanel extends StatelessWidget {
  const _InboxPanel({
    required this.email,
    required this.messages,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  final GeneratedEmail? email;
  final List<InboxMessage> messages;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.inbox_rounded,
            title: 'Inbox',
            accent: _telkomGold,
            action: IconButton(
              tooltip: 'Refresh inbox',
              onPressed: email == null || loading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 16),
          if (email == null)
            const _EmptyState(
              icon: Icons.alternate_email_rounded,
              title: 'Belum ada email aktif',
              text: 'Generate email untuk melihat inbox.',
            )
          else if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: CircularProgressIndicator(color: _telkomRed),
              ),
            )
          else if (error != null)
            _InlineError(message: error!)
          else if (messages.isEmpty)
            const _EmptyState(
              icon: Icons.move_to_inbox_rounded,
              title: 'Inbox kosong',
              text: 'Email baru akan tampil di sini.',
            )
          else
            Column(
              children: [
                for (final message in messages) ...[
                  _MessageTile(message: message),
                  if (message != messages.last) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final InboxMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.mail_rounded, color: Color(0xFF9B6F00)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _telkomInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.sender,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF687080),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message.preview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    message.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF4C5361)),
                  ),
                ],
              ],
            ),
          ),
          if (message.dateLabel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              message.dateLabel,
              style: const TextStyle(
                color: Color(0xFF8A92A3),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.accent,
    this.action,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _telkomInk,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD7DE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _telkomRed, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _telkomInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFCAD4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: _telkomRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _telkomDeepRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF9AA3B2), size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _telkomInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF687080)),
          ),
        ],
      ),
    );
  }
}

class QEmailApi {
  QEmailApi({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.qemail.web.id';
  final http.Client _client;

  Future<List<EmailDomain>> fetchDomains() async {
    final response = await _client.get(Uri.parse('$_baseUrl/v1/email/domains'));
    final body = _decode(response);

    if (response.statusCode != 200) {
      throw QEmailException('Gagal memuat domain (${response.statusCode}).');
    }

    if (body is! List) {
      throw const QEmailException('Format data domain tidak sesuai.');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(EmailDomain.fromJson)
        .toList();
  }

  Future<GeneratedEmail> generateEmail({
    required int domainId,
    String? username,
    String? password,
    String? forwardTo,
  }) async {
    final payload = <String, Object?>{'domain_id': domainId};
    if (username != null) payload['username'] = username;
    if (password != null) payload['password'] = password;
    if (forwardTo != null) payload['forward_to'] = forwardTo;

    final response = await _client.post(
      Uri.parse('$_baseUrl/v1/email/generate'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = _decode(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw QEmailException(
        _messageFromBody(body) ??
            'Gagal membuat email (${response.statusCode}).',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw const QEmailException('Format data email tidak sesuai.');
    }

    return GeneratedEmail.fromJson(body);
  }

  Future<List<InboxMessage>> fetchInbox(String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/email/inbox/$token?page=1&limit=20'),
    );
    final body = _decode(response);

    if (response.statusCode != 200) {
      throw QEmailException(
        _messageFromBody(body) ??
            'Gagal memuat inbox (${response.statusCode}).',
      );
    }

    final rawMessages = switch (body) {
      {'data': final List data} => data,
      final List data => data,
      _ => const [],
    };

    return rawMessages
        .whereType<Map<String, dynamic>>()
        .map(InboxMessage.fromJson)
        .toList();
  }

  Object? _decode(http.Response response) {
    final content = utf8.decode(response.bodyBytes);
    if (content.trim().isEmpty) return null;

    try {
      return jsonDecode(content);
    } on FormatException {
      return content;
    }
  }

  String? _messageFromBody(Object? body) {
    if (body case {'message': final Object message}) return message.toString();
    if (body case {'error': final Object error}) return error.toString();
    return null;
  }

  void close() => _client.close();
}

class EmailDomain {
  const EmailDomain({required this.id, required this.name});

  final int id;
  final String name;

  factory EmailDomain.fromJson(Map<String, dynamic> json) {
    return EmailDomain(
      id: (json['id'] as num).toInt(),
      name: json['name'].toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EmailDomain && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

class GeneratedEmail {
  const GeneratedEmail({
    required this.email,
    required this.sessionToken,
    required this.expiresAt,
    this.token,
  });

  final String email;
  final String sessionToken;
  final String? token;
  final DateTime? expiresAt;

  factory GeneratedEmail.fromJson(Map<String, dynamic> json) {
    return GeneratedEmail(
      email: json['email'].toString(),
      sessionToken: json['session_token'].toString(),
      token: json['token']?.toString(),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }

  String get expiryLabel {
    final date = expiresAt;
    if (date == null) return 'aktif';

    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    return '$day/$month/$year';
  }
}

class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.subject,
    required this.sender,
    required this.preview,
    required this.dateLabel,
  });

  final String id;
  final String subject;
  final String sender;
  final String preview;
  final String dateLabel;

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    final rawSender = json['from'] ?? json['sender'] ?? json['from_email'];
    final sender = switch (rawSender) {
      {'email': final Object email} => email.toString(),
      {'address': final Object address} => address.toString(),
      {'name': final Object name} => name.toString(),
      final Object value => value.toString(),
      null => 'unknown sender',
    };

    return InboxMessage(
      id: (json['id'] ?? json['messageId'] ?? json['message_id'] ?? '')
          .toString(),
      subject: (json['subject'] ?? 'Tanpa subjek').toString(),
      sender: sender,
      preview: (json['text'] ?? json['snippet'] ?? json['preview'] ?? '')
          .toString(),
      dateLabel:
          (json['created_at'] ?? json['received_at'] ?? json['date'] ?? '')
              .toString(),
    );
  }
}

class QEmailException implements Exception {
  const QEmailException(this.message);

  final String message;
}
