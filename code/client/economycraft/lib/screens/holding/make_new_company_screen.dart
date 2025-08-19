import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MakeNewCompanyScreen extends StatefulWidget {
  const MakeNewCompanyScreen({super.key});

  @override
  State<MakeNewCompanyScreen> createState() => _MakeNewCompanyScreenState();
}

class _MakeNewCompanyScreenState extends State<MakeNewCompanyScreen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController sloganController = TextEditingController();
  final TextEditingController lotNumberController = TextEditingController();
  bool notificationEnabled = false;
  bool isLoading = false;
  String companyAvatarUrl =
      'https://cdn-icons-png.flaticon.com/512/149/149071.png'; // Default avatar URL

  @override
  void dispose() {
    companyNameController.dispose();
    sloganController.dispose();
    lotNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Company',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/holdings'),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background_images/quartz_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          Center(
            child: Container(
              width: screenWidth * 0.6,
              height: screenHeight * 0.85,
              padding: const EdgeInsets.all(30.0),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    const Center(
                      child: Text(
                        'Register Your Company',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 23, 221, 97),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Fill out the details below to establish your business presence',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Two-column layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Company Avatar
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Company Logo',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // Avatar container with border
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
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
                                      color: Color.fromARGB(255, 244, 244, 244),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    companyAvatarUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.business,
                                          size: 80,
                                          color: Colors.white70,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Avatar selection button
                              ElevatedButton.icon(
                                onPressed: isLoading ? null : _pickAvatar,
                                icon: const Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Upload Company Logo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    74,
                                    237,
                                    217,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'A professional logo helps establish your brand identity',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        // Right column - Company Details Form
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Company Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Company Name Field
                              _buildFormField(
                                controller: companyNameController,
                                label: 'Company Name',
                                hint: 'Enter your company name',
                                icon: Icons.business,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),

                              // Company Slogan Field
                              _buildFormField(
                                controller: sloganController,
                                label: 'Company Slogan',
                                hint: 'A catchy phrase about your business',
                                icon: Icons.format_quote,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),

                              // Lot Number Field
                              _buildFormField(
                                controller: lotNumberController,
                                label: 'Lot Number',
                                hint: 'Enter your in-game lot number',
                                icon: Icons.place,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                helperText:
                                    'The lot identifier for your company in-game',
                              ),
                              const SizedBox(height: 25),

                              // Notifications toggle
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    244,
                                    244,
                                    244,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Enable Notifications',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Get updates about your company',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: notificationEnabled,
                                      activeColor: const Color.fromARGB(
                                        255,
                                        23,
                                        221,
                                        97,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          notificationEnabled = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Create Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () async {
                                            if (companyNameController
                                                    .text
                                                    .isEmpty ||
                                                sloganController.text.isEmpty ||
                                                lotNumberController
                                                    .text
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please fill in all required fields.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() {
                                              isLoading = true;
                                            });

                                            await _createCompany();

                                            if (mounted) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          },
                                  icon:
                                      isLoading
                                          ? Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.all(2.0),
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                          )
                                          : const Icon(
                                            Icons.create_new_folder,
                                            color: Colors.white,
                                          ),
                                  label: Text(
                                    isLoading
                                        ? 'Creating...'
                                        : 'Create Company',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      23,
                                      221,
                                      97,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Cancel Button
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () => context.go('/home/holdings'),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Cancel and go back'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: const TextStyle(fontSize: 12),
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: const Color.fromARGB(255, 250, 250, 250),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 201, 201, 201),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 201, 201, 201),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 74, 237, 217),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAvatar() async {
    setState(() {
      isLoading = true;
    });

    final avatarUrl = await SupabaseHelper.addCompanyAvatar();

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (avatarUrl != '') {
        companyAvatarUrl = avatarUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload logo. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _createCompany() async {
    String companyName = companyNameController.text;
    String slogan = sloganController.text;
    String lotNumber = lotNumberController.text;

    try {
      // Validate inputs
      int? lotNumberInt = int.tryParse(lotNumber);
      if (lotNumberInt == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid lot number (numbers only).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check for existing lot number and company name
      final validLot = await SupabaseHelper.checkForLotNumber(lotNumberInt);
      if (!mounted) return;

      final validCompanyName = await SupabaseHelper.checkForCompanyName(
        companyName,
      );
      if (!mounted) return;

      if (validLot && validCompanyName) {
        // Create the company in the database
        await SupabaseHelper.createCompany(
          companyName,
          slogan,
          companyAvatarUrl,
          lotNumberInt,
          notificationEnabled,
        );

        if (!mounted) return;

        // Show success message
        _showInformationDialog();
      } else {
        // Show error messages
        if (!validLot && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Lot number is already taken by another company. If you believe this is an error, please contact an administrator.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }

        if (!validCompanyName && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Company name already exists. Please choose a different name.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating company: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInformationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.check_circle,
                color: Color.fromARGB(255, 23, 221, 97),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Company Created Successfully',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thank you for creating a new company!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your company will now enter a brief validation period to ensure accuracy of provided information. During this time, other players will not be able to see your company.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Once the validation is complete, you will receive a notification and your company will be visible to all players.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 245, 245),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can check the status of your company in the "My Holdings" tab.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text(
                'Return to My Holdings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 221, 97),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                context.go('/home/holdings');
              },
            ),
          ],
        );
      },
    );
  }
}
