import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/crud_services.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<StatefulWidget> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<AddContact> {
  final formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  bool isEdit = false;
  String docId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args != null && args is DocumentSnapshot) {
      isEdit = true;
      docId = args.id;

      _nameController.text = args['name'];
      _phoneController.text = args['phone'];
      _emailController.text = args['email'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Update Contact" : "Add Contact"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(children: [
            const SizedBox(height: 30),

            
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: TextFormField(
                controller: _nameController,
                validator: (value) =>
                    value!.isEmpty ? "Name cannot be empty" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                ),
              ),
            ),

            const SizedBox(height: 10),

            // PHONE
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: TextFormField(
                controller: _phoneController,
                validator: (value) =>
                    value!.isEmpty ? "Phone cannot be empty" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Phone",
                ),
              ),
            ),

            const SizedBox(height: 10),

            // EMAIL
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: TextFormField(
                controller: _emailController,
                validator: (value) =>
                    value!.isEmpty ? "Email cannot be empty" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width * .9,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (isEdit) {
                      CrudServices()
                          .updateContacts(
                        docId,
                        _nameController.text,
                        _phoneController.text,
                        _emailController.text,
                      )
                          .then((result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                        Navigator.pop(context);
                      });
                    } else {
                      CrudServices()
                          .addNewContacts(
                        _nameController.text,
                        _phoneController.text,
                        _emailController.text,
                      )
                          .then((result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                        Navigator.pop(context);
                      });
                    }
                  }
                },
                child: Text(
                  isEdit ? "Update Contact" : "Add Contact",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}