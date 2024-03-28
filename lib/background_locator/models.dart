class LocationModel {
  double lat;
  double long;

  LocationModel({required this.lat, required this.long});

  factory LocationModel.fromJson(Map<String, dynamic> json){
    return LocationModel(lat: json['lat'], long: json['lang']);
  }

  toJson(){
    return {
      "lat":lat,
      "long": long
    };
  }
}

class JobModel {
  String job_id;
  double minMoney;
  double minKm;
  double kmMoney;
  double amount;
  double totalDistanceKm;
  String status;
  double lat;
  double long;


  JobModel({
    required this.job_id,
    required this.minMoney,
    required this.minKm,
    required this.kmMoney,
    required this.amount,
    required this.totalDistanceKm,
    required this.status,
    required this.lat,
    required this.long,
  });

  factory JobModel.fromJson(Map<String, dynamic> json){
    return JobModel(job_id: json['id'], minMoney: json['minMoney'], minKm: json['minKm'], kmMoney: json['kmMoney'], amount: json['amount'], totalDistanceKm: json['totalDistanceKm'], status: json['status'], lat: json['lat'], long: json['long']);
  }

  toJson(){
    return {
      "job_id":job_id,
      "minMoney": minMoney,
      "minKm": minKm,
      "kmMoney": kmMoney,
      "amount": amount,
      "totalDistanceKm": totalDistanceKm,
      "status": status,
      "lat": lat,
      "long": long,
    };
  }
}