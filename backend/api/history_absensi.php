<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/db.php'; // Ini akan membuat $pdo tersedia

$response = array();
$response['success'] = false;
$response['message'] = 'Terjadi kesalahan.';

// Tambahan: Endpoint untuk daftar izin
if (isset($_GET['izin_list']) && $_GET['izin_list'] == '1') {
    try {
        $query = "SELECT
                    a.absensi_id,
                    a.murid_id,
                    a.tanggal,
                    a.jenis,
                    a.keterangan,
                    a.konfirmasi_orang_tua,
                    a.waktu_konfirmasi,
                    m.nis,
                    u.nama_lengkap
                  FROM absensi a
                  JOIN murid m ON a.murid_id = m.murid_id
                  JOIN users u ON m.user_id = u.user_id
                  WHERE a.jenis = 'izin'
                  ORDER BY a.tanggal DESC";
        $stmt = $pdo->prepare($query);
        $stmt->execute();

        $izinList = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $response['success'] = true;
        $response['data'] = $izinList;
    } catch (PDOException $e) {
        $response['message'] = 'Error database: ' . $e->getMessage();
    }
    echo json_encode($response);
    exit;
}

// Pastikan request method adalah GET
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Ambil parameter tanggal dari query string
    $tanggal = isset($_GET['tanggal']) ? $_GET['tanggal'] : die(json_encode(array("message" => "Parameter 'tanggal' dibutuhkan.")));
    $kelas_id = isset($_GET['id_kelas']) ? $_GET['id_kelas'] : null; // Menggunakan id_kelas dari Flutter

    try {
        $query = "SELECT
                      k.kelas_id,
                      k.nama_kelas,
                      COUNT(m.murid_id) AS jumlah_siswa_kelas,
                      SUM(
                          CASE 
                              WHEN EXISTS (
                                  SELECT 1 FROM absensi a2 
                                  WHERE a2.murid_id = m.murid_id 
                                    AND a2.tanggal = :tanggal 
                                    AND (a2.jenis = 'masuk' OR a2.jenis = 'pulang')
                              ) THEN 1 ELSE 0 
                          END
                      ) AS hadir,
                      SUM(
                          CASE 
                              WHEN EXISTS (
                                  SELECT 1 FROM absensi a2 
                                  WHERE a2.murid_id = m.murid_id 
                                    AND a2.tanggal = :tanggal 
                                    AND a2.jenis = 'izin'
                              ) THEN 1 ELSE 0 
                          END
                      ) AS izin,
                      SUM(
                          CASE 
                              WHEN EXISTS (
                                  SELECT 1 FROM absensi a2 
                                  WHERE a2.murid_id = m.murid_id 
                                    AND a2.tanggal = :tanggal 
                                    AND a2.jenis = 'sakit'
                              ) THEN 1 ELSE 0 
                          END
                      ) AS sakit,
                      SUM(
                          CASE 
                              WHEN EXISTS (
                                  SELECT 1 FROM absensi a2 
                                  WHERE a2.murid_id = m.murid_id 
                                    AND a2.tanggal = :tanggal 
                                    AND a2.jenis = 'alpha'
                              ) THEN 1 ELSE 0 
                          END
                      ) AS alpha
                  FROM
                      kelas k
                  LEFT JOIN
                      murid m ON k.kelas_id = m.kelas_id
                  ";
        $params = array(':tanggal' => $tanggal);
        if ($kelas_id) {
            $query .= " WHERE k.kelas_id = :kelas_id ";
            $params[':kelas_id'] = $kelas_id;
        }
        $query .= " GROUP BY k.kelas_id, k.nama_kelas ORDER BY k.nama_kelas ASC";

        $stmt = $pdo->prepare($query);
        $stmt->execute($params);

        $history = array();
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $absensi_detail = array(
                "hadir" => (int)$row['hadir'],
                "izin" => (int)$row['izin'],
                "sakit" => (int)$row['sakit'],
                "alpha" => (int)$row['alpha']
            );

            // Ambil detail absensi per siswa untuk kelas dan tanggal ini
            $murid_query = "SELECT 
                                u.nama_lengkap, 
                                a.jenis, 
                                a.keterangan, 
                                a.waktu_submit 
                            FROM murid m
                            LEFT JOIN users u ON m.user_id = u.user_id
                            LEFT JOIN absensi a ON a.murid_id = m.murid_id AND a.tanggal = :tanggal
                            WHERE m.kelas_id = :kelas_id";
            $murid_stmt = $pdo->prepare($murid_query);
            $murid_stmt->execute([
                ':tanggal' => $tanggal,
                ':kelas_id' => $row['kelas_id']
            ]);
            $detail = $murid_stmt->fetchAll(PDO::FETCH_ASSOC);

            $history_item = array(
                "id_kelas" => $row['kelas_id'],
                "nama_kelas" => $row['nama_kelas'],
                "jumlah_siswa_kelas" => (int)$row['jumlah_siswa_kelas'],
                "absensi_detail" => $absensi_detail,
                "detail" => $detail // <-- tambahkan ini
            );
            array_push($history, $history_item);
        }

        $response['success'] = true;
        $response['message'] = 'Riwayat absensi berhasil dimuat.';
        $response['data'] = $history;

    } catch (PDOException $e) {
        $response['message'] = 'Error database: ' . $e->getMessage();
    }
} else {
    $response['message'] = 'Invalid request method.';
}

echo json_encode($response);
?>