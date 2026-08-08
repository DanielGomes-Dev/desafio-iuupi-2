// To parse this JSON data, do
//
//     final Transaction = TransactionFromJson(jsonString);

import 'dart:convert';

Transaction transactionFromJson(String str) => Transaction.fromJson(json.decode(str));

String transactionToJson(Transaction data) => json.encode(data.toJson());

class Transaction {
    List<Datum> data;
    Pagination pagination;

    Transaction({
        required this.data,
        required this.pagination,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
    };
}

class Datum {
    int id;
    String type;
    String description;
    int amount;
    DateTime createdAt;

    Datum({
        required this.id,
        required this.type,
        required this.description,
        required this.amount,
        required this.createdAt,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        type: json["type"],
        description: json["description"],
        amount: json["amount"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "description": description,
        "amount": amount,
        "created_at": createdAt.toIso8601String(),
    };
}

class Pagination {
    int page;
    int perPage;
    int total;
    int totalPages;

    Pagination({
        required this.page,
        required this.perPage,
        required this.total,
        required this.totalPages,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        perPage: json["per_page"],
        total: json["total"],
        totalPages: json["total_pages"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "per_page": perPage,
        "total": total,
        "total_pages": totalPages,
    };
}
