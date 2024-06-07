// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class SmsService {
//   final String accountSid = 'AC0c82564d13fa1fc886e42c46b592ce7d';
//   final String authToken = '7c8c65aee1f36257aab588f0fabbd157';
//   final String fromPhoneNumber = '+13348359292';

//   Future<void> sendMessage(String to, String body) async {
//     final url = Uri.parse(
//         'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization':
//             'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
//       },
//       body: {
//         'From': fromPhoneNumber,
//         'To': to,
//         'Body': body,
//       },
//     );

//     if (response.statusCode == 201) {
//       print('Message sent to $to');
//     } else {
//       print('Failed to send message to $to: ${response.body}');
//     }
//   }

//   Future<void> sendMessages(List<String> toList, String body) async {
//     for (var to in toList) {
//       await sendMessage(to, body);
//     }
//   }
// }
import 'package:telephony/telephony.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<void> sendMessages(List<String> phoneNumbers, String message) async {
    for (String number in phoneNumbers) {
      try {
        await telephony.sendSms(
          to: number,
          message: message,
        );
        print('Message sent to $number');
      } catch (e) {
        print('Failed to send message to $number: $e');
      }
    }
  }
}

