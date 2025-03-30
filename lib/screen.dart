// import 'package:ble_flutter/ble_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:get/get_state_manager/src/simple/get_state.dart';

// class Screen extends StatefulWidget {
//   const Screen({super.key});

//   @override
//   State<Screen> createState() => _ScreenState();
// }

// class _ScreenState extends State<Screen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text("BLE SCANNER"),),
//         body: GetBuilder<BleController>(
//           init: BleController(),
//           builder: (BleController controller)
//           {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   StreamBuilder<List<ScanResult>>(
//                       stream: controller.scanResult,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           return Expanded(
//                             child: ListView.builder(
//                                 shrinkWrap: true,
//                                 itemCount: snapshot.data!.length,
//                                 itemBuilder: (context, index) {
//                                   final data = snapshot.data![index];
//                                   return Card(
//                                     elevation: 2,
//                                     child: ListTile(
//                                       title: Text(data.device.name),
//                                       subtitle: Text(data.device.id.id),
//                                       trailing: Text(data.rssi.toString()),
//                                       onTap: ()=> controller.connectingDevice(data.device),
//                                     ),
//                                   );
//                                 }),
//                           );
//                         }else{
//                           return Center(child: Text("No Device Found"),);
//                         }
//                       }),
//                   SizedBox(height: 10,),
//                   ElevatedButton(onPressed: ()  async {
//                     controller.startScan();
//                     // await controller.disconnectDevice();
//                   }, child: Text("SCAN")),
//                 ],
//               ),
//             );
//           },
//         )
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  List<ScanResult> blueList = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    permissionBle();
  }

  Future <void> permissionBle() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
  }

  Future startScan() async {
    setState(() {
      blueList.clear();
      isScanning = true;
    });
    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((result) {
        setState(() {
          blueList = result;
        });
      });
    } catch (e) {
      e.toString();
    }
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      isScanning = false;
    });
  }

  Future<void> connectingBlue(BluetoothDevice device) async {
    await device.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Scanner')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isScanning ? null : startScan,
              child: Text(isScanning ? 'Scanning...' : 'Start Scan'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: blueList.length,
              itemBuilder: (context, index) {
                final result = blueList[index];
                return ListTile(
                  title: Text(
                    result.device.platformName.isEmpty
                        ? 'Unknown Device'
                        : result.device.platformName,
                  ),
                  subtitle: Text(result.device.id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => connectingBlue(result.device),
                    child: const Text('Connect'),
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
