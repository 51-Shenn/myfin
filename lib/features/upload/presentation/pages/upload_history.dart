// import 'package:flutter/material.dart';
// import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
// import 'package:myfin/features/upload/presentation/pages/upload_main.dart';
// import 'package:myfin/features/upload/presentation/widgets/document_card.dart';
// import 'package:myfin/features/upload/domain/entities/document.dart';

// class UploadHistoryScreen extends StatefulWidget {
//   const UploadHistoryScreen({super.key});

//   @override
//   State<UploadHistoryScreen> createState() => _UploadHistoryScreenState();
// }

// class _UploadHistoryScreenState extends State<UploadHistoryScreen> {
//   late List<Document> _documents = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadDocuments();
//   }

//   Future<void> _loadDocuments() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });
      
//       final repository = context.read<DocumentRepository>;
//       _documents = await repository.getDocuments(limit: 50);
//     } catch (e) {
//       _errorMessage = 'Failed to load documents: $e';
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Upload History',
//           style: TextStyle(
//             fontFamily: 'Inter',
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadDocuments,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _errorMessage!,
//                         style: TextStyle(color: Colors.red),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _loadDocuments,
//                         child: Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : _documents.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'No documents found',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           ElevatedButton(
//                             onPressed: _loadDocuments,
//                             child: Text('Refresh'),
//                           ),
//                         ],
//                       ),
//                     )
//                   : RefreshIndicator(
//                       onRefresh: _loadDocuments,
//                       child: ListView.builder(
//                         padding: EdgeInsets.all(16),
//                         itemCount: _documents.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: DocumentCard(
//                               document: _documents[index],
//                               onTap: () {
//                                 Navigator.pushNamed(
//                                   context,
//                                   '/doc_details',
//                                   arguments: _documents[index].id,
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//     );
//   }
// }