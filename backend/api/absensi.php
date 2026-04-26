<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

require_once '../config/db.php';

// GET: Ambil riwayat absensi atau absensi hari ini
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $murid_id = $_GET['murid_id'] ?? '';
    $tanggal = $_GET['tanggal'] ?? '';
    
    if ($murid_id === '') {
        echo json_encode(['success' => false, 'message' => 'murid_id diperlukan']);
        exit;
    }

    try {
        if ($tanggal !== '') {
            $query = "SELECT * FROM absensi WHERE murid_id = :murid_id AND tanggal = :tanggal ORDER BY waktu_submit ASC";
            $stmt = $pdo->prepare($query);
            $stmt->execute([
                ':murid_id' => $murid_id,
                ':tanggal' => $tanggal
            ]);
        } else {
            $query = "SELECT * FROM absensi WHERE murid_id = :murid_id ORDER BY tanggal DESC, waktu_submit ASC";
            $stmt = $pdo->prepare($query);
            $stmt->execute([
                ':murid_id' => $murid_id
            ]);
        }
        
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'data' => $data]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Gagal mengambil data: ' . $e->getMessage()
        ]);
    }
    exit;
}

// POST: Simpan absensi baru
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $murid_id = $_POST['murid_id'] ?? '';
    $jenis = $_POST['jenis'] ?? '';
    $keterangan = $_POST['keterangan'] ?? '';
    $tanggal = date('Y-m-d');
    
    // Validasi input
    if (empty($murid_id) || empty($jenis)) {
        echo json_encode([
            'success' => false,
            'message' => 'Data tidak lengkap'
        ]);
        exit;
    }

    try {
        // Cek apakah sudah ada aksi absensi yang sama pada hari yang sama
        $check_query = "SELECT * FROM absensi WHERE murid_id = :murid_id AND tanggal = :tanggal AND jenis = :jenis";
        $check_stmt = $pdo->prepare($check_query);
        $check_stmt->execute([
            ':murid_id' => $murid_id,
            ':tanggal' => $tanggal,
            ':jenis' => $jenis
        ]);

        if ($check_stmt->rowCount() > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Anda sudah melakukan absensi ' . $jenis . ' hari ini'
            ]);
            exit;
        }

        // Handle file upload jika ada
        $bukti_file = null;
        if (isset($_FILES['bukti_file']) && $_FILES['bukti_file']['error'] === UPLOAD_ERR_OK) {
            $upload_dir = '../uploads/';
            if (!file_exists($upload_dir)) {
                mkdir($upload_dir, 0777, true);
            }

            $file_extension = strtolower(pathinfo($_FILES['bukti_file']['name'], PATHINFO_EXTENSION));
            $new_filename = uniqid() . '.' . $file_extension;
            $upload_path = $upload_dir . $new_filename;

            if (move_uploaded_file($_FILES['bukti_file']['tmp_name'], $upload_path)) {
                $bukti_file = $new_filename;
            }
        }

        // Insert absensi
        $query = "INSERT INTO absensi (murid_id, jenis, tanggal, keterangan, bukti_file) VALUES (:murid_id, :jenis, :tanggal, :keterangan, :bukti_file)";
        $stmt = $pdo->prepare($query);
        $stmt->execute([
            ':murid_id' => $murid_id,
            ':jenis' => $jenis,
            ':tanggal' => $tanggal,
            ':keterangan' => $keterangan,
            ':bukti_file' => $bukti_file
        ]);

        echo json_encode([
            'success' => true,
            'message' => 'Absensi berhasil disimpan'
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Gagal menyimpan absensi: ' . $e->getMessage()
        ]);
    }
} else if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode([
        'success' => false,
        'message' => 'Method tidak diizinkan'
    ]);
}
?>