import 'dart:async';
import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/../../../config/theme/color.dart';

// Function to get the current position of the user
/*Future<LatLng> _getPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied, we cannot request permissions.';
  }

  Position position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}

// Riverpod provider for managing route data
final routeProvider = ChangeNotifierProvider<RouteNotifier>((ref) => RouteNotifier());
*/
// Main widget for the example
class AddressInputEditShelter extends StatefulWidget {
  const AddressInputEditShelter({Key? key, required this.onAddressSelected}) : super(key: key);
  final void Function(Address) onAddressSelected;

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
  final controllerv = TextEditingController();
  late Address shelterAddress;
  final polylines = <Polyline>{};
  final markers = <Marker>{};
  final origCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  late final Address shelterLocation;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    TextEditingController controller;
    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

    const borderRadius = Radius.circular(15);

    return Container(
      decoration: BoxDecoration(
          color: AppColor.appBgColor,
          /*borderRadius: const BorderRadius.only(
              topLeft: borderRadius,
              bottomLeft: borderRadius,
              bottomRight: borderRadius),*/
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: TextFormField(
        controller: controllerv, // Utilizar controller
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
Coords? GiveAddressEdit (Address shelterAddress){
  return shelterAddress.coords;
}




