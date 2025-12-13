import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/presentation/cubit/additional_info_cubit.dart';
import 'package:myfin/features/upload/presentation/cubit/additional_info_state.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:myfin/features/upload/presentation/pages/doc_field_header.dart';

class DocumentDetailsScreen extends StatelessWidget {
  const DocumentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdditionalInfoCubit(),
      child: DocDetailsView(),
    );
  }
}

class DocDetailsView extends StatelessWidget {
  const DocDetailsView({super.key});

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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildTextFormFields(DocFieldHeader.name),
                        _buildTextFormFields(DocFieldHeader.type),
                      ],
                    )
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: 150,
                          height: 150,
                          child: const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextFormFields(DocFieldHeader.status)),
                  Expanded(flex: 2, child: _buildTextFormFields(DocFieldHeader.postingDate)),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    BlocBuilder<AdditionalInfoCubit, AdditionalInfoState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            for (int i = 0; i < state.rows.length; i++) 
                              _buildAdditionalRow(context, i, state.rows[i]),
                          ],
                        );
                      }
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Material(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(10.0),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {
                            context.read<AdditionalInfoCubit>().addNewRow();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: Text(
                              '+ Add New Row',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildDivider(),
            ],
          ),
        )
      )
    );
  }

  Widget _buildTextFormFields(DocFieldHeader header, {String? value, bool readOnly = false, bool isAdditional = false, void Function(String)? func}) {
    final double contentPadding = isAdditional? 5 : 10;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAdditional)
            Text(
              '${header.fieldName}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: value,
            readOnly: readOnly,
            onChanged: func,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFFFF),
              contentPadding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),

              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),
            ),
            autocorrect: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalRow(BuildContext context, int index, AdditionalInfoRow row) {
    return Row(
      key: ValueKey(row.id),
      children: [
        Expanded(
          child: _buildTextFormFields(
            DocFieldHeader.none, 
            isAdditional: true, 
            value: row.key,
            func: (value) {
              context.read<AdditionalInfoCubit>().updateRowKey(index, value);
            }
          ),
        ),
        Text(':', style: TextStyle(fontWeight: FontWeight.w900),),
        Expanded(
          flex: 2, 
          child: _buildTextFormFields(
            DocFieldHeader.none, 
            isAdditional: true,
            value: row.value,
            func: (value) {
              context.read<AdditionalInfoCubit>().updateRowValue(index, value);
            }
          ),
          
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<AdditionalInfoCubit>().deleteRow(index);
          },
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.black,
      height: 50,
      thickness: 2,
      indent: 10,
      endIndent: 10,
    );
  }
}