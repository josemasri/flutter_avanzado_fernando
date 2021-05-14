import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    this._socket = IO.io(
      Platform.isIOS ? 'http://localhost:3000' : 'http://192.168.68.102:3000',
      {
        'transports': ['websocket'],
        'autoconnect': true
      },
    );
    Timer(Duration(seconds: 10), () {
      if (_serverStatus == ServerStatus.Connecting) {
        this._serverStatus = ServerStatus.Offline;
        notifyListeners();
      }
    });
    this._socket.onConnect((_) {
      print('connected');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Connecting;
      Timer(Duration(seconds: 10), () {
        if (_serverStatus == ServerStatus.Connecting) {
          this._serverStatus = ServerStatus.Offline;
          notifyListeners();
        }
      });
      notifyListeners();
      print('Disconnected');
    });
  }
}
