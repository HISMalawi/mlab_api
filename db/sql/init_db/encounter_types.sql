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
-- Table structure for table `encounter_types`
--

DROP TABLE IF EXISTS `encounter_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encounter_types` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `voided` int DEFAULT NULL,
  `voided_by` bigint DEFAULT NULL,
  `voided_reason` varchar(255) DEFAULT NULL,
  `voided_date` datetime(6) DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_3b11e06173` (`voided_by`),
  KEY `fk_rails_c085b6c147` (`creator`),
  CONSTRAINT `fk_rails_3b11e06173` FOREIGN KEY (`voided_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c085b6c147` FOREIGN KEY (`creator`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encounter_types`
--

LOCK TABLES `encounter_types` WRITE;
/*!40000 ALTER TABLE `encounter_types` DISABLE KEYS */;
INSERT INTO `encounter_types` VALUES (2,'In Patient','In Patient',1,0,NULL,NULL,NULL,'2024-05-02 14:11:17.990971','2024-05-02 14:11:17.990971',1),(13,'Out Patient','Out Patient',1,0,NULL,NULL,NULL,'2024-05-02 14:11:17.993335','2024-05-02 14:11:17.993335',1),(15,'Referral','Referral',1,0,NULL,NULL,NULL,'2024-05-02 14:11:17.995210','2024-05-02 14:11:17.995210',1);
/*!40000 ALTER TABLE `encounter_types` ENABLE KEYS */;
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
