class Address{

  final String pincode;
  final String flat;
  final String colony;
  final String city;

  Address({
    this.pincode,
    this.flat,
    this.colony,
    this.city
  });

  factory Address.fromJson(Map<String, dynamic> parsedJson){
    return Address(
        pincode: parsedJson['pincode'],
        flat: parsedJson['flat'],
        colony: parsedJson['colony'],
        city: parsedJson['city']
    );
  }

}

class Response{
  final int status;
  final List<Address> addresses;
  final String message;

  Response({
    this.status,
    this.addresses,
    this.message
  });

  factory Response.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['data'] as List;
    List<Address> AddressList = list.map((i) => Address.fromJson(i)).toList();

    return Response(
        status: parsedJson['status'],
        addresses: AddressList,
        message: parsedJson['message']
    );
  }

}