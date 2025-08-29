import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../constants/style.dart';
import '../../../../providers/transactions_provider.dart';
import '../../../../ui/device.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../utils/location_bag.dart';
import '../../../../ui/snack_bars/snack_bar.dart';

class LocationSelector extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const LocationSelector({required this.scrollController, super.key});

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();

  LatLng? selectedPosition;
  Set<Marker> markers = {};
  
  LatLng initialPosition = LatLng(0, 0);
  final String _googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  Widget build(BuildContext context) {
    LocationBag? location = ref.read(locationTransactionProvider);
    double lat = location?.latitude ?? 45.4642; // Default to Milan if no location is set
    double lng = location?.longitude ?? 9.1900; // Default to Milan if
    initialPosition = LatLng(lat, lng);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a place',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _fetchSuggestions(value);
                  } else {
                    setState(() {
                      _suggestions = [];
                    });
                  }
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchPlace(value);
                    setState(() {
                      _suggestions = [];
                    });
                  }
                },
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        title: Text(suggestion['text']),
                        onTap: () {
                          searchController.text = suggestion['text'];
                          _selectSuggestion(
                            suggestion['id'],
                            suggestion['text']
                          );
                          setState(() {
                            _suggestions = [];
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: markers,
            mapType: MapType.normal,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            liteModeEnabled: false,
          ),
        ),
        SafeArea(
          child: Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  blurRadius: 5.0,
                  offset: const Offset(0, -1.0),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: selectedPosition != null
                    ? () async {
                        ref.read(locationTransactionProvider.notifier).state = LocationBag(latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, searchText: searchController.text);
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('ADD LOCATION'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    LocationBag? location = ref.read(locationTransactionProvider);
    if (location != null) {
      await _moveToLocationWithZoom(location.latitude, location.longitude);
    }
  }

  Future<void> _searchPlace(String query) async {
    final String url = 'https://places.googleapis.com/v1/places:searchText';
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _googleApiKey,
      'X-Goog-FieldMask': 'places.displayName,places.location'
    };

    final body = jsonEncode({
      'textQuery': query,
      'maxResultCount': 10,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"error": "timeout"}', 408),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['places'] != null && data['places'].isNotEmpty) {
          final place = data['places'][0];
          final location = place['location'];
          final LatLng position = LatLng(location['latitude'], location['longitude']);
          
          await _moveToPosition(position, place['displayName']['text'] ?? query);
        }
      } else {
        showErrorMessage("Error during search");
      }
    } catch (e) {
      showErrorMessage("Error during search");
    }
  }

  Future<void> _fetchSuggestions(String input) async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _googleApiKey,
      'X-Goog-FieldMask': 'suggestions.placePrediction.text,suggestions.placePrediction.placeId',
    };
    final body = jsonEncode({
      'input': input,
    });

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"error": "timeout"}', 408),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = (data['suggestions'] as List?)
            ?.where((suggestion) => suggestion['placePrediction'] != null)
            .map((suggestion) => {
                  'text': suggestion['placePrediction']['text']['text'],
                  'id': suggestion['placePrediction']['placeId'],
                })
            .toList();

        setState(() {
          _suggestions = suggestions ?? [];
        });
      } else {
        setState(() {
          _suggestions = [];
        });

        showErrorMessage('Error fetching suggestions');
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
      });
      
      showErrorMessage("Error fetching suggestions");
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> _moveToPosition(LatLng position, String title) async {
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLng(position),
      );
      
      setState(() {
        selectedPosition = position;
      });
      
      _addMarker(position, title);
    }
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _selectSuggestion(String placeId, String text) async {
    setState(() {
      _suggestions = [];
      searchController.text = text;
    });

    final placeDetails = await _getPlaceDetails(placeId);
    if (placeDetails != null) {
      final lat = placeDetails['location']['latitude'];
      final lng = placeDetails['location']['longitude'];
      
      await _moveToLocationWithZoom(lat, lng);
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _googleApiKey,
      'X-Goog-FieldMask': 'location',
    };

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"error": "timeout"}', 408),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        showErrorMessage("Error fetching suggestions");
        return null;
      }
    } catch (e) {
      showErrorMessage("Error fetching suggestions");
      return null;
    }
  }

  Future<void> _moveToLocationWithZoom(double lat, double lng) async {
    final CameraPosition newPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 15.0,
    );
    
    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(newPosition),
    );
    
    _addMarker(LatLng(lat, lng), 'Selected Location');
  }

  void showErrorMessage(String message) {
    Navigator.of(context).pop();
    if (!mounted) return;
    showSnackBar(context, message: message);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}