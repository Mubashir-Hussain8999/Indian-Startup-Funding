# Indian Startup Funding Analysis (2015–2020)

An end-to-end data analytics project on **3,037 startup funding rounds** in India. Raw data was cleaned and explored in **Python**, queried in **SQL Server**, visualised in a **Power BI** dashboard, and also published as an interactive **web dashboard** (HTML + Chart.js).

**Live web dashboard:** https://mubashir-hussain8999.github.io/indian-startup-funding-dashboard/

---

## Dashboard Preview

| Executive Overview | Sector & Geography | Investors & Startups |
|---|---|---|
| ![Executive Overview](screenshots/executive-overview.png) | ![Sector & Geography](screenshots/sector-geography.png) | ![Investors & Startups](screenshots/investors-startups.png) |

---

## Project Workflow

```
Raw CSV (3,044 rows) → Python cleaning & EDA → Cleaned CSV (3,037 rows)
                                            ↘ SQL Server analysis (24 query sections)
                                            ↘ Power BI dashboard (3 pages)
                                            ↘ Web dashboard (GitHub Pages)
```

## Business Questions

1. Which sectors received the highest total funding?
2. Which cities attracted the most funding?
3. Which investors participated in the most deals?
4. How has funding changed over the years?
5. Which investment types received the most capital?
6. Which startups raised the largest amounts?
7. Which sectors have the highest average deal size?
8. How does deal count compare with total funding?
9. Which cities dominate which sectors?
10. How concentrated is funding among a few large deals?

## Data Cleaning (Python)

| Step | Detail |
|---|---|
| Column names | Renamed to a clean format (`Startup_Name`, `Funding_USD`, `Investment_Type`, ...) |
| Duplicates | Checked – 0 duplicate rows |
| Text | Removed non-breaking spaces, extra whitespace and trailing commas |
| Dates | Converted to datetime (day-first); **7 invalid dates removed** → 3,044 → 3,037 rows |
| Funding amount | Removed commas, converted to numeric; **971 rows have no disclosed amount** (kept as null, not filled with 0) so the 2,066 disclosed deals give honest averages |
| Categories | Standardised industry labels (e.g. `ecommerce` → `e-commerce`), merged investment-type variants (e.g. `seed funding`, `seed / angel funding` → `seed round`) |
| Cities | `Bangalore → Bengaluru`, `Gurgaon → Gurugram`, `Delhi → New Delhi`, multi-city entries → `Multiple Locations` |
| Features | Added `Year`, `Month`, `Month_Name`, `Quarter`, `Year_Month` |
| Investors | Multi-investor deals split into one row per investor **in a separate analysis table** to avoid double-counting funding |

## Key Metrics

| Metric | Value |
|---|---|
| Total funding | **$38.12B** |
| Funding rounds | **3,037** (2,066 with a disclosed amount) |
| Unique startups | 2,452 |
| Average disclosed deal | $18.45M |
| Median disclosed deal | $1.77M |
| Largest deal | $3.9B (Rapido Bike Taxi, 2019) |
| Top 10 deals' share of funding | 34.8% |
| Top 50 deals' share of funding | 57.3% |

## Key Insights

- **Funding is highly concentrated.** The top 10 deals make up ~35% of all funding, and the average ($18.45M) is ~10x the median ($1.77M). IQR analysis flags 284 outlier deals above ~$19.4M.
- **Bengaluru dominates.** $18.48B (~48% of funding) across 583 disclosed deals, followed by Mumbai ($4.93B), Gurugram and New Delhi.
- **E-commerce leads by capital, consumer internet by volume.** E-commerce raised $8.25B in 204 deals; consumer internet raised $6.25B across 589 deals (smaller average ticket).
- **Late-stage rounds carry the money.** Private equity rounds account for $27.26B (~71% of funding); seed rounds are the most frequent deal type.
- **Volume and value moved differently.** Deal count fell from 649 (2015) to 456 (2017) while funding rose from $8.67B to $10.43B, meaning fewer but larger rounds. Year-over-year: 2016 −56%, 2017 +172%, 2018 −51%, 2019 +89%. 2020 shows only $0.39B and should be read as incomplete.
- **Top investors by deal count:** Sequoia Capital (68 disclosed-amount deals), Accel Partners (60), SAIF Partners (48).
- **Top startups by funding:** Flipkart ($4.06B, 5 rounds), Rapido Bike Taxi ($3.9B), Paytm.

## SQL Analysis (SQL Server / T-SQL)

`Indian_Startup_Funding.sql` contains 24 query sections:

- **Exploration & KPIs:** record count, unique startups, total / average / median funding
- **Aggregations:** sector, city, investment type, startup, investor rankings
- **Time series:** yearly, monthly and quarterly funding, year-over-year growth
- **Window functions & CTEs:** `LAG`, `RANK`, `ROW_NUMBER`, `NTILE`, running totals, top sector per city
- **Concentration:** share of total funding from the top 10 deals
- **Data quality:** missing values and distinct-count checks
- **Investor normalisation:** a `funding_investors` table (one row per investor per deal) joined back to the main table

## Power BI Dashboard

Three pages: **Executive Overview**, **Sector & Geography**, **Investors & Startups**.

- KPI cards, annual funding trend, top sectors and cities, investment-type breakdown, sector share donut, top investors, top startups, and a largest-deals table
- Year and Industry slicers synced across pages
- Custom theme (`theme/StartupFunding-Theme.json`)
- Star-style model: main funding table + `DateTable` + `Investors` table linked on `Sr_No`

```DAX
Total Funding   = SUM ( Funding[Funding_USD] )
Total Deals     = COUNTROWS ( Funding )
Disclosed Deals = COUNTROWS ( FILTER ( Funding, NOT ISBLANK ( Funding[Funding_USD] ) ) )
Total Startups  = DISTINCTCOUNT ( Funding[Startup_Name] )
Average Funding = AVERAGE ( Funding[Funding_USD] )
Median Funding  = MEDIAN ( Funding[Funding_USD] )
Investor Deals  = DISTINCTCOUNT ( Investors[Sr_No] )
```

## Web Dashboard

`index.html` is a single-file interactive version of the dashboard (Chart.js) that runs on GitHub Pages. It merges a few obvious name variants (e.g. Flipkart / Flipkart.com) and counts investor deals across all rounds, so a few figures differ slightly from the notebook.

## Tech Stack

Python (Pandas, NumPy, Matplotlib, Seaborn) · Jupyter Notebook · SQL Server (T-SQL) · Power BI (Power Query, DAX) · HTML / CSS / JavaScript (Chart.js)

## Repository Structure

```
indian-startup-funding-dashboard/
├── index.html                              # Web dashboard (GitHub Pages)
├── notebooks/
│   └── Indian_Startup_Funding.ipynb        # Cleaning + EDA
├── sql/
│   └── Indian_Startup_Funding.sql          # 24 SQL analysis queries
├── PowerBI/
│   └── Indian_Startup_Funding_Dashboard.pbix
├── data/
│   └── Indian_Startup_Funding_Cleaned.csv
├── theme/
│   └── StartupFunding-Theme.json
├── screenshots/
└── README.md
```

## How to Use

- **Web:** open `index.html` or the live link above.
- **Power BI:** open the `.pbix` in Power BI Desktop. If the data source path breaks, go to *Transform data → Data source settings → Change source* and select `data/Indian_Startup_Funding_Cleaned.csv`.
- **Notebook:** open in Jupyter or Google Colab and load the raw `startup_funding.csv`.
- **SQL:** create a `startup_funding` table in SQL Server from the cleaned CSV, then run the queries in order.

## Limitations

- 31.5% of rounds have no disclosed amount, so funding totals cover only disclosed deals.
- The dataset ends early in 2020, so 2020 is incomplete.
- Amounts are in USD as reported and are not inflation-adjusted.

## Author

**Mubashir Hussain** – Data Analyst
[LinkedIn](https://linkedin.com/in/mubashir-hussain-365407321) · [GitHub](https://github.com/Mubashir-Hussain8999)
