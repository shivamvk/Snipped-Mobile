class Faq{

  final String id;
  final String ques;
  final String ans;

  Faq({
    this.id,
    this.ques,
    this.ans
  });

  factory Faq.fromJson(Map<String, dynamic> parsedJson){
    return Faq(
      id: parsedJson['_id'],
      ques: parsedJson['ques'],
      ans: parsedJson['ans']
    );
  }

}

class Response{
  final int status;
  final List<Faq> faqs;
  final String message;

  Response({
    this.status,
    this.faqs,
    this.message
  });

  factory Response.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['data'] as List;
    List<Faq> faqsList = list.map((i) => Faq.fromJson(i)).toList();

    return Response(
        status: parsedJson['status'],
        faqs: faqsList,
        message: parsedJson['message']
    );
  }

}