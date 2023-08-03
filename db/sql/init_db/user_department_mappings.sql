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
-- Table structure for table `user_department_mappings`
--

DROP TABLE IF EXISTS `user_department_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_department_mappings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `department_id` bigint NOT NULL,
  `retired` int DEFAULT NULL,
  `retired_by` bigint DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `retired_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_department_mappings_on_user_id` (`user_id`),
  KEY `index_user_department_mappings_on_department_id` (`department_id`),
  KEY `fk_rails_700d5dc05d` (`retired_by`),
  KEY `fk_rails_749595bdf9` (`creator`),
  CONSTRAINT `fk_rails_61199adc2e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_700d5dc05d` FOREIGN KEY (`retired_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_749595bdf9` FOREIGN KEY (`creator`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_d1faf37492` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1156 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_department_mappings`
--

LOCK TABLES `user_department_mappings` WRITE;
/*!40000 ALTER TABLE `user_department_mappings` DISABLE KEYS */;
INSERT INTO `user_department_mappings` VALUES (1,1,12,0,NULL,NULL,NULL,1,'2023-06-23 04:14:15.177109','2023-06-23 04:14:15.177109',NULL),(2,1,7,0,NULL,NULL,NULL,1,'2023-06-23 04:14:19.583319','2023-06-23 04:14:19.583319',NULL),(3,1,5,0,NULL,NULL,NULL,1,'2023-06-23 04:14:24.260594','2023-06-23 04:14:24.260594',NULL),(4,1,9,0,NULL,NULL,NULL,1,'2023-06-23 04:14:26.159951','2023-06-23 04:14:26.159951',NULL),(5,1,8,0,NULL,NULL,NULL,1,'2023-06-23 04:14:28.495598','2023-06-23 04:14:28.495598',NULL),(6,1,3,0,NULL,NULL,NULL,1,'2023-06-23 04:14:32.330246','2023-06-23 04:14:32.330246',NULL),(7,1,10,0,NULL,NULL,NULL,1,'2023-06-23 04:14:33.975773','2023-06-23 04:14:33.975773',NULL),(8,1,6,0,NULL,NULL,NULL,1,'2023-06-23 04:14:38.174282','2023-06-23 04:14:38.174282',NULL),(9,1,2,0,NULL,NULL,NULL,1,'2023-06-23 04:14:42.872714','2023-06-23 04:14:42.872714',NULL),(10,1,11,0,NULL,NULL,NULL,1,'2023-06-23 04:14:44.636225','2023-06-23 04:14:44.636225',NULL),(11,1,1,0,NULL,NULL,NULL,1,'2023-06-23 04:14:48.576465','2023-06-23 04:14:48.576465',NULL),(12,1,4,0,NULL,NULL,NULL,1,'2023-06-23 04:14:53.162994','2023-06-23 04:14:53.162994',NULL);
/*!40000 ALTER TABLE `user_department_mappings` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-08-03 15:03:49
