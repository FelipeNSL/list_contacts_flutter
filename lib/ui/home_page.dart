import 'dart:io';

import 'package:list_contact/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:list_contact/helpers/contact_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  // ignore: deprecated_member_use
  List<Contact> _contacts = List();
  // ignore: deprecated_member_use
  List<Contact> contactsFilter = List();
  TextEditingController _searchController = new TextEditingController();

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        _contacts = list;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    /* Contact c = Contact();
    c.name = "Felipe";
    c.email = "felipe@gmail.com";
    c.phone = "1234";
    c.img = "img";
    helper.saveContact(c).then((contact) {
      print(contact.id);
    }); */
    _getAllContacts();
    //_searchController.addListener(() {
    //filterContacts();
    //});
  }

  void pesquisar(String text) {
    if (text.isEmpty) {
      _searchController.text = "";
      _getAllContacts();
    } else {
      print(text);
      helper.buscar(text).then((contact) {
        setState(() {
          _contacts = contact;
        });
      });
    }
  }

  /* filterContacts({Contact contact}) {
    // ignore: deprecated_member_use
    List<Contact> _contacts = [];
    _contacts.addAll(_contacts);
    if (_searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = _searchController.text.toLowerCase();
        String contactName = contact.name;
        return identical(
            searchTerm, contactName); //searchTerm.contains(contactName);
      });
      setState(() {
        //Verificar se esta chegando os valores;
        contactsFilter.addAll(_contacts);
        // = _contacts;
        // ignore: unnecessary_brace_in_string_interps
        print("Array,${contactsFilter}");
      });
    } else {
      _getAllContacts();
    }
  } */

  Widget _contactCard(BuildContext context, int index) {
    var contact = _contacts[index];
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              /* TextField(
                controller: _searchController,
                decoration: InputDecoration(labelText: 'Search'),
              ), */
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contact.img != null
                            ? FileImage(File(contact.img))
                            : AssetImage('images/person.png'),
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact.name ?? "",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(contact.email ?? "",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    Text(contact.phone ?? "",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, contact);
      },
    );
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          // ignore: missing_required_param
          return BottomSheet(
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ignore: deprecated_member_use
                    FlatButton(
                      child: Text(
                        "Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      child: Text(
                        "Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contact);
                      },
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      child: Text(
                        "Remover",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        print(contact);
                        //contact.id pq deu erro
                        helper.deleteContact(contact.id).then((value) {
                          Navigator.pop(context);
                          _getAllContacts();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
            onClosing: () {},
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final redContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (redContact != null) {
      if (contact != null) {
        await helper.updateContact(redContact);
      } else {
        await helper.saveContact(redContact);
      }
      _getAllContacts();
    }
  }
  // ignore: deprecated_member_use

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () {
          _showContactPage();
        },
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquise',
                    border: OutlineInputBorder(
                      borderSide:
                          new BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onChanged: pesquisar),
            ),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    return _contactCard(context, index);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
