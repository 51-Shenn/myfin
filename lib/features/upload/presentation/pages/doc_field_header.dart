enum DocFieldHeader {
  name(fieldName: 'Document Name'),
  type(fieldName: 'Document Type'),
  status(fieldName: 'Status'),
  postingDate(fieldName: 'Posting Date'),
  none(fieldName: '');

  final String fieldName;
  const DocFieldHeader({required this.fieldName});
}