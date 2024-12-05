import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/function_utils.dart';
import 'package:oezbooking/core/utils/image_helper.dart';
import 'package:oezbooking/features/events/data/model/event.dart';

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
  late TextEditingController locationController;
  late TextEditingController eventTypeController;
  late TextEditingController descriptionController;
  late TextEditingController ticketPriceController;
  late TextEditingController availableTicketsController;
  late TextEditingController thumbnailController;
  late TextEditingController posterController;
  late TextEditingController videoUrlController;
  late TextEditingController additionalInfoController;
  late DateTime selectedDate;

  List<String> imageUrls = [];
  ValueNotifier<List<File>> imageUrlsSelect = ValueNotifier<List<File>>([]);

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    // Initialize controllers with existing event data or empty strings
    nameController = TextEditingController(text: event?.name ?? '');
    locationController = TextEditingController(text: event?.location ?? '');
    eventTypeController = TextEditingController(text: event?.eventType ?? '');
    descriptionController =
        TextEditingController(text: event?.description ?? '');
    ticketPriceController =
        TextEditingController(text: event?.ticketPrice.toString() ?? '0.0');
    availableTicketsController =
        TextEditingController(text: event?.availableTickets.toString() ?? '0');
    thumbnailController = TextEditingController(text: event?.thumbnail ?? '');
    posterController = TextEditingController(text: event?.poster ?? '');
    videoUrlController = TextEditingController(text: event?.videoUrl ?? '');
    additionalInfoController =
        TextEditingController(text: event?.additionalInfo ?? '');

    selectedDate =
        event?.date ?? DateTime.now().toUtc().add(const Duration(hours: 7));
    imageUrls = event?.imageUrls ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    eventTypeController.dispose();
    descriptionController.dispose();
    ticketPriceController.dispose();
    availableTicketsController.dispose();
    thumbnailController.dispose();
    posterController.dispose();
    videoUrlController.dispose();
    additionalInfoController.dispose();
    imageUrlsSelect.dispose();
    imageUrls = [];
    super.dispose();
  }


  void _handleSave() async {
    DialogUtils.showLoadingDialog(context);
    await uploadFilesToFirebase(imageUrlsSelect.value);
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id ?? generateRandomId(6),
        name: nameController.text,
        location: locationController.text,
        eventType: eventTypeController.text,
        description: descriptionController.text,
        date: selectedDate,
        ticketPrice: double.parse(ticketPriceController.text),
        availableTickets: int.parse(availableTicketsController.text),
        thumbnail:
            thumbnailController.text.isEmpty ? null : thumbnailController.text,
        poster: posterController.text.isEmpty ? null : posterController.text,
        imageUrls: imageUrls,
        videoUrl:
            videoUrlController.text.isEmpty ? null : videoUrlController.text,
        additionalInfo: additionalInfoController.text.isEmpty
            ? null
            : additionalInfoController.text,
        organizer: widget.event?.organizer,
        geoPoint: widget.event?.geoPoint,
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

  @override
  Widget build(BuildContext context) {
    print(imageUrls.length);
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
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: locationController,
                      label: 'Location',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter location'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: eventTypeController,
                      label: 'Event Type',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter event type'
                          : null,
                    ),
                  ),
                ],
              ),

              // Date and Tickets Section
              _buildDatePicker(),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: ticketPriceController,
                      label: 'Ticket Price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return 'Please enter ticket price';
                        if (double.tryParse(value!) == null)
                          return 'Invalid price';
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
                        if (value?.isEmpty ?? true)
                          return 'Please enter available tickets';
                        if (int.tryParse(value!) == null)
                          return 'Invalid number';
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
              // _buildSectionTitle('Media'),
              // _buildTextFormField(
              //   controller: thumbnailController,
              //   label: 'Thumbnail URL',
              // ),
              // _buildTextFormField(
              //   controller: posterController,
              //   label: 'Poster URL',
              // ),
              // _buildTextFormField(
              //   controller: videoUrlController,
              //   label: 'Video URL',
              // ),

              // Image URLs Section
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
            const Text('Images'),
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
}
