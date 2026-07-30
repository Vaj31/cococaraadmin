class ShippingScheduleModel {
  String shippingId;
  String type;
  String pod;
  String orderId;
  String itemCode;
  String? supplier1;
  String? supplier1Qty;
  String? supplier2;
  String? supplier2Qty;
  String? supplier3;
  String? supplier3Qty;

  ShippingScheduleModel({
    this.shippingId = "",
    this.type = "",
    this.pod = "",
    this.orderId = "",
    this.itemCode = "",
    this.supplier1,
    this.supplier1Qty,
    this.supplier2,
    this.supplier2Qty,
    this.supplier3,
    this.supplier3Qty,
  });

  factory ShippingScheduleModel.fromJson(Map<String, dynamic> json) {
    return ShippingScheduleModel(
      shippingId: json['shippingId']?.toString() ?? json['shippingid']?.toString() ?? "",
      type: json['type']?.toString() ?? json['containerType']?.toString() ?? "",
      pod: json['pod']?.toString() ?? "",
      orderId: json['orderId']?.toString() ?? json['orderid']?.toString() ?? "",
      itemCode: json['itemCode']?.toString() ?? json['itemcode']?.toString() ?? "",
      supplier1: json['supplier1']?.toString(),
      supplier1Qty: json['supplier1Qty']?.toString() ?? json['supplier1qty']?.toString(),
      supplier2: json['supplier2']?.toString(),
      supplier2Qty: json['supplier2Qty']?.toString() ?? json['supplier2qty']?.toString(),
      supplier3: json['supplier3']?.toString(),
      supplier3Qty: json['supplier3Qty']?.toString() ?? json['supplier3qty']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shippingId'] = shippingId;
    data['type'] = type;
    data['pod'] = pod;
    data['orderId'] = orderId;
    data['itemCode'] = itemCode;
    data['supplier1'] = supplier1;
    data['supplier1Qty'] = supplier1Qty;
    data['supplier2'] = supplier2;
    data['supplier2Qty'] = supplier2Qty;
    data['supplier3'] = supplier3;
    data['supplier3Qty'] = supplier3Qty;
    return data;
  }
}