import '../models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../pages/screens.dart';
import '../utils/utils.dart';

// class GoogleMapWidget extends StatelessWidget {
//   final mapType;
//   final List<ClinicModel> clinicObjectList;
//   const GoogleMapWidget({Key? key, required this.clinicObjectList, this.mapType}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: SizedBox(
//         child: Text('this is temporary, until map configuration'),
//       ),
//     );
//   }
// }

class GoogleMapWidget extends StatefulWidget {
  final String mapType;
  // pin_clinic, clinic_location, view_doctor_profile
  // final List<Map<String, double>> coordinate;
  final List<ClinicModel> clinicObjectList;
  final MapType mapStyle;
  const GoogleMapWidget({
    Key? key,
    required this.mapType,
    // required this.coordinate,
    required this.clinicObjectList,
    this.mapStyle = MapType.normal,
  }) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final Set<Marker> _markers = {};

  late BitmapDescriptor _mapIconMarker;

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcon();
  }

  void _onMapTapped(LatLng cordinate) {
    // print('===========inside the _onMapTapped'); {'lat': 34.53401150373386, 'lng': 69.1728845254006}
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClinicMapLocation(
                  clinicObjectList: widget.clinicObjectList,
                )));
    // print(cordinate);
  }

  void _setCustomMarkerIcon() async {
    _mapIconMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), GlobalVariable.GLOBAL_MARKER);
  }

  void _onMapCreated(GoogleMapController theController) {
    theController.setMapStyle(GlobalVariable.mapStyleJson);

    if (widget.clinicObjectList.isNotEmpty) {
      setState(() {
        for (var element in widget.clinicObjectList) {
          _markers.add(
            Marker(
              markerId: MarkerId(element.latitude == null
                  ? 34.53401150373386.toString()
                  : element.latitude.toString()),
              position: LatLng(
                  element.latitude ?? 34.53401150373386, element.longtitude ?? 69.1728845254006),
              icon: _mapIconMarker,
              infoWindow: InfoWindow(
                title: element.clinicName ?? 'Unknown Clinic',
                snippet: element.address ?? 'Uknown Address',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: widget.mapStyle,
      zoomControlsEnabled: widget.mapType == 'clinic_location' ? true : false,
      myLocationButtonEnabled: false,
      myLocationEnabled: widget.mapType == 'clinic_location' ? true : false,
      zoomGesturesEnabled: widget.mapType == 'clinic_location' ? true : false,
      onMapCreated: _onMapCreated,
      markers: _markers,
      onTap: widget.mapType == 'view_doctor_profile' ? _onMapTapped : null,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.clinicObjectList.first.latitude ?? 34.53401150373386,
          widget.clinicObjectList.first.longtitude ?? 69.1728845254006,
        ),
        zoom: widget.mapType == 'clinic_location' ? 13 : 11,
      ),
    );
  }
}
