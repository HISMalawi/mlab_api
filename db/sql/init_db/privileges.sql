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
-- Table structure for table `privileges`
--

DROP TABLE IF EXISTS `privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `privileges` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `retired` int DEFAULT NULL,
  `retired_by` bigint DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `retired_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_74d4b13f40` (`retired_by`),
  KEY `fk_rails_13b25d4d99` (`creator`),
  CONSTRAINT `fk_rails_13b25d4d99` FOREIGN KEY (`creator`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_74d4b13f40` FOREIGN KEY (`retired_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `privileges`
--

LOCK TABLES `privileges` WRITE;
/*!40000 ALTER TABLE `privileges` DISABLE KEYS */;
INSERT INTO `privileges` VALUES (1,'view_names','Can view patient names',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.513895','2023-06-23 04:14:54.513895',NULL),(2,'manage_patients','Can add patients',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.535073','2023-06-23 04:14:54.535073',NULL),(3,'receive_external_test','Can receive test requests',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.545668','2023-06-23 04:14:54.545668',NULL),(4,'request_test','Can request new test',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.555577','2023-06-23 04:14:54.555577',NULL),(5,'accept_test_specimen','Can accept test specimen',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.564674','2023-06-23 04:14:54.564674',NULL),(6,'reject_test_specimen','Can reject test specimen',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.575324','2023-06-23 04:14:54.575324',NULL),(7,'change_test_specimen','Can change test specimen',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.590854','2023-06-23 04:14:54.590854',NULL),(8,'start_test','Can start tests',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.602843','2023-06-23 04:14:54.602843',NULL),(9,'enter_test_results','Can enter tests results',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.613632','2023-06-23 04:14:54.613632',NULL),(10,'edit_test_results','Can edit test results',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.629149','2023-06-23 04:14:54.629149',NULL),(11,'verify_test_results','Can verify test results',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.641791','2023-06-23 04:14:54.641791',NULL),(12,'send_results_to_external_system','Can send test results to external systems',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.655412','2023-06-23 04:14:54.655412',NULL),(13,'refer_specimens','Can refer specimens',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.666914','2023-06-23 04:14:54.666914',NULL),(14,'manage_users','Can manage users',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.682973','2023-06-23 04:14:54.682973',NULL),(15,'manage_test_catalog','Can manage test catalog',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.695166','2023-06-23 04:14:54.695166',NULL),(16,'manage_lab_configurations','Can manage lab configurations',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.708812','2023-06-23 04:14:54.708812',NULL),(17,'view_reports','Can view reports',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.722767','2023-06-23 04:14:54.722767',NULL),(18,'manage_inventory','Can manage inventory',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.737951','2023-06-23 04:14:54.737951',NULL),(19,'request_topup','Can request top-up',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.750073','2023-06-23 04:14:54.750073',NULL),(20,'manage_qc','Can manage Quality Control',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.760396','2023-06-23 04:14:54.760396',NULL),(21,'void_test','Can void test',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.769977','2023-06-23 04:14:54.769977',NULL),(22,'ignore_test','Can claim test not done',0,NULL,NULL,NULL,1,'2023-06-23 04:14:54.783164','2023-06-23 04:14:54.783164',NULL);
/*!40000 ALTER TABLE `privileges` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-08-03 14:46:55
