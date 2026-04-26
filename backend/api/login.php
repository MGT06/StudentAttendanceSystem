<?php
header('Content-Type: application/json');
require_once '../config/db.php'; // pastikan file koneksi sudah benar

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode([
        'success' => false,
        'message' => 'Username dan password wajib diisi'
    ]);
    exit;
}

// Cek user di database
$query = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$query->execute([$username]);
$user = $query->fetch(PDO::FETCH_ASSOC);

if ($user && $password == $user['password']) {
    $response = [
        'success' => true,
        'role' => $user['role'],
        'message' => 'Login berhasil'
    ];

    if ($user['role'] == 'murid') {
        $stmt = $pdo->prepare("
            SELECT 
                m.*, 
                u.nama_lengkap, 
                k.nama_kelas AS kelas
            FROM murid m
            JOIN users u ON m.user_id = u.user_id
            LEFT JOIN kelas k ON m.kelas_id = k.kelas_id
            WHERE m.user_id = ?
        ");
        $stmt->execute([$user['user_id']]);
        $murid = $stmt->fetch(PDO::FETCH_ASSOC);
        $response['murid'] = $murid;
    } else if ($user['role'] == 'orang_tua') {
        $stmt = $pdo->prepare("SELECT * FROM orang_tua WHERE user_id = ?");
        $stmt->execute([$user['user_id']]);
        $orang_tua = $stmt->fetch(PDO::FETCH_ASSOC);
        $response['orang_tua'] = $orang_tua;
    }
    // Untuk guru, cukup role dan message saja

    echo json_encode($response);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Username atau password salah'
    ]);
}