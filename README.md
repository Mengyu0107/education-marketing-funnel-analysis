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
1. Import raw data from csv files
2. Clean data
3. Remove historical enrollments
4. Join datasets
5. Build customer funnel
6. Calculate KPIs
7. Segment by acquisition channel
8. Generate business report

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

### class_tel

| Column | Description |
|---------|-------------|
| `手机号` | Mobile number (Primary Key) |
| `课程名称` | Course name |
| `年级` | Student grade |
| `报课日期` | Enrollment date |
| `校区` | Campus |

> **Note:** This table records course enrollment information and is used to identify enrolled users, enrollment counts, and summer course registrations.

### total_class_tel

| Column | Description |
|---------|-------------|
| `手机号` | Mobile number (Primary Key) |
| `历史报课记录` | Historical enrollment records |

> **Note:** This table is used to exclude users who enrolled before the campaign, ensuring that only new conversion users are included in the analysis.

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

## Metrics
| Metric | Description |
|---------|-------------|
| Reservation | Number of reserved users |
| Attendance | Number of attendees |
| Coupon Purchase | Number of Purchased coupons |
| Coupon Redemption | Redeemed users |
| Enrollment | Enrolled students |
| GMV | Gross Merchandise Value |
| ROI | Return on Investment |
