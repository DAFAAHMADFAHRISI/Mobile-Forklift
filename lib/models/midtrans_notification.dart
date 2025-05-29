class MidtransNotification {
  final String transactionStatus;
  final String orderId;
  final String fraudStatus;
  final String statusCode;
  final String grossAmount;
  final String paymentType;
  final String transactionId;
  final String signatureKey;
  final String simulate;

  MidtransNotification({
    required this.transactionStatus,
    required this.orderId,
    required this.fraudStatus,
    required this.statusCode,
    required this.grossAmount,
    required this.paymentType,
    required this.transactionId,
    required this.signatureKey,
    required this.simulate,
  });

  factory MidtransNotification.fromJson(Map<String, dynamic> json) {
    return MidtransNotification(
      transactionStatus: json['transaction_status'] ?? '',
      orderId: json['order_id'] ?? '',
      fraudStatus: json['fraud_status'] ?? '',
      statusCode: json['status_code'] ?? '',
      grossAmount: json['gross_amount'] ?? '',
      paymentType: json['payment_type'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      signatureKey: json['signature_key'] ?? '',
      simulate: json['simulate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_status': transactionStatus,
      'order_id': orderId,
      'fraud_status': fraudStatus,
      'status_code': statusCode,
      'gross_amount': grossAmount,
      'payment_type': paymentType,
      'transaction_id': transactionId,
      'signature_key': signatureKey,
      'simulate': simulate,
    };
  }
}
