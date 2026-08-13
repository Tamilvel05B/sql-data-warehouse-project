# 🏢 Data Warehouse & Analytics Project

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)
![ETL](https://img.shields.io/badge/ETL-Pipeline-blue)
![Data Modeling](https://img.shields.io/badge/Data%20Model-Star%20Schema-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

Welcome to the **Data Warehouse & Analytics Project**! This repository showcases the end-to-end development of a modern data warehouse and analytics solution — built following the **Medallion Architecture** — designed to transform raw, messy source data into clean, reliable, business-ready insights.

This project demonstrates industry best practices in:

- 🏗️ Designing scalable data warehouse architectures
- 🔄 Building efficient ETL/ELT data pipelines
- ⭐ Implementing dimensional data models (Star Schema)
- 🧹 Applying data cleansing, standardization, and quality checks
- 📝 Writing optimized SQL for analytics and reporting
- 📊 Creating insightful, business-friendly reports
- 🔐 Applying data quality and governance principles

Whether you're a recruiter, hiring manager, fellow data professional, or someone passionate about data engineering and analytics, this repository offers a practical, hands-on look at designing and implementing a robust analytics platform from the ground up.

---

## 📑 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Project Requirements](#-project-requirements)
  - [Building the Data Warehouse (Data Engineering)](#️-building-the-data-warehouse-data-engineering)
  - [BI: Analytics & Reporting](#-bi-analytics--reporting-data-analysis)
- [Repository Structure](#-repository-structure)
- [Tools & Technologies](#-tools--technologies)
- [Data Flow](#-data-flow)
- [How to Use](#-how-to-use)
- [License](#-license)
- [About Me](#-about-me)

---

## 🏛️ Architecture Overview

This project follows the **Medallion Architecture** (Bronze → Silver → Gold) to progressively refine data from raw ingestion to analytics-ready models.

| Layer | Purpose | Description |
|-------|---------|-------------|
| 🥉 **Bronze** | Raw ingestion | Source CRM & ERP CSV files loaded as-is via `BULK INSERT`, no transformations |
| 🥈 **Silver** | Cleaned & standardized | Data cleansing, deduplication, type casting, and business rule application |
| 🥇 **Gold** | Business-ready | Star schema (fact & dimension views) optimized for reporting and analytics |

```
Source Systems (CRM & ERP CSVs)
        │
        ▼
   🥉 Bronze Layer   →  Raw data, 1:1 load from source
        │
        ▼
   🥈 Silver Layer   →  Cleaned, standardized, deduplicated
        │
        ▼
   🥇 Gold Layer     →  Star schema (Fact & Dimension views)
        │
        ▼
   📊 BI & Reporting →  Power BI / SQL-based Analytics
```

---

## 🚀 Project Requirements

This project is divided into two core phases: **Data Engineering** and **Business Intelligence (BI) & Analytics**. The primary objective is to build a modern data warehouse and generate actionable business insights using SQL Server.

### 🏗️ Building the Data Warehouse (Data Engineering)

**Objective**
Design and develop a modern **SQL Server** data warehouse that consolidates sales data from multiple business systems into a centralized repository for analytics and reporting.

**Requirements**

- **Data Sources:** Import and integrate data from two source systems (**ERP** and **CRM**) provided as CSV files.
- **Data Quality:** Clean, validate, and standardize the data by resolving missing values, duplicates, inconsistencies, and other quality issues.
- **Data Integration:** Merge data from both source systems into a unified, business-friendly dimensional data model optimized for analytical queries.
- **Scope:** Process only the latest available dataset. Historical tracking (historization) is outside the scope of this project.
- **Documentation:** Provide comprehensive documentation of the data model, including tables, relationships, and business definitions to support both technical and business users.

### 📊 BI: Analytics & Reporting (Data Analysis)

**Objective**
Develop SQL-based analytical solutions that transform warehouse data into meaningful business insights for data-driven decision-making.

**Analytics Focus Areas**

| Focus Area | Key Analyses |
|------------|--------------|
| 👥 **Customer Behavior** | Customer segmentation, purchase patterns, customer lifetime value, retention analysis |
| 📦 **Product Performance** | Best- and worst-selling products, category analysis, revenue contribution, inventory insights |
| 📈 **Sales Trends** | Monthly & yearly performance, revenue growth, seasonal trends, key sales KPIs |

**Expected Outcome**

The project delivers a scalable analytics platform that enables stakeholders to:

- ✅ Make informed, data-driven business decisions
- ✅ Monitor business performance through reliable metrics
- ✅ Identify customer and product trends
- ✅ Support strategic planning with actionable insights

---

## 📂 Repository Structure

```
data-warehouse-project/
│
├── datasets/                      # Raw source CSV files (CRM & ERP)
│   ├── crm/
│   └── erp/
│
├── scripts/
│   ├── bronze/                    # Bronze layer DDL + load procedures
│   ├── silver/                    # Silver layer DDL + load procedures
│   └── gold/                      # Gold layer views (star schema)
│
├── tests/                         # Data quality & validation checks
│     ├── silver/                    # Silver Layer Quality Checks
|     └── gold/                      # Gold Layer
├── docs/
│   ├── data_architecture.png      # Overall architecture diagram
│   ├── data_flow.png              # Data flow diagram
│   ├── data_model.png             # Star schema diagram
│   └── naming_conventions.md      # Naming standards used across layers
│
├── README.md
└── LICENSE
```

---

## 🛠️ Tools & Technologies

- **SQL Server / SSMS** — Data warehouse engine & development environment
- **T-SQL** — ETL logic, stored procedures, and analytical queries
- **Draw.io** — Architecture, data flow, and data model diagrams
- **Git & GitHub** — Version control and project documentation
- **Power BI (optional/next phase)** — Dashboards and visual reporting

---

## 🔄 Data Flow

1. **Extract** — CSV files from CRM and ERP source systems are bulk-loaded into the **Bronze** layer with no transformations.
2. **Transform** — Data is cleaned, deduplicated, standardized (naming, codes, formats), and validated in the **Silver** layer.
3. **Load** — Business-ready **Gold** layer views expose a star schema (fact tables + dimension tables) for reporting.
4. **Analyze** — SQL-based analytical queries and/or Power BI dashboards consume the Gold layer to surface customer, product, and sales insights.

---

## ▶️ How to Use

1. Clone this repository.
2. Run the DDL scripts in `scripts/bronze/`, `scripts/silver/`, and `scripts/gold/` in order to create the schemas and tables.
3. Update file paths in `bronze.load_bronze` to point to your local `datasets/` folder.
4. Execute the load procedures:
   ```sql
   EXEC bronze.load_bronze;
   EXEC silver.load_silver;
   ```
5. Query the Gold layer views for analytics, or connect Power BI/SSMS for reporting.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE). You are free to **use**, **modify**, **distribute**, and **share** this project with proper attribution.

---

## 👋 About Me

Hi, I'm **Tamilvel** — a **Power BI Developer & Data Analyst** with hands-on experience across healthcare, telecom, and manufacturing, and a strong interest in **Data Engineering** and **Business Intelligence**. I enjoy building scalable data solutions, designing data warehouses, and transforming raw data into actionable insights that support smarter business decisions.

📫 **Let's connect:**
[LinkedIn](https://www.linkedin.com/in/tamilvel-b-059301240/?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base_contact_details%3B7YlJ6wgJTImiGgWcaM%2Fwkg%3D%3D) • [GitHub](Github) •

*(Replace the links above with your actual profile URLs)*
