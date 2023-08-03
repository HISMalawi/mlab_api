-- MySQL dump 10.13  Distrib 8.0.33, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: mlab_api_development
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
-- Table structure for table `drugs`
--

DROP TABLE IF EXISTS `drugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drugs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `short_name` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `retired` int DEFAULT NULL,
  `retired_by` bigint DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `retired_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_6c278e75fd` (`retired_by`),
  KEY `fk_rails_f659be91a8` (`creator`),
  CONSTRAINT `fk_rails_6c278e75fd` FOREIGN KEY (`retired_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_f659be91a8` FOREIGN KEY (`creator`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drugs`
--

LOCK TABLES `drugs` WRITE;
/*!40000 ALTER TABLE `drugs` DISABLE KEYS */;
INSERT INTO `drugs` VALUES (1,NULL,'Amoxicillin/Clavulanate',0,NULL,NULL,NULL,1,'2023-06-23 04:19:20.978985','2023-06-23 04:19:20.978985',1),(2,NULL,'Ampicillin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:20.986723','2023-06-23 04:19:20.986723',1),(3,NULL,'Ceftriaxone',0,NULL,NULL,NULL,1,'2023-06-23 04:19:20.996348','2023-06-23 04:19:20.996348',1),(4,NULL,'Chloramphenicol',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.003574','2023-06-23 04:19:21.003574',1),(5,NULL,'Ciprofloxacin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.011530','2023-06-23 04:19:21.011530',1),(6,NULL,'Azithromycin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.022500','2023-06-23 04:19:21.022500',1),(7,NULL,'Trimethoprim/Sulfamethoxazole',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.034818','2023-06-23 04:19:21.034818',1),(8,NULL,'Clindamycin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.048197','2023-06-23 04:19:21.048197',1),(9,NULL,'Erythromycin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.062415','2023-06-23 04:19:21.062415',1),(10,NULL,'Gentamicin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.072347','2023-06-23 04:19:21.072347',1),(11,NULL,'Penicillin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.080992','2023-06-23 04:19:21.080992',1),(12,NULL,'Oxacillin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.089176','2023-06-23 04:19:21.089176',1),(13,NULL,'Tetracycline',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.096485','2023-06-23 04:19:21.096485',1),(14,NULL,'Ceftazidime',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.102797','2023-06-23 04:19:21.102797',1),(15,NULL,'Tigecycline',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.111506','2023-06-23 04:19:21.111506',1),(16,NULL,'Piperacillin/Tazobactam',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.119426','2023-06-23 04:19:21.119426',1),(17,NULL,'Ceftriaxon',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.129960','2023-06-23 04:19:21.129960',1),(18,NULL,'Cefotaxim',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.139208','2023-06-23 04:19:21.139208',1),(19,NULL,'Vancomycin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.148969','2023-06-23 04:19:21.148969',1),(20,NULL,'Cefoxitin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.158678','2023-06-23 04:19:21.158678',1),(21,NULL,'Nitrofurantoin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.168385','2023-06-23 04:19:21.168385',1),(22,NULL,'Naladixic Acid',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.178870','2023-06-23 04:19:21.178870',1),(23,NULL,'Amikacin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.194748','2023-06-23 04:19:21.194748',1),(24,NULL,'Amoxicillin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.210464','2023-06-23 04:19:21.210464',1),(25,NULL,'Cefuroxime',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.225699','2023-06-23 04:19:21.225699',1),(26,NULL,'Ampicillin/Sulbactam',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.241763','2023-06-23 04:19:21.241763',1),(27,NULL,'Meropenam',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.256613','2023-06-23 04:19:21.256613',1),(28,NULL,'Tobramycin',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.264965','2023-06-23 04:19:21.264965',1),(29,NULL,'Linezolid',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.274726','2023-06-23 04:19:21.274726',1),(30,NULL,'Fuscidic acid',0,NULL,NULL,NULL,1,'2023-06-23 04:19:21.286403','2023-06-23 04:19:21.286403',1);
/*!40000 ALTER TABLE `drugs` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-08-03 14:37:32
