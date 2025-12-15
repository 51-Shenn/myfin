import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_state.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;

  const DocumentCard({super.key, required this.document, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: Align(
        alignment: Alignment.center,
        child: Material(
          elevation: 1,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0C9FF),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Icon(
                      Icons.description_outlined, 
                      size: 24, 
                      color: const Color(0xFF2B46F9),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dateFormat.format(document.updatedAt).toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.navigate_next,
                    size: 26,
                    color: Colors.grey
                  ),
                ]
              )
            )
          ),
        ),
      )
    );
  }
}