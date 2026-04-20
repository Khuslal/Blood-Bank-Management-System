-- ------------------------------------------------------
-- 1. DATABASE INITIALIZATION
-- ------------------------------------------------------
CREATE DATABASE IF NOT EXISTS blood_bank;
USE blood_bank;

-- ------------------------------------------------------
-- 2. CLEANUP (Ignore the 'Unknown table' warnings)
-- ------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS blood_stock_summary;
DROP TABLE IF EXISTS fulfilled_donations;
DROP TABLE IF EXISTS donors;
DROP TABLE IF EXISTS system_alerts;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS blood_requests;
DROP TABLE IF EXISTS blood_stock;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------
-- 3. TABLE STRUCTURES
-- ------------------------------------------------------

-- Physical table to track current stock levels
CREATE TABLE `blood_stock` (
  `blood_group` varchar(5) NOT NULL,
  `total_units` int DEFAULT 0,
  PRIMARY KEY (`blood_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `blood_group` varchar(5) DEFAULT NULL,
  `password` varchar(64) NOT NULL,
  `role` varchar(20) DEFAULT 'User',
  `points` int DEFAULT 0,
  `last_donation_date` date DEFAULT NULL,
  `donation_count` int DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `blood_requests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `hospital_name` varchar(100) DEFAULT NULL,
  `blood_group` varchar(5) DEFAULT NULL,
  `units_requested` int DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `request_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `system_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `blood_group` varchar(5) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------
-- 4. DATA INSERTION
-- ------------------------------------------------------

-- Initializing stock levels
INSERT INTO `blood_stock` (`blood_group`, `total_units`) VALUES 
('O+', 50), ('O-', 10), ('A+', 30), ('A-', 15), ('B+', 40), ('B-', 12), ('AB+', 20), ('AB-', 8);

INSERT INTO `users` (`name`, `username`, `email`, `blood_group`, `password`, `role`) VALUES
('System Admin', 'admin', 'admin@bloodbank.com', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Admin'),
('Suman Hamal', 'suman123', 'suman@email.com', 'O+', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 'User');

INSERT INTO `blood_requests` (`hospital_name`, `blood_group`, `units_requested`, `status`) VALUES
('City Hospital', 'O-', 2, 'Pending'),
('Teaching Hospital', 'A-', 2, 'Pending');

-- ------------------------------------------------------
-- 5. TRIGGER (This will now update the blood_stock table)
-- ------------------------------------------------------
DELIMITER //

CREATE TRIGGER update_stock_after_request
AFTER UPDATE ON blood_requests
FOR EACH ROW
BEGIN
    -- Only subtract from stock if the status changes from Pending to Approved
    IF NEW.status = 'Approved' AND OLD.status = 'Pending' THEN
        UPDATE blood_stock 
        SET total_units = total_units - NEW.units_requested
        WHERE blood_group = NEW.blood_group;
    END IF;
END //

DELIMITER ;

-- ------------------------------------------------------
-- 6. VERIFICATION
-- ------------------------------------------------------

-- Show current stock before update
SELECT 'Before Approval' as info, blood_group, total_units FROM blood_stock WHERE blood_group = 'O-';

-- Simulate an approval
UPDATE blood_requests SET status = 'Approved' WHERE request_id = 1;

-- Show current stock after update (O- should be 8 now)
SELECT 'After Approval' as info, blood_group, total_units FROM blood_stock WHERE blood_group = 'O-';
