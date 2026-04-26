<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/db.php';

$response = array();
$response['success'] = false;
$response['message'] = 'Terjadi kesalahan.';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $orang_tua_id = isset($_GET['orang_tua_id']) ? $_GET['orang_tua_id'] : null;
    if (!$orang_tua_id) {
        echo json_encode(['success' => false, 'message' => 'Parameter orang_tua_id dibutuhkan.']);
        exit;
    }

    try {
        // Ambil semua murid_id yang terhubung dengan orang_tua_id ini
        $query = "SELECT m.murid_id, u.nama_lengkap
                  FROM relasi_orang_tua_murid r
                  JOIN murid m ON r.murid_id = m.murid_id
                  JOIN users u ON m.user_id = u.user_id
                  WHERE r.orang_tua_id = :orang_tua_id";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':orang_tua_id', $orang_tua_id);
        $stmt->execute();

        $muridList = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (!$muridList) {
            $response['success'] = true;
            $response['data'] = [];
            echo json_encode($response);
            exit;
        }

        $izinList = [];
        foreach ($muridList as $murid) {
            $murid_id = $murid['murid_id'];
            $nama_lengkap = $murid['nama_lengkap'];

            // Ambil absensi izin untuk murid ini
            $q2 = "SELECT absensi_id, tanggal, keterangan, konfirmasi_orang_tua
                   FROM absensi
                   WHERE murid_id = :murid_id AND jenis = 'izin'
                   ORDER BY tanggal DESC";
            $s2 = $pdo->prepare($q2);
            $s2->bindParam(':murid_id', $murid_id);
            $s2->execute();

            while ($izin = $s2->fetch(PDO::FETCH_ASSOC)) {
                $izin['nama_lengkap'] = $nama_lengkap;
                $izinList[] = $izin;
            }
        }

        $response['success'] = true;
        $response['data'] = $izinList;
    } catch (PDOException $e) {
        $response['message'] = 'Error database: ' . $e->getMessage();
    }
} else {
    $response['message'] = 'Invalid request method.';
}

echo json_encode($response);
?>