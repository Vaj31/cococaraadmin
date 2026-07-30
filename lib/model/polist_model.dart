class PolistModel {
  String revision;
  String orderId;
  String orderDate;
  String shippingId;
  String deliveryDate;
  String sales;
  String customer;
  String itemCode;
  String planterCode;
  String drainCode;
  String qty;
  String orderStatus;
  String product;
  String planting;
  String deliveryLT;
  String material;
  String l;
  String d;
  String h;
  String ec;
  String crop;
  String planter;
  String planterSize;
  String planterShape;
  String space;
  String drain;
  String drainPosition;
  String lifespan;
  String memo;
  String drainSize;
  String drainShape;
  String diagram;
  String coverCutting;
  String requireSlitCut;
  String excess;
  String ccExcess;
  String polybag;
  String packingBag;
  String cartonBox;

  PolistModel({
    required this.revision,
    required this.orderId,
    required this.orderDate,
    required this.shippingId,
    required this.deliveryDate,
    required this.sales,
    required this.customer,
    required this.itemCode,
    required this.planterCode,
    required this.drainCode,
    required this.qty,
    required this.orderStatus,
    required this.product,
    required this.planting,
    required this.deliveryLT,
    required this.material,
    required this.l,
    required this.d,
    required this.h,
    required this.ec,
    required this.crop,
    required this.planter,
    required this.planterSize,
    required this.planterShape,
    required this.space,
    required this.drain,
    required this.drainPosition,
    required this.lifespan,
    required this.memo,
    required this.drainSize,
    required this.drainShape,
    required this.diagram,
    required this.coverCutting,
    required this.requireSlitCut,
    required this.excess,
    required this.ccExcess,
    required this.polybag,
    required this.packingBag,
    required this.cartonBox,
  });

  factory PolistModel.fromJson(Map<String, dynamic> json) {
    String val(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key].toString();
        }
      }
      return "";
    }

    String parsedQty = val(['qty', 'QTY']);
    if (parsedQty.isNotEmpty) {
      double? d = double.tryParse(parsedQty);
      if (d != null) {
        parsedQty = d.toInt().toString();
      }
    }

    return PolistModel(
      revision: val(['revision', 'Revision', 'Rev', 'rev']),
      orderId: val(['orderId', 'Order_Id', 'orderid']),
      orderDate: val(['orderDate', 'Order_Date', 'orderdate']),
      shippingId: val(['shippingId', 'Shipping_Id', 'shippingid', 'Shipping Id']),
      deliveryDate: val(['deliveryDate', 'Delivery_Date', 'deliverydate', 'Delivery Date']),
      sales: val(['sales', 'Sales']),
      customer: val(['customer', 'Customer', 'customerName', 'customername']),
      itemCode: val(['itemCode', 'Item_Code', 'itemcode']),
      planterCode: val(['planterCode', 'Planter_Code', 'plantercode', 'Planter Code']),
      drainCode: val(['drainCode', 'Drain_Code', 'draincode', 'Drain Code']),
      qty: parsedQty,
      orderStatus: val(['orderStatus', 'Status', 'status']),
      product: val(['product', 'Product']),
      planting: val(['planting', 'Planting']),
      deliveryLT: val(['deliveryLT', 'DeliveryLT', 'deliveryl/t']),
      material: val(['material', 'Material']),
      l: val(['l', 'L']),
      d: val(['d', 'D']),
      h: val(['h', 'H']),
      ec: val(['ec', 'EC']),
      crop: val(['crop', 'Crop']),
      planter: val(['planter', 'Planter']),
      planterSize: val(['planterSize', 'Planter_Size', 'plantersize']),
      planterShape: val(['planterShape', 'Planter_Shape', 'plantershape']),
      space: val(['space', 'Space']),
      drain: val(['drain', 'Drain']),
      drainPosition: val(['drainPosition', 'Drain_Position', 'drainposition']),
      lifespan: val(['lifespan', 'Lifespan']),
      memo: val(['memo', 'Memo (IN)', 'Memo', 'memo(IN)']),
      drainSize: val(['drainSize', 'Drain_Size', 'drainsize']),
      drainShape: val(['drainShape', 'Drain_Shape', 'drainshape']),
      diagram: val(['diagram', 'Diagram']),
      coverCutting: val(['coverCutting', 'CoverCutting']),
      requireSlitCut: val(['requireSlitCut', 'RequireSlitCut']),
      excess: val(['excess', 'Excess']),
      ccExcess: val(['ccExcess', 'CcExcess', 'ccexcess']),
      polybag: val(['polybag', 'Polybag']),
      packingBag: val(['packingBag', 'packing bag', 'packingbag', 'PackingBag']),
      cartonBox: val(['cartonBox', 'carton box', 'cartonbox', 'CartonBox']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revision': revision,
      'orderId': orderId,
      'orderDate': orderDate,
      'shippingId': shippingId,
      'deliveryDate': deliveryDate,
      'sales': sales,
      'customer': customer,
      'itemCode': itemCode,
      'planterCode': planterCode,
      'drainCode': drainCode,
      'qty': qty,
      'orderStatus': orderStatus,
      'product': product,
      'planting': planting,
      'deliveryLT': deliveryLT,
      'material': material,
      'l': l,
      'd': d,
      'h': h,
      'ec': ec,
      'crop': crop,
      'planter': planter,
      'planterSize': planterSize,
      'planterShape': planterShape,
      'space': space,
      'drain': drain,
      'drainPosition': drainPosition,
      'lifespan': lifespan,
      'memo': memo,
      'drainSize': drainSize,
      'drainShape': drainShape,
      'diagram': diagram,
      'coverCutting': coverCutting,
      'requireSlitCut': requireSlitCut,
      'excess': excess,
      'ccExcess': ccExcess,
      'polybag': polybag,
      'packingBag': packingBag,
      'cartonBox': cartonBox,
    };
  }
}
