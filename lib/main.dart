import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:file_picker/file_picker.dart';
import 'contact_service.dart';
import 'sms_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mass SMS',
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  ContactService contactService = ContactService();
  SmsService smsService = SmsService();
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    List<Contact> _contacts = await contactService.getContacts();
    setState(() {
      contacts = _contacts;
    });
  }

  Future<void> _pickContactsFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);
      String fileExtension = filePath.split('.').last;
      if (fileExtension == 'txt') {
        try {
          String fileContent = await file.readAsString();
          List<String> phoneNumbers = fileContent.split('\n').map((e) => e.trim()).toList();
          // Create Contact objects from phone numbers
          List<Contact> fileContacts = phoneNumbers.map((e) => Contact(phones: [Phone(e)])).toList();
          setState(() {
            contacts.addAll(fileContacts);
          });
        } catch (e) {
          // Handle error
          print('Error reading file: $e');
        }
      } else {
        print('Unsupported file type: $fileExtension');
      }
    }
  }

  Future<void> _sendMessages() async {
    String message = messageController.text;
    List<String> phoneNumbers = selectedContacts.map((c) => c.phones.first.number).toList();
    await smsService.sendMessages(phoneNumbers, message);
  }

  void _selectAllContacts() {
    setState(() {
      selectedContacts = List.from(contacts);
    });
  }

  void _deselectAllContacts() {
    setState(() {
      selectedContacts.clear();
    });
  }

  void _showContactSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              ListTile(
                title: Text('Select Contacts'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.select_all),
                      onPressed: _selectAllContacts,
                    ),
                    IconButton(
                      icon: Icon(Icons.deselect),
                      onPressed: _deselectAllContacts,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: contacts.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(contacts[index].displayName ?? contacts[index].phones.first.number),
                            trailing: Checkbox(
                              value: selectedContacts.contains(contacts[index]),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedContacts.add(contacts[index]);
                                  } else {
                                    selectedContacts.remove(contacts[index]);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mass SMS'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: _pickContactsFromFile,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessages,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Enter your message',
              ),
              maxLines: null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showContactSelectionModal,
              child: Text('Select Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}
