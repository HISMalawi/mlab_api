-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: m_qch
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.24.04.1

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
-- Table structure for table `attributes`
--

DROP TABLE IF EXISTS `attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attributes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `description` text,
  `field_type` varchar(255) NOT NULL DEFAULT 'text',
  `options` text,
  `active` tinyint(1) DEFAULT '1',
  `voided` int DEFAULT '0',
  `voided_by` bigint DEFAULT NULL,
  `voided_reason` varchar(255) DEFAULT NULL,
  `voided_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attributes_on_name` (`name`),
  KEY `index_attributes_on_active` (`active`),
  KEY `index_attributes_on_field_type` (`field_type`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attributes`
--

LOCK TABLES `attributes` WRITE;
/*!40000 ALTER TABLE `attributes` DISABLE KEYS */;
INSERT INTO `attributes` VALUES (1,'Reason For Examination','Reason For Examination','Reason For Examination','radio','[\"Diagnosis\",\"Follow up\"]',1,0,NULL,NULL,NULL,229,'2026-04-20 09:15:53.715526','2026-04-20 09:15:53.715526',229,'2026-04-20 09:15:53.715438','2026-04-20 09:15:53.715438'),(2,'Follow Up Period','Follow Up Period','Follow Up Period','select','[\"2 months\",\"5 months\",\"6 months\"]',1,0,NULL,NULL,NULL,229,'2026-04-20 09:17:01.332173','2026-04-20 09:17:01.332173',229,'2026-04-20 09:17:01.332069','2026-04-20 09:17:01.332069'),(3,'Phone','Patient Phone Number','','number','[]',1,0,NULL,NULL,NULL,229,'2026-04-20 10:45:36.321433','2026-05-12 09:33:49.696401',37,'2026-04-20 10:45:36.321208','2026-05-12 09:33:49.696552'),(4,'District TB Reg No','District TB Reg No','','text','[]',1,0,NULL,NULL,NULL,37,'2026-05-12 09:34:27.786949','2026-05-12 09:34:27.786949',37,'2026-05-12 09:34:27.786815','2026-05-12 09:34:27.786815'),(5,'HIV Status','HIV Status','','select','[\"Positive\",\"Negative\",\"Unknown/Not Tested\"]',1,0,NULL,NULL,NULL,37,'2026-05-12 09:35:19.419321','2026-05-12 09:36:22.584727',37,'2026-05-12 09:35:19.419190','2026-05-12 09:36:22.584855'),(6,'TB Treatment History','TB Treatment History','','select','[\"New\",\"Previously Treated\"]',1,0,NULL,NULL,NULL,37,'2026-05-12 09:40:27.985387','2026-05-12 09:40:27.985387',37,'2026-05-12 09:40:27.985350','2026-05-12 09:40:27.985350'),(7,'Health Facility','Health Facility','','text','[]',1,0,NULL,NULL,NULL,37,'2026-05-12 09:41:24.738453','2026-05-12 09:41:24.738453',37,'2026-05-12 09:41:24.738327','2026-05-12 09:41:24.738327');
/*!40000 ALTER TABLE `attributes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-03 15:31:54
