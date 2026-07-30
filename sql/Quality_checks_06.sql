/*
Purpose: Validate the joins and identify issues before publishing results.
These queries should return either zero rows or explainable exceptions.
*/

USE education_marketing_funnel;

-- Invalid or unusually short phone identifiers.
SELECT 'reservations' AS source_table, 手机号 AS raw_phone
FROM D21_detailed_data
WHERE LENGTH(clean_phone(手机号)) < 7
UNION ALL
SELECT 'attendance', 手机号
FROM sign_in_509
WHERE LENGTH(clean_phone(手机号)) < 7
UNION ALL
SELECT 'purchases', 手机号
FROM purchase_record
WHERE LENGTH(clean_phone(手机号)) < 7
UNION ALL
SELECT 'receipts', 手机号
FROM record_detail
WHERE LENGTH(clean_phone(手机号)) < 7;

-- Duplicate reservation identifiers.
SELECT reservation_id, COUNT(*) AS duplicate_rows
FROM clean_reservations
GROUP BY reservation_id
HAVING COUNT(*) > 1;

-- Customers with multiple raw acquisition channels.
SELECT phone, COUNT(DISTINCT raw_channel) AS channel_count
FROM clean_reservations
GROUP BY phone
HAVING COUNT(DISTINCT raw_channel) > 1;

/* Customer Deduplication Validation

A small number of customers registered through multiple marketing channels.

To prevent duplicate attribution, the customer funnel was validated to ensure:

- One row per customer (phone number)
- No duplicated customer records
- No duplicated GMV or conversion events
 */

SELECT
    phone,
    COUNT(*) AS row_count
FROM customer_funnel
GROUP BY phone
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

SELECT
    COUNT(*) AS funnel_rows,
    COUNT(DISTINCT phone) AS distinct_customers,
    COUNT(*) - COUNT(DISTINCT phone) AS duplicate_rows
FROM customer_funnel;

/*
Validation result:

- `COUNT(*) = COUNT(DISTINCT phone)`
- No duplicated phone numbers detected

Therefore, downstream funnel metrics are calculated at the customer level rather than the reservation level.
*/

-- Purchases that cannot be matched to a reservation.
SELECT
    COUNT(DISTINCT p.phone) AS unmatched_purchase_customers
FROM clean_purchases p
LEFT JOIN reservation_base r USING (phone)
WHERE r.phone IS NULL;

-- Attendance records that cannot be matched to a reservation.
SELECT
    COUNT(DISTINCT a.phone) AS unmatched_attendance_customers
FROM clean_attendance a
LEFT JOIN reservation_base r USING (phone)
WHERE r.phone IS NULL;

/*
Unmatched Enrollment Records

Validation identified a number of attendance and receipt records without matching seminar reservations.

These unmatched records are expected and can be explained by several business scenarios rather than data quality issues.

Possible explanations include:

The receipt dataset contains all transactions recorded during the three-day observation window, including existing students renewing courses and customers acquired through channels unrelated to the seminar.
In family-based enrollment scenarios, one guardian may complete the seminar reservation while another guardian attends the event or completes the payment using a different phone number.
Reservation, attendance, and payment records are linked only by phone number. Without a household or student identifier, legitimate family-level matches cannot always be identified automatically.

Therefore, these unmatched records reflect differences in business processes and identifier granularity rather than missing or incorrect data.

Future improvements could introduce a household or student identifier to replace phone-number-based matching, reducing unmatched records caused by family members using different contact numbers across reservation, attendance, and payment records.
*/
CREATE OR REPLACE VIEW unmatched_attendance AS
SELECT a.*
FROM clean_attendance a
LEFT JOIN clean_reservations r
    ON a.phone = r.phone
WHERE r.phone IS NULL;

SELECT COUNT(DISTINCT phone)
FROM unmatched_attendance;

CREATE OR REPLACE VIEW unmatched_receipt_customers AS
SELECT rb.*
FROM receipt_by_customer rb
LEFT JOIN clean_reservations r
    ON rb.phone = r.phone
WHERE r.phone IS NULL;

SELECT COUNT(DISTINCT phone)
FROM unmatched_receipt_customers;


-- Funnel sanity check: later stages may exceed earlier stages when customers
-- enter through untracked channels; investigate rather than silently deleting.
SELECT
    channel_group,
    reservations,
    attendees,
    coupon_buyers,
    coupon_redeemers,
    enrolled_customers
FROM channel_funnel_metrics
WHERE attendees > reservations
   OR coupon_redeemers > coupon_buyers;
