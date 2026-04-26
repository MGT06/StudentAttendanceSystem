<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/db.php'; // Ini akan membuat $pdo tersedia

$response = array();
$response['success'] = false;
$response['message'] = 'Terjadi kesalahan.';

try {
    // Gunakan $pdo langsung dari config.php
    $query = "SELECT kelas_id, nama_kelas FROM kelas ORDER BY nama_kelas ASC";
    $stmt = $pdo->prepare($query);
    $stmt->execute();

    $kelas = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $kelas_item = array(
            "id_kelas" => $row['kelas_id'],
            "nama_kelas" => $row['nama_kelas']
        );
        array_push($kelas, $kelas_item);
    }

    $response['success'] = true;
    $response['message'] = 'Daftar kelas berhasil dimuat.';
    $response['data'] = $kelas;

} catch (PDOException $e) {
    $response['message'] = 'Error database: ' . $e->getMessage();
}

echo json_encode($response);
?> 