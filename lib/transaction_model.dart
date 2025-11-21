class Transaction {
  final String type;           // "Add Funds", "Withdraw", etc.
  final String details;        // Description
  final int amount;
  final DateTime date;
  final String reference;
  final String status;
  final String destinationBank;
  final String narration;
  final String sender;         // optional but default to empty
  final String account;        // optional but default to empty

  Transaction({
    required this.type,
    required this.details,
    required this.amount,
    required this.date,
    required this.reference,
    required this.status,
    String? destinationBank,
    String? narration,
    String? sender,
    String? account,
  })  : destinationBank = destinationBank ?? "",
        narration = narration ?? "",
        sender = sender ?? "",
        account = account ?? "";

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "details": details,
      "amount": "$amount XAF",
      "date": date.toIso8601String(),
      "reference": reference,
      "status": status,
      "destinationBank": destinationBank,
      "narration": narration,
      "sender": sender,
      "account": account,
    };
  }
}
