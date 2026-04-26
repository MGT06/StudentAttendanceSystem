<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/db.php';

$response = array();
$response['success'] = false;
$response['message'] = 'Terjadi kesalahan.';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $absensi_id = isset($_POST['absensi_id']) ? $_POST['absensi_id'] : null;
    if (!$absensi_id) {
        echo json_encode(['success' => false, 'message' => 'Parameter absensi_id dibutuhkan.']);
        exit;
    }

    try {
        $query = "UPDATE absensi SET konfirmasi_orang_tua = 1, waktu_konfirmasi = NOW() WHERE absensi_id = :absensi_id";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':absensi_id', $absensi_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $response['success'] = true;
            $response['message'] = 'Izin berhasil dikonfirmasi.';
        } else {
            $response['message'] = 'Data tidak ditemukan atau sudah dikonfirmasi.';
        }
    } catch (PDOException $e) {
        $response['message'] = 'Error database: ' . $e->getMessage();
    }
} else {
    $response['message'] = 'Invalid request method.';
}

echo json_encode($response);
?>