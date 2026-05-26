import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:laprak/main.dart';

void main() {
  testWidgets('QEmail app shows domains and generated email', (tester) async {
    await tester.pumpWidget(MyApp(api: _FakeQEmailApi()));
    await tester.pump();

    expect(find.text('QEmail Tel-U'), findsOneWidget);
    expect(find.text('Domain API'), findsOneWidget);
    expect(find.text('qemail.web.id'), findsOneWidget);
    expect(find.text('id: 5'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'mahasiswa');
    await tester.tap(find.text('Generate Email'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Email Aktif'), findsOneWidget);
    expect(find.text('mahasiswa@qemail.web.id'), findsWidgets);
    expect(find.text('Selamat datang'), findsOneWidget);
  });
}

class _FakeQEmailApi extends QEmailApi {
  _FakeQEmailApi() : super(client: _StubClient());

  @override
  Future<List<EmailDomain>> fetchDomains() async {
    return const [
      EmailDomain(id: 5, name: 'qemail.web.id'),
      EmailDomain(id: 15, name: 'aii.my.id'),
    ];
  }

  @override
  Future<GeneratedEmail> generateEmail({
    required int domainId,
    String? username,
    String? password,
    String? forwardTo,
  }) async {
    return const GeneratedEmail(
      email: 'mahasiswa@qemail.web.id',
      sessionToken: 'session-token-123456',
      expiresAt: null,
    );
  }

  @override
  Future<List<InboxMessage>> fetchInbox(String token) async {
    return const [
      InboxMessage(
        id: 'message-1',
        subject: 'Selamat datang',
        sender: 'admin@qemail.web.id',
        preview: 'Inbox berhasil tersambung.',
        dateLabel: 'hari ini',
      ),
    ];
  }

  @override
  void close() {}
}

class _StubClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }
}
