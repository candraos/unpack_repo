class Statistics{
  int totalShipments = 0;
  Map<String,dynamic> statusCounts;
  double averageDeliveryTime = 0.0;

  Statistics({required this.totalShipments,required this.statusCounts,required this.averageDeliveryTime});

  factory Statistics.fromJson(Map<String,dynamic> json){
    return Statistics(
        totalShipments: json["totalShipments"],
        statusCounts: json["statusCounts"],
        averageDeliveryTime: json["averageDeliveryTime"] as double
    );
  }
}