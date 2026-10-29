// lib/screens/connection_screen.dart

import 'package:flutter/material.dart';
import 'package:overlord/models/character_sheet.dart';
import 'package:overlord/services/network_manager.dart';
import 'package:overlord/screens/online_tabletop_screen.dart';

class ConnectionScreen extends StatefulWidget {
  // Recebe as fichas do Main para passar para o TableTop
  final List<CharacterSheet> sheets; 

  const ConnectionScreen({super.key, required this.sheets});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _ipController = TextEditingController();
  String _status = "Desconectado";
  int _playersCount = 0;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
  }

  void _setupNetworkListeners() {
    final net = NetworkManager();
    
    // Atualiza status na tela (Ex: "Conectado", "Erro")
    net.onStatusChanged = (msg) {
      if (mounted) setState(() => _status = msg);
    };

    // Atualiza contador de jogadores (apenas para o Host ver)
    net.onClientCountChanged = (count) {
      if (mounted) setState(() => _playersCount = count);
    };

    // Log visual para debug (opcional)
    net.onMessageReceived = (msg) {
      if (mounted) {
        setState(() {
          // Mantém apenas os últimos 10 logs para não poluir
          if (_logs.length > 10) _logs.removeLast();
          _logs.insert(0, "Recebido: $msg");
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final net = NetworkManager();
    final bool isConnected = net.isConnected;

    // GestureDetector na raiz permite fechar o teclado ao tocar em qualquer lugar vazio da tela
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Mesa Online (LAN)")),
        // SingleChildScrollView resolve o congelamento e permite rolar a tela se o teclado cobrir algo
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CARD DE STATUS ---
              Card(
                color: isConnected ? Colors.green[900] : Colors.grey[800],
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        isConnected 
                          ? (net.isHost ? "VOCÊ É O MESTRE (HOST)" : "VOCÊ É JOGADOR") 
                          : "DESCONECTADO",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(_status, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                      if (net.isHost)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text("Jogadores na sala: $_playersCount", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- CONTROLES DE CONEXÃO ---
              if (!isConnected) ...[
                // MODO MESTRE
                const Text("Modo Mestre", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.router, color: Colors.white),
                  label: const Text("CRIAR MESA (HOST)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[800], 
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => net.startHost(),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(color: Colors.white24, thickness: 1),
                ),
                
                // MODO JOGADOR
                const Text("Modo Jogador", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 10),
                TextField(
                  controller: _ipController,
                  textInputAction: TextInputAction.done, // Botão de "Concluído" no teclado
                  decoration: InputDecoration(
                    labelText: "IP da Mesa",
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent), borderRadius: BorderRadius.circular(8)),
                    hintText: "xxx.xxx.xxx.xxx", // Formato genérico adicionado
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(Icons.wifi, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true), // Facilita no celular
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text("ENTRAR NA MESA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800], 
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Fecha o teclado antes de conectar
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (_ipController.text.isNotEmpty) {
                      net.joinTable(_ipController.text.trim());
                    }
                  },
                ),
              ] else ...[
                // --- SE JÁ ESTIVER CONECTADO ---
                const SizedBox(height: 20),
                
                // BOTÃO PARA IR PARA O TABLETOP (MESA DE JOGO)
                SizedBox(
                  height: 65,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.table_restaurant, size: 28),
                    label: const Text("ABRIR MESA DE JOGO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                         return OnlineTabletopScreen(
                           isHost: net.isHost,
                           availableSheets: widget.sheets, 
                         );
                      }));
                    },
                  ),
                ),
                
                const SizedBox(height: 40), // Substituiu o Spacer() que quebrava o layout no mobile
                
                // BOTÃO PARA SAIR
OutlinedButton.icon(
  icon: const Icon(Icons.close, color: Colors.redAccent),
  label: const Text("SAIR DA MESA / ENCERRAR", style: TextStyle(color: Colors.redAccent)),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.all(16),
    side: const BorderSide(color: Colors.redAccent),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  onPressed: () {
    net.stop();
    // ESSA LINHA ABAIXO É A QUE LIMPA OS TOKENS E O MAPA DEFINITIVAMENTE
    OnlineTabletopScreen.clearTable(); 
    setState(() => _status = "Desconectado");
  },
),

              // --- LOGS DE DEBUG ---
              if (_logs.isNotEmpty) ...[
                const SizedBox(height: 30),
                const Text("Últimas atividades:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(_logs[i], style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'Courier')),
                    ),
                  ),
                ),
              ]
            ],
            ],
        ),
      ),
    )
    );
  }
}