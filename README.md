# education-marketing-funnel-analysis

## Project Overview
This project analyzes an offline education marketing campaign using SQL.

The objective is to evaluate the effectiveness of different acquisition channels by tracking customers throughout the complete marketing funnel, from reservation to final course enrollment.

The project integrates multiple business datasets, including reservation records, attendance records, coupon purchases, coupon redemption records, and enrollment transactions, to generate business KPIs that support marketing decisions.

## Business Background
Offline educational seminars are one of the major customer acquisition channels.

After each event, the business team needs to answer questions such as:

• Which marketing channel attracted the highest-quality users to the seminars?
• Which channel generated the highest ROI?
• What percentage of reserved users actually attended?
• How many attendees purchased promotional coupons?
• How many coupon buyers eventually enrolled?

This project builds an end-to-end SQL workflow to answer these questions.

## Analysis workflow
- Raw CSV Files
- MySQL Raw Tables
- Data Cleaning Views
- Customer-level Funnel Construction
- Channel-level KPI Aggregation
- Data Quality Validation
- Business Insights

## Dataset overview

### D21_detailed_data
| Column | Description |
|---------|-------------|
| `记录编号` | Record ID |
| `二维码名称` | Acquisition channel |
| `称呼` | Customer name |
| `手机号` | Mobile number (Primary Key) |
| `年级` | Student grade |
| `预计参与人数` | Expected number of participants |
| `学习意向校区` | Preferred campus |
| `填表人` | Form submitter |
| `填写方式` | Submission method |

### sign_in_509
| Column | Description |
|---------|-------------|
| `手机号` | Mobile number (Primary Key) |
| `是否出席` | Attendance status |
| `出席人数` | Number of attendees |
| `验证时间` | Check-in time |

### purchase_record
| Column | Description |
|---------|-------------|
| `订单号` | Order ID |
| `商品名称` | Product name |
| `订单状态` | Order status |
| `手机号` | Mobile number (Primary Key) |
| `商品退款状态` | Refund status |
| `买家付款时间` | Payment time |
| `交易成功时间` | Transaction completion time |
| `应收订单金额` | Original order amount |
| `订单实付金额` | Actual payment amount |

### record_detail

| Column | Description |
|---------|-------------|
| `交费日期` | Payment date |
| `收据号` | Receipt ID |
| `学号` | Student ID |
| `姓名` | Student name |
| `手机号` | Mobile number (Primary Key) |
| `优惠券名称` | Coupon name |
| `实交金额` | Payment amount |
| `校区` | Campus |
| `收据类型` | Receipt type |
| `状态` | Record status |


## SQL techniques used
• INNER JOIN
• LEFT JOIN
• GROUP BY
• CASE WHEN
• DISTINCT
• REGEXP
• Aggregate Functions
• Temporary Tables
• Data Cleaning
• Funnel Analysis

## Result Metrics

| Column                           | Definition                                                                         | Formula / Notes                                                                            |
| -------------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `channel_group`                  | Marketing channel category assigned to each reservation.                           | Derived from QR code / reservation source during data cleaning.                            |
| `reservations`                   | Number of unique customers who submitted seminar reservations through the channel. | Customer-level reservation count.                                                          |
| `attendees`                      | Number of unique customers who attended the seminar.                               | Customers with successful attendance records.                                              |
| `attendee_headcount`             | Total number of attendees, including accompanying family members.                  | May be greater than `attendees` because one reservation may include multiple participants. |
| `coupon_buyers`                  | Number of customers who purchased the campaign coupon.                             | Customer-level binary aggregation after deduplication.                                     |
| `coupon_redeemers`               | Number of customers who redeemed the target campaign coupon.                       | Customer-level binary aggregation after deduplication.                                     |
| `enrolled_customers`             | Number of customers who enrolled in courses after the campaign.                    | Reserved for future extension. Enrollment dataset unavailable in this public version.      |
| `target_course_customers`        | Number of customers enrolled in the target course.                                 | Reserved for future extension.                                                             |
| `enrolled_courses`               | Total number of enrolled courses.                                                  | Reserved for future extension.                                                             |
| `gmv`                            | Gross Merchandise Value generated by matched customers.                            | Sum of all positive payment amounts.                                                       |
| `strong_related_gmv`             | Revenue directly associated with the target campaign coupon.                       | Sum of payment amounts where the target coupon was redeemed.                               |
| `attendance_rate`                | Percentage of reserved customers who attended the seminar.                         | `attendees / reservations`                                                                 |
| `attendee_to_purchase_rate`      | Percentage of attendees who purchased the campaign coupon.                         | `coupon_buyers / attendees`                                                                |
| `purchase_to_redemption_rate`    | Percentage of coupon buyers who redeemed the campaign coupon.                      | `coupon_redeemers / coupon_buyers`                                                         |
| `attendee_to_redemption_rate`    | Percentage of attendees who ultimately redeemed the campaign coupon.               | `coupon_redeemers / attendees`                                                             |
| `reservation_to_redemption_rate` | Overall conversion from reservation to coupon redemption.                          | `coupon_redeemers / reservations`                                                          |

### Metric Notes
- All metrics are calculated at the customer level, with duplicate reservations consolidated by phone number.
- 'gmv' represents the total positive transaction value generated by matched customers.
- 'strong_related_gmv' only includes revenue directly attributable to the target campaign coupon.
- Enrollment-related metrics (enrolled_customers, target_course_customers, and enrolled_courses) were included in the SQL pipeline for extensibility but are unavailable because the enrollment dataset was not provided.
- Marketing cost data was also unavailable. Once campaign cost information becomes available, additional metrics such as Cost per Attendee and Campaign ROI can be calculated without changing the existing SQL workflow.

## Key Findings

The analysis identified several meaningful differences in marketing channel performance during the May 9 seminar campaign.

- **Headquarters** generated the largest reservation volume, making it the primary customer acquisition channel.
- **Campus** achieved the strongest downstream performance, producing higher attendance, coupon purchase, coupon redemption rates, and the highest campaign-related GMV despite attracting fewer reservations than Headquarters.
- **Zhiban Community** generated a moderate number of reservations and attendees but experienced substantial drop-off during coupon purchase and redemption, indicating opportunities to improve post-event conversion.
- Customer-level deduplication successfully prevented duplicate reservations from inflating funnel metrics, ensuring that each customer contributed only once to the final analysis.

## Limitations

Several business constraints should be considered when interpreting the results.

- Customer matching relies solely on **phone numbers**. In some cases, different family members may use different phone numbers for reservation, attendance, and payment, preventing automatic record linkage.
- The payment dataset covers **all transactions within three days after the seminar**, including existing student renewals and customers acquired through channels unrelated to the event. Therefore, unmatched payment records do not necessarily indicate data quality issues.
- Course enrollment data was unavailable in the public dataset. As a result, enrollment-related metrics were designed in the SQL pipeline but could not be calculated.
- Campaign cost information was not available, preventing the calculation of marketing efficiency metrics such as cost per attendee and ROI.

## Future Improvements

The SQL pipeline was designed to support additional business datasets without requiring major structural changes. The current workflow is modular, allowing additional business datasets and KPIs to be incorporated with minimal modifications to the existing SQL pipeline.

Future enhancements may include:

- Integrating campaign cost data to calculate **Cost per Attendee**, **Channel ROI**, and additional marketing efficiency metrics.
- Incorporating course enrollment records to measure end-to-end conversion from reservation to course enrollment and evaluate customer lifetime value.
- Introducing a household or student identifier to improve customer matching across reservation, attendance, and payment records, reducing unmatched records caused by family members using different phone numbers.
- Extending the framework to support multiple marketing campaigns for longitudinal channel performance analysis.

