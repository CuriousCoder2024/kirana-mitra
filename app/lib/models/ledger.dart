class LedgerCustomer {
  const LedgerCustomer({
    required this.customerName,
    required this.balance,
    this.lastEntryAt,
  });

  final String customerName;
  final num balance;
  final String? lastEntryAt;

  factory LedgerCustomer.fromJson(Map<String, dynamic> json) => LedgerCustomer(
        customerName: json['customer_name'] as String? ?? '',
        balance: json['balance'] as num? ?? 0,
        lastEntryAt: json['last_entry_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'customer_name': customerName,
        'balance': balance,
        'last_entry_at': lastEntryAt,
      };
}

class LedgerResponse {
  const LedgerResponse({required this.customers, required this.totalOutstanding});

  final List<LedgerCustomer> customers;
  final num totalOutstanding;

  factory LedgerResponse.fromJson(Map<String, dynamic> json) => LedgerResponse(
        customers: (json['customers'] as List? ?? const [])
            .map((e) =>
                LedgerCustomer.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        totalOutstanding: json['total_outstanding'] as num? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'customers': customers.map((e) => e.toJson()).toList(),
        'total_outstanding': totalOutstanding,
      };
}
