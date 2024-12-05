import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/function_utils.dart';
import 'package:oezbooking/features/login/data/model/organizer.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';

class OrganizerProfilePage extends StatefulWidget {
  final Organizer organizer;

  const OrganizerProfilePage({super.key, required this.organizer});

  @override
  _OrganizerProfilePageState createState() => _OrganizerProfilePageState();
}

class _OrganizerProfilePageState extends State<OrganizerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _facebookController;
  XFile? pickedImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing organizer data
    _nameController = TextEditingController(text: widget.organizer.name);
    _emailController = TextEditingController(text: widget.organizer.email);
    _phoneController =
        TextEditingController(text: widget.organizer.phoneNumber);
    _addressController = TextEditingController(text: widget.organizer.address);
    _websiteController = TextEditingController(text: widget.organizer.website);
    _facebookController =
        TextEditingController(text: widget.organizer.facebook);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<String> uploadImage(XFile pickedImage) async {
    // Upload image to Firebase Storage
    final _storage = FirebaseStorage.instance;
    try {
      String fileName = generateRandomId(7);
      File imageFile = File(pickedImage.path);

      // Upload image to Firebase Storage
      UploadTask uploadTask =
          _storage.ref('images/avatars/$fileName').putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text("Image uploaded successfully!"),
      //     backgroundColor: AppColors.primaryColor,
      //   ),
      // );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error uploading image!")),
      );
      return "";
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        DialogUtils.showLoadingDialog(context);
        String? avatarUrl;
        if (pickedImage != null) {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: "admin@ezbooking.vn", password: "ezbooking");
          avatarUrl = await uploadImage(pickedImage!);
        }
        // Update organizer profile
        final updatedOrganizer = Organizer(
          id: widget.organizer.id,
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          website: _websiteController.text,
          facebook: _facebookController.text,
          avatarUrl: avatarUrl ?? widget.organizer.avatarUrl,
          passwordHash: widget.organizer.passwordHash,
          createdAt: widget.organizer.createdAt,
        );

        await FirebaseFirestore.instance
            .collection("organizers")
            .doc(updatedOrganizer.id)
            .update(updatedOrganizer.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully')),
        );
        final loginBloc = BlocProvider.of<LoginBloc>(context);
        loginBloc.organizer = updatedOrganizer;
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error When Updating Profile')),
        );
      } finally {
        DialogUtils.hide(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.drawerColor,
        title: Text('Organizer Profile', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Avatar
              Center(
                child: Stack(
                  children: [
                    pickedImage != null
                        ? CircleAvatar(
                            radius: 46,
                            backgroundImage: FileImage(
                              File(pickedImage!.path),
                            ),
                          )
                        : CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.blueGrey,
                            backgroundImage: widget.organizer.avatarUrl != null
                                ? CachedNetworkImageProvider(
                                    widget.organizer.avatarUrl!)
                                : null,
                            child: widget.organizer.avatarUrl == null
                                ? const Icon(Icons.person,
                                    size: 46, color: Colors.white)
                                : null,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                          onPressed: () async {
                            // TODO: Implement avatar upload logic
                            final ImagePicker imagePicker = ImagePicker();
                            final XFile? image = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (image == null) return;
                            setState(() {
                              pickedImage = image;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile Information Fields
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your email';
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  return !emailRegex.hasMatch(value!)
                      ? 'Enter a valid email'
                      : null;
                },
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter your phone number'
                    : null,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _websiteController,
                label: 'Website',
                icon: Icons.web,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _facebookController,
                label: 'Facebook Profile',
                icon: Icons.facebook,
              ),
              SizedBox(height: 20),

              // Save Profile Button
              ElevatedButton(
                onPressed: () async => _saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: AppColors.drawerColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
    );
  }
}
