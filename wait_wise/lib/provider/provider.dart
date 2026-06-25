import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wait_wise/model/QueueState.dart';
import 'package:wait_wise/repository/repo.dart';

final serverUrlProvider = StateProvider<String?>((ref) => null);

final clinicIdProvider = StateProvider<String?>((ref) => null);


final repoProvider = Provider<Repository>((ref) {
  return Repository();
});


final socketProvider = Provider<IO.Socket?>((ref){
  final url = ref.watch(serverUrlProvider);
  final clinicId = ref.watch(clinicIdProvider);
  if(url == null || clinicId == null){
    return null;
  }

  final repo = ref.watch(repoProvider);
  final socket = repo.makeSocket(url, clinicId);
  print("Socket Provider Created");
  ref.onDispose((){
    socket.disconnect();
    socket.dispose();
  });
  return socket;
});


final queueProvider = StateNotifierProvider<QueueNotifier, QueueState>((ref){
  return QueueNotifier(ref.watch(socketProvider));
});

class QueueNotifier extends StateNotifier<QueueState>{
  final IO.Socket? socket;
  QueueNotifier(this.socket) : super(QueueState.empty()){ //runs before constructor body, 'll initialze QueueState as empty
    print("QueueNotifier created");
    socket?.on("queueUpdated", (data){
      state = QueueState.fromJson(data);
    });
    socket?.onAny((event, data) {
      print("EVENT: $event");
      print("DATA: $data");
    });
    socket?.onConnect((_) => state = state.copyWith(connected: true));
    socket?.onDisconnect((_) => state = state.copyWith(connected: false));
  }

  void callNext() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final clinicDbId = await prefs.get('clinicDbId');
    if(socket == null){
      return;
    }
    state = state.optimisticCallNext();
    socket!.emitWithAck('callNext', {clinicDbId}, ack: (res){
      if(res['ok'] != true){
        state = state.rollback();
      }
    });
  }
   void addPatient({
    required String name,
    required String reason,
    required String mobile,
    String? age,
    String? gender,
    String? weight,
    String? bloodPressure,
    String? address,
    
  }) async{
    
    if (socket == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final clinicDbId = await prefs.get('clinicDbId');
    socket!.emitWithAck(
      'addPatient',
      {
        'name': name,
        'reason': reason,
        'age': age,
        'gender': gender,
        'weight': weight,
        'bloodPressure': bloodPressure,
        'address': address,
        'mobile' : mobile,
        'clinicDbId' : clinicDbId
      },
      ack: (res) {
        if (res['ok'] != true) {
          
          print("addPatient error: ${res['error']}");
        }
      },
    );
  }
}