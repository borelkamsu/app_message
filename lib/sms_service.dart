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

