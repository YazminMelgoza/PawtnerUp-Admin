import 'dart:async';
import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/theme/color.dart';

// Function to get the current position of the user
Future<LatLng> _getPosition() async {
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

// Main widget for the example
class Example extends StatefulWidget {
  const Example(this.initialPosition, {Key? key}) : super(key: key);

  final LatLng initialPosition;

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final geoMethods = GeoMethods(
    googleApiKey: 'AIzaSyAQfvXv9t3P6FsxWKDNU2eTlqsoSi4yK9Q',
    language: 'es',
    countryCode: 'mx',
    countryCodes: ['us', 'es', 'co'],
    country: 'Mexico',
  );



  late final GoogleMapController controller;
  final polylines = <Polyline>{};
  final markers = <Marker>{};
  final origCtrl = TextEditingController();
  final destCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(15);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              compassEnabled: true,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              rotateGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 14.5,
              ),
              onMapCreated: (GoogleMapController ctrl) {
                controller = ctrl;
              },
              polylines: polylines,
              markers: markers,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: borderRadius,
                    bottomLeft: borderRadius,
                    bottomRight: borderRadius),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            height: 55.0,
            child: Column(
              children: [
                TextField(

                  controller: origCtrl,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AddressSearchDialog.withProvider(
                        provider: routeProvider,
                        addressId: AddressId.origin,
                      );
                    },
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ingresar Direccion',
                    hintStyle: TextStyle( // Text style within the field
                      fontSize: 16.0, // Font size
                      fontWeight: FontWeight.normal, // Font weight
                      color: Colors.black54, // Text color
                      fontFamily: 'outfit'
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Waypoints widget to manage waypoints in the route
class Waypoints extends ConsumerStatefulWidget {
  const Waypoints(this.geoMethods, {Key? key}) : super(key: key);

  final GeoMethods geoMethods;

  @override
  ConsumerState<Waypoints> createState() => _WaypointsState();
}

class _WaypointsState extends ConsumerState<Waypoints> {
  bool addNewWP = false;

  @override
  Widget build(BuildContext context) {
    final waypoints = ref.watch(routeProvider).waypoints;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: () => setState(() => addNewWP = !addNewWP),
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return AddressLocator(
          coords: const Coords(0.96126, -79.6581883),
          geoMethods: widget.geoMethods,
          onDone: (address) => waypoints.isEmpty ? _onDone(address, waypoints, 0) : null,
          child: ListView.separated(
            itemCount: waypoints.length + (addNewWP ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Colors.blue[50],
              );
            },
            itemBuilder: (BuildContext context, int index) {
              final TextEditingController controller = TextEditingController(text: waypoints.getReference(index));
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                color: Colors.blue[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: constraints.constrainWidth() - 30 - 25,
                      child: TextField(
                        controller: controller,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AddressSearchDialog(
                            controller: controller,
                            geoMethods: widget.geoMethods,
                            onDone: (address) => _onDone(address, waypoints, index),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (index != 0) {
                              ref.read(routeProvider).reorderWaypoint(index, index - 1);
                            }
                          },
                          child: const Icon(Icons.keyboard_arrow_up),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (index + 1 != waypoints.length) {
                              ref.read(routeProvider).reorderWaypoint(index, index + 1);
                            }
                          },
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _onDone(Address address, List<Address> waypoints, int index) {
    if (waypoints.asMap().containsKey(index)) {
      ref.read(routeProvider).updateWaypoint(index, address);
    } else {
      ref.read(routeProvider).addWaypoint(address);
    }
    setState(() => addNewWP = false);
  }
}