import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:intl/intl.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  String? address;
  String? imageUrl;
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Player Profile',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background_images/quartz_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: screenWidth * 0.6, // Made wider for better layout
              height: screenHeight * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 189, 189, 189),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading user data: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No user data found'));
                  } else {
                    final userData = snapshot.data!;
                    // Format date if it exists
                    String formattedDate = 'N/A';
                    if (userData['created_at'] != null) {
                      try {
                        final createdAt = DateTime.parse(
                          userData['created_at'],
                        );
                        formattedDate = dateFormat.format(createdAt);
                      } catch (e) {
                        formattedDate = userData['created_at'];
                      }
                    }

                    // Format money value
                    String formattedBalance = 'N/A';
                    if (userData['money'] != null) {
                      try {
                        final money = double.parse(
                          userData['money'].toString(),
                        );
                        formattedBalance = currencyFormat.format(money);
                      } catch (e) {
                        formattedBalance = userData['money'].toString();
                      }
                    }

                    return Row(
                      children: [
                        // Left column - Player image and basic info
                        Container(
                          width: screenWidth * 0.2,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 229, 255, 252),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Image
                              Container(
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      201,
                                      201,
                                      201,
                                    ),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 189, 189, 189),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl ??
                                        'https://example.com/default_avatar.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Player Name
                              Text(
                                '${userData['minecraft_username'] ?? 'Player'}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),

                              // Balance Display
                              const Text(
                                'Account Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formattedBalance,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 23, 221, 97),
                                ),
                              ),

                              const Divider(height: 40),

                              // Actions Button
                              ElevatedButton(
                                onPressed: () async {
                                  await uploadImage();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    74,
                                    237,
                                    217,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Change Avatar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Change Address'),
                                        content: TextField(
                                          controller: addressController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter new address',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await changeAddress(
                                                addressController.text,
                                              );
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    23,
                                    221,
                                    97,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Change Address',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right column - Player details
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Player Information',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Information Containers
                                _buildInfoContainer(
                                  title: 'Contact Information',
                                  children: [
                                    _buildInfoRow(
                                      'Email',
                                      userData['email'] ?? 'N/A',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'Delivery Address',
                                      address ?? 'Not set',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                _buildInfoContainer(
                                  title: 'Account Details',
                                  children: [
                                    _buildInfoRow(
                                      'Account Created',
                                      formattedDate,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'User ID',
                                      userData['id']?.toString() ?? 'N/A',
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                // Bottom section with additional actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Navigate to transaction history
                                      },
                                      child: const Text('Transaction History'),
                                    ),
                                    const SizedBox(width: 20),
                                    TextButton(
                                      onPressed: () {
                                        // Navigate to settings
                                      },
                                      child: const Text('Account Settings'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 201, 201, 201),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 244, 244, 244),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> getUserData() async {
    final response = await SupabaseHelper.getUserData();
    address = response['delivery_address'];
    imageUrl = response['avatar_url'];
    return response;
  }

  Future<void> changeAddress(String newAddress) async {
    SupabaseHelper.updateUserAddress(newAddress);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address updated successfully!')),
      );
      setState(() {
        address = addressController.text;
        addressController.clear();
      });
    }
  }

  Future<void> uploadImage() async {
    final imageUrl = await SupabaseHelper.updateUserProfilePicture();
    if (mounted) {
      if (imageUrl != null) {
        setState(() {
          this.imageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      }
    }
  }
}
