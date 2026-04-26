<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config/db.php';

// Ambil tanggal dari GET, default hari ini
$tanggal = $_GET['tanggal'] ?? date('Y-m-d');

// Total murid
$stmt = $pdo->query("SELECT COUNT(*) as total FROM murid");
$total_murid = $stmt->fetch()['total'];

// Hadir (masuk)
$stmt = $pdo->prepare("SELECT COUNT(*) as total FROM absensi WHERE jenis = 'masuk' AND tanggal = :tanggal");
$stmt->execute([':tanggal' => $tanggal]);
$hadir = $stmt->fetch()['total'];

// Izin
$stmt = $pdo->prepare("SELECT COUNT(*) as total FROM absensi WHERE jenis = 'izin' AND tanggal = :tanggal");
$stmt->execute([':tanggal' => $tanggal]);
$izin = $stmt->fetch()['total'];

// Sakit
$stmt = $pdo->prepare("SELECT COUNT(*) as total FROM absensi WHERE jenis = 'sakit' AND tanggal = :tanggal");
$stmt->execute([':tanggal' => $tanggal]);
$sakit = $stmt->fetch()['total'];

// Alpha (tidak ada absensi masuk/izin/sakit pada tanggal tsb)
$stmt = $pdo->prepare("
    SELECT COUNT(*) as total FROM murid m
    WHERE NOT EXISTS (
        SELECT 1 FROM absensi a
        WHERE a.murid_id = m.murid_id
        AND a.tanggal = :tanggal
        AND a.jenis IN ('masuk','izin','sakit')
    )
");
$stmt->execute([':tanggal' => $tanggal]);
$alpha = $stmt->fetch()['total'];

echo json_encode([
    'success' => true,
    'data' => [
        'hadir' => $hadir,
        'izin' => $izin,
        'sakit' => $sakit,
        'alpha' => $alpha,
        'total_murid' => $total_murid,
        'tanggal' => $tanggal
    ]
]);