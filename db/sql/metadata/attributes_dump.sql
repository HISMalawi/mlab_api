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

--
-- Table structure for table `test_type_attributes`
--

DROP TABLE IF EXISTS `test_type_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_type_attributes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `test_type_id` bigint NOT NULL,
  `attribute_id` bigint NOT NULL,
  `is_required` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `parent_attribute_id` bigint DEFAULT NULL,
  `parent_attribute_value` varchar(255) DEFAULT NULL,
  `test_type_specific_options` text,
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
  UNIQUE KEY `index_test_type_attrs_on_test_type_and_attr` (`test_type_id`,`attribute_id`),
  KEY `index_test_type_attributes_on_test_type_id` (`test_type_id`),
  KEY `index_test_type_attributes_on_attribute_id` (`attribute_id`),
  KEY `index_test_type_attributes_on_parent_attribute_id` (`parent_attribute_id`),
  KEY `index_test_type_attributes_on_active` (`active`),
  KEY `index_test_type_attributes_on_test_type_id_and_active` (`test_type_id`,`active`),
  CONSTRAINT `fk_rails_0a36816561` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`),
  CONSTRAINT `fk_rails_25207c7464` FOREIGN KEY (`parent_attribute_id`) REFERENCES `attributes` (`id`),
  CONSTRAINT `fk_rails_4db68a9d17` FOREIGN KEY (`test_type_id`) REFERENCES `test_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_type_attributes`
--

LOCK TABLES `test_type_attributes` WRITE;
/*!40000 ALTER TABLE `test_type_attributes` DISABLE KEYS */;
INSERT INTO `test_type_attributes` VALUES (1,100,1,0,1,NULL,NULL,NULL,1,0,NULL,NULL,NULL,37,'2026-05-12 09:31:26.415722','2026-05-12 09:31:26.415722',37,'2026-05-12 09:31:26.415663','2026-05-12 09:31:26.415663'),(2,100,2,0,2,1,'Follow up',NULL,1,0,NULL,NULL,NULL,37,'2026-05-12 09:31:33.626036','2026-05-12 09:31:45.184881',37,'2026-05-12 09:31:33.625910','2026-05-12 09:31:45.185178'),(3,100,3,0,3,NULL,NULL,NULL,1,1,37,'Removed by user','2026-06-03 12:41:33.950309',37,'2026-05-12 09:37:23.468795','2026-06-03 12:41:33.964382',37,'2026-05-12 09:37:23.468752','2026-06-03 12:41:33.964550'),(4,100,4,0,4,NULL,NULL,NULL,1,1,37,'Removed by user','2026-06-03 12:41:29.926171',37,'2026-05-12 09:37:28.796676','2026-06-03 12:41:29.944102',37,'2026-05-12 09:37:28.796632','2026-06-03 12:41:29.944333'),(5,100,5,0,5,NULL,NULL,NULL,1,1,37,'Removed by user','2026-06-03 12:32:00.139908',37,'2026-05-12 09:37:33.235748','2026-06-03 12:32:00.254991',37,'2026-05-12 09:37:33.235719','2026-06-03 12:32:00.255268'),(6,100,6,0,6,NULL,NULL,NULL,1,0,NULL,NULL,NULL,37,'2026-05-12 09:41:47.860066','2026-05-12 09:41:47.860066',37,'2026-05-12 09:41:47.859949','2026-05-12 09:41:47.859949'),(7,100,7,0,7,NULL,NULL,NULL,1,1,37,'Removed by user','2026-06-03 12:41:25.808832',37,'2026-05-12 09:41:52.663304','2026-06-03 12:41:25.938996',37,'2026-05-12 09:41:52.663277','2026-06-03 12:41:25.939312'),(8,1,1,0,1,NULL,NULL,NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.075320','2026-06-03 12:36:38.450136',NULL,'2026-05-15 09:34:43.075206','2026-06-03 12:36:38.451092'),(9,1,2,0,2,1,'Follow up',NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.134929','2026-06-03 12:36:38.502815',NULL,'2026-05-15 09:34:43.134857','2026-06-03 12:36:38.503101'),(10,1,3,0,3,NULL,NULL,NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.151536','2026-06-03 12:36:38.539437',NULL,'2026-05-15 09:34:43.151475','2026-06-03 12:36:38.539780'),(11,1,4,0,4,NULL,NULL,NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.166430','2026-06-03 12:36:38.591554',NULL,'2026-05-15 09:34:43.166371','2026-06-03 12:36:38.591935'),(12,1,5,0,5,NULL,NULL,NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.180715','2026-06-03 12:36:38.629383',NULL,'2026-05-15 09:34:43.180654','2026-06-03 12:36:38.629641'),(13,1,6,0,6,NULL,NULL,NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.194259','2026-06-03 12:36:38.660888',NULL,'2026-05-15 09:34:43.194198','2026-06-03 12:36:38.661230'),(14,1,7,0,7,NULL,NULL,NULL,1,0,NULL,NULL,NULL,NULL,'2026-05-15 09:34:43.208561','2026-06-03 12:36:38.691560',NULL,'2026-05-15 09:34:43.208503','2026-06-03 12:36:38.691829');
/*!40000 ALTER TABLE `test_type_attributes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-03 14:42:42
