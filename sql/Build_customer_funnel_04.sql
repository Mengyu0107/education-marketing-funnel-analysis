/*
Purpose: Build one customer-level record across the complete campaign funnel.
Grain: One row per reserved mobile number.

Important assumptions recovered from the original analysis:
- Mobile number is the cross-system customer identifier.
- Target coupon names contain '25暑1000抵2000优惠券'.
- New Senior One summer courses contain '新高一'.
- Enrolments dated 5-5 to 5-8 were treated as pre-campaign and excluded.
*/

USE education_marketing_funnel;

SET @campaign_date = DATE('2025-05-09');
SET @target_coupon_pattern = '%25暑1000抵2000优惠券%';
SET @target_course_pattern = '%新高一%';

SELECT
    coupon_name,
    COUNT(*) AS usage_count
FROM clean_receipts
WHERE coupon_name IS NOT NULL
GROUP BY coupon_name
ORDER BY usage_count DESC;

CREATE OR REPLACE VIEW reservation_base AS
SELECT
    phone,
    MIN(reservation_id) AS reservation_id,
    MAX(raw_channel) AS raw_channel,
    MAX(channel_group) AS channel_group,
    MAX(student_grade) AS student_grade,
    MAX(preferred_campus) AS preferred_campus,
    MAX(COALESCE(expected_attendees, 1)) AS expected_attendees
FROM clean_reservations
GROUP BY phone;

CREATE OR REPLACE VIEW attendance_by_customer AS
SELECT
    phone,
    MAX(attended) AS attended,
    MAX(COALESCE(attendee_count, 0)) AS attendee_count
FROM clean_attendance
GROUP BY phone;

CREATE OR REPLACE VIEW purchase_by_customer AS
SELECT
    phone,
    MAX(valid_purchase) AS purchased_coupon,
    COUNT(DISTINCT CASE WHEN valid_purchase = 1 THEN order_id END) AS purchase_orders,
    SUM(CASE WHEN valid_purchase = 1 THEN COALESCE(paid_amount, 0) ELSE 0 END)
        AS coupon_purchase_value,
    MIN(CASE WHEN valid_purchase = 1 THEN paid_at END) AS first_purchase_at
FROM clean_purchases
GROUP BY phone;

CREATE OR REPLACE VIEW receipt_by_customer AS
SELECT
    phone,
    MAX(CASE WHEN coupon_name LIKE '%25暑1000抵2000优惠券%' THEN 1 ELSE 0 END)
        AS redeemed_target_coupon,
    COUNT(DISTINCT CASE
        WHEN coupon_name LIKE '%25暑1000抵2000优惠券%' THEN receipt_id
    END) AS target_coupon_redemptions,
    SUM(CASE WHEN payment_amount > 0 THEN payment_amount ELSE 0 END) AS gmv,
    SUM(CASE
        WHEN coupon_name LIKE '%25暑1000抵2000优惠券%' AND payment_amount > 0
        THEN payment_amount ELSE 0
    END) AS strong_related_gmv
FROM clean_receipts
GROUP BY phone;

CREATE OR REPLACE VIEW enrolment_by_customer AS
SELECT
    phone,
    MAX(CASE WHEN enrolment_date >= DATE('2025-05-09') THEN 1 ELSE 0 END) AS enrolled,
    MAX(CASE
        WHEN enrolment_date >= DATE('2025-05-09')
         AND course_name LIKE '%新高一%'
        THEN 1 ELSE 0
    END) AS enrolled_target_course,
    COUNT(DISTINCT CASE
        WHEN enrolment_date >= DATE('2025-05-09') THEN course_name
    END) AS enrolled_course_count,
    MIN(CASE WHEN enrolment_date >= DATE('2025-05-09') THEN enrolment_date END)
        AS first_enrolment_date
FROM clean_enrolments
GROUP BY phone;

CREATE OR REPLACE VIEW customer_funnel AS
SELECT
    r.phone,
    r.reservation_id,
    r.raw_channel,
    r.channel_group,
    r.student_grade,
    r.preferred_campus,
    r.expected_attendees,
    COALESCE(a.attended, 0) AS attended,
    COALESCE(a.attendee_count, 0) AS attendee_count,
    COALESCE(p.purchased_coupon, 0) AS purchased_coupon,
    COALESCE(p.purchase_orders, 0) AS purchase_orders,
    COALESCE(p.coupon_purchase_value, 0) AS coupon_purchase_value,
    p.first_purchase_at,
    COALESCE(rc.redeemed_target_coupon, 0) AS redeemed_target_coupon,
    COALESCE(rc.target_coupon_redemptions, 0) AS target_coupon_redemptions,
    COALESCE(e.enrolled, 0) AS enrolled,
    COALESCE(e.enrolled_target_course, 0) AS enrolled_target_course,
    COALESCE(e.enrolled_course_count, 0) AS enrolled_course_count,
    e.first_enrolment_date,
    COALESCE(rc.gmv, 0) AS gmv,
    COALESCE(rc.strong_related_gmv, 0) AS strong_related_gmv
FROM reservation_base r
LEFT JOIN attendance_by_customer a USING (phone)
LEFT JOIN purchase_by_customer p USING (phone)
LEFT JOIN receipt_by_customer rc USING (phone)
LEFT JOIN enrolment_by_customer e USING (phone);

/* Validation */
SELECT COUNT(*) AS customer_count
FROM receipt_by_customer;

SELECT
    redeemed_target_coupon,
    COUNT(*) AS customer_count
FROM receipt_by_customer
GROUP BY redeemed_target_coupon;

SELECT
    COUNT(*) AS redeemed_customers,
    SUM(target_coupon_redemptions) AS redemption_count,
    SUM(gmv) AS total_gmv,
    SUM(strong_related_gmv) AS strong_related_gmv
FROM receipt_by_customer
WHERE redeemed_target_coupon = 1;

/* Check gmv, phone number to find potential errors in calculation*/
SELECT
    MIN(gmv) AS min_gmv,
    MAX(gmv) AS max_gmv,
    AVG(gmv) AS avg_gmv,
    SUM(gmv) AS total_gmv
FROM receipt_by_customer;

SELECT
    phone,
    target_coupon_redemptions,
    gmv,
    strong_related_gmv
FROM receipt_by_customer
WHERE target_coupon_redemptions > 1
ORDER BY target_coupon_redemptions DESC, strong_related_gmv DESC;
