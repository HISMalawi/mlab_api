-- MySQL dump 10.13  Distrib 8.0.33, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: mlab_mo
-- ------------------------------------------------------
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `instruments`
--

DROP TABLE IF EXISTS `instruments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instruments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `retired` int DEFAULT NULL,
  `retired_by` bigint DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `retired_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_b85ba53bf5` (`retired_by`),
  KEY `fk_rails_31d4d000b3` (`creator`),
  CONSTRAINT `fk_rails_31d4d000b3` FOREIGN KEY (`creator`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_b85ba53bf5` FOREIGN KEY (`retired_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instruments`
--

LOCK TABLES `instruments` WRITE;
/*!40000 ALTER TABLE `instruments` DISABLE KEYS */;
INSERT INTO `instruments` VALUES (1,'Celltac F Mek 8222','Automatic analyzer with 22 parameters and WBC 5 part diff Hematology Analyzer','192.168.1.12','HEMASERVER',0,NULL,NULL,NULL,NULL,'2016-05-22 14:50:03.000000','2016-05-22 14:50:03.000000',NULL),(4,'ERBA XL 600 KCH-BC-02','Automatic analyzer For LFTs, RFTs, electrolytes etc','192.168.9.152','',0,NULL,NULL,NULL,NULL,'2016-05-23 08:10:48.000000','2019-06-26 09:27:57.000000',NULL),(8,'Gene-Xpert','Automatic analyzer for TB ','192.168.9.112','',0,NULL,NULL,NULL,NULL,'2016-07-22 08:14:42.000000','2016-07-22 08:15:02.000000',NULL),(10,'ERBA Lyte Plus','Automatic analyzer for Electrolytes','192.168.9.152','',0,NULL,NULL,NULL,NULL,'2019-06-26 11:51:27.000000','2019-06-26 11:52:47.000000',NULL),(12,'Mindray BC 3000','Automatic analyzer with 22 parameters Hematology Analyzer',NULL,NULL,0,NULL,NULL,NULL,NULL,'2019-10-10 13:25:26.000000','2019-10-10 13:25:26.000000',NULL),(20,'Sysmex-XN-1000','Automatic Six-Part-Diff Haematology Analyzer',NULL,NULL,0,NULL,NULL,NULL,NULL,'2021-08-27 16:01:34.000000','2021-08-27 16:01:34.000000',NULL),(21,'Sysmex-XN-530','Automatic Six-Part-Diff Haematology Analyzer',NULL,NULL,0,NULL,NULL,NULL,NULL,'2021-09-14 12:44:42.000000','2021-09-14 12:44:42.000000',NULL),(26,'Mindray BC 120','Automatic Analyzer for Enzymes',NULL,NULL,0,NULL,NULL,NULL,NULL,'2023-07-14 10:02:55.000000','2023-07-14 10:02:55.000000',NULL),(29,'DXH560','Automatic analyzer with 22 parameters Hematology Analyzer',NULL,NULL,0,NULL,NULL,NULL,NULL,'2023-11-29 08:13:16.000000','2023-11-29 08:13:16.000000',NULL),(32,'ELBA XL-640','Automatic Analyzer for Enzymes',NULL,NULL,0,NULL,NULL,NULL,NULL,'2023-12-04 13:32:39.000000','2023-12-04 13:32:39.000000',NULL);
/*!40000 ALTER TABLE `instruments` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-03  8:25:01
