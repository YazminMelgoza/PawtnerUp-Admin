import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:pawtnerup_admin/app/menu/screen/userSettingsPage/address_input_edit_shelter.dart';
import 'package:pawtnerup_admin/models/shelter_model.dart';
import 'package:pawtnerup_admin/services/shelter_service.dart';
import 'package:pawtnerup_admin/shared/shared.dart';
import 'package:pawtnerup_admin/config/config.dart';

import '../../../../auth/screens/address_input.dart';

class EditScreen extends StatefulWidget {
  final ShelterModel shelter;

  const EditScreen({required this.shelter, Key? key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _nameController;
  Address? selectedAddress; // Add this line
  Coords? selectedCoords; // Add this line
  late final String reference;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.shelter.address);
    _descriptionController = TextEditingController(text: widget.shelter.description);
    _websiteController = TextEditingController(text: widget.shelter.website);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Create an updated ShelterModel
      ShelterModel updatedShelter = widget.shelter.copyWith(
        address: selectedAddress?.reference ?? '',
        description: _descriptionController.text,
        website: _websiteController.text, name: _nameController.text, shelter: widget.shelter,
        latitude: selectedCoords!.latitude, longitude: selectedCoords!.longitude
      );

      // Call a service to update the shelter data
      await ShelterService().updateShelter(updatedShelter);

      // Navigate back to the previous screen
      Navigator.pop(context, updatedShelter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontFamily: 'outfit')),
        backgroundColor:Color.fromRGBO(255, 141, 0, 100),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white,),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                color: Colors.transparent,

                height: 55,
                child: AddressInputEditShelter(
                  onAddressSelected: (Address address) {
                    setState(() {
                      selectedAddress = address;
                      selectedCoords = GiveAddressEdit(address);
                      reference = address.reference!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website/Link de Adopcion'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a website/link';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
