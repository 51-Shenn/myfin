enum DocFieldHeader {
  // main
  name(fieldName: 'Document Name'),
  type(fieldName: 'Document Type'),
  status(fieldName: 'Status'),
  postingDate(fieldName: 'Posting Date'),
  none(fieldName: ''),

  // line item
  date(fieldName: 'Date'),
  category(fieldName: 'Category'),
  description(fieldName: 'Description'),
  total(fieldName: 'Total');

  final String fieldName;
  const DocFieldHeader({required this.fieldName});
}