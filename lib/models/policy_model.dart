class PolicySection {
  final int id;
  final String title;
  final List<PolicyContentElement> elements;

  PolicySection({
    required this.id,
    required this.title,
    required this.elements,
  });

  factory PolicySection.fromJson(Map<String, dynamic> json) {
    return PolicySection(
      id: json['id'] as int,
      title: json['title'] as String,
      elements: (json['elements'] as List)
          .map((e) => PolicyContentElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}

class PolicyContentElement {
  final String type; // 'text' | 'bullet' | 'table' | 'formula'
  final String? text;
  final List<String>? tableHeaders;
  final List<List<String>>? tableRows;
  final List<Map<String, String>>? formulas; // For pricing formulas list

  PolicyContentElement({
    required this.type,
    this.text,
    this.tableHeaders,
    this.tableRows,
    this.formulas,
  });

  factory PolicyContentElement.fromJson(Map<String, dynamic> json) {
    return PolicyContentElement(
      type: json['type'] as String,
      text: json['text'] as String?,
      tableHeaders: (json['tableHeaders'] as List?)?.map((e) => e as String).toList(),
      tableRows: (json['tableRows'] as List?)
          ?.map((row) => (row as List).map((cell) => cell as String).toList())
          .toList(),
      formulas: (json['formulas'] as List?)
          ?.map((f) => Map<String, String>.from(f as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (text != null) 'text': text,
      if (tableHeaders != null) 'tableHeaders': tableHeaders,
      if (tableRows != null) 'tableRows': tableRows,
      if (formulas != null) 'formulas': formulas,
    };
  }
}
