<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config/db.php';

// Ambil tanggal dari GET, default hari ini
$tanggal = $_GET['tanggal'] ?? date('Y-m-d');

// Ambil semua kelas
$stmt = $pdo->query("SELECT kelas_id, nama_kelas FROM kelas");
$kelasList = $stmt->fetchAll(PDO::FETCH_ASSOC);

$result = [];

foreach ($kelasList as $kelas) {
    $kelas_id = $kelas['kelas_id'];
    $nama_kelas = $kelas['nama_kelas'];

    // Jumlah siswa per kelas
    $stmtSiswa = $pdo->prepare("SELECT COUNT(*) as total FROM murid WHERE kelas_id = :kelas_id");
    $stmtSiswa->execute([':kelas_id' => $kelas_id]);
    $jumlah_siswa = $stmtSiswa->fetch()['total'];

    // Jumlah hadir hari ini
    $stmtHadir = $pdo->prepare("
        SELECT COUNT(*) as total FROM absensi a
        JOIN murid m ON a.murid_id = m.murid_id
        WHERE a.tanggal = :tanggal AND a.jenis = 'masuk' AND m.kelas_id = :kelas_id
    ");
    $stmtHadir->execute([':tanggal' => $tanggal, ':kelas_id' => $kelas_id]);
    $jumlah_hadir = $stmtHadir->fetch()['total'];

    // Persentase kehadiran
    $persen = $jumlah_siswa > 0 ? round(($jumlah_hadir / $jumlah_siswa) * 100) : 0;

    $result[] = [
        'kelas_id' => $kelas_id,
        'nama_kelas' => $nama_kelas,
        'jumlah_siswa' => $jumlah_siswa,
        'jumlah_hadir' => $jumlah_hadir,
        'persentase_kehadiran' => $persen
    ];
}

echo json_encode([
    'success' => true,
    'data' => $result
]);