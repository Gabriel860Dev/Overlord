// lib/services/network_manager.dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final List<Socket> _connectedClients = [];

  // Callbacks
  Function(String message)? onMessageReceived;
  Function(String status)? onStatusChanged;
  Function(int count)? onClientCountChanged;
  Function(String peerId)? onPeerConnected;
  Function(String peerId)? onPeerDisconnected;

  bool get isHost => _serverSocket != null;
  bool get isConnected => _serverSocket != null || _clientSocket != null;

  // --- MÉTODOS UNIFICADOS (CORREÇÃO DE ERROS) ---
  
  // Apelido para compatibilidade com connection_screen.dart
  Future<void> startHost({int port = 4545}) async => startHosting(port: port);
  Future<void> joinTable(String ip, {int port = 4545}) async => joinSession(ip, port: port);
  void sendRoll(String p, String d, int r) {
     sendMessage(jsonEncode({'type': 'ROLL', 'player': p, 'details': d, 'result': r}));
  }

  // --- IMPLEMENTAÇÃO ---

  Future<void> startHosting({int port = 4545}) async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      String ip = "Desconhecido";
      if (interfaces.isNotEmpty) {
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback) { ip = addr.address; break; }
          }
        }
      }
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _notifyStatus("Mesa aberta! IP: $ip");
      _notifyClientCount();
      _serverSocket!.listen((Socket client) { _handleNewConnection(client); });
    } catch (e) {
      _notifyStatus("Erro: $e");
      stop();
    }
  }

  void _handleNewConnection(Socket client) {
    _connectedClients.add(client);
    _notifyClientCount();
    if (onPeerConnected != null) onPeerConnected!(client.remoteAddress.address);
    client.listen((List<int> data) {
        final message = String.fromCharCodes(data);
        _handleIncomingData(message, sender: client);
      },
      onError: (e) => _disconnectClient(client),
      onDone: () => _disconnectClient(client),
    );
  }

  Future<void> joinSession(String ipAddress, {int port = 4545}) async {
    try {
      _notifyStatus("Conectando...");
      _clientSocket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5));
      _notifyStatus("Conectado!");
      _clientSocket!.listen((List<int> data) {
          final message = String.fromCharCodes(data);
          if (onMessageReceived != null) onMessageReceived!(message);
        },
        onError: (e) { _notifyStatus("Erro: $e"); stop(); },
        onDone: () { _notifyStatus("Fechado."); stop(); },
      );
    } catch (e) {
      _notifyStatus("Falha: $e");
      stop();
    }
  }

  void sendMessage(String message) {
    if (isHost) {
      _broadcast(message);
      if (onMessageReceived != null) onMessageReceived!(message);
    } else if (_clientSocket != null) {
      try { _clientSocket!.write(message); } catch (e) { debugPrint("Erro envio: $e"); }
    } else {
      // Loopback local para teste
      if (onMessageReceived != null) onMessageReceived!(message);
    }
  }

  void _broadcast(String message, {Socket? exclude}) {
    if (!isHost) return;
    for (var client in _connectedClients) {
      if (client != exclude) {
        try { client.write(message); } catch (_) {}
      }
    }
  }

  void _handleIncomingData(String message, {Socket? sender}) {
    if (onMessageReceived != null) onMessageReceived!(message);
    if (isHost) _broadcast(message, exclude: sender);
  }

  void _disconnectClient(Socket client) {
    client.close();
    _connectedClients.remove(client);
    _notifyClientCount();
    if (onPeerDisconnected != null) onPeerDisconnected!(client.remoteAddress.address);
  }

  void stop() {
    try {
      _serverSocket?.close(); _serverSocket = null;
      _clientSocket?.close(); _clientSocket = null;
      for (var c in _connectedClients) {
        c.close();
      }
      _connectedClients.clear();
    } catch (_) {}
    _notifyStatus("Desconectado.");
    _notifyClientCount();
  }

  void _notifyStatus(String msg) { if (onStatusChanged != null) onStatusChanged!(msg); }
  void _notifyClientCount() { if (onClientCountChanged != null) onClientCountChanged!(_connectedClients.length); }
}