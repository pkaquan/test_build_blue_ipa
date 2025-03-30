import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue blue = FlutterBlue.instance;
  Future startScan() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        blue.startScan(timeout: Duration(seconds: 5));
        blue.stopScan();
      }
    }
  }

  Future<void> connectingDevice(BluetoothDevice device) async {
    await device?.connect(timeout: Duration(seconds: 15));
    device?.state.listen((isConnecting) {
      if (isConnecting == BluetoothDeviceState.connecting) {
        print("Đang kết nối");
      } else if (isConnecting == BluetoothDeviceState.connected) {
        print("Đã kết nối");
      } else {
        print("Chưa kết nối");
      }
    });
  }

  Stream<List<ScanResult>> get scanResult => blue.scanResults;
}
