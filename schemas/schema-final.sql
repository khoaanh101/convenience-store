-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: cuahangtienloi
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ca_lam_viec`
--

DROP TABLE IF EXISTS `ca_lam_viec`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ca_lam_viec` (
  `MaCLV` varchar(10) NOT NULL,
  `GioBatDau` time NOT NULL,
  `GioKetThuc` time NOT NULL,
  PRIMARY KEY (`MaCLV`),
  CONSTRAINT `CK_CA_LAM_VIEC` CHECK ((`GioKetThuc` <> `GioBatDau`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chi_tiet_hoa_don`
--

DROP TABLE IF EXISTS `chi_tiet_hoa_don`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chi_tiet_hoa_don` (
  `MaCTHD` varchar(20) NOT NULL,
  `MaHD` varchar(20) NOT NULL,
  `MaHH` varchar(10) NOT NULL,
  `SoLuong` int NOT NULL,
  `Gia` decimal(12,2) NOT NULL,
  `ThanhTien` decimal(22,2) GENERATED ALWAYS AS ((`SoLuong` * `Gia`)) STORED,
  PRIMARY KEY (`MaCTHD`),
  UNIQUE KEY `UQ_HD_HH` (`MaHD`,`MaHH`),
  KEY `FK_CTHD_HANG_HOA` (`MaHH`),
  CONSTRAINT `FK_CTHD_HANG_HOA` FOREIGN KEY (`MaHH`) REFERENCES `hang_hoa` (`MaHH`) ON UPDATE CASCADE,
  CONSTRAINT `FK_CTHD_HOA_DON` FOREIGN KEY (`MaHD`) REFERENCES `hoa_don` (`MaHD`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `CK_CTHD_Gia` CHECK ((`Gia` >= 0)),
  CONSTRAINT `CK_CTHD_SoLuong` CHECK ((`SoLuong` > 0)),
  CONSTRAINT `CK_CTHD_ThanhTien` CHECK ((`ThanhTien` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chuc_vu`
--

DROP TABLE IF EXISTS `chuc_vu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuc_vu` (
  `MaCV` varchar(10) NOT NULL,
  `TenCV` varchar(50) NOT NULL,
  `LuongCoBan` decimal(12,2) NOT NULL,
  PRIMARY KEY (`MaCV`),
  UNIQUE KEY `uq_chuc_vu_tencv` (`TenCV`),
  CONSTRAINT `ck_chuc_vu_luong` CHECK ((`LuongCoBan` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hang_hoa`
--

DROP TABLE IF EXISTS `hang_hoa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hang_hoa` (
  `MaHH` varchar(10) NOT NULL,
  `TenHang` varchar(100) NOT NULL,
  `Loai` varchar(50) NOT NULL,
  `Gia` decimal(12,2) NOT NULL,
  `HSD` date DEFAULT NULL,
  `SoLuongHangTonKho` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`MaHH`),
  KEY `idx_hh_tenhang` (`TenHang`),
  KEY `idx_hh_hsd` (`HSD`),
  CONSTRAINT `ck_hh_gia` CHECK ((`Gia` >= 0)),
  CONSTRAINT `ck_hh_soluong` CHECK ((`SoLuongHangTonKho` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hoa_don`
--

DROP TABLE IF EXISTS `hoa_don`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hoa_don` (
  `MaHD` varchar(20) NOT NULL,
  `MaPK` varchar(10) NOT NULL,
  `MaKH` varchar(10) DEFAULT NULL,
  `ThoiGian` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`MaHD`),
  KEY `fk_hd_pcc` (`MaPK`),
  KEY `fk_hd_kh` (`MaKH`),
  KEY `idx_hd_thoigian` (`ThoiGian`),
  CONSTRAINT `fk_hd_kh` FOREIGN KEY (`MaKH`) REFERENCES `khach_hang` (`MaKH`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_hd_pcc` FOREIGN KEY (`MaPK`) REFERENCES `phan_cong_ca` (`MaPK`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `khach_hang`
--

DROP TABLE IF EXISTS `khach_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `khach_hang` (
  `MaKH` varchar(10) NOT NULL,
  `HoTen` varchar(100) NOT NULL,
  `SDT` varchar(10) NOT NULL,
  PRIMARY KEY (`MaKH`),
  UNIQUE KEY `UQ_KHACH_HANG_SDT` (`SDT`),
  CONSTRAINT `CK_KHACH_HANG_SDT` CHECK (regexp_like(`SDT`,_utf8mb4'^0[35789][0-9]{8}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `luong_nv`
--

DROP TABLE IF EXISTS `luong_nv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `luong_nv` (
  `MaNV` varchar(10) NOT NULL,
  `Thang` tinyint NOT NULL,
  `Nam` smallint NOT NULL,
  `Thuong` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`MaNV`,`Thang`,`Nam`),
  CONSTRAINT `FK_LUONG_NV_NV` FOREIGN KEY (`MaNV`) REFERENCES `nhan_vien` (`MaNV`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `CK_LUONG_NV_Nam` CHECK ((`Nam` >= 1)),
  CONSTRAINT `CK_LUONG_NV_Thang` CHECK ((`Thang` between 1 and 12)),
  CONSTRAINT `CK_LUONG_NV_Thuong` CHECK ((`Thuong` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nha_cung_cap`
--

DROP TABLE IF EXISTS `nha_cung_cap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nha_cung_cap` (
  `MaNCC` varchar(10) NOT NULL,
  `TenNCC` varchar(100) NOT NULL,
  `SDT` varchar(10) NOT NULL,
  `DiaChi` varchar(255) NOT NULL,
  PRIMARY KEY (`MaNCC`),
  UNIQUE KEY `uq_ncc_sdt` (`SDT`),
  CONSTRAINT `ck_ncc_sdt` CHECK (regexp_like(`SDT`,_utf8mb4'^0[0-9]{9}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nhan_vien`
--

DROP TABLE IF EXISTS `nhan_vien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhan_vien` (
  `MaNV` varchar(10) NOT NULL,
  `HoTen` varchar(100) NOT NULL,
  `GioiTinh` varchar(5) NOT NULL,
  `NgaySinh` date NOT NULL,
  `SDT` varchar(10) NOT NULL,
  `MaCV` varchar(10) NOT NULL,
  PRIMARY KEY (`MaNV`),
  UNIQUE KEY `UQ_NHAN_VIEN_SDT` (`SDT`),
  KEY `FK_NHAN_VIEN_CV` (`MaCV`),
  CONSTRAINT `FK_NHAN_VIEN_CV` FOREIGN KEY (`MaCV`) REFERENCES `chuc_vu` (`MaCV`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `CK_NHAN_VIEN_GT` CHECK (((`GioiTinh` collate utf8mb4_bin) in (_utf8mb4'Nam',_utf8mb4'Nữ'))),
  CONSTRAINT `CK_NHAN_VIEN_SDT` CHECK (regexp_like(`SDT`,_utf8mb4'^0[35789][0-9]{8}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nhap_hang`
--

DROP TABLE IF EXISTS `nhap_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhap_hang` (
  `MaNH` varchar(10) NOT NULL,
  `MaHH` varchar(10) NOT NULL,
  `MaNCC` varchar(10) NOT NULL,
  `SoLuong` int NOT NULL,
  `DonGia` decimal(12,2) NOT NULL,
  `NgayNhap` date NOT NULL,
  PRIMARY KEY (`MaNH`),
  KEY `fk_nh_hh` (`MaHH`),
  KEY `fk_nh_ncc` (`MaNCC`),
  KEY `idx_nh_ngaynhap` (`NgayNhap`),
  CONSTRAINT `fk_nh_hh` FOREIGN KEY (`MaHH`) REFERENCES `hang_hoa` (`MaHH`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_nh_ncc` FOREIGN KEY (`MaNCC`) REFERENCES `nha_cung_cap` (`MaNCC`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_nh_dongia` CHECK ((`DonGia` >= 0)),
  CONSTRAINT `ck_nh_soluong` CHECK ((`SoLuong` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phan_cong_ca`
--

DROP TABLE IF EXISTS `phan_cong_ca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phan_cong_ca` (
  `MaPK` varchar(10) NOT NULL,
  `MaNV` varchar(10) NOT NULL,
  `MaCLV` varchar(10) NOT NULL,
  `NgayLam` date NOT NULL,
  PRIMARY KEY (`MaPK`),
  UNIQUE KEY `UQ_PHAN_CONG_CA` (`MaNV`,`MaCLV`,`NgayLam`),
  KEY `FK_PHAN_CONG_CA_CLV` (`MaCLV`),
  CONSTRAINT `FK_PHAN_CONG_CA_CLV` FOREIGN KEY (`MaCLV`) REFERENCES `ca_lam_viec` (`MaCLV`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `FK_PHAN_CONG_CA_NV` FOREIGN KEY (`MaNV`) REFERENCES `nhan_vien` (`MaNV`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `the_thanh_vien`
--

DROP TABLE IF EXISTS `the_thanh_vien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `the_thanh_vien` (
  `MaThe` varchar(10) NOT NULL,
  `MaKH` varchar(10) NOT NULL,
  `NgayMua` date NOT NULL,
  `GiaThe` decimal(12,2) NOT NULL,
  `HSD` date NOT NULL,
  `TrangThaiThe` varchar(20) NOT NULL,
  PRIMARY KEY (`MaThe`),
  KEY `IDX_THE_THANH_VIEN_MAKH` (`MaKH`),
  CONSTRAINT `FK_THE_THANH_VIEN_KH` FOREIGN KEY (`MaKH`) REFERENCES `khach_hang` (`MaKH`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `CK_THE_THANH_VIEN_GIA` CHECK ((`GiaThe` >= 0)),
  CONSTRAINT `CK_THE_THANH_VIEN_HSD` CHECK ((`HSD` >= `NgayMua`)),
  CONSTRAINT `CK_THE_THANH_VIEN_TRANGTHAI` CHECK ((`TrangThaiThe` in (_utf8mb4'HoatDong',_utf8mb4'HetHan',_utf8mb4'DaHuy')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-05 20:12:58
