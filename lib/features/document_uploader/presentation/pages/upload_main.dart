import 'package:flutter/material.dart';
import 'package:myfin/features/document_uploader/presentation/pages/option.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen ({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 30,
            fontWeight: FontWeight.bold
            )
          ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUploadOptionCard(Option.manual),
            _buildUploadOptionCard(Option.file),
            Row(
              children: [
                Expanded(
                  child: _buildUploadOptionCard(
                    Option.gallery,
                    customPadding: EdgeInsets.fromLTRB(30, 10, 10, 10)
                  )
                ),
                Expanded(
                  child: _buildUploadOptionCard(
                    Option.scan,
                    customPadding: EdgeInsets.fromLTRB(10, 10, 30, 10)
                  )
                )
              ],
            ),
            _buildRecentUploads(),
          ],
        )
      )
    );
  }

  Widget _buildUploadOptionCard(Option option, {EdgeInsetsGeometry? customPadding}) {
    double iconSize = option.isMainOption? 50 : 40;
    double titleFontSize = option.isMainOption? 20: 14;
    double descFontSize = option.isMainOption? 16 : 20;
    double horizontalPadding = option.isMainOption? 25 : 15;

    return Padding(
      padding: customPadding?? EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Align(
        alignment: Alignment.center,
        child: Material(
          elevation: 2,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, option.navigateTo), // should get button to navigate to their own
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Icon(option.icon, size: iconSize, color: const Color(0xFF2B46F9),),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              option.title,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: titleFontSize,
                                fontWeight: option.isMainOption? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                          ),
                          Text(
                            option.description,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: descFontSize,
                              fontWeight: option.isMainOption? FontWeight.normal : FontWeight.bold,
                              color: option.isMainOption? const Color.fromARGB(255, 106, 106, 106) : Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              )
            )
          )
        )
      )
    );
  }

  Widget _buildRecentUploads() {
    return Container(); // TODO
  }
}