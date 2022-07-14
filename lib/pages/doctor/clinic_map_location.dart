import '../../models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

// class ClinicMapLocation extends StatelessWidget {
//   final bool isGetLocation;
//   final List<ClinicModel> clinicObjectList;
//   const ClinicMapLocation({Key? key, required this.clinicObjectList, required this.isGetLocation})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('clinic map location'),
//       ),
//       body: const Text('This is a temporary placehoder'),
//     );
//   }
// }

class ClinicMapLocation extends StatefulWidget {
  final List<ClinicModel> clinicObjectList;

  const ClinicMapLocation({Key? key, required this.clinicObjectList}) : super(key: key);
  @override
  _ClinicMapLocationState createState() => _ClinicMapLocationState();
}

class _ClinicMapLocationState extends State<ClinicMapLocation> {
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
  }

  Widget _onMapButton(VoidCallback function, IconData icon, String tag) {
    print('inside th_onMapButton');
    return FloatingActionButton(
      splashColor: Palette.blueAppBar,
      heroTag: tag,
      elevation: 8,
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Palette.imageBackground,
      child: Icon(
        icon,
        size: 35.0,
        color: Colors.amberAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Clinic Location',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMapWidget(
              mapType: 'clinic_location',
              mapStyle: _mapType,
              clinicObjectList: widget.clinicObjectList,
              // coordinate: [
              //   ...widget.clinicObjectList.map((e) => {
              //         'lat': e.latitude ?? 34.53401150373386,
              //         'lng': e.longtitude ?? 69.1728845254006
              //       })
              //   // {'lat': 34.53401150373386, 'lng': 69.1728845254006},
              //   // {'lat': 34.53696709035473, 'lng': 69.19056250241701},
              // ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 65,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    _onMapButton(_changeMapType, Icons.map, 'change_map'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _changeMapType() {
    print('insdie the _changeMapType');
    setState(() {
      _mapType = _mapType == MapType.normal
          ? MapType.hybrid
          : (_mapType == MapType.hybrid ? MapType.terrain : MapType.normal);
    });
  }
}
