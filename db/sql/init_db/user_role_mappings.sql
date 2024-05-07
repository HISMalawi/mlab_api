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
-- Table structure for table `user_role_mappings`
--

DROP TABLE IF EXISTS `user_role_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_role_mappings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `retired` int DEFAULT NULL,
  `retired_by` bigint DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `retired_date` datetime(6) DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `updated_date` datetime(6) DEFAULT NULL,
  `created_date` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_role_mappings_on_user_id` (`user_id`),
  KEY `index_user_role_mappings_on_role_id` (`role_id`),
  KEY `fk_rails_7009c0ebef` (`retired_by`),
  KEY `fk_rails_70a7a9087a` (`creator`),
  CONSTRAINT `fk_rails_7009c0ebef` FOREIGN KEY (`retired_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_70a7a9087a` FOREIGN KEY (`creator`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_7ddbbdbc99` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `fk_rails_e84071773e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role_mappings`
--

LOCK TABLES `user_role_mappings` WRITE;
/*!40000 ALTER TABLE `user_role_mappings` DISABLE KEYS */;
INSERT INTO `user_role_mappings` VALUES (1,1,1,0,NULL,NULL,NULL,1,'2024-05-02 13:55:45.080778','2024-05-02 13:55:45.080778',NULL);
/*!40000 ALTER TABLE `user_role_mappings` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-03  8:25:02
