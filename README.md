# Olist E-commerce Performance & Delivery Analysis

An end-to-end analysis of ~100K orders from a Brazilian online marketplace (Olist): sales trends, product categories, delivery performance, customer behaviour and payment methods. Data was loaded into **SQL Server**, analysed with **T-SQL**, and presented in a two-page **Power BI** dashboard.

**Tools:** SQL Server (T-SQL), Power BI (DAX), Python (Pandas, SQLAlchemy, pyodbc) for data loading

### Highlights

- **R$ 15.4M** revenue from **96K delivered orders** (Sep 2016 to Aug 2018)
- Late deliveries (about **8%** of orders) cut review scores from **4.3 to 2.6**
- Only **3%** of customers ever ordered twice, so growth depends on new customers
- Rio de Janeiro, the #2 market, has a **13.5%** late rate, more than double São Paulo's

---

## Dashboard preview

**Page 1: Sales Overview**



**Page 2: Delivery & Customer Satisfaction**


---

## Objective

Answer five business questions:

1. How have revenue and orders changed over time?
2. Which product categories drive the most revenue?
3. How fast does Olist deliver, and where are deliveries slowest or most often late?
4. Does late delivery hurt customer satisfaction?
5. How much revenue comes from repeat customers, and how do customers pay?

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle): 8 related tables (orders, items, payments, reviews, customers, products, sellers, category translations).
Orders span **4 Sep 2016 to 17 Oct 2018**. All amounts are in **Brazilian reals (R$)**.

## Definitions and data notes

- **Revenue (payments):** total `payment_value` of *delivered* orders (includes freight). Used for monthly trends, repeat customers and the dashboard's Total Revenue.
- **Revenue (product):** sum of item `price` for *delivered* orders (excludes freight). Used for category rankings.
- **Late order:** delivered after the estimated delivery date.
- **Repeat customer:** a `customer_unique_id` with 2+ delivered orders (`customer_id` changes per order, so it cannot identify a person).
- **Payment-method analysis** in SQL covers all orders, not only delivered ones, so its total differs slightly from the monthly revenue total.
- **Late % differs slightly between tools:** SQL gives about 8.0% (orders that have a review), Power BI shows 8.11% (all delivered orders with a delivery date).
- **Incomplete periods:** late 2016 has almost no data (Oct 2016 has 265 orders, Dec 2016 has 1, and Sep/Nov 2016 have none). Delivered orders in 2018 run through August only. Month-over-month growth for early 2017 is therefore distorted and should not be read as real growth.

---

## Key findings

### 1. Revenue grew rapidly through 2017, then levelled off in 2018
- Delivered-order revenue was **R$ 6.92M in 2017** and **R$ 8.45M in Jan–Aug 2018**. Comparing the same eight months, 2018 revenue was **about 143% higher** than 2017 (R$ 8.45M vs R$ 3.47M), and orders rose about 140% (52,783 vs 21,998).
- Monthly revenue rose from **R$ 127.5K (Jan 2017)** to a plateau of **roughly R$ 1.0–1.13M per month** in 2018.
- Growth stalled in 2018: monthly revenue stayed in a narrow band, and August 2018 (R$ 985K) was below the March–May level (R$ 1.12–1.13M).

### 2. November 2017 was the strongest spike, followed by a pullback
- November 2017 reached **R$ 1.15M from 7,289 orders**, up **53.6% on October** (orders +63%). This coincides with Black Friday, though the data alone cannot prove the cause.
- December 2017 then fell **26.9%** to R$ 843K.
- Average order value was fairly stable (about R$ 155–170), so growth came mainly from **more orders**, not larger baskets.

### 3. A handful of categories lead product revenue
Top 5 by product revenue (delivered orders):

| Rank | Category               | Revenue (R$) | Orders |
|------|------------------------|--------------|--------|
| 1    | health_beauty          | 1,233,132    | 8,647  |
| 2    | watches_gifts          | 1,166,177    | 5,495  |
| 3    | bed_bath_table         | 1,023,435    | 9,272  |
| 4    | sports_leisure         | 954,853      | 7,530  |
| 5    | computers_accessories  | 888,725      | 6,530  |

- The top 3 categories alone generated **R$ 3.42M**, and the top 10 together about **R$ 8.25M**.
- **watches_gifts** earns more than **bed_bath_table** with about 40% fewer orders, so it has a much higher revenue per order.

### 4. health_beauty overtook bed_bath_table as the #1 category
- In 2017 the ranking was bed_bath_table (R$ 491K), watches_gifts (R$ 476K), health_beauty (R$ 474K).
- In 2018 health_beauty moved to **#1 with R$ 756K** in only eight months, already **about 59% above its full-year 2017 revenue**.

### 5. Delivery speed varies enormously by state
- **São Paulo (SP)**, the largest market (about 42% of delivered orders), has the fastest average delivery at **8.7 days**.
- The slowest states are in the north: **Roraima (29.3 days)**, **Amapá (27.2)** and **Amazonas (26.4)**, about three times slower than SP. (These are small markets: RR has 41 orders and AP 67.)
- Late-delivery rates are highest in **Alagoas (23.9%)**, **Maranhão (19.7%)** and **Piauí (16.0%)**, versus **5.9% in SP**.
- **Rio de Janeiro** stands out: it is the second-largest market (12,350 orders) but **13.5% of its orders arrive late**.

### 6. Late delivery is strongly associated with poor reviews
- About **8% of orders (7,661)** were delivered late.
- On-time orders average **4.29 / 5** in review score; late orders average **2.57 / 5**, a gap of **1.72 points**.

### 7. Almost all customers buy only once
- Only **3.0% of customers (2,801)** ordered more than once, and they account for **5.6% of revenue (R$ 0.86M)**.
- **94.4% of revenue (R$ 14.6M)** comes from one-time customers.

### 8. Credit cards dominate payments
- **Credit cards: about 78% of payment revenue** (R$ 12.5M), with the highest average payment (R$ 163).
- **Boleto** (a Brazilian bank-slip payment) is second at about **18%** (R$ 2.9M).
- Vouchers are used on 3,866 orders but have a much smaller average payment (R$ 66).

---

## Recommendations

1. **Fix late deliveries in the worst regions.** Late orders score 1.72 points lower, so improving carriers or delivery estimates in Alagoas, Maranhão, Piauí and especially Rio de Janeiro (large volume, 13.5% late) should have the biggest effect on satisfaction.
2. **Set realistic delivery estimates for distant states.** Northern states average 20+ days; more accurate promises would reduce "late" orders even if shipping speed is unchanged.
3. **Invest in retention.** With only 3% of customers returning, even a small repeat-purchase programme (follow-up offers, loyalty rewards) could add meaningful revenue.
4. **Plan for the November peak.** Stock and logistics capacity should be ready ahead of Black Friday, since November 2017 orders jumped 63%.
5. **Prioritise health_beauty and watches_gifts** in marketing and inventory, as the #1 and #2 categories by revenue.

## About the dashboard

- **Model:** 7 tables in Import mode, linked by `order_id`, `customer_id`, `product_id` and category name, plus a date table related to the order date.
- **Key DAX measures:** Total Revenue, Total Orders, Avg Order Value, Product Revenue, Avg Review Score, Avg Delivery Days, Late %.
- **Calculated columns:** Order Date, Delivery Days, Is Late, Delivery Status.
- **Interactivity:** Year and State slicers, page navigation buttons.

## Limitations

- Correlation is not causation. The link between late delivery and low reviews is strong, but other factors (product quality, seller issues) were not controlled for.
- Data ends in 2018, and some months are incomplete (see Definitions).
- Small states have few orders, so their averages are less reliable.

---

## Project structure

```
olist-ecommerce-analysis/
├── data/          # raw CSVs (not committed, download from Kaggle)
├── notebooks/     # load_data.py: loads CSVs into SQL Server
├── sql/           # analysis.sql: T-SQL queries behind the findings
├── outputs/       # query results exported as CSV
├── dashboard/     # Power BI file and dashboard screenshots
└── README.md
```

## How to reproduce

1. Download the dataset from Kaggle and place the CSV files in `data/`.
2. Create an empty database named `olist` in SQL Server.
3. Install the packages: `pip install pandas sqlalchemy pyodbc`.
4. Run `python notebooks/load_data.py` (edit `SERVER` and `DRIVER` at the top; it uses Windows Authentication, so no password is stored).
5. Run the queries in `sql/analysis.sql` in SQL Server Management Studio.
6. Open the Power BI file in `dashboard/` and refresh it against your own SQL Server instance.

## Author

**Dameruppula Ajay**: B.Tech (AI & ML) student, Hyderabad, looking for data analyst roles and internships.

[LinkedIn](https://www.linkedin.com/in/23c41a6602) · [GitHub](https://github.com/dameruppulaajay43) · [Portfolio](https://ajay-career.vercel.app)
