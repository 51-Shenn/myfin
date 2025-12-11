import 'package:flutter/material.dart';

class DocumentDetailsScreen extends StatefulWidget {
  const DocumentDetailsScreen({super.key});

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 30,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [

            ],
          )
        )
      )
    );
  }
}