import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:tes_victoria_care/db_helper.dart';

import '../auth.dart';

class CheckInScreen extends StatefulWidget {
  static const routeName = '/check-in';
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _currentDate = DateFormat('yyy-MM-dd').format(DateTime.now());
  final _currentTime = DateFormat('HH:mm').format(DateTime.now());
  double _lat = 0;
  double _long = 0;
  String? _catatan;
  File? _pickedImage;
  var _showImageError = false;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final Completer<GoogleMapController> _mapController = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  final List<Marker> _markers = <Marker>[];

  Future<Position> getCurrentLocation() async {
    await Geolocator.getCurrentPosition()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print('ERROR' + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    getCurrentLocation().then((value) async {
      print('baskdbahbdks' +
          value.latitude.toString() +
          ' ' +
          value.longitude.toString());

      _markers.add(Marker(
          markerId: const MarkerId('1'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(
            title: 'My Current Location',
          )));
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14,
      );
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      _lat = value.latitude;
      _long = value.longitude;
      controller.dispose();
    });
    super.initState();
  }

  Future<void> _takePicture() async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImage = File(image.path);
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    _pickedImage = await File(image.path).copy('${appDir.path}/$fileName');

    setState(() {
      _showImageError = false;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate() ||
        _lat == 0 ||
        _long == 0 ||
        _pickedImage == null) {
      if (_pickedImage == null) {
        setState(() {
          _showImageError = true;
        });
        return;
      }
      return;
    }
    _formKey.currentState!.save();

    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock In Succesful'),
        content: Text(
          'Waktu: $_currentDate, $_currentTime\nPosisi: $_lat,$_long\ncatatan: $_catatan\nGambar: ${_pickedImage!.path}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    DBHelper.insert('clockin', {
      'catatan': _catatan,
      'loc_lat': _lat,
      'loc_long': _long,
      'image': _pickedImage!.path,
      'time': _currentDate,
    });
  }

  void _logOut() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await Auth().signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Yes'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _refresh() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      CheckInScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            mapContainer(),
            formContainer(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          label: const Text('Clock In'), onPressed: _submit),
    );
  }

  AppBar appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: _logOut,
        icon: const Icon(Icons.logout_outlined),
      ),
      title: Center(
        child: Text(_currentTime),
      ),
      actions: [
        IconButton(
          onPressed: _refresh,
          icon: Icon(Icons.refresh),
        ),
      ],
    );
  }

  Container mapContainer() {
    return Container(
      color: Colors.grey,
      height: 250,
      child: GoogleMap(
        initialCameraPosition: _kGoogle,
        markers: Set<Marker>.of(_markers),
        mapType: MapType.normal,
        myLocationEnabled: true,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
      ),
    );
  }

  Container formContainer() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            catatanField(),
            const SizedBox(height: 15),
            pictureField(),
            if (_showImageError)
              Text(
                'Foto Tidak boleh Kosong',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextFormField catatanField() {
    return TextFormField(
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Catatan',
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Catatan Tidak Boleh Kosong';
        }
      },
      onSaved: (value) => _catatan = value!,
    );
  }

  Row pictureField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: _takePicture,
          icon: Icon(Icons.camera_alt),
          label: Text('Ambil Foto'),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.grey,
          child: _pickedImage == null
              ? const Center(
                  child: Text(
                    'No Image Picked',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Image.file(
                  _pickedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
        )
      ],
    );
  }
}
