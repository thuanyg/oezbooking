import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/apps/app_styles.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/encryption_helper.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_bloc.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_event.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_state.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/page/ticket_scanner_result.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/widgets/scanner_overlay.dart';

class TicketScannerPage extends StatefulWidget {
  const TicketScannerPage({super.key});

  @override
  State<TicketScannerPage> createState() => _TicketScannerPageState();
}

class _TicketScannerPageState extends State<TicketScannerPage>
    with SingleTickerProviderStateMixin {
  /// Controller
  late MobileScannerController controller;
  late AnimationController animationController;

  /// Value notifier
  ValueNotifier<TorchState> torchStateNotifier = ValueNotifier(TorchState.off);
  ValueNotifier<CameraFacing> cameraDirectionNotifier =
      ValueNotifier(CameraFacing.back);

  /// Flag variable
  bool isProcessingScan = false;
  bool isShowingDialog = false;

  /// Bloc
  late FetchTicketBloc fetchTicketBloc;

  @override
  void initState() {
    super.initState();
    fetchTicketBloc = BlocProvider.of<FetchTicketBloc>(context);
    controller = MobileScannerController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      print("CAM START _______________");
      startCam();
    }
  }

  startCam() async {
    await controller.start().then((value) => controller.start());
  }

  stopCam() async {
    await controller.stop().then((value) => controller.stop());
  }

  @override
  void dispose() {
    print("CAM STOPPED _______________");
    animationController.dispose();
    controller.dispose();
    super.dispose();
    stopCam();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          const Flexible(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Place the QR code to the area",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Scanning will be started automatically",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffb7b7b7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    height: size.width * 0.8,
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MobileScanner(
                      controller: controller,
                      placeholderBuilder: (p0, p1) {
                        return const Center(
                          child: Text("Đang khởi tạo máy ảnh"),
                        );
                      },
                      fit: BoxFit.cover,
                      scanWindowUpdateThreshold: 2,
                      onDetect: (capture) async {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final String? code = barcode.rawValue;
                          if (code != null) {
                            await handleScannedCode(code);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No value found in the scanned code'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(size.width * 0.8, size.width * 0.8),
                        painter: ScannerOverlayPainter(
                          animationValue: animationController.value,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: BlocListener(
              bloc: fetchTicketBloc,
              listener: (context, state) async {
                if (state is FetchTicketSuccess) {
                  DialogUtils.hide(context);
                  isShowingDialog = false;

                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return TicketScannerResult(ticket: state.ticket);
                    },
                  ));
                }
              },
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      title: Text(
        "QR Code Scanner",
        style: AppStyle.appBarTitle.copyWith(color: Colors.white),
      ),
      centerTitle: true,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: ValueListenableBuilder(
            valueListenable: torchStateNotifier,
            builder: (context, state, child) {
              return Icon(
                state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                color: Colors.white70,
              );
            },
          ),
          onPressed: () => switchTorch(),
        ),
        IconButton(
          icon: ValueListenableBuilder(
            valueListenable: cameraDirectionNotifier,
            builder: (context, state, child) {
              return Icon(
                state == CameraFacing.front
                    ? Icons.camera_front
                    : Icons.camera_rear,
                color: Colors.white70,
              );
            },
          ),
          onPressed: () => switchCamera(),
        ),
      ],
    );
  }

  void switchTorch() {
    controller.toggleTorch();
    // Toggle between front and back camera
    torchStateNotifier.value = torchStateNotifier.value == TorchState.off
        ? TorchState.on
        : TorchState.off;
  }

  void switchCamera() {
    controller.switchCamera();
    // Toggle between front and back camera
    cameraDirectionNotifier.value =
        cameraDirectionNotifier.value == CameraFacing.back
            ? CameraFacing.front
            : CameraFacing.back;
  }

  handleScannedCode(String code) async {
    if (isProcessingScan || isShowingDialog) {
      return;
    }
    isProcessingScan = true;

    try {
      String qrCodeData =
          EncryptionHelper.decryptData(code, EncryptionHelper.secretKey);
      // Extract parameters from the decrypted string
      Map<String, String> params = Uri.splitQueryString(qrCodeData);

      // Access individual parameters
      String? ticketId = params['ticketId'];
      // String? orderId = params['orderId'];
      // String? eventId = params['eventId'];

      if (ticketId == null) {
        await _showErrorModal(code,
            message: "*The QR code does not belong to the EzBooking system");
        return;
      }

      // Show Loading Dialog
      DialogUtils.showLoadingDialog(context);
      isShowingDialog = true;

      // Stop camera
      await controller.stop().then((value) => controller.stop());

      // Ticket Handling
      fetchTicketBloc.add(FetchTicket(ticketId));
    } catch (e) {
      await _showErrorModal(
        code,
        message: "*The QR code does not belong to the EzBooking system",
        onDismiss: () {
          isShowingDialog = false;
        },
      );
    } finally {
      // Ensure state reset regardless of outcome
      isProcessingScan = false;
    }
  }

  Future<void> _showErrorModal(String code,
      {required String message, VoidCallback? onDismiss}) async {
    isShowingDialog = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Column(
            children: [
              Text(
                "Scanner Results",
                style: AppStyle.appBarTitle.copyWith(fontSize: 16),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    code,
                    textAlign: TextAlign.center,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppStyle.appBarTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    ).then(
      (value) {
        if (onDismiss != null) {
          onDismiss();
        }
      },
    );
  }
}
