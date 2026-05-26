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
      title: 'Domain Email',
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const DomainPage(),
    );
  }
}

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  List domains = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDomains();
  }

  Future<void> fetchDomains() async {
    final url =
        Uri.parse('https://api.qemail.web.id/v1/email/domains');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        domains = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F4F1),

      appBar: AppBar(
        backgroundColor: const Color(0xffA3B18A),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Data Domain Email",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(14),

              child: ListView.builder(
                itemCount: domains.length,

                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    child: Card(
                      color: Colors.white,
                      elevation: 2,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),

                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              const Color(0xffDDE5D0),

                          child: Text(
                            domains[index]["id"].toString(),

                            style: const TextStyle(
                              color: Color(0xff5C6B57),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        title: Text(
                          domains[index]["name"],

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3A3A3A),
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),

                          child: Text(
                            "ID Domain : ${domains[index]["id"]}",

                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xffA3B18A),
                          size: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}