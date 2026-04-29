import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';
import 'package:rider34/features/home/data/route_service.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'dart:async';

enum SelectionMode { none, origin, destination, stop }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapController = MapController();
  final _destinationCtrl = TextEditingController();

  // Default location — will be replaced with real GPS in next iteration
  final _defaultLocation = const LatLng(-17.8252, 31.0335); // Harare, Zimbabwe

  // Quick-access saved places
  final _quickPlaces = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.work_outline, 'label': 'Work'},
    {'icon': Icons.history_rounded, 'label': 'Recent'},
  ];

  // Routing State
  LatLng? _originLatLng;
  LatLng? _destinationLatLng;
  List<LatLng> _stops = [];
  List<LatLng> _routePoints = [];
  Map<String, dynamic>? _routeInfo;
  SelectionMode _selectionMode = SelectionMode.none;
  int? _activeStopIndex;

  final _originCtrl = TextEditingController(text: 'Current Location');

  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get initial position
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _originLatLng ??=
          _currentLocation; // Set origin to current location by default
    });

    // Move map to current location
    _mapController.move(_currentLocation!, 14.5);

    // Listen for updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _updateRoute() async {
    if (_originLatLng == null || _destinationLatLng == null) {
      setState(() {
        _routePoints = [];
        _routeInfo = null;
      });
      return;
    }

    final result = await RouteService.fetchRoute(
      _originLatLng!,
      _destinationLatLng!,
      waypoints: _stops,
    );

    if (result != null) {
      setState(() {
        _routePoints = result['points'];
        _routeInfo = {
          'distance': result['distance'],
          'duration': result['duration'],
        };
      });

      // Fit map to route
      if (_routePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
          ),
        );
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_selectionMode == SelectionMode.none) return;

    setState(() {
      if (_selectionMode == SelectionMode.origin) {
        _originLatLng = point;
        _originCtrl.text = 'Selected on Map';
      } else if (_selectionMode == SelectionMode.destination) {
        _destinationLatLng = point;
        _destinationCtrl.text = 'Selected on Map';
      } else if (_selectionMode == SelectionMode.stop &&
          _activeStopIndex != null) {
        if (_activeStopIndex! < _stops.length) {
          _stops[_activeStopIndex!] = point;
        } else {
          _stops.add(point);
        }
      }
      _selectionMode = SelectionMode.none;
    });
    _updateRoute();
  }

  void _addStop() {
    setState(() {
      _stops.add(const LatLng(0, 0)); // Placeholder
      _selectionMode = SelectionMode.stop;
      _activeStopIndex = _stops.length - 1;
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
    _updateRoute();
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _originCtrl.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen OpenStreetMap ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 14.5,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.loficode.rider34',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColors.primary,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Origin
                  if (_originLatLng != null)
                    Marker(
                      point: _originLatLng!,
                      width: 40,
                      height: 40,
                      child: const _PlaceMarker(
                          color: AppColors.success,
                          icon: Icons.person_pin_circle_rounded),
                    ),
                  // Destination
                  if (_destinationLatLng != null)
                    Marker(
                      point: _destinationLatLng!,
                      width: 40,
                      height: 40,
                      child: const _PlaceMarker(
                          color: AppColors.error,
                          icon: Icons.location_on_rounded),
                    ),
                  // Stops
                  ..._stops.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    if (point.latitude == 0)
                      return const Marker(
                          point: LatLng(0, 0), child: SizedBox());
                    return Marker(
                      point: point,
                      width: 32,
                      height: 32,
                      child: _StopMarker(index: index + 1),
                    );
                  }),
                ],
              ),
              // Current location pulsing marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation ?? _defaultLocation,
                    width: 60,
                    height: 60,
                    child: _PulsingMarker(),
                  ),
                ],
              ),
              // Simulated nearby driver markers
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      _defaultLocation.latitude + 0.008,
                      _defaultLocation.longitude + 0.012,
                    ),
                    width: 40,
                    height: 40,
                    child: _DriverMarker(),
                  ),
                  Marker(
                    point: LatLng(
                      _defaultLocation.latitude - 0.006,
                      _defaultLocation.longitude - 0.009,
                    ),
                    width: 40,
                    height: 40,
                    child: _DriverMarker(),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar ──
          SafeArea(
            child: Column(
              children: [
                if (_selectionMode != SelectionMode.none)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Tap on map to set ${_selectionMode.name}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Menu
                      _MapIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => _openDrawer(context),
                      ),
                      const Spacer(),
                      // "Rider 34" pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Rider 34',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Notifications
                      Stack(
                        children: [
                          _MapIconButton(
                            icon: Icons.notifications_outlined,
                            onTap: () {},
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Route Info Chip ──
          if (_routeInfo != null)
            Positioned(
              bottom: 440, // Above card
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_routeInfo!['distance'].toStringAsFixed(1)} km · ${_routeInfo!['duration'].round()} min',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Bottom Sheet ──
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Re-center button
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _MapIconButton(
                      icon: Icons.my_location_rounded,
                      onTap: () {
                        if (_currentLocation != null) {
                          _mapController.move(_currentLocation!, 14.5);
                        } else {
                          _mapController.move(_defaultLocation, 14.5);
                        }
                      },
                    ),
                  ),
                ),

                // Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 30,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.slate200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Location inputs
                        const _LocationInput(
                          icon: Icons.radio_button_checked,
                          iconColor: AppColors.primary,
                          label: 'Pickup Location',
                          value: 'Current Location',
                          readOnly: true,
                        ),
                        const SizedBox(height: 2),
                        _LocationInput(
                          icon: Icons.location_on_outlined,
                          iconColor: AppColors.slate400,
                          label: 'Where to?',
                          value: '',
                          controller: _destinationCtrl,
                          onTap: () => _showSearchSheet(isDestination: true),
                          trailing: GestureDetector(
                            onTap: _addStop,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.slate200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                        ),

                        // Stops list
                        if (_stops.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ..._stops.asMap().entries.map((entry) {
                            final i = entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _LocationInput(
                                icon: Icons.circle,
                                iconColor: AppColors.amber,
                                label: 'Stop ${i + 1}',
                                value: 'Stop Location',
                                onTap: () => _showSearchSheet(stopIndex: i),
                                trailing: IconButton(
                                  icon:
                                      const Icon(Icons.close_rounded, size: 20),
                                  onPressed: () => _removeStop(i),
                                ),
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 16),

                        // Quick-select places
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _quickPlaces.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final place = _quickPlaces[i];
                              return _QuickPlaceChip(
                                icon: place['icon'] as IconData,
                                label: place['label'] as String,
                                onTap: () {},
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Request Ride CTA
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(AppRoutes.offerFare),
                            icon: const Text(
                              'Request Ride',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: const Icon(Icons.arrow_forward, size: 20),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Next: Negotiate your fare',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SideMenu(),
    );
  }

  void _showSearchSheet({bool isDestination = false, int? stopIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocationSearchSheet(
        onLocationSelected: (location, address) {
          setState(() {
            if (stopIndex != null) {
              _stops[stopIndex] = location;
            } else if (isDestination) {
              _destinationLatLng = location;
              _destinationCtrl.text = address;
            } else {
              _originLatLng = location;
              _originCtrl.text = address;
            }
          });
          _updateRoute();
        },
        onMapPickRequested: () {
          Navigator.pop(context);
          setState(() {
            _selectionMode = stopIndex != null
                ? SelectionMode.stop
                : (isDestination
                    ? SelectionMode.destination
                    : SelectionMode.origin);
            _activeStopIndex = stopIndex;
          });
        },
      ),
    );
  }
}

// ── Supporting widgets ──────────────────────────────

class _PulsingMarker extends StatefulWidget {
  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Transform.scale(
            scale: 1.0 + _anim.value * 1.5,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.3 * (1 - _anim.value)),
              ),
            ),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0x40256AF4), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _PlaceMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _StopMarker extends StatelessWidget {
  final int index;

  const _StopMarker({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.amber,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        index.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LocationSearchSheet extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final VoidCallback onMapPickRequested;

  const _LocationSearchSheet({
    required this.onLocationSelected,
    required this.onMapPickRequested,
  });

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final _searchCtrl = TextEditingController();
  List<geo.Placemark> _results = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final places =
            await geo.placemarkFromCoordinates(loc.latitude, loc.longitude);
        setState(() {
          _results = places;
        });
        // For simplicity in this demo, we'll just pick the first result's location
        // but keep the place name for the UI.
        // In a real app, you'd show a list of suggestions.
      }
    } catch (e) {
      print('Search error: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search address...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : null,
                  ),
                  onSubmitted: _search,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: widget.onMapPickRequested,
                icon: const Icon(Icons.map_rounded),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final p = _results[i];
                  final address = '${p.name}, ${p.locality}';
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppColors.slate400),
                    title: Text(address),
                    onTap: () async {
                      final locations = await geo.locationFromAddress(address);
                      if (locations.isNotEmpty) {
                        widget.onLocationSelected(
                          LatLng(locations.first.latitude,
                              locations.first.longitude),
                          address,
                        );
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DriverMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.slate900, size: 22),
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextEditingController? controller;
  final bool readOnly;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _LocationInput({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.controller,
    this.readOnly = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller:
                        controller ?? TextEditingController(text: value),
                    readOnly:
                        true, // Make it always readOnly if we use our own sheet
                    enabled: false,
                    onTap: onTap,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.slate900,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.only(bottom: 10),
                      hintText: 'Enter location',
                      hintStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _QuickPlaceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickPlaceChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.slate500),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.person_outline, 'My Profile', AppRoutes.profile),
      (Icons.history_rounded, 'Ride History', AppRoutes.rideHistory),
      (Icons.settings_outlined, 'Settings', AppRoutes.settings),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.$1, color: AppColors.slate700),
              title: Text(
                item.$2,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.go(item.$3);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
