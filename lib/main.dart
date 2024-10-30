// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gd6_a_1660/database/sql_helper.dart';
import 'package:gd6_a_1660/entity/employee.dart';
import 'package:gd6_a_1660/inputPage.dart';
import 'package:gd6_a_1660/vehiclePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFLITE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages for each navigation item
  final List<Widget> _pages = [
    const EmployeePage(),
    const VehiclePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Employee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Vehicle',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<Map<String, dynamic>> employee = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  void refresh() async {
    final data = await SQLHelper.getEmployee();
    setState(() {
      employee = data;
      filteredEmployees = data; // Initialize filtered list
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void _filterEmployees(String query) {
    final filteredList = employee.where((emp) {
      final nameLower = emp['name'].toLowerCase();
      final emailLower = emp['email'].toLowerCase();
      return nameLower.contains(query.toLowerCase()) ||
          emailLower.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredEmployees = filteredList;
    });
  }

  void _performSearch() {
    _filterEmployees(searchController.text); // Trigger filter on button press
    searchController.clear(); // Clear the search field after search
  }

  Future<void> deleteEmployee(int id) async {
    await SQLHelper.deleteEmployee(id);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
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
            : const Text("EMPLOYEE"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle the search bar
                if (!isSearching) {
                  filteredEmployees = employee; // Reset filtered list
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
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InputPage(
                    title: 'INPUT EMPLOYEE',
                    id: null,
                    name: null,
                    email: null,
                  ),
                ),
              ).then((_) => refresh());
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: isSearching ? filteredEmployees.length : employee.length,
        itemBuilder: (context, index) {
          final emp = isSearching ? filteredEmployees[index] : employee[index];
          return Slidable(
            key: ValueKey(emp['id']),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputPage(
                          title: 'INPUT EMPLOYEE',
                          id: emp['id'],
                          name: emp['name'],
                          email: emp['email'],
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
                    await deleteEmployee(emp['id']);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              title: Text(emp['name']),
              subtitle: Text(emp['email']),
            ),
          );
        },
      ),
    );
  }
}
