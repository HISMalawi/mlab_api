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
-- Table structure for table `test_panels`
--

DROP TABLE IF EXISTS `test_panels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_panels` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `short_name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `retired` int DEFAULT NULL,
  `retired_by` bigint DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `retired_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_37372fa1a2` (`retired_by`),
  KEY `fk_rails_f9cb5cd94a` (`creator`),
  CONSTRAINT `fk_rails_37372fa1a2` FOREIGN KEY (`retired_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_f9cb5cd94a` FOREIGN KEY (`creator`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_panels`
--

LOCK TABLES `test_panels` WRITE;
/*!40000 ALTER TABLE `test_panels` DISABLE KEYS */;
INSERT INTO `test_panels` VALUES (1,'CSF Analysis','CSF',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.484889','2024-05-02 14:11:14.484889',1),(2,'Urinalysis','UA',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.488214','2024-05-02 14:11:14.488214',1),(3,'Sterile Fluid Analysis','StFL',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.490531','2024-05-02 14:11:14.490531',1),(4,'MC&S','MCS',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.493092','2024-05-02 14:11:14.493092',1),(5,'Bleeding Time','BT',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.495310','2024-05-02 14:11:14.495310',1),(7,'Prostrate Specific Antigen','PSA',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.497688','2024-05-02 14:11:14.497688',1),(9,'Thyroid Function Tests','TFT',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.499812','2024-05-02 14:11:14.499812',1),(10,'Prostrate Specific Antigens','PSA',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.501949','2024-05-02 14:11:14.501949',1),(15,'CrAg','',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.516809','2024-05-02 14:11:14.516809',1),(16,'Stool Culture','Stol MCS',NULL,0,NULL,NULL,NULL,1,'2024-05-02 14:11:14.521887','2024-05-02 14:11:14.521887',1);
/*!40000 ALTER TABLE `test_panels` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-03  9:43:04
