import 'package:flutter/material.dart';
import '../screen/login_screen.dart';
import '../services/API_services.dart';
import '../widgets/stat_card.dart';
import '../widgets/kelas_card.dart';
import '../widgets/absensi_row.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GuruScreen extends StatefulWidget {
  const GuruScreen({Key? key}) : super(key: key);

  @override
  State<GuruScreen> createState() => _GuruScreenState();
}

class _GuruScreenState extends State<GuruScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _summary;
  bool _isLoadingSummary = false;
  List<Map<String, dynamic>> _kelasAktif = [];
  bool _isLoadingKelas = false;

  String? _selectedKelasId;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _kelasList = [];
  bool _isLoadingHistory = false;
  List<Map<String, dynamic>> _absensiHistory = [];

  // Tambahan untuk tab izin
  List<Map<String, dynamic>> _izinList = [];
  bool _isLoadingIzin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAbsensiSummary();
    _fetchKelasAktif();
    _fetchKelasList();
    _fetchAbsensiHistory();
    _fetchIzinList();
  }

  Future<void> _fetchAbsensiSummary() async {
    setState(() => _isLoadingSummary = true);
    final response = await ApiServices.getAbsensiSummary();
    setState(() {
      _isLoadingSummary = false;
      if (response['success'] == true) {
        _summary = response['data'];
      }
    });
  }

  Future<void> _fetchKelasAktif() async {
    setState(() => _isLoadingKelas = true);
    final now = DateTime.now();
    final tanggal =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final data = await ApiServices.getKelasAktifSummary(tanggal: tanggal);
    setState(() {
      _kelasAktif = data;
      _isLoadingKelas = false;
    });
  }

  Future<void> _fetchKelasList() async {
    final data = await ApiServices.getKelasList();
    setState(() {
      _kelasList = data;
      if (_kelasList.isNotEmpty) {
        _selectedKelasId = _kelasList.first['id_kelas'].toString();
      }
    });
  }

  Future<void> _fetchAbsensiHistory() async {
    setState(() => _isLoadingHistory = true);
    final tanggal =
        "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final data = await ApiServices.getAbsensiHistory(
      tanggal: tanggal,
      idKelas: _selectedKelasId,
    );
    setState(() {
      _absensiHistory = data;
      _isLoadingHistory = false;
    });
  }

  Future<void> _fetchIzinList() async {
    setState(() => _isLoadingIzin = true);
    final data = await ApiServices.getDaftarIzin();
    setState(() {
      _izinList = data;
      _isLoadingIzin = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _exportAbsensiHistoryPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Riwayat Absensi',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              ..._absensiHistory.map((kelasData) {
                final kelasName = kelasData['nama_kelas'];
                final totalSiswa = kelasData['jumlah_siswa_kelas'];
                final absensiDetail = kelasData['detail'];
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('$kelasName ($totalSiswa Siswa)',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Bullet(text: 'Hadir: ${absensiDetail['hadir']}'),
                    pw.Bullet(text: 'Izin: ${absensiDetail['izin']}'),
                    pw.Bullet(text: 'Sakit: ${absensiDetail['sakit']}'),
                    pw.Bullet(text: 'Alpha: ${absensiDetail['alpha']}'),
                    pw.SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _exportKelasPDF(Map<String, dynamic> kelasData) async {
    final pdf = pw.Document();
    final kelasName = kelasData['nama_kelas'];
    final totalSiswa = kelasData['jumlah_siswa_kelas'];
    final List<dynamic> detailList = kelasData['detail'] ??
        []; // Pastikan backend mengirim list detail absensi per siswa

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rekap Absensi $kelasName',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Jumlah Siswa: $totalSiswa'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Nama', 'Jenis', 'Keterangan', 'Waktu'],
                data: detailList
                    .map((item) => [
                          item['nama_lengkap'] ?? '-',
                          (item['jenis'] ?? '-').toString().toUpperCase(),
                          item['keterangan'] ?? '-',
                          item['waktu_submit'] ?? '-',
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 10),
                border: pw.TableBorder.all(),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Guru',
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
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Beranda'),
            Tab(icon: Icon(Icons.history_outlined), text: 'Riwayat'),
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Izin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBerandaTab(),
          _buildRiwayatTab(),
          _buildIzinTab(),
        ],
      ),
    );
  }

  Widget _buildBerandaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rangkuman Kehadiran',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoadingSummary)
            const Center(child: CircularProgressIndicator())
          else if (_summary != null)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                    title: 'Hadir',
                    value: _summary!['hadir'].toString(),
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF4CAF50)),
                StatCard(
                    title: 'Izin',
                    value: _summary!['izin'].toString(),
                    icon: Icons.event_busy,
                    color: const Color(0xFFFFA000)),
                StatCard(
                    title: 'Sakit',
                    value: _summary!['sakit'].toString(),
                    icon: Icons.medical_services,
                    color: const Color(0xFFE91E63)),
                StatCard(
                    title: 'Alpha',
                    value: _summary!['alpha'].toString(),
                    icon: Icons.cancel_outlined,
                    color: const Color(0xFFF44336)),
              ]
                  .map((card) => SizedBox(
                        width: (MediaQuery.of(context).size.width - 16 * 3) /
                            2, // 2 kolom, 16 padding kiri-kanan dan spacing
                        child: card,
                      ))
                  .toList(),
            )
          else
            const Text('Gagal memuat data rangkuman.'),
          const SizedBox(height: 32),
          const Text(
            'Kelas Aktif',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingKelas)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: _kelasAktif
                  .map((kelas) => KelasCard(
                        kelas: kelas['nama_kelas'],
                        jumlahSiswa: "${kelas['jumlah_siswa']} Siswa",
                        kehadiran:
                            "${kelas['persentase_kehadiran']}% Kehadiran",
                        color: const Color(0xFF2196F3),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Absensi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 16),
          if (_isLoadingHistory)
            const Center(child: CircularProgressIndicator())
          else if (_absensiHistory.isNotEmpty)
            _buildKelasList()
          else
            const Center(child: Text('Tidak ada data riwayat absensi.')),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Semua Kelas')),
                      ..._kelasList
                          .map((kelas) => DropdownMenuItem(
                                value: kelas['id_kelas'].toString(),
                                child: Text(kelas['nama_kelas']),
                              ))
                          .toList(),
                    ],
                    value: _selectedKelasId,
                    onChanged: (value) {
                      setState(() {
                        _selectedKelasId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: "${_selectedDate.day.toString().padLeft(2, '0')}-"
                          "${_selectedDate.month.toString().padLeft(2, '0')}-"
                          "${_selectedDate.year.toString().padLeft(4, '0')}",
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportAbsensiHistoryPDF,
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKelasList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _absensiHistory.length,
      itemBuilder: (context, index) {
        final kelasData = _absensiHistory[index];
        final kelasName = kelasData['nama_kelas'];
        final totalSiswa = kelasData['jumlah_siswa_kelas'];
        final absensiDetail = kelasData['absensi_detail'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.class_,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              kelasName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('$totalSiswa Siswa'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AbsensiRow(
                        label: 'Hadir',
                        value: absensiDetail['hadir'].toString(),
                        color: const Color(0xFF4CAF50)),
                    AbsensiRow(
                        label: 'Izin',
                        value: absensiDetail['izin'].toString(),
                        color: const Color(0xFFFFA000)),
                    AbsensiRow(
                        label: 'Sakit',
                        value: absensiDetail['sakit'].toString(),
                        color: const Color(0xFFE91E63)),
                    AbsensiRow(
                        label: 'Alpha',
                        value: absensiDetail['alpha'].toString(),
                        color: const Color(0xFFF44336)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _exportKelasPDF(kelasData),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export PDF'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIzinTab() {
    return RefreshIndicator(
      onRefresh: _fetchIzinList,
      child: _isLoadingIzin
          ? const Center(child: CircularProgressIndicator())
          : _izinList.isEmpty
              ? const Center(child: Text('Tidak ada data izin.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _izinList.length,
                  itemBuilder: (context, index) {
                    final izin = _izinList[index];
                    final namaMurid = izin['nama_lengkap'] ?? '-';
                    final tanggal = izin['tanggal'] ?? '-';
                    final keterangan = izin['keterangan'] ?? '-';
                    final jenis = izin['jenis'] ?? '-';
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
                                Icon(Icons.person,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(namaMurid,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(tanggal,
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(jenis.toString().toUpperCase()),
                                  backgroundColor: jenis == 'izin'
                                      ? Colors.orange[50]
                                      : jenis == 'sakit'
                                          ? Colors.pink[50]
                                          : Colors.blue[50],
                                  labelStyle: TextStyle(
                                    color: jenis == 'izin'
                                        ? Colors.orange
                                        : jenis == 'sakit'
                                            ? Colors.pink
                                            : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    konfirmasi
                                        ? 'Sudah Dikonfirmasi'
                                        : 'Belum Dikonfirmasi',
                                    style: TextStyle(
                                      color: konfirmasi
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: konfirmasi
                                      ? Colors.green[50]
                                      : Colors.orange[50],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Keterangan: $keterangan'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
