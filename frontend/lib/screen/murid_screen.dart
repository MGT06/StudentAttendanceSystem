import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/API_services.dart';
import '../screen/login_screen.dart';
import 'package:geolocator/geolocator.dart';

class MuridScreen extends StatefulWidget {
  final Map<String, dynamic> muridData;
  const MuridScreen({Key? key, required this.muridData}) : super(key: key);

  @override
  State<MuridScreen> createState() => _MuridScreenState();
}

class _MuridScreenState extends State<MuridScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _absensiHariIni = [];
  List<Map<String, dynamic>> _riwayatAbsensi = [];
  bool _isLoadingRiwayat = false;

  final double sekolahLat = -6.252915153626877; // Ganti dengan latitude sekolah
  final double sekolahLng = 107.06096700833123; // Ganti dengan longitude sekolah
  final double maxDistanceMeter = 150; // Radius area sekolah dalam meter

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAbsensiHariIni();
    _fetchRiwayatAbsensi();
  }

  Future<void> _pickFile() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _selectedFile = File(file.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Murid',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profil'),
            Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Absensi'),
            Tab(icon: Icon(Icons.history_outlined), text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfilTab(),
          _buildAbsensiTab(),
          _buildRiwayatTab(),
        ],
      ),
    );
  }

  Widget _buildProfilTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Informasi Pribadi',
            children: [
              _buildInfoItem(Icons.person, 'Nama', widget.muridData['nama_lengkap'] ?? '-'),
              _buildInfoItem(Icons.badge, 'NIS', widget.muridData['nis'] ?? '-'),
              _buildInfoItem(Icons.class_, 'Kelas', widget.muridData['kelas'] ?? '-'),
              _buildInfoItem(Icons.date_range, 'Tanggal Lahir', widget.muridData['tanggal_lahir'] ?? '-'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Kontak',
            children: [
              _buildInfoItem(Icons.location_on, 'Alamat', widget.muridData['alamat'] ?? '-'),
              _buildInfoItem(Icons.phone, 'No. Telepon', widget.muridData['no_telepon'] ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Absensi Hari Ini',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAbsensiButton(
                        'Masuk',
                        Icons.login,
                        const Color(0xFF4CAF50),
                      ),
                      _buildAbsensiButton(
                        'Pulang',
                        Icons.logout,
                        const Color(0xFFF44336),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Keterangan Khusus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeteranganButton(
                        'Izin',
                        Icons.event_busy,
                        const Color(0xFFFFA000),
                        () => _showKeteranganDialog('Izin'),
                      ),
                      _buildKeteranganButton(
                        'Sakit',
                        Icons.medical_services,
                        const Color(0xFFE91E63),
                        () => _showKeteranganDialog('Sakit'),
                      ),
                      _buildKeteranganButton(
                        'Pulang Awal',
                        Icons.directions_walk,
                        const Color(0xFF9C27B0),
                        () => _showKeteranganDialog('Pulang Awal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Status Kehadiran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._absensiHariIni.map((absen) {
            if (absen['jenis'] == 'masuk' || absen['jenis'] == 'pulang' || absen['jenis'] == 'pulang_awal') {
              String? alasanTelat;
              if (absen['jenis'] == 'masuk' && absen['keterangan'] != null && absen['keterangan'].toString().toLowerCase().contains('terlambat')) {
                alasanTelat = absen['keterangan'];
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(
                    absen['jenis'].toString().capitalize(),
                    absen['waktu_submit'] != null ? absen['waktu_submit'].toString().substring(11, 16) : '-',
                    'Tercatat',
                    absen['jenis'] == 'masuk' ? const Color(0xFF4CAF50)
                      : absen['jenis'] == 'pulang' ? const Color(0xFFF44336)
                      : const Color(0xFF9C27B0),
                  ),
                  if (alasanTelat != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              alasanTelat,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            } else {
              return _buildKeteranganStatusCard(
                absen['jenis'].toString().capitalize(),
                absen['keterangan'] ?? '-',
                absen['jenis'] == 'izin'
                    ? const Color(0xFFFFA000)
                    : absen['jenis'] == 'sakit'
                        ? const Color(0xFFE91E63)
                        : const Color(0xFF9C27B0),
              );
            }
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRiwayatTab() {
    if (_isLoadingRiwayat) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final riwayatSebelumHariIni = _riwayatAbsensi.where((absen) {
      final absenDate = DateTime.parse(absen['tanggal']);
      return absenDate.isBefore(today);
    }).toList();

    // Kelompokkan masuk, pulang, pulang_awal per tanggal
    final Map<String, Map<String, dynamic>> grouped = {};
    // List untuk izin/sakit
    final List<Map<String, dynamic>> izinSakitList = [];

    for (var absen in riwayatSebelumHariIni) {
      final tanggal = absen['tanggal'];
      if (absen['jenis'] == 'izin' || absen['jenis'] == 'sakit') {
        izinSakitList.add(absen);
      } else {
        grouped.putIfAbsent(tanggal, () => {'masuk': null, 'pulang': null, 'pulang_awal': null, 'alpha': null, 'tanggal': tanggal});
        if (absen['jenis'] == 'masuk') {
          grouped[tanggal]!['masuk'] = absen;
        } else if (absen['jenis'] == 'pulang') {
          grouped[tanggal]!['pulang'] = absen;
        } else if (absen['jenis'] == 'pulang_awal') {
          grouped[tanggal]!['pulang_awal'] = absen;
        } else if (absen['jenis'] == 'alpha') {
          grouped[tanggal]!['alpha'] = absen;
        }
      }
    }

    // Gabungkan dan urutkan semua tanggal
    final sortedTanggal = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    izinSakitList.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

    if (grouped.isEmpty && izinSakitList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat absensi',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Card masuk-pulang-pulang_awal
        ...sortedTanggal.map((tanggal) {
          final data = grouped[tanggal]!;
          final masuk = data['masuk'];
          final pulang = data['pulang'];
          final pulangAwal = data['pulang_awal'];
          final alpha = data['alpha'];
          final tgl = DateTime.parse(tanggal);
          final formattedDate = "${tgl.day.toString().padLeft(2, '0')}-${tgl.month.toString().padLeft(2, '0')}-${tgl.year}";

          if (alpha != null) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                constraints: const BoxConstraints(minHeight: 80),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.red, size: 32),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alpha - $formattedDate',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (alpha['keterangan'] != null && alpha['keterangan'].toString().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              alpha['keterangan'],
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(minHeight: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tanggal: $formattedDate',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeInfo(
                            'Masuk',
                            masuk != null && masuk['waktu_submit'] != null
                                ? masuk['waktu_submit'].toString().substring(11, 16)
                                : '-',
                          ),
                          if (masuk != null && masuk['keterangan'] != null && masuk['keterangan'].toString().toLowerCase().contains('terlambat'))
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    masuk['keterangan'],
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      _buildTimeInfo(
                        'Pulang',
                        pulang != null && pulang['waktu_submit'] != null
                            ? pulang['waktu_submit'].toString().substring(11, 16)
                            : pulangAwal != null && pulangAwal['waktu_submit'] != null
                                ? pulangAwal['waktu_submit'].toString().substring(11, 16)
                                : '-',
                      ),
                    ],
                  ),
                  if (pulangAwal != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color:  Color(0xFF9C27B0)),
                        const SizedBox(width: 6),
                        const Text(
                          'Pulang Awal',
                          style: TextStyle(
                            color:  Color(0xFF9C27B0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pulangAwal['keterangan'] != null && pulangAwal['keterangan'].toString().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            pulangAwal['keterangan'],
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        // Card izin/sakit
        ...izinSakitList.map((absen) {
          final tgl = DateTime.parse(absen['tanggal']);
          final formattedDate = "${tgl.day.toString().padLeft(2, '0')}-${tgl.month.toString().padLeft(2, '0')}-${tgl.year}";
          IconData icon;
          Color color;
          String label;
          if (absen['jenis'] == 'izin') {
            icon = Icons.event_busy;
            color = const Color(0xFFFFA000);
            label = 'Izin';
          } else {
            icon = Icons.medical_services;
            color = const Color(0xFFE91E63);
            label = 'Sakit';
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(minHeight: 100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$label - $formattedDate',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (absen['keterangan'] != null && absen['keterangan'].toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            absen['keterangan'],
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (label == 'Masuk' || label == 'Pulang') {
          bool inArea = await _isInSchoolArea();
          if (!inArea) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anda harus berada di area sekolah untuk absen Masuk/Pulang!')),
            );
            return;
          }
        }
        if (label == 'Masuk') {
          final now = DateTime.now();
          final jamTelat = DateTime(now.year, now.month, now.day, 7, 0);
          if (now.isAfter(jamTelat)) {
            // Tampilkan dialog alasan telat
            final alasanController = TextEditingController();
            final alasan = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Alasan Telat'),
                content: TextField(
                  controller: alasanController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alasan kenapa telat',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (alasanController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alasan telat wajib diisi!')),
                        );
                        return;
                      }
                      Navigator.pop(context, alasanController.text);
                    },
                    child: const Text('Kirim'),
                  ),
                ],
              ),
            );
            if (alasan == null || alasan.isEmpty) return;
            final response = await ApiServices.submitAbsensi(
              muridId: widget.muridData['murid_id'],
              jenis: 'masuk',
              keterangan: 'Terlambat: $alasan',
            );
            if (response['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'] ?? 'Absensi berhasil disimpan')),
              );
              await _fetchAbsensiHariIni();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'] ?? 'Gagal menyimpan absensi')),
              );
            }
            return;
          }
        }
        if (label == 'Pulang') {
          final now = DateTime.now();
          final jamPulang = DateTime(now.year, now.month, now.day, 15, 20);
          if (now.isBefore(jamPulang)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Absen pulang hanya bisa dilakukan mulai jam 15.20!')),
            );
            return;
          }
        }
        if (label == 'Masuk' || label == 'Pulang') {
          final response = await ApiServices.submitAbsensi(
            muridId: widget.muridData['murid_id'],
            jenis: label.toLowerCase(),
            keterangan: 'Absensi ${label.toLowerCase()}',
          );

          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Absensi berhasil disimpan')),
            );
            await _fetchAbsensiHariIni();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Gagal menyimpan absensi')),
            );
          }
        }
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }

  Widget _buildStatusCard(String type, String time, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(type == 'Masuk' ? Icons.login : Icons.logout, color: color),
        ),
        title: Text(type),
        subtitle: Text(time),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Tepat Waktu' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == 'Tepat Waktu' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  bool _hasAbsenMasuk() {
    return _absensiHariIni.any((absen) => absen['jenis'] == 'masuk');
  }

  Widget _buildKeteranganButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    bool isDisabled = false;
    if (_hasAbsenMasuk()) {
      if (label == 'Izin' || label == 'Sakit') {
        isDisabled = true;
      }
    }

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : () {
        if (label == 'Sakit') {
          _showKeteranganDialog('Sakit');
        } else if (label == 'Izin') {
          _showKeteranganDialog('Izin');
        } else if (label == 'Pulang Awal') {
          _showKeteranganDialog('Pulang Awal');
        }
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildKeteranganStatusCard(String type, String keterangan, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    type == 'Izin' ? Icons.event_busy :
                    type == 'Sakit' ? Icons.medical_services :
                    Icons.directions_walk,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keterangan:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    keterangan,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeteranganDialog(String type) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keterangan $type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Masukkan keterangan $type',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              if (type == 'Sakit') ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_selectedFile != null 
                    ? 'File Terpilih: ${_selectedFile!.path.split('/').last}'
                    : 'Upload Surat Sakit'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFile = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (type == 'Sakit' && _selectedFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harap upload surat sakit')),
                );
                return;
              }
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harap isi keterangan')),
                );
                return;
              }

              final response = await ApiServices.submitAbsensi(
                muridId: widget.muridData['murid_id'],
                jenis: type == 'Pulang Awal' ? 'pulang_awal' : type.toLowerCase(),
                keterangan: controller.text,
                buktiFile: _selectedFile,
              );

              if (response['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? 'Absensi berhasil disimpan')),
                );
                setState(() {
                  _selectedFile = null;
                });
                Navigator.pop(context);
                await _fetchAbsensiHariIni();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? 'Gagal menyimpan absensi')),
                );
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAbsensiHariIni() async {
    final now = DateTime.now();
    final tanggal = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final response = await ApiServices.getRiwayatAbsensi(widget.muridData['murid_id'], tanggal: tanggal);
    if (response['success'] == true && response['data'] != null) {
      setState(() {
        _absensiHariIni = List<Map<String, dynamic>>.from(response['data']);
      });
    }
  }

  Future<void> _fetchRiwayatAbsensi() async {
    setState(() {
      _isLoadingRiwayat = true;
    });

    final response = await ApiServices.getRiwayatAbsensi(widget.muridData['murid_id']);
    
    setState(() {
      _isLoadingRiwayat = false;
      if (response['success'] == true && response['data'] != null) {
        _riwayatAbsensi = List<Map<String, dynamic>>.from(response['data']);
      } else {
        _riwayatAbsensi = [];
      }
    });
  }

  Color _getStatusColor(String jenis) {
    switch (jenis) {
      case 'masuk':
        return const Color(0xFF4CAF50);
      case 'pulang':
        return const Color(0xFFF44336);
      case 'izin':
        return const Color(0xFFFFA000);
      case 'sakit':
        return const Color(0xFFE91E63);
      case 'pulang_awal':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  Map<String, Map<String, dynamic>> _groupAbsensiMasukPulang(List<Map<String, dynamic>> data) {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (var absen in data) {
      final tanggal = absen['tanggal'];
      if (!grouped.containsKey(tanggal)) {
        grouped[tanggal] = {'masuk': null, 'pulang': null, 'tanggal': tanggal};
      }
      if (absen['jenis'] == 'masuk') {
        grouped[tanggal]!['masuk'] = absen;
      } else if (absen['jenis'] == 'pulang') {
        grouped[tanggal]!['pulang'] = absen;
      } else if (absen['jenis'] == 'pulang_awal') {
        grouped[tanggal]!['pulang_awal'] = absen;
      }
    }
    return grouped;
  }

  Future<bool> _isInSchoolArea() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      sekolahLat,
      sekolahLng,
    );

    return distance <= maxDistanceMeter;
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
