/*
Purpose: Produce channel-level funnel totals and conversion rates.
Output: channel_funnel_metrics view

Cost is intentionally not hard-coded because the original notes state that it
was supplied externally. Populate campaign_channel_cost before calculating cost
per attendee or ROI.
*/

USE education_marketing_funnel;

CREATE TABLE IF NOT EXISTS campaign_channel_cost (
    channel_group VARCHAR(100) PRIMARY KEY,
    campaign_cost DECIMAL(12,2) NOT NULL DEFAULT 0
);

CREATE OR REPLACE VIEW channel_funnel_metrics AS
WITH totals AS (
    SELECT
        channel_group,
        COUNT(*) AS reservations,
        SUM(attended) AS attendees,
        SUM(attendee_count) AS attendee_headcount,
        SUM(purchased_coupon) AS coupon_buyers,
        SUM(redeemed_target_coupon) AS coupon_redeemers,
        SUM(enrolled) AS enrolled_customers,
        SUM(enrolled_target_course) AS target_course_customers,
        SUM(enrolled_course_count) AS enrolled_courses,
        SUM(gmv) AS gmv,
        SUM(strong_related_gmv) AS strong_related_gmv
    FROM customer_funnel
    GROUP BY channel_group
)
SELECT
    t.channel_group,
    t.reservations,
    t.attendees,
    t.attendee_headcount,
    t.coupon_buyers,
    t.coupon_redeemers,
    t.enrolled_customers,
    t.target_course_customers,
    t.enrolled_courses,
    ROUND(t.gmv, 2) AS gmv,
    ROUND(t.strong_related_gmv, 2) AS strong_related_gmv,
    ROUND(c.campaign_cost, 2) AS campaign_cost,
    ROUND(t.attendees / NULLIF(t.reservations, 0), 4) AS attendance_rate,
    ROUND(c.campaign_cost / NULLIF(t.attendees, 0), 2) AS cost_per_attendee,
    ROUND(t.coupon_buyers / NULLIF(t.attendees, 0), 4) AS attendee_to_purchase_rate,
    ROUND(t.coupon_redeemers / NULLIF(t.coupon_buyers, 0), 4) AS purchase_to_redemption_rate,
    ROUND(t.coupon_redeemers / NULLIF(t.attendees, 0), 4) AS attendee_to_redemption_rate,
    ROUND(t.coupon_redeemers / NULLIF(t.reservations, 0), 4) AS reservation_to_redemption_rate,
    ROUND(t.enrolled_courses / NULLIF(t.enrolled_customers, 0), 2) AS courses_per_customer,
    ROUND(t.gmv / NULLIF(t.enrolled_customers, 0), 2) AS average_revenue_per_customer,
    ROUND(t.strong_related_gmv / NULLIF(c.campaign_cost, 0), 4) AS strong_related_roi
FROM totals t
LEFT JOIN campaign_channel_cost c USING (channel_group);

SELECT *
FROM channel_funnel_metrics
ORDER BY strong_related_gmv DESC, reservations DESC;

/* Validation */

SELECT
    SUM(reservations) AS reservations,
    SUM(attendees) AS attendees,
    SUM(coupon_buyers) AS coupon_buyers,
    SUM(coupon_redeemers) AS coupon_redeemers,
    SUM(gmv) AS gmv,
    SUM(strong_related_gmv) AS strong_related_gmv
FROM channel_funnel_metrics;

SELECT
    COUNT(*) AS reservations,
    SUM(attended) AS attendees,
    SUM(purchased_coupon) AS coupon_buyers,
    SUM(redeemed_target_coupon) AS coupon_redeemers,
    SUM(gmv) AS gmv,
    SUM(strong_related_gmv) AS strong_related_gmv
FROM customer_funnel;

/* summary:
- Campus generated fewer reservations than Headquarters but achieved higher attendance, purchase, and coupon-redemption conversion rates.
- Campus produced the highest campaign-related GMV, indicating stronger downstream customer quality.
- Zhiban Community attracted substantial reservation volume but experienced significant drop-off between attendance, coupon purchase, and redemption.
*/