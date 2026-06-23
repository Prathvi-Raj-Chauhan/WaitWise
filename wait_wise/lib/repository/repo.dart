import 'package:socket_io_client/socket_io_client.dart' as IO;

class Repository {
  IO.Socket makeSocket(String url, String clinicId) {
    final socket = IO.io(
      url,
      IO.OptionBuilder().setTransports(['websocket']).setQuery({
        'clinicId': clinicId,
      }).build(),
    );
    socket.connect();
    return socket;
  }
}
