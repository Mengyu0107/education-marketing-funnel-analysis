/*
Purpose: Standardise identifiers and convert text fields to analysis-ready types.
Inputs: Raw tables created in 01_create_schema.sql
Outputs: clean_* views
*/

USE education_marketing_funnel;

DROP FUNCTION IF EXISTS clean_phone;
DELIMITER $$
CREATE FUNCTION clean_phone(raw_phone VARCHAR(100))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN REGEXP_REPLACE(TRIM(raw_phone), '[^0-9]', '');
END$$
DELIMITER ;

CREATE OR REPLACE VIEW clean_reservations AS
SELECT
    记录编号 AS reservation_id,
    clean_phone(手机号) AS phone,
    NULLIF(TRIM(二维码名称), '') AS raw_channel,
    CASE
        WHEN 二维码名称 LIKE '%总部直播%' THEN 'Headquarters Livestream'
        WHEN 二维码名称 LIKE '%总部%' THEN 'Headquarters'
        WHEN 二维码名称 LIKE '%知伴社群%' THEN 'Zhiban Community'
        WHEN 二维码名称 LIKE '%渠道_知伴%' THEN 'Zhiban Channel'
        WHEN 二维码名称 LIKE '%校区%' THEN 'Campus'
        WHEN 二维码名称 LIKE '%数学王老师%' THEN 'Teacher Wang'
        WHEN 二维码名称 LIKE '%西玲%' THEN 'Xiling'
        WHEN 二维码名称 LIKE '%千帆%' THEN 'Qianfan'
        WHEN 二维码名称 LIKE '%魔都升学圈%' THEN 'Modu Education Community'
        WHEN 二维码名称 LIKE '%哈童%' THEN 'Hatong'
        WHEN 二维码名称 LIKE '%品牌%' THEN 'Brand'
        WHEN 二维码名称 LIKE '%教学%' THEN 'Teaching Team'
        WHEN 二维码名称 LIKE '%程大帅%' THEN 'Cheng Dashuai'
        WHEN 二维码名称 LIKE '%陈无极%' THEN 'Chen Wuji'
        WHEN 二维码名称 LIKE '%Y%' THEN 'Channel Y'
        WHEN NULLIF(TRIM(二维码名称), '') IS NULL THEN 'Unknown'
        ELSE 'Other'
    END AS channel_group,
    NULLIF(TRIM(称呼), '') AS customer_name,
    NULLIF(TRIM(年级), '') AS student_grade,
    CAST(NULLIF(REGEXP_REPLACE(预计参与人数, '[^0-9.]', ''), '') AS DECIMAL(10,2))
        AS expected_attendees,
    NULLIF(TRIM(学习意向校区), '') AS preferred_campus,
    NULLIF(TRIM(填表人), '') AS submitted_by,
    NULLIF(TRIM(填写方式), '') AS submission_method
FROM D21_detailed_data
WHERE LENGTH(clean_phone(手机号)) >= 7;

CREATE OR REPLACE VIEW clean_attendance AS
SELECT
    clean_phone(手机号) AS phone,
    CASE WHEN LOWER(TRIM(是否出席)) IN ('y', 'yes', '是') THEN 1 ELSE 0 END AS attended,
    CAST(NULLIF(REGEXP_REPLACE(出席人数, '[^0-9.]', ''), '') AS DECIMAL(10,2))
        AS attendee_count,
    NULLIF(TRIM(验证时间), '') AS check_in_time
FROM sign_in_509
WHERE LENGTH(clean_phone(手机号)) >= 7;

CREATE OR REPLACE VIEW clean_purchases AS
SELECT
    NULLIF(TRIM(订单号), '') AS order_id,
    clean_phone(手机号) AS phone,
    NULLIF(TRIM(商品名称), '') AS product_name,
    NULLIF(TRIM(订单状态), '') AS order_status,
    NULLIF(TRIM(商品退款状态), '') AS refund_status,
    STR_TO_DATE(NULLIF(TRIM(买家付款时间), ''), '%Y/%c/%e %H:%i') AS paid_at,
    STR_TO_DATE(NULLIF(TRIM(交易成功时间), ''), '%Y/%c/%e %H:%i') AS completed_at,
    CAST(NULLIF(REGEXP_REPLACE(应收订单金额, '[^0-9.-]', ''), '') AS DECIMAL(12,2))
        AS gross_order_amount,
    CAST(NULLIF(REGEXP_REPLACE(订单实付金额, '[^0-9.-]', ''), '') AS DECIMAL(12,2))
        AS paid_amount,
    CAST(NULLIF(REGEXP_REPLACE(商品已退款金额, '[^0-9.-]', ''), '') AS DECIMAL(12,2))
        AS refunded_amount,
    CASE
        WHEN 订单状态 = '已完成'
             AND COALESCE(商品退款状态, '') NOT LIKE '%全额退款%'
        THEN 1 ELSE 0
    END AS valid_purchase
FROM purchase_record
WHERE LENGTH(clean_phone(手机号)) >= 7;

CREATE OR REPLACE VIEW clean_receipts AS
SELECT
    NULLIF(TRIM(收据号), '') AS receipt_id,
    clean_phone(手机号) AS phone,
    STR_TO_DATE(NULLIF(TRIM(交费日期), ''), '%Y/%c/%e') AS payment_date,
    NULLIF(TRIM(优惠券名称), '') AS coupon_name,
    CAST(NULLIF(REGEXP_REPLACE(实交金额, '[^0-9.-]', ''), '') AS DECIMAL(12,2))
        AS payment_amount,
    NULLIF(TRIM(校区), '') AS campus,
    NULLIF(TRIM(收据类型), '') AS receipt_type,
    NULLIF(TRIM(核销指定券情况), '') AS designated_coupon_redemption
FROM record_detail
WHERE LENGTH(clean_phone(手机号)) >= 7;

CREATE OR REPLACE VIEW clean_enrolments AS
SELECT
    clean_phone(手机号) AS phone,
    STR_TO_DATE(NULLIF(TRIM(交费日期), ''), '%Y/%c/%e') AS enrolment_date,
    NULLIF(TRIM(收据号), '') AS receipt_id,
    NULLIF(TRIM(课程名称), '') AS course_name,
    NULLIF(TRIM(课程所属校区), '') AS course_campus
FROM record_with_grade
WHERE LENGTH(clean_phone(手机号)) >= 7;

/* Validation */

SELECT 'clean_reservations' AS view_name, COUNT(*) AS row_count
FROM clean_reservations

UNION ALL

SELECT 'clean_attendance', COUNT(*)
FROM clean_attendance

UNION ALL

SELECT 'clean_purchases', COUNT(*)
FROM clean_purchases

UNION ALL

SELECT 'clean_receipts', COUNT(*)
FROM clean_receipts

UNION ALL

SELECT 'clean_enrolments', COUNT(*)
FROM clean_enrolments;
