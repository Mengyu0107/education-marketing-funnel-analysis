/*
Project: Education Marketing Funnel Analysis
File: 02_import_raw_data.sql
Purpose: Import the four raw CSV datasets into MySQL.

Prerequisites:
1. Run 01_create_schema.sql first.
2. Enable local file loading on the server:
      SET GLOBAL local_infile = 1;
3. Open the MySQL command-line client with:
      mysql --local-infile=1 -u root -p

Source-file mapping:
- D21_detailed_data.csv -> D21_detailed_data
- sign_in_509.csv       -> sign_in_509
- purchase_record.csv   -> purchase_record
- record_detail.csv     -> record_detail

Note:
`purchase_record.csv` and `有赞买券表.csv` are duplicate exports.
Import only ONE of them.
*/

USE education_marketing_funnel;


/* =========================================================
   OPTIONAL RESET
   =========================================================
   Run these only when you want to reload all four raw tables
   from the beginning. They remove rows but keep table schemas.

TRUNCATE TABLE D21_detailed_data;
TRUNCATE TABLE sign_in_509;
TRUNCATE TABLE purchase_record;
TRUNCATE TABLE record_detail;
*/


/* =========================================================
   1. RESERVATION DATA
   Grain: one reservation record
   ========================================================= */

LOAD DATA LOCAL INFILE
'C:/Users/汪萌予/OneDrive - University College London/桌面/实习/数据/D21_detailed_data.csv'
INTO TABLE D21_detailed_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    记录编号,
    二维码名称,
    称呼,
    手机号,
    年级,
    预计参与人数,
    学习意向校区,
    填表人,
    填写方式
);


/* =========================================================
   2. EVENT ATTENDANCE DATA
   Grain: one check-in record
   ========================================================= */

LOAD DATA LOCAL INFILE
'C:/Users/汪萌予/OneDrive - University College London/桌面/实习/数据/sign_in_509.csv'
INTO TABLE sign_in_509
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    手机号,
    是否出席,
    出席人数,
    验证时间
);


/* =========================================================
   3. COUPON PURCHASE DATA
   Grain: one purchase order

   Import purchase_record.csv OR 有赞买券表.csv, not both.
   ========================================================= */

LOAD DATA LOCAL INFILE
'C:/Users/汪萌予/OneDrive - University College London/桌面/实习/数据/purchase_record.csv'
INTO TABLE purchase_record
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    订单号,
    商品名称,
    订单状态,
    手机号,
    商品退款状态,
    商品已退款金额,
    买家付款时间,
    交易成功时间,
    应收订单金额,
    订单实付金额,
    买家备注,
    买家名称
);


/* =========================================================
   4. RECEIPT AND COUPON REDEMPTION DATA
   Grain: one receipt-detail record
   ========================================================= */

LOAD DATA LOCAL INFILE
'C:/Users/汪萌予/OneDrive - University College London/桌面/实习/数据/record_detail.csv'
INTO TABLE record_detail
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    交费日期,
    收据号,
    学号,
    姓名,
    手机号,
    优惠券名称,
    实交金额,
    校区,
    收据类型,
    状态,
    签单类型,
    业绩归属人,
    外部备注,
    内部备注,
    核销指定券情况
);


/* =========================================================
   5. IMPORT VALIDATION
   ========================================================= */

SELECT
    'D21_detailed_data' AS table_name,
    COUNT(*) AS row_count
FROM D21_detailed_data

UNION ALL

SELECT
    'sign_in_509',
    COUNT(*)
FROM sign_in_509

UNION ALL

SELECT
    'purchase_record',
    COUNT(*)
FROM purchase_record

UNION ALL

SELECT
    'record_detail',
    COUNT(*)
FROM record_detail;


/* Check whether the purchase file was accidentally imported twice. */

SELECT
    COUNT(*) AS purchase_rows,
    COUNT(DISTINCT 订单号) AS distinct_purchase_orders,
    COUNT(*) - COUNT(DISTINCT 订单号) AS duplicate_order_rows
FROM purchase_record;


/* Preview a few rows from each raw table. */

SELECT * FROM D21_detailed_data LIMIT 5;
SELECT * FROM sign_in_509 LIMIT 5;
SELECT * FROM purchase_record LIMIT 5;
SELECT * FROM record_detail LIMIT 5;


