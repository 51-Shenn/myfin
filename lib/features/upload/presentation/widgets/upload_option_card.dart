import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:myfin/features/upload/presentation/pages/option.dart';

class UploadOptionCard extends StatelessWidget {
  final Option option;
  final EdgeInsetsGeometry? customPadding;

  const UploadOptionCard({
    super.key,
    required this.option,
    this.customPadding
  });

  @override
  Widget build(BuildContext context) {
    final uploadCubit = context.read<UploadCubit>();
    
    double iconSize = option.isMainOption? 40 : 35;
    double titleFontSize = option.isMainOption? 20: 12;
    double descFontSize = option.isMainOption? 15 : 18;
    double horizontalPadding = option.isMainOption? 25 : 10;

    return Padding(
      padding: customPadding?? EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Align(
        alignment: Alignment.center,
        child: Material(
          elevation: 2,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: InkWell(
              onTap: () {
                switch(option) {
                  case Option.manual: 
                    uploadCubit.manualKeyInSelected();
                    break;
                  case Option.file:
                    uploadCubit.fileUploadSelected();
                    break;
                  case Option.gallery:
                    uploadCubit.selectFromGallery();
                    break;
                  case Option.scan:
                    uploadCubit.scanUsingCamera();
                    break;
                }
              },
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
}