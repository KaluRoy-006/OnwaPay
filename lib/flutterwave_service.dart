import 'dart:convert';
import 'package:http/http.dart' as http;

/// Minimal Flutterwave Transfers client focused on Mobile Money (XAF)
class FlutterwaveService {
  FlutterwaveService({required this.secretKey, this.baseUrl = "https://api.flutterwave.com/v3"});

  final String secretKey;
  final String baseUrl;

  /// Initiate a Mobile Money payout (Cameroon XAF).
  /// operatorCode: "MTN" or "ORANGEMONEY"
  Future<Map<String, dynamic>> initiateMobileMoneyTransfer({
    required String operatorCode,
    required String msisdn,          // e.g. "237650000000"
    required int amount,             // integers only
    String currency = "XAF",
    required String reference,       // unique ref from your app
    String narration = "KoloPay transfer",
    required String beneficiaryName, // what you display/know
    Map<String, dynamic>? meta,      // optional
  }) async {
    final url = Uri.parse("$baseUrl/transfers");

    final payload = <String, dynamic>{
      "account_bank": operatorCode,
      "account_number": msisdn,
      "amount": amount,
      "currency": currency,
      "narration": narration,
      "reference": reference,
      "beneficiary_name": beneficiaryName,
      if (meta != null) "meta": meta,
    };

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $secretKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    final body = jsonDecode(res.body.isEmpty ? "{}" : res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return body;
    }
    throw Exception("Flutterwave error (${res.statusCode}): ${body["message"] ?? res.body}");
  }
}
