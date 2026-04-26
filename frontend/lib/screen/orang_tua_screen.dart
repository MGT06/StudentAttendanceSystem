import 'package:flutter/material.dart';
import '../services/API_services.dart';
import 'login_screen.dart';

class OrangTuaScreen extends StatefulWidget {
  final Map<String, dynamic> orangTuaData;
  const OrangTuaScreen({Key? key, required this.orangTuaData}) : super(key: key);

  @override
  State<OrangTuaScreen> createState() => _OrangTuaScreenState();
}

class _OrangTuaScreenState extends State<OrangTuaScreen> {
  List<Map<String, dynamic>> _izinList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchIzinAnak();
  }

  Future<void> _fetchIzinAnak() async {
    setState(() => _isLoading = true);
    final response = await ApiServices.getIzinAnak(widget.orangTuaData['orang_tua_id']);
    setState(() {
      _isLoading = false;
      if (response['success'] == true && response['data'] != null) {
        _izinList = List<Map<String, dynamic>>.from(response['data']);
      } else {
        _izinList = [];
      }
    });
  }

  Future<void> _konfirmasiIzin(int absensiId) async {
    final response = await ApiServices.konfirmasiIzinOrtu(absensiId);
    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Konfirmasi berhasil')),
      );
      await _fetchIzinAnak();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal konfirmasi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Orang Tua', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _izinList.isEmpty
              ? const Center(child: Text('Tidak ada permintaan izin.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _izinList.length,
                  itemBuilder: (context, index) {
                    final izin = _izinList[index];
                    final namaAnak = izin['nama_lengkap'] ?? '-';
                    final tanggal = izin['tanggal'] ?? '-';
                    final keterangan = izin['keterangan'] ?? '-';
                    final konfirmasi = izin['konfirmasi_orang_tua'] == 1;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(namaAnak, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(tanggal, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Keterangan: $keterangan'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    konfirmasi ? 'Sudah Dikonfirmasi' : 'Belum Dikonfirmasi',
                                    style: TextStyle(
                                      color: konfirmasi ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: konfirmasi ? Colors.green[50] : Colors.orange[50],
                                ),
                                const Spacer(),
                                if (!konfirmasi)
                                  ElevatedButton(
                                    onPressed: () => _konfirmasiIzin(izin['absensi_id']),
                                    child: const Text('Konfirmasi'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 