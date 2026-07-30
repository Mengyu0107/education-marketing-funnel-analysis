/*
Project: Education Marketing Funnel Analysis
Purpose: Create raw source tables for the 9 May 2025 campaign.
Database: MySQL 8.0+

Before running LOAD DATA INFILE, replace @data_dir with the directory allowed by
MySQL's secure_file_priv setting. The repository CSV files contain anonymised /
portfolio data only if publication has been approved.
*/

CREATE DATABASE IF NOT EXISTS education_marketing_funnel
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE education_marketing_funnel;

SET @data_dir = 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/';

DROP TABLE IF EXISTS D21_detailed_data;
CREATE TABLE D21_detailed_data (
    记录编号       VARCHAR(50),
    二维码名称     VARCHAR(255),
    称呼           VARCHAR(100),
    手机号         VARCHAR(50),
    年级           VARCHAR(100),
    预计参与人数   VARCHAR(20),
    学习意向校区   VARCHAR(255),
    填表人         VARCHAR(100),
    填写方式       VARCHAR(100)
);

DROP TABLE IF EXISTS sign_in_509;
CREATE TABLE sign_in_509 (
    手机号       VARCHAR(50),
    是否出席     VARCHAR(20),
    出席人数     VARCHAR(20),
    验证时间     VARCHAR(50)
);

DROP TABLE IF EXISTS purchase_record;
CREATE TABLE purchase_record (
    订单号           VARCHAR(100),
    商品名称         VARCHAR(255),
    订单状态         VARCHAR(50),
    手机号           VARCHAR(50),
    商品退款状态     VARCHAR(100),
    商品已退款金额   VARCHAR(50),
    买家付款时间     VARCHAR(50),
    交易成功时间     VARCHAR(50),
    应收订单金额     VARCHAR(50),
    订单实付金额     VARCHAR(50),
    买家备注         VARCHAR(500),
    买家名称         VARCHAR(100)
);

DROP TABLE IF EXISTS record_detail;
CREATE TABLE record_detail (
    交费日期         VARCHAR(50),
    收据号           VARCHAR(100),
    学号             VARCHAR(100),
    姓名             VARCHAR(100),
    手机号           VARCHAR(50),
    优惠券名称       VARCHAR(500),
    实交金额         VARCHAR(50),
    校区             VARCHAR(255),
    收据类型         VARCHAR(100),
    状态             VARCHAR(100),
    签单类型         VARCHAR(100),
    业绩归属人       VARCHAR(255),
    外部备注         VARCHAR(2000),
    内部备注         VARCHAR(1000),
    核销指定券情况   VARCHAR(100)
);

/* Optional internal source: one row per enrolled course. */
DROP TABLE IF EXISTS record_with_grade;
CREATE TABLE record_with_grade (
    交费日期       VARCHAR(50),
    收据号         VARCHAR(100),
    手机号         VARCHAR(50),
    课程名称       VARCHAR(500),
    课程所属校区   VARCHAR(255),
    课程名称地点   VARCHAR(255)
);

/* Optional internal source: campaign-attributed enrolled customers. */
DROP TABLE IF EXISTS class_tel;
CREATE TABLE class_tel (
    手机号       VARCHAR(50),
    二维码名称   VARCHAR(255)
);

/* Optional internal source: all enrolled customers, including historical ones. */
DROP TABLE IF EXISTS total_class_tel;
CREATE TABLE total_class_tel (
    手机号       VARCHAR(50),
    二维码名称   VARCHAR(255)
);

/*
Example import command. MySQL does not support concatenating @data_dir directly
inside LOAD DATA INFILE, so edit the paths below before execution.

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/D21_detailed_data.csv'
INTO TABLE D21_detailed_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(记录编号, 二维码名称, 称呼, 手机号, 年级, 预计参与人数, 学习意向校区, 填表人, 填写方式);

Repeat the same pattern for sign_in_509.csv, purchase_record.csv,
record_detail.csv, and the optional internal enrollment files.
*/