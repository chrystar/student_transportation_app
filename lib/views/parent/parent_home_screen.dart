import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/register_screen.dart';
import 'message_screen.dart';
import 'parent_tracking_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _parentName = '';
  String _parentEmail = '';
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _children = [];
  final _formKey = GlobalKey<FormState>();
  final _childController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadChildren();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        if (userData.exists) {
          setState(() {
            _parentName = userData.get('name') ?? 'Parent';
            _parentEmail = user.email ?? '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _loadChildren() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final childrenSnapshot = await _firestore
          .collection('users')
          .where('parentId', isEqualTo: userId)
          .get();

      setState(() {
        _children = childrenSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.get('name'),
                  'email': doc.get('email'),
                })
            .toList();
      });
    } catch (e) {
      print('Error loading children: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _linkChild() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Parent user not found. Please log in again.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        final childId = _childController.text.trim();
        if (childId.isEmpty) { //check if the childId is empty
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Child ID cannot be empty.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        // Check if the child document exists
        final childDocRef = _firestore.collection('users').doc(childId);
        final childDocSnapshot = await childDocRef.get();

        if (!childDocSnapshot.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Child with provided ID does not exist.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
          return; // Exit the function if the child doesn't exist
        }
        //check if the child already has a parent.
        final existingParentId = childDocSnapshot.data()?['parentId'];
        if (existingParentId != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Child already has a parent.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
          return; // Exit if child already has a parent.
        }

        // Update the child document with the parent's ID
        await childDocRef.update({'parentId': userId});

        // Refresh the list of children
        await _loadChildren();

        if (mounted) {
          Navigator.of(context).pop(); // Close the bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Child linked successfully!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error linking child: $e'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        print('Error linking child: $e');
      } finally {
        _formKey.currentState?.reset();
        _childController.clear();
      }
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Children',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_children.isEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                //color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Text(
                      'No children registered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          //todo: linking uisng uid: the parent have to input the uuid of the register child
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Form(
                                      key: _formKey,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(
                                          top: 20,
                                          left: 20,
                                          right: 20,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Link Your Child',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: _childController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter child\'s ID';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.grey.shade300,
                                                labelText: "Enter child's Id",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            GestureDetector(
                                              onTap: _linkChild,
                                              child: Container(
                                                width: double.infinity,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Link',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      "Link your child using uid",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Icon(Icons.link),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        //todo: linking uisng QR code: the parent have to scan the code of the child using qr code scanner

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    "Link your child using QR Code",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(Icons.link),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          //Todo: once successfully linked a child display the child
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return _buildChildCard(child);
              },
            ),
          const SizedBox(height: 24),
          Text(
            'Active Trips',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildActiveTripsSection(),
        ],
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('trips')
            .where('studentId', isEqualTo: child['id'])
            .where('status', isEqualTo: 'inProgress')
            .snapshots(),
        builder: (context, snapshot) {
          bool isActive = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

          return ListTile(
            leading: CircleAvatar(
              child: Text(child['name'][0]),
            ),
            title: Text(child['name']),
            subtitle: Text(child['email']),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? 'In Transit' : 'Not Active',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTripsSection() {
    if (_children.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No children registered'),
        ),
      );
    }

    final childrenIds = _children.map((child) => child['id']).toList();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('trips')
          .where('studentId', whereIn: childrenIds)
          .where('status', isEqualTo: 'inProgress')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No active trips'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final tripData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final childName = _children.firstWhere(
                (child) => child['id'] == tripData['studentId'])['name'];

            return Card(
              child: ListTile(
                title: Text('$childName\'s Trip'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${tripData['pickupAddress']}'),
                    Text('To: ${tripData['dropoffAddress']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParentTrackingScreen(
                          tripId: snapshot.data!.docs[index].id,
                          studentName: childName ?? 'Unknown',
                          pickupAddress: tripData['pickupAddress'],
                          dropoffAddress: tripData['dropoffAddress'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesSection() {
    if (_children.isEmpty) {
      return const Center(child: Text('No children registered'));
    }

    final childrenIds = _children.map((child) => child['id']).toList();

    return ListView.builder(
      itemCount: _children.length,
      itemBuilder: (context, index) {
        final child = _children[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(child['name'][0]),
            ),
            title: Text(child['name']),
            subtitle: Text(child['email']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentMessageScreen(
                    recipientId: child['id'],
                    recipientName: child['name'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    // return StreamBuilder<QuerySnapshot>(
    //   stream: _firestore
    //       .collection('messages')
    //       .where('studentId', whereIn: childrenIds)
    //       .where('recipientType', isEqualTo: 'parent')
    //       .orderBy('timestamp', descending: true)
    //       .limit(50)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return const Text('Something went wrong');
    //     }
    //
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //
    //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    //       return const Center(child: Text('No messages'));
    //     }
    //
    //     return ListView.builder(
    //       itemCount: snapshot.data!.docs.length,
    //       itemBuilder: (context, index) {
    //         final message = snapshot.data!.docs[index];
    //         final data = message.data() as Map<String, dynamic>;
    //         final timestamp = data['timestamp'] as Timestamp?;
    //
    //         return Card(
    //           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //           color: data['isEmergency'] == true
    //               ? Colors.red.shade100
    //               : Theme.of(context).cardColor,
    //           child: ListTile(
    //             leading: Icon(
    //               data['isEmergency'] == true ? Icons.warning : Icons.message,
    //               color: data['isEmergency'] == true ? Colors.red : null,
    //             ),
    //             title: Text(data['studentName'] ?? 'Unknown'),
    //             subtitle: Text(data['message']),
    //             trailing: timestamp != null
    //                 ? Text(
    //                     '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}')
    //                 : null,
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _parentName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    _parentEmail,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.child_care),
              title: const Text('Children'),
              onTap: () {
                Navigator.pop(context);
                // tODO: Navigate to children management screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Trip History'),
              onTap: () {
                Navigator.pop(context);
                // tODO: Navigate to trip history screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                //  Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          _buildMessagesSection(),
          const Center(child: Text('Trip History')), //tODO: Implement
          const Center(child: Text('Settings')), // tODO: Implement
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
