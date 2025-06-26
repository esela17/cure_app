import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen>
    with TickerProviderStateMixin {
  LatLng? selectedLocation;
  late GoogleMapController mapController;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _determinePosition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      // التحقق من الصلاحيات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'تم رفض صلاحية الوصول للموقع';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'صلاحية الوصول للموقع مرفوضة نهائياً';
          isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ في تحديد الموقع: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      selectedLocation = location;
    });

    // إضافة تأثير اهتزاز بسيط للمؤشر
    _animationController.reset();
    _animationController.forward();
  }

  void _centerOnCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLocation = newLocation;
      });

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLocation, zoom: 16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحديد الموقع الحالي: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "اختر الموقع",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // الخريطة
          if (isLoading)
            _buildLoadingWidget()
          else if (errorMessage != null)
            _buildErrorWidget()
          else
            FadeTransition(
              opacity: _fadeAnimation,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedLocation!,
                  zoom: 16,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                  // تطبيق نمط مخصص للخريطة
                  _setMapStyle();
                },
                onTap: _onMapTap,
                markers: selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: selectedLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                        )
                      }
                    : {},
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),

          // أزرار التحكم
          if (!isLoading && errorMessage == null) ...[
            // زر الموقع الحالي
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: _centerOnCurrentLocation,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // معلومات الموقع
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'الموقع المحدد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedLocation != null)
                      Text(
                        'خط العرض: ${selectedLocation!.latitude.toStringAsFixed(6)}\n'
                        'خط الطول: ${selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: selectedLocation != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context, selectedLocation);
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                label: const Text(
                  "تأكيد الموقع",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.check_circle),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحديد موقعك...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.location_off,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'خطأ في الموقع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _determinePosition();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 115, 145, 255),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setMapStyle() {
    const String mapStyle = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "transit",
        "elementType": "labels",
        "stylers": [{"visibility": "off"}]
      }
    ]
    ''';

    mapController.setMapStyle(mapStyle);
  }
}
