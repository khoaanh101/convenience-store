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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `TRG_CLV_DOI_GIO` BEFORE UPDATE ON `ca_lam_viec` FOR EACH ROW BEGIN
    DECLARE v_trung INT DEFAULT 0;
    IF NEW.GioBatDau <> OLD.GioBatDau
       OR NEW.GioKetThuc <> OLD.GioKetThuc THEN
        SELECT COUNT(*)
        INTO v_trung
        FROM phan_cong_ca a
        JOIN phan_cong_ca b
            ON a.MaNV = b.MaNV
           AND a.MaPK <> b.MaPK
           AND b.NgayLam BETWEEN
               DATE_SUB(a.NgayLam, INTERVAL 1 DAY)
               AND DATE_ADD(a.NgayLam, INTERVAL 1 DAY)
        JOIN ca_lam_viec cb
            ON b.MaCLV = cb.MaCLV
        WHERE a.MaCLV = OLD.MaCLV
          AND
          TIMESTAMP(a.NgayLam, NEW.GioBatDau)
          <
          TIMESTAMP(
              DATE_ADD(b.NgayLam, INTERVAL (cb.GioKetThuc <= cb.GioBatDau) DAY),
              cb.GioKetThuc
          )
          AND
          TIMESTAMP(
              DATE_ADD(a.NgayLam, INTERVAL (NEW.GioKetThuc <= NEW.GioBatDau) DAY),
              NEW.GioKetThuc
          )
          >
          TIMESTAMP(b.NgayLam, cb.GioBatDau);
        IF v_trung > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Khong the doi gio ca vi bi trung voi ca khac cua nhan vien!';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `cthd_ai` AFTER INSERT ON `chi_tiet_hoa_don` FOR EACH ROW BEGIN
    CALL tru_ton_kho(NEW.MaHH, NEW.SoLuong);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `cthd_au` AFTER UPDATE ON `chi_tiet_hoa_don` FOR EACH ROW BEGIN
    DECLARE v_delta INT DEFAULT 0;
    IF NEW.MaHH = OLD.MaHH THEN
        SET v_delta = NEW.SoLuong - OLD.SoLuong;
        IF v_delta > 0 THEN
            CALL tru_ton_kho(NEW.MaHH, v_delta);
        ELSEIF v_delta < 0 THEN
            UPDATE hang_hoa
            SET SoLuongHangTonKho = SoLuongHangTonKho - v_delta
            WHERE MaHH = NEW.MaHH;
        END IF;
    ELSE
        UPDATE hang_hoa
        SET SoLuongHangTonKho = SoLuongHangTonKho + OLD.SoLuong
        WHERE MaHH = OLD.MaHH;
        CALL tru_ton_kho(NEW.MaHH, NEW.SoLuong);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `cthd_ad` AFTER DELETE ON `chi_tiet_hoa_don` FOR EACH ROW BEGIN
    UPDATE hang_hoa
    SET SoLuongHangTonKho = SoLuongHangTonKho + OLD.SoLuong
    WHERE MaHH = OLD.MaHH;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `hd_trong_ca_bi` BEFORE INSERT ON `hoa_don` FOR EACH ROW BEGIN
    CALL kiem_tra_hd_trong_ca(NEW.MaPK, NEW.ThoiGian);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `hd_trong_ca_bu` BEFORE UPDATE ON `hoa_don` FOR EACH ROW BEGIN
    IF NOT (NEW.MaPK <=> OLD.MaPK) OR NOT (NEW.ThoiGian <=> OLD.ThoiGian) THEN
        CALL kiem_tra_hd_trong_ca(NEW.MaPK, NEW.ThoiGian);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `NV_TUOI_INS` BEFORE INSERT ON `nhan_vien` FOR EACH ROW BEGIN
    IF NEW.NgaySinh IS NULL
       OR TIMESTAMPDIFF(YEAR, NEW.NgaySinh, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nhan vien phai du 18 tuoi';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `NV_TUOI_UPD` BEFORE UPDATE ON `nhan_vien` FOR EACH ROW BEGIN
    IF NEW.NgaySinh IS NULL OR TIMESTAMPDIFF(YEAR, NEW.NgaySinh, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nhan vien phai du 18 tuoi';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `nhap_hang_bi` BEFORE INSERT ON `nhap_hang` FOR EACH ROW BEGIN
    DECLARE v_hsd DATE;
    SELECT HSD INTO v_hsd
    FROM hang_hoa
    WHERE MaHH = NEW.MaHH;
    IF v_hsd IS NOT NULL AND v_hsd <= NEW.NgayNhap THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Han su dung phai lon hon ngay nhap hang';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `nhap_hang_ai` AFTER INSERT ON `nhap_hang` FOR EACH ROW BEGIN
    UPDATE hang_hoa
    SET SoLuongHangTonKho = SoLuongHangTonKho + NEW.SoLuong
    WHERE MaHH = NEW.MaHH;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `nhap_hang_bu` BEFORE UPDATE ON `nhap_hang` FOR EACH ROW BEGIN
    DECLARE v_hsd DATE;
    SELECT HSD INTO v_hsd FROM hang_hoa WHERE MaHH = NEW.MaHH;
    IF v_hsd IS NOT NULL AND v_hsd <= NEW.NgayNhap THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Han su dung phai lon hon ngay nhap hang';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `nhap_hang_au` AFTER UPDATE ON `nhap_hang` FOR EACH ROW BEGIN
    DECLARE v_delta INT DEFAULT 0;
    IF NEW.MaHH = OLD.MaHH THEN
        SET v_delta = NEW.SoLuong - OLD.SoLuong;
        IF v_delta > 0 THEN
            UPDATE hang_hoa
            SET SoLuongHangTonKho = SoLuongHangTonKho + v_delta
            WHERE MaHH = NEW.MaHH;
        ELSEIF v_delta < 0 THEN
            CALL tru_ton_kho(NEW.MaHH, -v_delta);
        END IF;
    ELSE
        CALL tru_ton_kho(OLD.MaHH, OLD.SoLuong);
        UPDATE hang_hoa
        SET SoLuongHangTonKho = SoLuongHangTonKho + NEW.SoLuong
        WHERE MaHH = NEW.MaHH;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `nhap_hang_ad` AFTER DELETE ON `nhap_hang` FOR EACH ROW BEGIN
    CALL tru_ton_kho(OLD.MaHH, OLD.SoLuong);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `PCC_TRUNG_CA_INS` BEFORE INSERT ON `phan_cong_ca` FOR EACH ROW BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    SELECT TIMESTAMP(NEW.NgayLam, GioBatDau),
           CASE
               WHEN GioKetThuc <= GioBatDau
                   THEN DATE_ADD(TIMESTAMP(NEW.NgayLam, GioKetThuc), INTERVAL 1 DAY)
               ELSE TIMESTAMP(NEW.NgayLam, GioKetThuc)
           END
      INTO v_start, v_end
    FROM ca_lam_viec
    WHERE MaCLV = NEW.MaCLV;
    SELECT COUNT(*) INTO v_count
    FROM phan_cong_ca p
    JOIN ca_lam_viec c ON c.MaCLV = p.MaCLV
    WHERE p.MaNV = NEW.MaNV
      AND p.NgayLam BETWEEN DATE_SUB(NEW.NgayLam, INTERVAL 1 DAY)
                        AND DATE_ADD(NEW.NgayLam, INTERVAL 1 DAY)
      AND v_start < CASE
            WHEN c.GioKetThuc <= c.GioBatDau
                THEN DATE_ADD(TIMESTAMP(p.NgayLam, c.GioKetThuc), INTERVAL 1 DAY)
            ELSE TIMESTAMP(p.NgayLam, c.GioKetThuc)
          END
      AND TIMESTAMP(p.NgayLam, c.GioBatDau) < v_end;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nhan vien da duoc phan cong ca bi trung gio';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `PCC_TRUNG_CA_UPD` BEFORE UPDATE ON `phan_cong_ca` FOR EACH ROW BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    SELECT TIMESTAMP(NEW.NgayLam, GioBatDau),
           CASE
               WHEN GioKetThuc <= GioBatDau
                   THEN DATE_ADD(TIMESTAMP(NEW.NgayLam, GioKetThuc), INTERVAL 1 DAY)
               ELSE TIMESTAMP(NEW.NgayLam, GioKetThuc)
           END
      INTO v_start, v_end
    FROM ca_lam_viec
    WHERE MaCLV = NEW.MaCLV;
    SELECT COUNT(*) INTO v_count
    FROM phan_cong_ca p
    JOIN ca_lam_viec c ON c.MaCLV = p.MaCLV
    WHERE p.MaNV = NEW.MaNV
      AND p.MaPK <> OLD.MaPK
      AND p.NgayLam BETWEEN DATE_SUB(NEW.NgayLam, INTERVAL 1 DAY)
                        AND DATE_ADD(NEW.NgayLam, INTERVAL 1 DAY)
      AND v_start < CASE
            WHEN c.GioKetThuc <= c.GioBatDau
                THEN DATE_ADD(TIMESTAMP(p.NgayLam, c.GioKetThuc), INTERVAL 1 DAY)
            ELSE TIMESTAMP(p.NgayLam, c.GioKetThuc)
          END
      AND TIMESTAMP(p.NgayLam, c.GioBatDau) < v_end;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nhan vien da duoc phan cong ca bi trung gio';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `THE_TV_INS` BEFORE INSERT ON `the_thanh_vien` FOR EACH ROW BEGIN
    DECLARE v_count INT DEFAULT 0;
    IF NEW.TrangThaiThe = 'HoatDong'
       AND NEW.NgayMua <= CURDATE()
       AND NEW.HSD >= CURDATE() THEN
        SELECT COUNT(*) INTO v_count
        FROM the_thanh_vien
        WHERE MaKH = NEW.MaKH
          AND TrangThaiThe = 'HoatDong'
          AND NgayMua <= CURDATE()
          AND HSD >= CURDATE();
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Khach hang da co the thanh vien con hieu luc';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `THE_TV_UPD` BEFORE UPDATE ON `the_thanh_vien` FOR EACH ROW BEGIN
    DECLARE v_count INT DEFAULT 0;
    IF NEW.TrangThaiThe = 'HoatDong'
       AND NEW.NgayMua <= CURDATE()
       AND NEW.HSD >= CURDATE() THEN
        SELECT COUNT(*) INTO v_count
        FROM the_thanh_vien
        WHERE MaKH = NEW.MaKH
          AND MaThe <> OLD.MaThe
          AND TrangThaiThe = 'HoatDong'
          AND NgayMua <= CURDATE()
          AND HSD >= CURDATE();
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Khach hang da co the thanh vien con hieu luc';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `v_the_thanh_vien_con_hieu_luc`
--

DROP TABLE IF EXISTS `v_the_thanh_vien_con_hieu_luc`;
/*!50001 DROP VIEW IF EXISTS `v_the_thanh_vien_con_hieu_luc`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_the_thanh_vien_con_hieu_luc` AS SELECT 
 1 AS `MaThe`,
 1 AS `MaKH`,
 1 AS `HoTen`,
 1 AS `NgayMua`,
 1 AS `GiaThe`,
 1 AS `HSD`,
 1 AS `TrangThaiThe`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'cuahangtienloi'
--

--
-- Dumping routines for database 'cuahangtienloi'
--
/*!50003 DROP PROCEDURE IF EXISTS `capnhat_the_het_han` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `capnhat_the_het_han`()
BEGIN
    -- WHERE khong dung cot khoa nen MySQL Workbench (safe update mode) bao loi 1175.
    -- Tam tat safe update ngay trong thu tuc roi khoi phuc lai gia tri cu.
    DECLARE v_safe INT DEFAULT @@SQL_SAFE_UPDATES;
    DECLARE v_n INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET SQL_SAFE_UPDATES = v_safe;
        RESIGNAL;
    END;
    SET SQL_SAFE_UPDATES = 0;
    UPDATE the_thanh_vien
    SET TrangThaiThe = 'HetHan'
    WHERE TrangThaiThe = 'HoatDong' AND HSD < CURDATE();
    SET v_n = ROW_COUNT();
    SET SQL_SAFE_UPDATES = v_safe;
    SELECT v_n AS SoTheDaCapNhat;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `kiem_tra_hd_trong_ca` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `kiem_tra_hd_trong_ca`(IN p_mapk VARCHAR(10), IN p_thoigian DATETIME)
BEGIN
    DECLARE v_start DATETIME DEFAULT NULL;
    DECLARE v_end DATETIME DEFAULT NULL;
    SELECT TIMESTAMP(p.NgayLam, c.GioBatDau),
           CASE WHEN c.GioKetThuc <= c.GioBatDau
                THEN TIMESTAMP(DATE_ADD(p.NgayLam, INTERVAL 1 DAY), c.GioKetThuc)
                ELSE TIMESTAMP(p.NgayLam, c.GioKetThuc) END
      INTO v_start, v_end
    FROM phan_cong_ca p JOIN ca_lam_viec c ON c.MaCLV = p.MaCLV
    WHERE p.MaPK = p_mapk;
    IF v_start IS NULL OR p_thoigian < v_start OR p_thoigian >= v_end THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hoa don phai lap trong ca truc duoc phan cong';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ban_hang` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ban_hang`(
    IN p_mahd VARCHAR(20), IN p_mapk VARCHAR(10), IN p_makh VARCHAR(10),
    IN p_thoigian DATETIME, IN p_dong TEXT)
BEGIN
    DECLARE v_so_dong INT DEFAULT 0;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_tg DATETIME;
    DECLARE v_mahh VARCHAR(10);
    DECLARE v_sl INT;
    DECLARE v_tim INT DEFAULT 0;
    DECLARE v_gia DECIMAL(12,2);
    DECLARE v_hsd DATE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    IF p_dong IS NULL OR NOT JSON_VALID(p_dong) OR JSON_LENGTH(p_dong) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hoa don phai co it nhat mot dong hang';
    END IF;
    SET v_so_dong = JSON_LENGTH(p_dong);
    SET v_tg = IFNULL(p_thoigian, NOW());
    START TRANSACTION;
    INSERT INTO hoa_don (MaHD, MaPK, MaKH, ThoiGian) VALUES (p_mahd, p_mapk, p_makh, v_tg);
    WHILE v_i < v_so_dong DO
        SET v_mahh = JSON_UNQUOTE(JSON_EXTRACT(p_dong, CONCAT('$[', v_i, '].mahh')));
        SET v_sl   = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_dong, CONCAT('$[', v_i, '].sl'))) AS SIGNED);
        SELECT COUNT(*), MAX(Gia), MAX(HSD) INTO v_tim, v_gia, v_hsd
        FROM hang_hoa WHERE MaHH = v_mahh;
        IF v_tim = 0 OR (v_hsd IS NOT NULL AND v_hsd < DATE(v_tg)) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Co mat hang khong ton tai hoac da het han su dung';
        END IF;
        INSERT INTO chi_tiet_hoa_don (MaCTHD, MaHD, MaHH, SoLuong, Gia)
        VALUES (CONCAT(p_mahd, '-', LPAD(v_i + 1, 2, '0')), p_mahd, v_mahh, v_sl, v_gia);
        SET v_i = v_i + 1;
    END WHILE;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cap_the` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cap_the`(
    IN p_mathe VARCHAR(10), IN p_makh VARCHAR(10), IN p_giathe DECIMAL(12,2), IN p_so_ngay INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    IF p_so_ngay IS NULL OR p_so_ngay <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So ngay hieu luc phai lon hon 0';
    END IF;
    START TRANSACTION;
    UPDATE the_thanh_vien
    SET TrangThaiThe = 'HetHan'
    WHERE MaKH = p_makh AND TrangThaiThe = 'HoatDong' AND HSD < CURDATE();
    INSERT INTO the_thanh_vien (MaThe, MaKH, NgayMua, GiaThe, HSD, TrangThaiThe)
    VALUES (p_mathe, p_makh, CURDATE(), p_giathe, DATE_ADD(CURDATE(), INTERVAL p_so_ngay DAY), 'HoatDong');
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_huy_hoa_don` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_huy_hoa_don`(IN p_mahd VARCHAR(20))
BEGIN
    DECLARE v_n INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SELECT COUNT(*) INTO v_n FROM hoa_don WHERE MaHD = p_mahd;
    IF v_n = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hoa don khong ton tai';
    END IF;
    START TRANSACTION;
    DELETE FROM chi_tiet_hoa_don WHERE MaHD = p_mahd;
    DELETE FROM hoa_don WHERE MaHD = p_mahd;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tinh_luong` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `tinh_luong`(IN p_Thang INT, IN p_Nam INT)
BEGIN
    IF p_Thang IS NULL OR p_Thang NOT BETWEEN 1 AND 12 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thang khong hop le';
    END IF;
    IF p_Nam IS NULL OR p_Nam < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nam khong hop le';
    END IF;
    SELECT nv.MaNV, nv.HoTen, cv.TenCV, cv.LuongCoBan,
           COUNT(p.MaPK) AS SoCaLam,
           IFNULL(l.Thuong, 0) AS Thuong,
           cv.LuongCoBan * COUNT(p.MaPK) + IFNULL(l.Thuong, 0) AS TongLuong
    FROM nhan_vien nv
    JOIN chuc_vu cv ON cv.MaCV = nv.MaCV
    LEFT JOIN phan_cong_ca p ON p.MaNV = nv.MaNV
         AND MONTH(p.NgayLam) = p_Thang AND YEAR(p.NgayLam) = p_Nam
    LEFT JOIN luong_nv l ON l.MaNV = nv.MaNV
         AND l.Thang = p_Thang AND l.Nam = p_Nam
    GROUP BY nv.MaNV, nv.HoTen, cv.TenCV, cv.LuongCoBan, l.Thuong
    ORDER BY nv.MaNV;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tru_ton_kho` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `tru_ton_kho`(
    IN p_mahh VARCHAR(10),
    IN p_soluong INT
)
BEGIN
    DECLARE v_ton INT DEFAULT NULL;
    IF p_soluong IS NULL OR p_soluong <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'So luong tru phai lon hon 0';
    END IF;
    SELECT SoLuongHangTonKho INTO v_ton
    FROM hang_hoa
    WHERE MaHH = p_mahh
    FOR UPDATE;
    IF v_ton IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma hang hoa khong ton tai';
    ELSEIF v_ton < p_soluong THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong du ton kho de tru';
    END IF;
    UPDATE hang_hoa
    SET SoLuongHangTonKho = SoLuongHangTonKho - p_soluong
    WHERE MaHH = p_mahh;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_the_thanh_vien_con_hieu_luc`
--

/*!50001 DROP VIEW IF EXISTS `v_the_thanh_vien_con_hieu_luc`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_the_thanh_vien_con_hieu_luc` AS select `tv`.`MaThe` AS `MaThe`,`tv`.`MaKH` AS `MaKH`,`kh`.`HoTen` AS `HoTen`,`tv`.`NgayMua` AS `NgayMua`,`tv`.`GiaThe` AS `GiaThe`,`tv`.`HSD` AS `HSD`,`tv`.`TrangThaiThe` AS `TrangThaiThe` from (`the_thanh_vien` `tv` join `khach_hang` `kh` on((`tv`.`MaKH` = `kh`.`MaKH`))) where ((`tv`.`TrangThaiThe` = 'HoatDong') and (`tv`.`NgayMua` <= curdate()) and (`tv`.`HSD` >= curdate())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-12 13:20:33
