import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gd6_a_1660/database/sql_helper.dart';
import 'VehicleInputPage.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> filteredVehicles = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    refresh(); // Load vehicle data on initialization
  }

  void refresh() async {
    final data = await SQLHelper.getVehicle();
    setState(() {
      vehicles = data;
      filteredVehicles = data; // Initialize filtered list
    });
  }

  Future<void> deleteVehicle(int id) async {
    await SQLHelper.deleteVehicle(id);
    refresh(); // Refresh the list after deletion
  }

  void _filterVehicles(String query) {
    final filteredList = vehicles.where((vehicle) {
      final nameLower = vehicle['name'].toLowerCase();
      final licensePlateLower = vehicle['licensePlate'].toLowerCase();
      return nameLower.contains(query.toLowerCase()) ||
          licensePlateLower.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredVehicles = filteredList;
    });
  }

  void _performSearch() {
    _filterVehicles(searchController.text); // Trigger filter on button press
    searchController.clear(); // Clear the search field after search
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : const Text("VEHICLE"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle the search bar
                if (!isSearching) {
                  filteredVehicles = vehicles; // Reset filtered vehicles
                  searchController.clear(); // Clear search field
                }
              });
            },
          ),
          if (isSearching) // Show search button only when searching
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _performSearch(); // Trigger search on button press
              },
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VehicleInputPage(title: 'Add Vehicle'),
                ),
              ).then((_) => refresh());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                return Slidable(
                  key: ValueKey(filteredVehicles[index]['id']),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleInputPage(
                                title: 'Edit Vehicle',
                                id: filteredVehicles[index]['id'],
                                name: filteredVehicles[index]['name'],
                                licensePlate: filteredVehicles[index]['licensePlate'],
                              ),
                            ),
                          ).then((_) => refresh());
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.update,
                        label: 'Update',
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          await deleteVehicle(filteredVehicles[index]['id']);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(filteredVehicles[index]['name']),
                    subtitle: Text(filteredVehicles[index]['licensePlate']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
