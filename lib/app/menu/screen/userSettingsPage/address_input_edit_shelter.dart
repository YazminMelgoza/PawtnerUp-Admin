import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pawtnerup_admin/models/shelter_model.dart';

import '/../../../config/theme/color.dart';

class AddressInputEditShelter extends StatefulWidget {
  final void Function(Address) onAddressSelected;
  final ShelterModel shelter;

  const AddressInputEditShelter(this.shelter, {Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  State<AddressInputEditShelter> createState() => _AddressInputShelter();
}

class _AddressInputShelter extends State<AddressInputEditShelter> {
  final geoMethods = GeoMethods(
    googleApiKey: 'AIzaSyAQfvXv9t3P6FsxWKDNU2eTlqsoSi4yK9Q',
    language: 'es',
    countryCode: 'mx',
    country: 'Mexico',
  );

  late TextEditingController controllerv;
  final polylines = <Polyline>{};
  final markers = <Marker>{};
  final origCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  late final Address shelterLocation;

  @override
  void initState() {
    super.initState();
    controllerv = TextEditingController(text: widget.shelter.address);
  }

  @override
  void dispose() {
    controllerv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

    const borderRadius = Radius.circular(15);

    return Container(
      decoration: BoxDecoration(
          color: AppColor.appBgColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: TextFormField(
        controller: controllerv,
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) => AddressSearchDialog(
              geoMethods: geoMethods,
              controller: controllerv,
              onDone: (Address address) {
                widget.onAddressSelected(address); // Call the callback
              },
            )
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black54),
        decoration: const InputDecoration(labelText: 'Registre tu ubicacion'),
      ),
    );
  }
}

Coords? GiveAddressEdit(Address shelterAddress) {
  return shelterAddress.coords;
}





