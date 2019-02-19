class Address{

  final String id;
  final String pincode;
  final String flat;
  final String colony;
  final String city;

  Address({
    this.id,
    this.pincode,
    this.flat,
    this.colony,
    this.city
  });

  factory Address.fromJson(Map<String, dynamic> parsedJson){
    return Address(
        id: parsedJson['_id'],
        pincode: parsedJson['pincode'],
        flat: parsedJson['flat'],
        colony: parsedJson['colony'],
        city: parsedJson['city']
    );
  }

}

class AddressResponse{
  final int status;
  final List<Address> addresses;
  final String message;

  AddressResponse({
    this.status,
    this.addresses,
    this.message
  });

  factory AddressResponse.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['data'] as List;
    List<Address> AddressList = list.map((i) => Address.fromJson(i)).toList();

    return AddressResponse(
        status: parsedJson['status'],
        addresses: AddressList,
        message: parsedJson['message']
    );
  }

}