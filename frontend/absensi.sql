-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 23, 2025 at 03:48 AM
-- Server version: 8.0.30
-- PHP Version: 8.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `absensi`
--

-- --------------------------------------------------------

--
-- Table structure for table `absensi`
--

CREATE TABLE `absensi` (
  `absensi_id` int NOT NULL,
  `murid_id` int NOT NULL,
  `tanggal` date NOT NULL,
  `jenis` enum('masuk','pulang','izin','sakit','pulang_awal','alpha') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `waktu_submit` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `keterangan` text,
  `bukti_file` varchar(255) DEFAULT NULL,
  `konfirmasi_orang_tua` tinyint(1) DEFAULT '0',
  `waktu_konfirmasi` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `absensi`
--

INSERT INTO `absensi` (`absensi_id`, `murid_id`, `tanggal`, `jenis`, `waktu_submit`, `keterangan`, `bukti_file`, `konfirmasi_orang_tua`, `waktu_konfirmasi`) VALUES
(1, 2, '2025-05-21', 'izin', '2025-05-21 07:27:59', 'df', NULL, 1, '2025-06-20 02:04:03'),
(2, 2, '2025-05-27', 'masuk', '2025-05-27 07:32:01', 'Absensi masuk', NULL, 0, NULL),
(3, 2, '2025-05-27', 'pulang', '2025-05-27 07:33:37', 'Absensi pulang', NULL, 0, NULL),
(4, 2, '2025-05-28', 'masuk', '2025-05-28 06:30:08', 'Absensi masuk', NULL, 0, NULL),
(5, 2, '2025-06-17', 'masuk', '2025-06-17 06:45:25', 'Absensi masuk', NULL, 0, NULL),
(6, 2, '2025-06-17', 'pulang_awal', '2025-06-17 06:46:19', 'ada acara', NULL, 0, NULL),
(7, 2, '2025-06-18', 'masuk', '2025-06-18 01:49:46', 'Absensi masuk', NULL, 0, NULL),
(9, 2, '2025-06-18', 'pulang_awal', '2025-06-18 02:17:49', 'tes', NULL, 0, NULL),
(10, 2, '2025-06-19', 'masuk', '2025-06-19 02:45:17', 'Absensi masuk', NULL, 0, NULL),
(11, 2, '2025-06-23', 'masuk', '2025-06-23 03:42:13', 'Terlambat: telat bangun', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `kelas`
--

CREATE TABLE `kelas` (
  `kelas_id` int NOT NULL,
  `nama_kelas` varchar(50) NOT NULL,
  `tahun_ajaran` varchar(20) NOT NULL,
  `wali_kelas_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kelas`
--

INSERT INTO `kelas` (`kelas_id`, `nama_kelas`, `tahun_ajaran`, `wali_kelas_id`) VALUES
(1, 'XI RPL 1', '2023/2026', NULL),
(2, 'XI RPL 2', '2023/2026', NULL),
(3, 'XI RPL 3', '2023/2026', NULL),
(4, 'XI RPL 4', '2023/2026', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `log_aktivitas`
--

CREATE TABLE `log_aktivitas` (
  `log_id` int NOT NULL,
  `user_id` int NOT NULL,
  `aktivitas` varchar(255) NOT NULL,
  `waktu` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `murid`
--

CREATE TABLE `murid` (
  `murid_id` int NOT NULL,
  `user_id` int NOT NULL,
  `nis` varchar(20) DEFAULT NULL,
  `kelas_id` int DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `alamat` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `murid`
--

INSERT INTO `murid` (`murid_id`, `user_id`, `nis`, `kelas_id`, `tanggal_lahir`, `alamat`) VALUES
(2, 1, '232410014', 4, '2008-04-30', 'JL. Duren Jaya');

-- --------------------------------------------------------

--
-- Table structure for table `orang_tua`
--

CREATE TABLE `orang_tua` (
  `orang_tua_id` int NOT NULL,
  `user_id` int NOT NULL,
  `no_telepon` varchar(15) DEFAULT NULL,
  `alamat` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orang_tua`
--

INSERT INTO `orang_tua` (`orang_tua_id`, `user_id`, `no_telepon`, `alamat`) VALUES
(1, 3, '081282358116', 'JL. Margahayu');

-- --------------------------------------------------------

--
-- Table structure for table `relasi_orang_tua_murid`
--

CREATE TABLE `relasi_orang_tua_murid` (
  `id` int NOT NULL,
  `orang_tua_id` int NOT NULL,
  `hubungan` varchar(20) NOT NULL,
  `murid_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `relasi_orang_tua_murid`
--

INSERT INTO `relasi_orang_tua_murid` (`id`, `orang_tua_id`, `hubungan`, `murid_id`) VALUES
(1, 1, 'Orang Tua', 2);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `role` enum('guru','murid','orang_tua') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`, `nama_lengkap`, `role`, `created_at`, `updated_at`) VALUES
(1, 'Given', 'given123', 'grdgiven4@gmail.com', 'Marianus Given Talenta', 'murid', '2025-05-19 13:00:05', '2025-05-19 13:00:37'),
(2, 'Marissa', 'marissa123', 'marissadewi123@gmail.com', 'Marrisa Dewi', 'guru', '2025-05-19 13:00:05', '2025-05-19 13:00:05'),
(3, 'orangtua', 'orangtua123', 'orangtua@gmail.com', 'orangtua', 'orang_tua', '2025-06-20 01:40:30', '2025-06-20 01:40:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `absensi`
--
ALTER TABLE `absensi`
  ADD PRIMARY KEY (`absensi_id`);

--
-- Indexes for table `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`kelas_id`),
  ADD KEY `wali_kelas_id` (`wali_kelas_id`);

--
-- Indexes for table `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `murid`
--
ALTER TABLE `murid`
  ADD PRIMARY KEY (`murid_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `nis` (`nis`),
  ADD KEY `kelas_id` (`kelas_id`);

--
-- Indexes for table `orang_tua`
--
ALTER TABLE `orang_tua`
  ADD PRIMARY KEY (`orang_tua_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `relasi_orang_tua_murid`
--
ALTER TABLE `relasi_orang_tua_murid`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orang_tua_id` (`orang_tua_id`),
  ADD KEY `fk_murid_id` (`murid_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `absensi`
--
ALTER TABLE `absensi`
  MODIFY `absensi_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `kelas`
--
ALTER TABLE `kelas`
  MODIFY `kelas_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `murid`
--
ALTER TABLE `murid`
  MODIFY `murid_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `orang_tua`
--
ALTER TABLE `orang_tua`
  MODIFY `orang_tua_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `relasi_orang_tua_murid`
--
ALTER TABLE `relasi_orang_tua_murid`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `kelas`
--
ALTER TABLE `kelas`
  ADD CONSTRAINT `kelas_ibfk_1` FOREIGN KEY (`wali_kelas_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  ADD CONSTRAINT `log_aktivitas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `murid`
--
ALTER TABLE `murid`
  ADD CONSTRAINT `murid_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `murid_ibfk_2` FOREIGN KEY (`kelas_id`) REFERENCES `kelas` (`kelas_id`) ON DELETE SET NULL;

--
-- Constraints for table `orang_tua`
--
ALTER TABLE `orang_tua`
  ADD CONSTRAINT `orang_tua_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `relasi_orang_tua_murid`
--
ALTER TABLE `relasi_orang_tua_murid`
  ADD CONSTRAINT `fk_murid_id` FOREIGN KEY (`murid_id`) REFERENCES `murid` (`murid_id`),
  ADD CONSTRAINT `relasi_orang_tua_murid_ibfk_1` FOREIGN KEY (`orang_tua_id`) REFERENCES `orang_tua` (`orang_tua_id`) ON DELETE CASCADE;

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `auto_alpha_absensi` ON SCHEDULE EVERY 1 DAY STARTS '2025-06-23 12:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
  -- Insert alpha untuk murid yang belum absen masuk hari ini
  INSERT INTO absensi (murid_id, tanggal, jenis, keterangan)
  SELECT m.murid_id, CURDATE(), 'alpha', 'Otomatis alpha karena tidak absen sampai jam 12'
  FROM murid m
  WHERE NOT EXISTS (
    SELECT 1 FROM absensi a
    WHERE a.murid_id = m.murid_id
      AND a.tanggal = CURDATE()
      AND a.jenis = 'masuk'
      AND a.jenis = 'izin'
      AND a.jenis = 'sakit'

  )
  AND NOT EXISTS (
    SELECT 1 FROM absensi a2
    WHERE a2.murid_id = m.murid_id
      AND a2.tanggal = CURDATE()
      AND a2.jenis = 'alpha'
  );
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
