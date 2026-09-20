-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 20, 2026 at 06:58 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `civilwatch`
--
CREATE DATABASE IF NOT EXISTS `civilwatch` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `civilwatch`;

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 1,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `body`, `is_published`, `published_at`, `created_at`, `updated_at`) VALUES
(1, 'Keep Digos City Clean and Safe!', 'Let\'s work together for a better community. Report any infrastructure or environmental concerns through the CivilWatch app.', 1, '2026-08-11 22:27:58', '2026-08-13 22:27:58', '2026-08-13 22:27:58'),
(2, 'Road Repair Schedule — Barangay San Miguel', 'Road repairs will be conducted from July 18–20, 2026. Expect partial road closures. Please use alternate routes.', 1, '2026-08-09 22:27:58', '2026-08-13 22:27:58', '2026-08-13 22:27:58');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `citizens`
--

CREATE TABLE `citizens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(191) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `barangay` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL DEFAULT 'Digos City',
  `pin_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `citizens`
--

INSERT INTO `citizens` (`id`, `full_name`, `email`, `phone`, `barangay`, `city`, `pin_hash`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'lawrence sereno', 'qwert@gmail.com', '639638527411', 'Binaton', 'Digos City', '$2y$12$c7niceAXJ7l7dfNV90liauOISzA0Q6GaoKQU73M6P2B0EkiZXF2Na', 1, '2026-08-13 22:58:01', '2026-08-13 22:58:01'),
(5, 'james sereno', 'qwerty@gmail.com', '639663388552', 'Igpit', 'Digos City', '$2y$12$.d4PmoA05D628C185WeIW.cTA.8WWakTBCU6tmohP0wEjMoqcKZnO', 1, '2026-09-11 20:04:27', '2026-09-11 20:04:27');

-- --------------------------------------------------------

--
-- Table structure for table `citizen_notifications`
--

CREATE TABLE `citizen_notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `citizen_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'status_update',
  `citizen_report_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reference_number` varchar(20) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `citizen_reports`
--

CREATE TABLE `citizen_reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reference_number` varchar(20) NOT NULL,
  `citizen_id` bigint(20) UNSIGNED NOT NULL,
  `category` enum('Infrastructure','Environment','Others') NOT NULL,
  `concern` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `purok` varchar(100) DEFAULT NULL,
  `barangay` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL DEFAULT 'Digos City',
  `province` varchar(100) NOT NULL DEFAULT 'Davao del Sur',
  `landmark` varchar(255) DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `severity` enum('Minor','Moderate','Severe') NOT NULL DEFAULT 'Moderate',
  `photo_url` varchar(500) DEFAULT NULL,
  `status` enum('Submitted','Pending Validation','Assigned to Office','In Progress','Resolved') NOT NULL DEFAULT 'Submitted',
  `assigned_office_id` bigint(20) UNSIGNED DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `government_offices`
--

CREATE TABLE `government_offices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `abbreviation` varchar(20) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(191) DEFAULT NULL,
  `address` varchar(500) DEFAULT NULL,
  `handles` enum('Infrastructure','Environment','Both') NOT NULL DEFAULT 'Both',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `government_offices`
--

INSERT INTO `government_offices` (`id`, `name`, `abbreviation`, `phone`, `email`, `address`, `handles`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'City Engineering Office', 'CEO', '+63 82 553 0001', 'ceo@digos.gov.ph', 'City Hall Complex, Digos City, Davao del Sur', 'Infrastructure', 1, '2026-08-13 22:27:58', '2026-08-13 22:27:58'),
(2, 'City Environment and Natural Resources Office', 'CENRO', '+63 82 553 0002', 'cenro@digos.gov.ph', 'City Hall Complex, Digos City, Davao del Sur', 'Environment', 1, '2026-08-13 22:27:58', '2026-08-13 22:27:58'),
(3, 'City Public Works Department', 'CPWD', '+63 82 553 0003', 'cpwd@digos.gov.ph', 'City Hall Complex, Digos City, Davao del Sur', 'Both', 1, '2026-08-13 22:27:58', '2026-08-13 22:27:58'),
(4, 'Digos City Disaster Risk Reduction and Management Office', 'CDRRMO', '+63 82 553 0004', 'cdrrmo@digos.gov.ph', 'City Hall Complex, Digos City, Davao del Sur', 'Both', 1, '2026-08-13 22:27:58', '2026-08-13 22:27:58'),
(5, 'City Veterinary Office', 'CVO', '+63 82 553 0005', 'cvo@digos.gov.ph', 'City Hall Complex, Digos City, Davao del Sur', 'Both', 1, '2026-08-13 22:27:58', '2026-08-13 22:27:58');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_01_01_000010_create_personal_access_tokens_table', 1),
(5, '2026_01_01_000001_create_citizens_table', 2),
(6, '2026_01_01_000002_create_otp_codes_table', 2),
(7, '2026_01_01_000003_create_government_offices_table', 2),
(8, '2026_01_01_000004_create_citizen_reports_table', 2),
(9, '2026_01_01_000005_create_report_activities_table', 2),
(10, '2026_01_01_000006_create_citizen_notifications_table', 2),
(11, '2026_01_01_000007_create_announcements_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `message` varchar(500) NOT NULL,
  `type` enum('report_submitted','report_assigned','status_update','report_resolved','system') NOT NULL DEFAULT 'system',
  `report_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Optional link back to the related report',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `message`, `type`, `report_id`, `is_read`, `created_at`) VALUES
(1, 1, 'New report submitted: Damaged Road in Aplaya (CW-2026-001).', 'report_submitted', 1, 0, '2026-08-10 07:15:00'),
(2, 1, 'New report submitted: Illegal Dumping in Carmen (CW-2026-002).', 'report_submitted', 2, 0, '2026-08-10 08:30:00'),
(3, 1, 'New report submitted: Damaged Sidewalk in Zone II (CW-2026-003).', 'report_submitted', 3, 0, '2026-08-10 09:00:00'),
(4, 1, 'New report submitted: Blocked Drainage in Magsaysay (CW-2026-004).', 'report_submitted', 4, 0, '2026-08-10 10:00:00'),
(5, 1, 'New report submitted: Overgrown Vegetation in Badiang (CW-2026-005).', 'report_submitted', 5, 0, '2026-08-10 11:00:00'),
(6, 1, 'Report CW-2026-011 updated to In Progress by City Engineering Office.', 'status_update', 11, 1, '2026-08-09 14:00:00'),
(7, 1, 'Report CW-2026-012 updated to In Progress by CENRO.', 'status_update', 12, 1, '2026-08-09 13:00:00'),
(8, 1, 'Report CW-2026-017 has been resolved by City Engineering Office.', 'report_resolved', 17, 1, '2026-08-09 11:00:00'),
(9, 1, 'Report CW-2026-019 has been resolved by City Engineering Office.', 'report_resolved', 19, 1, '2026-08-09 15:00:00'),
(10, 1, 'Report CW-2026-020 has been resolved by CENRO.', 'report_resolved', 20, 1, '2026-08-10 10:00:00'),
(11, 2, 'Report CW-2026-007 assigned to your office. Priority: Medium.', 'report_assigned', 7, 0, '2026-08-09 10:00:00'),
(12, 2, 'Report CW-2026-009 assigned to your office. Priority: High.', 'report_assigned', 9, 0, '2026-08-09 09:00:00'),
(13, 2, 'Report CW-2026-015 has been resolved. Great work!', 'report_resolved', 15, 1, '2026-08-08 17:00:00'),
(14, 3, 'Report CW-2026-008 assigned to your office. Priority: High.', 'report_assigned', 8, 0, '2026-08-09 11:00:00'),
(15, 3, 'Report CW-2026-010 assigned to your office. Priority: Medium.', 'report_assigned', 10, 0, '2026-08-09 08:30:00'),
(16, 3, 'Report CW-2026-016 has been resolved. Great work!', 'report_resolved', 16, 1, '2026-08-07 16:00:00'),
(17, 2, 'Report CW-2026-004 has been assigned to your office: Blocked Drainage.', 'report_assigned', 4, 0, '2026-09-12 13:28:39');

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `phone` varchar(20) NOT NULL,
  `code` varchar(10) NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(10, 'App\\Models\\User', 1, 'auth_token', '1b061ff38bd1b61821d060b3ea8e33ab21d46877ead66b5780971ea3b4653ce9', '[\"*\"]', '2026-08-13 21:31:07', NULL, '2026-08-13 21:29:12', '2026-08-13 21:31:07'),
(11, 'App\\Models\\User', 1, 'auth_token', '29990d68eb9b39e6edb335beef4b9a976d35a8b1a425b5e21e1e8e1285b90cfb', '[\"*\"]', '2026-08-13 23:41:57', NULL, '2026-08-13 22:18:54', '2026-08-13 23:41:57'),
(14, 'App\\Models\\User', 1, 'auth_token', 'e0cd58613c3bc996dbbef8c8f2435989db24a3e9da3ac94067c95e2f81770f90', '[\"*\"]', '2026-08-14 00:30:31', NULL, '2026-08-14 00:05:39', '2026-08-14 00:30:31'),
(16, 'App\\Models\\User', 1, 'auth_token', '0ab9488d5ce0bffdfca7e7cdf7d271c208f89f2bac9e68bd08d3f9f0321ec0b9', '[\"*\"]', '2026-08-14 00:54:06', NULL, '2026-08-14 00:30:34', '2026-08-14 00:54:06'),
(20, 'App\\Models\\User', 1, 'auth_token', 'd432554e77fc5ee700707113e7ac9b92303959d1dcf2371cf4c278ff17cda650', '[\"*\"]', '2026-08-14 02:03:05', NULL, '2026-08-14 01:07:02', '2026-08-14 02:03:05'),
(27, 'App\\Models\\User', 1, 'auth_token', '944968a77b9e0aa262224ce9c037a258de5e0f9a024056b201d5cafe5776460f', '[\"*\"]', '2026-08-15 10:37:50', NULL, '2026-08-14 21:48:02', '2026-08-15 10:37:50'),
(31, 'App\\Models\\User', 1, 'auth_token', '90399b74809e423ab29a438ce7845a2bcbd34f694048efe7529750e663d4323d', '[\"*\"]', '2026-08-15 12:48:12', NULL, '2026-08-15 10:45:39', '2026-08-15 12:48:12'),
(34, 'App\\Models\\User', 1, 'auth_token', '0525f832d223e0db3ff48c12a2c2c3e30c3b043b6bc7ce1e9958d951f92bd45f', '[\"*\"]', '2026-08-15 22:25:19', NULL, '2026-08-15 20:22:53', '2026-08-15 22:25:19'),
(37, 'App\\Models\\User', 1, 'auth_token', 'd32a2ec62041c937a79684d3cf4c1a64fd375867629d4602f8f981bce4270480', '[\"*\"]', '2026-08-18 18:37:54', NULL, '2026-08-18 14:46:29', '2026-08-18 18:37:54'),
(40, 'App\\Models\\User', 1, 'auth_token', '15f921c95cb9ee22a75dae6d9a48aeccaf0125c09e641744b45a3cb2fe5d4613', '[\"*\"]', '2026-09-03 19:32:41', NULL, '2026-09-03 19:25:52', '2026-09-03 19:32:41'),
(51, 'App\\Models\\User', 1, 'auth_token', '8670baf271abdc19f3863cb487c9c7db19fa7afaf777c395008d23cd64d9da7d', '[\"*\"]', '2026-09-11 22:13:11', NULL, '2026-09-11 21:51:31', '2026-09-11 22:13:11'),
(52, 'App\\Models\\User', 1, 'auth_token', 'b05fbf84e8b0164e6be394771f0695af30177a6606835f662b083e4de7e0fd48', '[\"*\"]', '2026-09-18 19:50:24', NULL, '2026-09-18 19:17:24', '2026-09-18 19:50:24'),
(53, 'App\\Models\\User', 1, 'auth_token', '93f8995c15f4a27b8658b584790fd168628baff40301cf2c1a75e7df556f1458', '[\"*\"]', '2026-09-20 08:58:13', NULL, '2026-09-20 08:46:32', '2026-09-20 08:58:13'),
(54, 'App\\Models\\Citizen', 1, 'mobile', 'b947798605c765129137973a38503150ea119c3e0c1c78d460f040fa1a8f53cc', '[\"*\"]', '2026-09-20 08:47:44', NULL, '2026-09-20 08:47:42', '2026-09-20 08:47:44');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(10) UNSIGNED NOT NULL,
  `reference_no` varchar(30) NOT NULL COMMENT 'e.g. CW-2026-00001',
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `category` enum('infrastructure','environmental','public_safety','sanitation','other') NOT NULL DEFAULT 'other',
  `status` enum('submitted','pending','assigned','in_progress','for_resolution','resolved') NOT NULL DEFAULT 'submitted',
  `priority` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `barangay` varchar(100) DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `address_text` varchar(255) DEFAULT NULL COMMENT 'Human-readable address from reverse geocode',
  `submitted_by` varchar(120) DEFAULT NULL COMMENT 'Citizen name (unauthenticated submission)',
  `submitted_contact` varchar(100) DEFAULT NULL COMMENT 'Email or phone of citizen',
  `assigned_to_office` enum('CEO','CENRO') DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`id`, `reference_no`, `title`, `description`, `category`, `status`, `priority`, `barangay`, `lat`, `lng`, `address_text`, `submitted_by`, `submitted_contact`, `assigned_to_office`, `resolved_at`, `created_at`, `updated_at`) VALUES
(1, 'CW-2026-001', 'Damaged Road', 'Multiple deep potholes along the main road in Aplaya causing difficulty for vehicles and risk of accidents especially at night.', 'infrastructure', 'pending', 'high', 'Aplaya', 6.7500000, 125.3540000, 'Aplaya Main Road, Digos City', 'Juan Dela Cruz', '0912-345-6789', NULL, NULL, '2026-08-10 07:15:00', '2026-08-10 07:15:00'),
(2, 'CW-2026-002', 'Illegal Dumping', 'Large volume of household garbage illegally dumped along the riverbank near Carmen barangay hall. Foul odor affecting nearby residents.', 'environmental', 'pending', 'high', 'Carmen', 6.7420000, 125.3480000, 'Carmen Riverbank, Digos City', 'Maria Santos', '0998-765-4321', NULL, NULL, '2026-08-10 08:30:00', '2026-08-10 08:30:00'),
(3, 'CW-2026-003', 'Damaged Sidewalk', 'Cracked and uneven sidewalk tiles near the public market in Zone II. Pedestrians especially elderly and children are at risk of tripping.', 'infrastructure', 'pending', 'medium', 'Zone II', 6.7560000, 125.3600000, 'Zone II Public Market, Digos City', 'Pedro Reyes', '0917-111-2222', NULL, NULL, '2026-08-10 09:00:00', '2026-08-10 09:00:00'),
(4, 'CW-2026-004', 'Blocked Drainage', 'Main drainage canal in Magsaysay is fully clogged with silt and debris causing floodwater to overflow into residential streets after rain.', 'infrastructure', 'assigned', 'medium', 'Magsaysay', 6.7480000, 125.3520000, 'Magsaysay Drainage Canal, Digos City', 'Ana Lopez', '0933-222-1111', 'CEO', NULL, '2026-08-10 10:00:00', '2026-09-12 05:28:39'),
(5, 'CW-2026-005', 'Overgrown Vegetation', 'Thick overgrown vegetation blocking the pathway and road visibility along the national highway in Badiang. Hazard for motorists.', 'environmental', 'pending', 'medium', 'Badiang', 6.7610000, 125.3680000, 'Badiang National Highway, Digos City', 'Ramon Garcia', '0906-888-7777', NULL, NULL, '2026-08-10 11:00:00', '2026-08-10 11:00:00'),
(6, 'CW-2026-006', 'Broken Streetlight', 'Three consecutive streetlights are not functioning along the road near Zone III basketball court. Area is very dark and unsafe at night.', 'infrastructure', 'pending', 'medium', 'Zone III', 6.7530000, 125.3570000, 'Zone III Basketball Court Road, Digos City', 'Carla Mendoza', '0915-333-4444', NULL, NULL, '2026-08-09 18:30:00', '2026-08-09 18:30:00'),
(7, 'CW-2026-007', 'Road Graveling Needed', 'Unpaved section of barangay road in Tiguman is impassable during rainy season. Residents requesting immediate graveling.', 'infrastructure', 'assigned', 'medium', 'Tiguman', 6.7460000, 125.3660000, 'Tiguman Barangay Road, Digos City', 'Luz Fernandez', '0921-444-5555', 'CEO', NULL, '2026-08-08 09:00:00', '2026-08-09 10:00:00'),
(8, 'CW-2026-008', 'Illegal Dumping', 'Dumping of construction waste along the creek in Dawis barangay. Blocking water flow and causing risk of flash flooding.', 'environmental', 'assigned', 'high', 'Dawis', 6.7320000, 125.3680000, 'Dawis Creek, Digos City', 'Roberto Cruz', '0908-777-8888', 'CENRO', NULL, '2026-08-08 10:30:00', '2026-08-09 11:00:00'),
(9, 'CW-2026-009', 'Damaged Bridge', 'Wooden footbridge in Ruparan has missing planks and damaged railings. Residents use it daily to cross to the farm areas.', 'infrastructure', 'assigned', 'high', 'Ruparan', 6.7140000, 125.3600000, 'Ruparan Footbridge, Digos City', 'Gloria Mendoza', '0932-987-6543', 'CEO', NULL, '2026-08-07 14:00:00', '2026-08-09 09:00:00'),
(10, 'CW-2026-010', 'Garbage Collection', 'Garbage has not been collected in San Agustin for over two weeks. Waste is piling up along the road attracting flies and rodents.', 'environmental', 'assigned', 'medium', 'San Agustin', 6.7400000, 125.3340000, 'San Agustin Barangay Road, Digos City', 'Elena Reyes', '0917-999-0000', 'CENRO', NULL, '2026-08-07 08:00:00', '2026-08-09 08:30:00'),
(11, 'CW-2026-011', 'Blocked Canal', 'Main irrigation canal in Kansas barangay is blocked by silt buildup. Farmlands are flooding and crops are being damaged.', 'infrastructure', 'in_progress', 'high', 'Kansas', 6.7220000, 125.3290000, 'Kansas Irrigation Canal, Digos City', 'Felix Santos', '0905-123-4567', 'CEO', NULL, '2026-08-05 07:00:00', '2026-08-09 14:00:00'),
(12, 'CW-2026-012', 'Soil Erosion', 'Severe soil erosion on the hillside in Kiagot is threatening nearby homes. Soil is visibly sliding during heavy rain events.', 'environmental', 'in_progress', 'high', 'Kiagot', 6.7180000, 125.3840000, 'Kiagot Hillside Area, Digos City', 'Mario Villanueva', '0916-222-3333', 'CENRO', NULL, '2026-08-04 10:00:00', '2026-08-09 13:00:00'),
(13, 'CW-2026-013', 'Road Sign Damage', 'Road signs at the intersection in San Jose are completely damaged and unreadable. Causing confusion for motorists and visitors.', 'infrastructure', 'in_progress', 'low', 'San Jose', 6.7720000, 125.3580000, 'San Jose Intersection, Digos City', 'Nora Bautista', '0922-555-6666', 'CEO', NULL, '2026-08-06 09:00:00', '2026-08-09 15:00:00'),
(14, 'CW-2026-014', 'Overgrown Vegetation', 'Tall cogon grass and shrubs along the road in Soong are obstructing visibility at a sharp curve. Risk of vehicular accidents.', 'environmental', 'in_progress', 'medium', 'Soong', 6.7640000, 125.3360000, 'Soong Road Curve, Digos City', 'Carlos Lim', '0935-777-8888', 'CENRO', NULL, '2026-08-06 11:00:00', '2026-08-09 16:00:00'),
(15, 'CW-2026-015', 'Broken Streetlight', 'Streetlight at the main entrance of Zone I repaired. New LED bulb and wiring replaced. Area is now well-lit at night.', 'infrastructure', 'resolved', 'low', 'Zone I', 6.7505000, 125.3560000, 'Zone I Main Entrance, Digos City', 'Ate Nena Reyes', '0910-111-2222', 'CEO', '2026-08-08 17:00:00', '2026-08-03 08:00:00', '2026-08-08 17:00:00'),
(16, 'CW-2026-016', 'Illegal Dumping', 'Illegal dump site near the creek in Tres De Mayo has been cleared. Warning signs installed to prevent recurrence.', 'environmental', 'resolved', 'medium', 'Tres De Mayo', 6.7250000, 125.3520000, 'Tres De Mayo Creek, Digos City', 'Jun Pascual', '0925-333-4444', 'CENRO', '2026-08-07 16:00:00', '2026-08-02 09:00:00', '2026-08-07 16:00:00'),
(17, 'CW-2026-017', 'Damaged Road', 'Pothole along the road in Matti has been patched with asphalt. Road surface is now smooth and safe for vehicles.', 'infrastructure', 'resolved', 'medium', 'Matti', 6.7280000, 125.3460000, 'Matti Barangay Road, Digos City', 'Precy Gomez', '0918-444-5555', 'CEO', '2026-08-09 11:00:00', '2026-08-04 07:00:00', '2026-08-09 11:00:00'),
(18, 'CW-2026-018', 'Garbage Collection', 'Uncollected garbage in Baracatan has been addressed. Regular collection schedule has been restored.', 'environmental', 'resolved', 'low', 'Baracatan', 6.7380000, 125.3420000, 'Baracatan Barangay, Digos City', 'Tess Aquino', '0939-666-7777', 'CENRO', '2026-08-08 14:00:00', '2026-08-03 10:00:00', '2026-08-08 14:00:00'),
(19, 'CW-2026-019', 'Blocked Drainage', 'Drainage along Mahayahay road has been fully cleared and desilted. Water now flows freely and flooding issue has been resolved.', 'infrastructure', 'resolved', 'high', 'Mahayahay', 6.7690000, 125.3480000, 'Mahayahay Road, Digos City', 'Danny Flores', '0927-888-9999', 'CEO', '2026-08-09 15:00:00', '2026-08-05 08:00:00', '2026-08-09 15:00:00'),
(20, 'CW-2026-020', 'Soil Erosion', 'Erosion on the slope in Lungag has been stabilized with riprap and vegetation planting. Area is now safe.', 'environmental', 'resolved', 'high', 'Lungag', 6.7560000, 125.3420000, 'Lungag Slope Area, Digos City', 'Minda Soriano', '0913-000-1111', 'CENRO', '2026-08-10 10:00:00', '2026-08-04 09:00:00', '2026-08-10 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `report_activities`
--

CREATE TABLE `report_activities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `citizen_report_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_assignments`
--

CREATE TABLE `report_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `report_id` int(10) UNSIGNED NOT NULL,
  `assigned_to` enum('CEO','CENRO') NOT NULL,
  `assigned_by` int(10) UNSIGNED NOT NULL COMMENT 'FK to users (super_admin)',
  `priority` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `report_assignments`
--

INSERT INTO `report_assignments` (`id`, `report_id`, `assigned_to`, `assigned_by`, `priority`, `notes`, `created_at`) VALUES
(1, 7, 'CEO', 1, 'medium', 'Please prioritize. Barangay road impassable during rain. Coordinate with barangay captain.', '2026-08-09 10:00:00'),
(2, 8, 'CENRO', 1, 'high', 'Construction waste near creek. Risk of flooding. Immediate cleanup required.', '2026-08-09 11:00:00'),
(3, 9, 'CEO', 1, 'high', 'Footbridge used daily by residents. Missing planks are a safety hazard. Urgent repair needed.', '2026-08-09 09:00:00'),
(4, 10, 'CENRO', 1, 'medium', 'Two weeks without collection. Coordinate with garbage truck schedule for San Agustin.', '2026-08-09 08:30:00'),
(5, 11, 'CEO', 1, 'high', 'Irrigation canal blocking crops. Farmers reporting losses. Desilting required immediately.', '2026-08-07 09:00:00'),
(6, 12, 'CENRO', 1, 'high', 'Hillside erosion near homes. Risk of landslide. Assess and recommend stabilization measures.', '2026-08-06 11:00:00'),
(7, 13, 'CEO', 1, 'low', 'Replace damaged road signs at intersection. Coordinate with traffic management office.', '2026-08-08 10:00:00'),
(8, 14, 'CENRO', 1, 'medium', 'Clear vegetation along road curve. Safety hazard for motorists.', '2026-08-08 12:00:00'),
(9, 15, 'CEO', 1, 'low', 'Replace bulb and check wiring for Zone I entrance streetlight.', '2026-08-04 09:00:00'),
(10, 16, 'CENRO', 1, 'medium', 'Clear dump site and install warning signs. Document for barangay records.', '2026-08-03 10:00:00'),
(11, 17, 'CEO', 1, 'medium', 'Patch pothole in Matti. Use cold-mix asphalt for immediate repair.', '2026-08-05 08:00:00'),
(12, 18, 'CENRO', 1, 'low', 'Restore garbage collection schedule for Baracatan. Coordinate with driver.', '2026-08-04 10:00:00'),
(13, 19, 'CEO', 1, 'high', 'Desilt Mahayahay drainage. Flooding reported after every rain.', '2026-08-06 09:00:00'),
(14, 20, 'CENRO', 1, 'high', 'Stabilize Lungag slope with riprap. Plant grass cover after. Monitor for 30 days.', '2026-08-05 10:00:00'),
(15, 4, 'CEO', 1, 'medium', 'under construction', '2026-09-12 13:28:39');

-- --------------------------------------------------------

--
-- Table structure for table `report_photos`
--

CREATE TABLE `report_photos` (
  `id` int(10) UNSIGNED NOT NULL,
  `report_id` int(10) UNSIGNED NOT NULL,
  `type` enum('before','after') NOT NULL DEFAULT 'before',
  `cloudinary_url` varchar(500) NOT NULL,
  `cloudinary_public_id` varchar(255) NOT NULL,
  `uploaded_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to users; null = citizen upload',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `report_photos`
--

INSERT INTO `report_photos` (`id`, `report_id`, `type`, `cloudinary_url`, `cloudinary_public_id`, `uploaded_by`, `created_at`) VALUES
(1, 1, 'before', 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&h=500&fit=crop&q=85', 'cw_damaged_road_001', NULL, '2026-08-10 07:15:00'),
(2, 2, 'before', 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=800&h=500&fit=crop&q=85', 'cw_illegal_dump_002', NULL, '2026-08-10 08:30:00'),
(3, 3, 'before', 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800&h=500&fit=crop&q=85', 'cw_damaged_sidewalk_003', NULL, '2026-08-10 09:00:00'),
(4, 4, 'before', 'https://images.unsplash.com/photo-1590845947670-c009801ffa74?w=800&h=500&fit=crop&q=85', 'cw_blocked_drainage_004', NULL, '2026-08-10 10:00:00'),
(5, 5, 'before', 'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=800&h=500&fit=crop&q=85', 'cw_overgrown_veg_005', NULL, '2026-08-10 11:00:00'),
(6, 6, 'before', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&h=500&fit=crop&q=85', 'cw_streetlight_006', NULL, '2026-08-09 18:30:00'),
(7, 7, 'before', 'https://images.unsplash.com/photo-1503516459261-40c66117780a?w=800&h=500&fit=crop&q=85', 'cw_road_gravel_007', NULL, '2026-08-08 09:00:00'),
(8, 8, 'before', 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=800&h=500&fit=crop&q=85', 'cw_illegal_dump_008', NULL, '2026-08-08 10:30:00'),
(9, 9, 'before', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=500&fit=crop&q=85', 'cw_damaged_bridge_009', NULL, '2026-08-07 14:00:00'),
(10, 10, 'before', 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=800&h=500&fit=crop&q=85', 'cw_garbage_010', NULL, '2026-08-07 08:00:00'),
(11, 11, 'before', 'https://images.unsplash.com/photo-1590845947670-c009801ffa74?w=800&h=500&fit=crop&q=85', 'cw_blocked_canal_011', NULL, '2026-08-05 07:00:00'),
(12, 12, 'before', 'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=800&h=500&fit=crop&q=85', 'cw_soil_erosion_012', NULL, '2026-08-04 10:00:00'),
(13, 13, 'before', 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=500&fit=crop&q=85', 'cw_road_sign_013', NULL, '2026-08-06 09:00:00'),
(14, 14, 'before', 'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=800&h=500&fit=crop&q=85', 'cw_overgrown_veg_014', NULL, '2026-08-06 11:00:00'),
(15, 15, 'before', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&h=500&fit=crop&q=85', 'cw_streetlight_before_015', NULL, '2026-08-03 08:00:00'),
(16, 15, 'after', 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=500&fit=crop&q=85', 'cw_streetlight_after_015', 2, '2026-08-08 17:00:00'),
(17, 16, 'before', 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=800&h=500&fit=crop&q=85', 'cw_dump_before_016', NULL, '2026-08-02 09:00:00'),
(18, 16, 'after', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800&h=500&fit=crop&q=85', 'cw_dump_after_016', 3, '2026-08-07 16:00:00'),
(19, 17, 'before', 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&h=500&fit=crop&q=85', 'cw_road_before_017', NULL, '2026-08-04 07:00:00'),
(20, 17, 'after', 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800&h=500&fit=crop&q=85', 'cw_road_after_017', 2, '2026-08-09 11:00:00'),
(21, 18, 'before', 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=800&h=500&fit=crop&q=85', 'cw_garbage_before_018', NULL, '2026-08-03 10:00:00'),
(22, 18, 'after', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800&h=500&fit=crop&q=85', 'cw_garbage_after_018', 3, '2026-08-08 14:00:00'),
(23, 19, 'before', 'https://images.unsplash.com/photo-1590845947670-c009801ffa74?w=800&h=500&fit=crop&q=85', 'cw_drainage_before_019', NULL, '2026-08-05 08:00:00'),
(24, 19, 'after', 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800&h=500&fit=crop&q=85', 'cw_drainage_after_019', 2, '2026-08-09 15:00:00'),
(25, 20, 'before', 'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=800&h=500&fit=crop&q=85', 'cw_erosion_before_020', NULL, '2026-08-04 09:00:00'),
(26, 20, 'after', 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&h=500&fit=crop&q=85', 'cw_erosion_after_020', 3, '2026-08-10 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `report_timeline`
--

CREATE TABLE `report_timeline` (
  `id` int(10) UNSIGNED NOT NULL,
  `report_id` int(10) UNSIGNED NOT NULL,
  `action` varchar(100) NOT NULL COMMENT 'e.g. status_change, note_added, photo_uploaded',
  `note` text DEFAULT NULL,
  `from_status` enum('submitted','pending','assigned','in_progress','for_resolution','resolved') DEFAULT NULL,
  `to_status` enum('submitted','pending','assigned','in_progress','for_resolution','resolved') DEFAULT NULL,
  `performed_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to users; null = system/citizen',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `report_timeline`
--

INSERT INTO `report_timeline` (`id`, `report_id`, `action`, `note`, `from_status`, `to_status`, `performed_by`, `created_at`) VALUES
(1, 1, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-10 07:15:00'),
(2, 2, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-10 08:30:00'),
(3, 3, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-10 09:00:00'),
(4, 4, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-10 10:00:00'),
(5, 5, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-10 11:00:00'),
(6, 6, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-09 18:30:00'),
(7, 7, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-08 09:00:00'),
(8, 7, 'status_change', 'Report validated by Super Admin.', 'submitted', 'pending', 1, '2026-08-08 14:00:00'),
(9, 7, 'report_assigned', 'Assigned to City Engineering Office. Priority: Medium.', 'pending', 'assigned', 1, '2026-08-09 10:00:00'),
(10, 8, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-08 10:30:00'),
(11, 8, 'status_change', 'Report validated by Super Admin.', 'submitted', 'pending', 1, '2026-08-08 16:00:00'),
(12, 8, 'report_assigned', 'Assigned to CENRO. Priority: High.', 'pending', 'assigned', 1, '2026-08-09 11:00:00'),
(13, 9, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-07 14:00:00'),
(14, 9, 'status_change', 'Report validated by Super Admin.', 'submitted', 'pending', 1, '2026-08-08 08:00:00'),
(15, 9, 'report_assigned', 'Assigned to City Engineering Office. Priority: High.', 'pending', 'assigned', 1, '2026-08-09 09:00:00'),
(16, 10, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-07 08:00:00'),
(17, 10, 'status_change', 'Report validated by Super Admin.', 'submitted', 'pending', 1, '2026-08-08 09:00:00'),
(18, 10, 'report_assigned', 'Assigned to CENRO. Priority: Medium.', 'pending', 'assigned', 1, '2026-08-09 08:30:00'),
(19, 11, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-05 07:00:00'),
(20, 11, 'status_change', 'Report validated by Super Admin.', 'submitted', 'pending', 1, '2026-08-06 08:00:00'),
(21, 11, 'report_assigned', 'Assigned to City Engineering Office. Priority: High.', 'pending', 'assigned', 1, '2026-08-07 09:00:00'),
(22, 11, 'status_change', 'Team deployed to site. Desilting work started.', 'assigned', 'in_progress', 2, '2026-08-09 14:00:00'),
(23, 12, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-04 10:00:00'),
(24, 12, 'status_change', 'Report validated by Super Admin.', 'submitted', 'pending', 1, '2026-08-05 09:00:00'),
(25, 12, 'report_assigned', 'Assigned to CENRO. Priority: High.', 'pending', 'assigned', 1, '2026-08-06 11:00:00'),
(26, 12, 'status_change', 'Site assessment done. Riprap installation started.', 'assigned', 'in_progress', 3, '2026-08-09 13:00:00'),
(27, 13, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-06 09:00:00'),
(28, 13, 'status_change', 'Validated. Signs ordered from supplier.', 'submitted', 'pending', 1, '2026-08-07 10:00:00'),
(29, 13, 'report_assigned', 'Assigned to City Engineering Office. Priority: Low.', 'pending', 'assigned', 1, '2026-08-08 10:00:00'),
(30, 13, 'status_change', 'Road signs delivered. Installation in progress.', 'assigned', 'in_progress', 2, '2026-08-09 15:00:00'),
(31, 14, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-06 11:00:00'),
(32, 14, 'status_change', 'Validated and prioritized.', 'submitted', 'pending', 1, '2026-08-07 11:00:00'),
(33, 14, 'report_assigned', 'Assigned to CENRO. Priority: Medium.', 'pending', 'assigned', 1, '2026-08-08 12:00:00'),
(34, 14, 'status_change', 'Clearing crew dispatched. Work ongoing.', 'assigned', 'in_progress', 3, '2026-08-09 16:00:00'),
(35, 15, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-03 08:00:00'),
(36, 15, 'status_change', 'Validated.', 'submitted', 'pending', 1, '2026-08-03 14:00:00'),
(37, 15, 'report_assigned', 'Assigned to City Engineering Office.', 'pending', 'assigned', 1, '2026-08-04 09:00:00'),
(38, 15, 'status_change', 'Electrician scheduled for repair.', 'assigned', 'in_progress', 2, '2026-08-07 10:00:00'),
(39, 15, 'status_change', 'Streetlight repaired. New LED bulb installed. Area is now well-lit.', 'in_progress', 'resolved', 2, '2026-08-08 17:00:00'),
(40, 16, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-02 09:00:00'),
(41, 16, 'status_change', 'Validated.', 'submitted', 'pending', 1, '2026-08-02 15:00:00'),
(42, 16, 'report_assigned', 'Assigned to CENRO.', 'pending', 'assigned', 1, '2026-08-03 10:00:00'),
(43, 16, 'status_change', 'Cleanup crew deployed.', 'assigned', 'in_progress', 3, '2026-08-06 08:00:00'),
(44, 16, 'status_change', 'Dump site fully cleared. Warning signs installed.', 'in_progress', 'resolved', 3, '2026-08-07 16:00:00'),
(45, 17, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-04 07:00:00'),
(46, 17, 'status_change', 'Validated.', 'submitted', 'pending', 1, '2026-08-04 14:00:00'),
(47, 17, 'report_assigned', 'Assigned to City Engineering Office.', 'pending', 'assigned', 1, '2026-08-05 08:00:00'),
(48, 17, 'status_change', 'Repair team on site. Patching started.', 'assigned', 'in_progress', 2, '2026-08-08 08:00:00'),
(49, 17, 'status_change', 'Pothole patched with asphalt. Road is now smooth.', 'in_progress', 'resolved', 2, '2026-08-09 11:00:00'),
(50, 18, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-03 10:00:00'),
(51, 18, 'status_change', 'Validated.', 'submitted', 'pending', 1, '2026-08-04 09:00:00'),
(52, 18, 'report_assigned', 'Assigned to CENRO.', 'pending', 'assigned', 1, '2026-08-04 10:00:00'),
(53, 18, 'status_change', 'Collection schedule restored for Baracatan.', 'assigned', 'resolved', 3, '2026-08-08 14:00:00'),
(54, 19, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-05 08:00:00'),
(55, 19, 'status_change', 'Validated.', 'submitted', 'pending', 1, '2026-08-05 14:00:00'),
(56, 19, 'report_assigned', 'Assigned to City Engineering Office.', 'pending', 'assigned', 1, '2026-08-06 09:00:00'),
(57, 19, 'status_change', 'Desilting work started.', 'assigned', 'in_progress', 2, '2026-08-08 07:00:00'),
(58, 19, 'status_change', 'Drainage fully cleared. Water flows freely. Flooding resolved.', 'in_progress', 'resolved', 2, '2026-08-09 15:00:00'),
(59, 20, 'report_submitted', 'Report submitted by citizen via mobile app.', NULL, 'submitted', NULL, '2026-08-04 09:00:00'),
(60, 20, 'status_change', 'Validated.', 'submitted', 'pending', 1, '2026-08-05 09:00:00'),
(61, 20, 'report_assigned', 'Assigned to CENRO.', 'pending', 'assigned', 1, '2026-08-05 10:00:00'),
(62, 20, 'status_change', 'Riprap installation started.', 'assigned', 'in_progress', 3, '2026-08-07 08:00:00'),
(63, 20, 'status_change', 'Slope stabilized with riprap and grass cover. Area is now safe.', 'in_progress', 'resolved', 3, '2026-08-10 10:00:00'),
(64, 4, 'report_assigned', 'Assigned to CEO with medium priority. Notes: under construction', 'pending', 'assigned', 1, '2026-09-12 13:28:39');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(191) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('super_admin','ceo','cenro') NOT NULL DEFAULT 'ceo',
  `office` varchar(100) DEFAULT NULL COMMENT 'e.g. CEO, CENRO ??? null for super_admin',
  `avatar_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `office`, `avatar_url`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'System Administrator', 'admin@civilwatch.gov.ph', '$2y$12$s1Vzu15Uv.MPVwc7T2Vq4./nti/GZqcQtknNq8Rul.F0wvxjMBVgq', 'super_admin', NULL, 'https://ui-avatars.com/api/?name=System+Administrator&background=1A56DB&color=fff&size=128', 1, NULL, '2026-08-01 08:00:00', '2026-08-01 08:00:00'),
(2, 'Engr. Miguel Santos', 'ceo@civilwatch.gov.ph', '$2y$12$5dcO09RTGhFsgE3WLVcvJe1QSfDKnig9H5uvaaBhvaKRBu8XQ/lne', 'ceo', 'CEO', 'https://ui-avatars.com/api/?name=Miguel+Santos&background=1A56DB&color=fff&size=128', 1, NULL, '2026-08-01 08:00:00', '2026-08-01 08:00:00'),
(3, 'Ramon Alonzo', 'cenro@civilwatch.gov.ph', '$2y$12$EBaTTstBpFin3BrdTggTS.Nn55zAKo38VtkpW7vgeLCfl6gh1G2jC', 'cenro', 'CENRO', 'https://ui-avatars.com/api/?name=Ramon+Alonzo&background=166534&color=fff&size=128', 1, NULL, '2026-08-01 08:00:00', '2026-08-01 08:00:00'),
(4, 'Super Administrator', 'admin@civilwatch.ph', '$2y$12$vbXtq6iw7PE7O0C5izBK4.SKBjtByFcUw8ylFVmiiMfO0W6STHLnm', 'super_admin', NULL, NULL, 1, NULL, '2026-08-14 06:27:58', '2026-08-14 06:27:58');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `citizens`
--
ALTER TABLE `citizens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `citizens_phone_unique` (`phone`),
  ADD UNIQUE KEY `citizens_email_unique` (`email`);

--
-- Indexes for table `citizen_notifications`
--
ALTER TABLE `citizen_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizen_notifications_citizen_id_foreign` (`citizen_id`),
  ADD KEY `citizen_notifications_citizen_report_id_foreign` (`citizen_report_id`);

--
-- Indexes for table `citizen_reports`
--
ALTER TABLE `citizen_reports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `citizen_reports_reference_number_unique` (`reference_number`),
  ADD KEY `citizen_reports_citizen_id_foreign` (`citizen_id`),
  ADD KEY `citizen_reports_assigned_office_id_foreign` (`assigned_office_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `government_offices`
--
ALTER TABLE `government_offices`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user_id` (`user_id`),
  ADD KEY `idx_notifications_is_read` (`is_read`),
  ADD KEY `idx_notifications_created` (`created_at`),
  ADD KEY `fk_notifications_report` (`report_id`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `otp_codes_phone_index` (`phone`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_reports_reference_no` (`reference_no`),
  ADD KEY `idx_reports_status` (`status`),
  ADD KEY `idx_reports_category` (`category`),
  ADD KEY `idx_reports_barangay` (`barangay`),
  ADD KEY `idx_reports_assigned` (`assigned_to_office`),
  ADD KEY `idx_reports_created_at` (`created_at`);

--
-- Indexes for table `report_activities`
--
ALTER TABLE `report_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `report_activities_citizen_report_id_foreign` (`citizen_report_id`);

--
-- Indexes for table `report_assignments`
--
ALTER TABLE `report_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_assignments_report_id` (`report_id`),
  ADD KEY `fk_assignments_assigner` (`assigned_by`);

--
-- Indexes for table `report_photos`
--
ALTER TABLE `report_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_photos_report_id` (`report_id`),
  ADD KEY `fk_photos_uploader` (`uploaded_by`);

--
-- Indexes for table `report_timeline`
--
ALTER TABLE `report_timeline`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_timeline_report_id` (`report_id`),
  ADD KEY `idx_timeline_created_at` (`created_at`),
  ADD KEY `fk_timeline_performer` (`performed_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `citizens`
--
ALTER TABLE `citizens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `citizen_notifications`
--
ALTER TABLE `citizen_notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `citizen_reports`
--
ALTER TABLE `citizen_reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `government_offices`
--
ALTER TABLE `government_offices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `report_activities`
--
ALTER TABLE `report_activities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `report_assignments`
--
ALTER TABLE `report_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `report_photos`
--
ALTER TABLE `report_photos`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `report_timeline`
--
ALTER TABLE `report_timeline`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `citizen_notifications`
--
ALTER TABLE `citizen_notifications`
  ADD CONSTRAINT `citizen_notifications_citizen_id_foreign` FOREIGN KEY (`citizen_id`) REFERENCES `citizens` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `citizen_notifications_citizen_report_id_foreign` FOREIGN KEY (`citizen_report_id`) REFERENCES `citizen_reports` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `citizen_reports`
--
ALTER TABLE `citizen_reports`
  ADD CONSTRAINT `citizen_reports_assigned_office_id_foreign` FOREIGN KEY (`assigned_office_id`) REFERENCES `government_offices` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `citizen_reports_citizen_id_foreign` FOREIGN KEY (`citizen_id`) REFERENCES `citizens` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `report_activities`
--
ALTER TABLE `report_activities`
  ADD CONSTRAINT `report_activities_citizen_report_id_foreign` FOREIGN KEY (`citizen_report_id`) REFERENCES `citizen_reports` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `report_assignments`
--
ALTER TABLE `report_assignments`
  ADD CONSTRAINT `fk_assignments_assigner` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_assignments_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `report_photos`
--
ALTER TABLE `report_photos`
  ADD CONSTRAINT `fk_photos_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_photos_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `report_timeline`
--
ALTER TABLE `report_timeline`
  ADD CONSTRAINT `fk_timeline_performer` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_timeline_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
--
-- Database: `phpmyadmin`
--
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `phpmyadmin`;

-- --------------------------------------------------------

--
-- Table structure for table `pma__bookmark`
--

CREATE TABLE `pma__bookmark` (
  `id` int(10) UNSIGNED NOT NULL,
  `dbase` varchar(255) NOT NULL DEFAULT '',
  `user` varchar(255) NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `query` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Bookmarks';

-- --------------------------------------------------------

--
-- Table structure for table `pma__central_columns`
--

CREATE TABLE `pma__central_columns` (
  `db_name` varchar(64) NOT NULL,
  `col_name` varchar(64) NOT NULL,
  `col_type` varchar(64) NOT NULL,
  `col_length` text DEFAULT NULL,
  `col_collation` varchar(64) NOT NULL,
  `col_isNull` tinyint(1) NOT NULL,
  `col_extra` varchar(255) DEFAULT '',
  `col_default` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Central list of columns';

-- --------------------------------------------------------

--
-- Table structure for table `pma__column_info`
--

CREATE TABLE `pma__column_info` (
  `id` int(5) UNSIGNED NOT NULL,
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `column_name` varchar(64) NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) NOT NULL DEFAULT '',
  `transformation_options` varchar(255) NOT NULL DEFAULT '',
  `input_transformation` varchar(255) NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__designer_settings`
--

CREATE TABLE `pma__designer_settings` (
  `username` varchar(64) NOT NULL,
  `settings_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Settings related to Designer';

-- --------------------------------------------------------

--
-- Table structure for table `pma__export_templates`
--

CREATE TABLE `pma__export_templates` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `export_type` varchar(10) NOT NULL,
  `template_name` varchar(64) NOT NULL,
  `template_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved export templates';

-- --------------------------------------------------------

--
-- Table structure for table `pma__favorite`
--

CREATE TABLE `pma__favorite` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Favorite tables';

-- --------------------------------------------------------

--
-- Table structure for table `pma__history`
--

CREATE TABLE `pma__history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db` varchar(64) NOT NULL DEFAULT '',
  `table` varchar(64) NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='SQL history for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__navigationhiding`
--

CREATE TABLE `pma__navigationhiding` (
  `username` varchar(64) NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `item_type` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Hidden items of navigation tree';

-- --------------------------------------------------------

--
-- Table structure for table `pma__pdf_pages`
--

CREATE TABLE `pma__pdf_pages` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `page_nr` int(10) UNSIGNED NOT NULL,
  `page_descr` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='PDF relation pages for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__recent`
--

CREATE TABLE `pma__recent` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Recently accessed tables';

--
-- Dumping data for table `pma__recent`
--

INSERT INTO `pma__recent` (`username`, `tables`) VALUES
('root', '[{\"db\":\"civilwatch\",\"table\":\"announcements\"},{\"db\":\"civilwatch\",\"table\":\"cache\"}]');

-- --------------------------------------------------------

--
-- Table structure for table `pma__relation`
--

CREATE TABLE `pma__relation` (
  `master_db` varchar(64) NOT NULL DEFAULT '',
  `master_table` varchar(64) NOT NULL DEFAULT '',
  `master_field` varchar(64) NOT NULL DEFAULT '',
  `foreign_db` varchar(64) NOT NULL DEFAULT '',
  `foreign_table` varchar(64) NOT NULL DEFAULT '',
  `foreign_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Relation table';

-- --------------------------------------------------------

--
-- Table structure for table `pma__savedsearches`
--

CREATE TABLE `pma__savedsearches` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `search_name` varchar(64) NOT NULL DEFAULT '',
  `search_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved searches';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_coords`
--

CREATE TABLE `pma__table_coords` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `pdf_page_number` int(11) NOT NULL DEFAULT 0,
  `x` float UNSIGNED NOT NULL DEFAULT 0,
  `y` float UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table coordinates for phpMyAdmin PDF output';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_info`
--

CREATE TABLE `pma__table_info` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `display_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_uiprefs`
--

CREATE TABLE `pma__table_uiprefs` (
  `username` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `prefs` text NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Tables'' UI preferences';

-- --------------------------------------------------------

--
-- Table structure for table `pma__tracking`
--

CREATE TABLE `pma__tracking` (
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `version` int(10) UNSIGNED NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text NOT NULL,
  `schema_sql` text DEFAULT NULL,
  `data_sql` longtext DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database changes tracking for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__userconfig`
--

CREATE TABLE `pma__userconfig` (
  `username` varchar(64) NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User preferences storage for phpMyAdmin';

--
-- Dumping data for table `pma__userconfig`
--

INSERT INTO `pma__userconfig` (`username`, `timevalue`, `config_data`) VALUES
('root', '2026-09-20 16:58:19', '{\"Console\\/Mode\":\"collapse\"}');

-- --------------------------------------------------------

--
-- Table structure for table `pma__usergroups`
--

CREATE TABLE `pma__usergroups` (
  `usergroup` varchar(64) NOT NULL,
  `tab` varchar(64) NOT NULL,
  `allowed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User groups with configured menu items';

-- --------------------------------------------------------

--
-- Table structure for table `pma__users`
--

CREATE TABLE `pma__users` (
  `username` varchar(64) NOT NULL,
  `usergroup` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and their assignments to user groups';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pma__central_columns`
--
ALTER TABLE `pma__central_columns`
  ADD PRIMARY KEY (`db_name`,`col_name`);

--
-- Indexes for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`);

--
-- Indexes for table `pma__designer_settings`
--
ALTER TABLE `pma__designer_settings`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`);

--
-- Indexes for table `pma__favorite`
--
ALTER TABLE `pma__favorite`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__history`
--
ALTER TABLE `pma__history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`,`db`,`table`,`timevalue`);

--
-- Indexes for table `pma__navigationhiding`
--
ALTER TABLE `pma__navigationhiding`
  ADD PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`);

--
-- Indexes for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  ADD PRIMARY KEY (`page_nr`),
  ADD KEY `db_name` (`db_name`);

--
-- Indexes for table `pma__recent`
--
ALTER TABLE `pma__recent`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__relation`
--
ALTER TABLE `pma__relation`
  ADD PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  ADD KEY `foreign_field` (`foreign_db`,`foreign_table`);

--
-- Indexes for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`);

--
-- Indexes for table `pma__table_coords`
--
ALTER TABLE `pma__table_coords`
  ADD PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`);

--
-- Indexes for table `pma__table_info`
--
ALTER TABLE `pma__table_info`
  ADD PRIMARY KEY (`db_name`,`table_name`);

--
-- Indexes for table `pma__table_uiprefs`
--
ALTER TABLE `pma__table_uiprefs`
  ADD PRIMARY KEY (`username`,`db_name`,`table_name`);

--
-- Indexes for table `pma__tracking`
--
ALTER TABLE `pma__tracking`
  ADD PRIMARY KEY (`db_name`,`table_name`,`version`);

--
-- Indexes for table `pma__userconfig`
--
ALTER TABLE `pma__userconfig`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__usergroups`
--
ALTER TABLE `pma__usergroups`
  ADD PRIMARY KEY (`usergroup`,`tab`,`allowed`);

--
-- Indexes for table `pma__users`
--
ALTER TABLE `pma__users`
  ADD PRIMARY KEY (`username`,`usergroup`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__history`
--
ALTER TABLE `pma__history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  MODIFY `page_nr` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- Database: `test`
--
CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `test`;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
