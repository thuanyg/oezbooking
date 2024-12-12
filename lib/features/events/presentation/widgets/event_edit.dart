import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/function_utils.dart';
import 'package:oezbooking/core/utils/image_helper.dart';
import 'package:oezbooking/features/events/data/model/category.dart';
import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/events/presentation/widgets/address_map_choose.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';

enum ActionType { create, update, read, delete }

class EditEvent extends StatefulWidget {
  final Event? event;
  final Function(Event) onSave;
  final ActionType actionType;
  final VoidCallback onClose;

  const EditEvent(
      {super.key,
      this.event,
      required this.onSave,
      required this.actionType,
      required this.onClose});

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController eventTypeController;
  late TextEditingController descriptionController;
  late TextEditingController ticketPriceController;
  late TextEditingController availableTicketsController;
  late TextEditingController additionalInfoController;
  late DateTime selectedDate;

  List<String> imageUrls = [];
  ValueNotifier<File?> thumbnailSelect = ValueNotifier(null);
  ValueNotifier<File?> posterSelect = ValueNotifier(null);
  ValueNotifier<List<File>> imageUrlsSelect = ValueNotifier<List<File>>([]);
  ValueNotifier<Category?> selectedCategory = ValueNotifier(null);
  ValueNotifier<LocationResult?> locationResult = ValueNotifier(null);

  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    loginBloc = BlocProvider.of<LoginBloc>(context);
    // Initialize controllers with existing event data or empty strings
    nameController = TextEditingController(text: event?.name ?? '');
    eventTypeController = TextEditingController(text: event?.eventType ?? '');
    descriptionController =
        TextEditingController(text: event?.description ?? '');
    ticketPriceController =
        TextEditingController(text: event?.ticketPrice.toString() ?? '0.0');
    availableTicketsController =
        TextEditingController(text: event?.availableTickets.toString() ?? '0');
    additionalInfoController =
        TextEditingController(text: event?.additionalInfo ?? '');

    selectedDate = event?.date.toUtc().add(const Duration(hours: 7)) ??
        DateTime.now().toUtc().add(const Duration(hours: 7));
    imageUrls = event?.imageUrls ?? [];

    if (widget.event != null) {
      locationResult.value = LocationResult(
        address: event?.location ?? "",
        position: LatLng(
          event!.geoPoint?.latitude ?? 21,
          event.geoPoint?.longitude ?? 21,
        ),
      );
    }

    appendCategory();
  }

  @override
  void dispose() {
    nameController.dispose();
    eventTypeController.dispose();
    descriptionController.dispose();
    ticketPriceController.dispose();
    availableTicketsController.dispose();
    additionalInfoController.dispose();
    imageUrlsSelect.dispose();
    imageUrls = [];

    thumbnailSelect.dispose();
    selectedCategory.dispose();
    posterSelect.dispose();
    imageUrlsSelect.dispose();
    locationResult.dispose();
    super.dispose();
  }

  void _handleSave() async {
    String? thumbnailNewUrl, posterNewUrl;
    if (_formKey.currentState!.validate()) {
      // Check category
      if (selectedCategory.value == null) {
        DialogUtils.showWarningDialog(
          context: context,
          title: "Please select category!",
          onClickOutSide: () {},
        );
        return;
      }

      // Check location
      if (locationResult.value == null) {
        DialogUtils.showWarningDialog(
          context: context,
          title: "Please select address!",
          onClickOutSide: () {},
        );
        return;
      }

      final geoPoint = GeoPoint(
        locationResult.value!.position.latitude,
        locationResult.value!.position.longitude,
      );

      DialogUtils.showLoadingDialog(context);
      if (imageUrlsSelect.value.isNotEmpty) {
        await uploadFilesToFirebase(imageUrlsSelect.value);
      }
      if (thumbnailSelect.value != null) {
        thumbnailNewUrl = await uploadFileAndReturnUrl(thumbnailSelect.value!);
      }
      if (posterSelect.value != null) {
        posterNewUrl = await uploadFileAndReturnUrl(posterSelect.value!);
      }
      final event = Event(
        id: widget.event?.id ?? "EZB-${generateRandomId(6)}",
        name: nameController.text,
        category: selectedCategory.value!.id,
        location: locationResult.value!.address,
        eventType: eventTypeController.text,
        description: descriptionController.text,
        date: selectedDate,
        ticketPrice: double.parse(ticketPriceController.text),
        availableTickets: int.parse(availableTicketsController.text),
        thumbnail: thumbnailNewUrl ?? widget.event?.thumbnail ?? "",
        poster: posterNewUrl ?? widget.event?.poster ?? "",
        imageUrls: imageUrls,
        videoUrl: widget.event?.videoUrl ?? "",
        additionalInfo:
            widget.event?.additionalInfo ?? additionalInfoController.text,
        organizer: widget.event?.organizer ?? (loginBloc.organizer?.id ?? ""),
        geoPoint: geoPoint,
        isDelete: false,
      );
      widget.onSave(event);
    }
  }

  Future<void> pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        // Lọc danh sách các file đã chọn
        List<File> validImages = result.paths
            .where((path) => path != null && _isValidImageExtension(path))
            .map((path) => File(path!))
            .toList();

        imageUrlsSelect.value = [...imageUrlsSelect.value, ...validImages];
        imageUrlsSelect.notifyListeners();

        if (imageUrlsSelect.value.isEmpty) {
          print("No valid images selected!");
        }
      }
      print(imageUrlsSelect.value.length);
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> pickThumbnailImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );

      if (result != null) {
        // Lọc danh sách các file đã chọn
        List<File> validImages = result.paths
            .where((path) => path != null && _isValidImageExtension(path))
            .map((path) => File(path!))
            .toList();

        thumbnailSelect.value = validImages.first;
        thumbnailSelect.notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> pickPosterImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );

      if (result != null) {
        // Lọc danh sách các file đã chọn
        List<File> validImages = result.paths
            .where((path) => path != null && _isValidImageExtension(path))
            .map((path) => File(path!))
            .toList();

        posterSelect.value = validImages.first;
        posterSelect.notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  bool _isValidImageExtension(String? path) {
    if (path == null) return false;
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    final extension = path.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  Future<void> uploadFilesToFirebase(List<File> files) async {
    List<String> uploadedImageUrls = [];

    try {
      for (File file in files) {
        // Tạo tên file ngẫu nhiên để tránh trùng lặp
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();

        // Tham chiếu Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('images/events/$fileName');

        // Tải lên file
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // Lấy URL tải xuống
        String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedImageUrls.add(downloadUrl);
      }

      imageUrls = [...imageUrls, ...uploadedImageUrls];

      print("Upload completed. URLs: $uploadedImageUrls");
    } catch (e) {
      print("Error uploading files: $e");
    }
  }

  Future<String?> uploadFileAndReturnUrl(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/events/$fileName');

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Lấy URL tải xuống
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on Exception catch (e) {
      print("Error uploading files: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    widget.event == null ? 'Create Event' : 'Edit Event',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => widget.onClose(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Details Section
              _buildSectionTitle('Event Details'),
              _buildTextFormField(
                controller: nameController,
                label: 'Event Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter event name' : null,
              ),
              _buildTextFormField(
                controller: eventTypeController,
                label: 'Event Type',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter event type' : null,
              ),

              _buildCategoryDropdown(),

              const SizedBox(height: 16),

              // Choose address

              ValueListenableBuilder(
                valueListenable: locationResult,
                builder: (context, value, child) {
                  if (value != null) {
                    return Row(
                      children: [
                        const Icon(Icons.location_on),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await showBottomSheetChooseLocation();
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value.address,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      const Icon(Icons.location_on),
                      TextButton(
                        onPressed: () async {
                          await showBottomSheetChooseLocation();
                        },
                        child: Text(
                          "Select Location",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Date and Tickets Section
              _buildDatePicker(),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: ticketPriceController,
                      label: 'Ticket Price (\$)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter ticket price';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Invalid price';
                        }
                        if (double.parse(value) < 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: availableTicketsController,
                      label: 'Available Tickets',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter available tickets';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Invalid number';
                        }
                        if (int.parse(value) < 0) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              _buildTextFormField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 5,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),

              // Media Section
              _buildSectionTitle('Thumbnail'),
              _buildThumbnailPicker(),
              _buildSectionTitle('Poster'),
              _buildPosterPicker(),
              // Image URLs Section
              _buildSectionTitle('Images Preview'),
              _buildImageUrlsList(),

              // Action Buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => widget.onClose(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.primaryColor)),
                      onPressed: _handleSave,
                      child: Text(
                        widget.actionType == ActionType.update
                            ? 'Save'
                            : "Add New",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}',
              maxLines: 1,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                currentDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                );
                if (time != null) {
                  setState(() {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
            child: Text(
              'Select',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUrlsList() {
    return ValueListenableBuilder(
      valueListenable: imageUrlsSelect,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (widget.event != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.event!.imageUrls.map(
                  (imageUrl) {
                    return Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 130,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: ImageHelper.loadNetworkImage(imageUrl),
                        ),
                        Positioned(
                          right: -14,
                          top: -14,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                imageUrls.removeWhere((img) => img == imageUrl);
                              });
                            },
                            icon: Icon(
                              Icons.remove_circle,
                              size: 20,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ).toList(),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: value.map(
                (file) {
                  return Stack(
                    children: [
                      Container(
                        height: 100,
                        width: 130,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        top: -10,
                        child: IconButton(
                          onPressed: () {
                            imageUrlsSelect.value.removeWhere((f) => f == file);
                            imageUrlsSelect.notifyListeners();
                          },
                          icon: Icon(
                            Icons.remove_circle,
                            size: 20,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await pickImages();
              },
              child: Text(
                "Add new images",
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      return querySnapshot.docs
          .map((doc) => Category.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<Category>>(
      future: fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No categories available');
        }

        final categories = snapshot.data!;

        return ValueListenableBuilder<Category?>(
          valueListenable: selectedCategory,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  isExpanded: true,
                  value: value,
                  hint: Text(
                    'Select Event Category',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade600,
                  ),
                  onChanged: (Category? newValue) {
                    selectedCategory.value = newValue;
                  },
                  items: categories
                      .map<DropdownMenuItem<Category>>((Category category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(
                        maxLines: 1,
                        category.categoryName,
                        style: const TextStyle(
                          color: Colors.black87,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  appendCategory() async {
    if (widget.event != null) {
      final categoryDoc = await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.event?.category)
          .get();

      final category =
          Category.fromJson(categoryDoc.data() as Map<String, dynamic>);

      selectedCategory.value = category;
    }
  }

  Widget _buildThumbnailPicker() {
    return ValueListenableBuilder(
      valueListenable: thumbnailSelect,
      builder: (context, value, child) {
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: value == null && widget.event != null
                      ? ImageHelper.loadNetworkImage(
                          widget.event!.thumbnail ?? "",
                          fit: BoxFit.cover,
                        )
                      : value != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                value,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                await pickThumbnailImages();
              },
              child: Text(
                "Add new thumbnails",
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPosterPicker() {
    return ValueListenableBuilder(
      valueListenable: posterSelect,
      builder: (context, value, child) {
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: value == null && widget.event != null
                      ? ImageHelper.loadNetworkImage(
                          widget.event!.poster ?? "",
                          fit: BoxFit.cover,
                        )
                      : value != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                value,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                await pickPosterImages();
              },
              child: Text(
                "Add new poster",
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  showBottomSheetChooseLocation() async {
    final LocationResult? locationResult = await showModalBottomSheet(
      context: context,
      barrierLabel: '',
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.87,
          width: double.infinity,
          child: const AddressFinderPage(),
        );
      },
    );

    if (locationResult != null) {
      this.locationResult.value = locationResult;
    }
  }
}
