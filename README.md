# 🚀 VM Autoescola - Automations & Infrastructure

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![n8n](https://img.shields.io/badge/n8n-EA4B71?style=for-the-badge&logo=n8n&logoColor=white)
![Odoo](https://img.shields.io/badge/Odoo%2017-714B67?style=for-the-badge&logo=odoo&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![WhatsApp](https://img.shields.io/badge/Evolution_API-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash_Script-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Rclone](https://img.shields.io/badge/Rclone-3F89F8?style=for-the-badge&logo=rclone&logoColor=white)
![Google Drive](https://img.shields.io/badge/Google_Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)

Complete automation stack and infrastructure documentation for **VM Autoescola**, featuring **n8n** workflows, **Odoo 17 CRM** integration, **Evolution API** WhatsApp notifications, and automated daily **Docker** infrastructure backups to **Google Drive**.

---

## 🏗️ System Architecture

```mermaid
graph TD
    subgraph Docker Infrastructure
        A[Odoo 17 CRM] -->|Reads/Writes| B[(PostgreSQL 15)]
        B -->|SQL Query: Active Leads| C[n8n Workflows]
        D[Redis] --> E[Evolution API]
    end

    F[Google Calendar] -->|Holiday Triggers| C
    C -->|Sanitized JSON Payload| E
    E -->|Automated WhatsApp| G((Students))

    subgraph Disaster Recovery
        H[Cron Job - 19:00] -->|Executes| I[/opt/backup.sh/]
        I -->|pg_dumpall| B
        I -->|tar.gz Volumes| A
        I -->|Rclone Sync| J[(Google Drive Cloud)]
    end
```

---

## 📅 Chronological Implementation History

### 1. Odoo 17 Integration & Active Leads Filtering
- **Objective:** Dynamically query the Odoo database to extract active students only, excluding those who have already completed the process (`Concluído / CNH Emitida`).
- **Implementation:** Custom SQL query utilizing subqueries and null handling in PostgreSQL to join the `crm_lead` and `crm_stage` tables.

### 2. WhatsApp Automations via Evolution API (n8n)
- **Holiday Notifications:**  
  - Integrated with **Google Calendar** to detect scheduled holidays.
  - Uses a `Switch` node to route messages based on the student's gender (`M` / Female / Neutral).
  - Phone number sanitization with special character removal (`replace(/\D/g, '')`) and dynamic extraction of the first name (`split(' ')[0]`) to personalize communication.
- **Completion Congratulations:**
  - Automated daily workflow that checks for students moved to the completion stage on the previous day and dispatches a personalized congratulatory message for their driver's license (CNH) issuance.

### 3. Backup & Security Infrastructure (Docker & Rclone)
- **Architecture:** Linux Docker server hosting **Odoo 17**, **n8n**, **Evolution API**, **Redis**, and **PostgreSQL**.
- **Daily Backup Strategy (19:00):**
  - Automated script (`/opt/backup.sh`) configured via `cron`.
  - Performs a complete PostgreSQL database dump (`pg_dumpall`).
  - Compresses Docker configuration directories and volumes.
  - Securely uploads the compressed package to a dedicated folder in **Google Drive** using **Rclone**.

---

## 🛠️ Tools & Technical Setup

### 1. n8n (Self-Hosted Workflow Automation)
- **Role:** Orchestrates webhook triggers, cron schedules, and data processing.
- **Configuration:**
  - Running in Docker via container `n8n`.
  - Authenticated via n8n REST API Keys for automated internal maintenance and reporting workflows.
  - Environment variables configured for timezone (`America/Fortaleza`) and secure webhook URLs.

### 2. Odoo 17 ERP & PostgreSQL 15
- **Role:** Core CRM and database backend (`vm-autoescola-db-1` & `vm-autoescola-web-1`).
- **Configuration:**
  - Custom PostgreSQL queries leveraging `crm_lead` and `crm_stage` tables to filter active leads (`Concluído / CNH Emitida` exclusion).
  - Automated daily database dumps via `pg_dumpall` inside the container lifecycle.

### 3. Evolution API & Redis (WhatsApp Gateway)
- **Role:** Multi-device WhatsApp instance manager and cache layer (`evolution-api` & `evolution-redis`) for automated outbound notifications.
- **Configuration:**
  - Containerized deployment communicating with n8n HTTP Request nodes.
  - Payload structure utilizing regex sanitization (`replace(/\D/g, '')`) for phone numbers and dynamic first-name extraction.

### 4. Rclone & Google Drive Backup Strategy
- **Role:** Cloud disaster recovery and automated storage synchronization.
- **Configuration:**
  - Configured via `rclone config` using OAuth2 port forwarding and the Google Drive remote (`gdrive:`).
  - Automated cron job executed daily at 19:00 (`0 19 * * * /bin/bash /opt/backup.sh`) combining database dumps and Docker directory archives (`/home/suporte/vm-autoescola`).

---

## 📂 Repository Structure

```text
vm-autoescola-automations/
├── scripts/
│   └── backup.sh                  # Automated PostgreSQL dump & Rclone cloud sync script
├── sql/
│   └── active_leads_filter.sql    # Odoo 17 PostgreSQL query for active students
├── workflows/
│   ├── holiday_notifications.json # n8n workflow for Google Calendar & WhatsApp alerts
│   └── cnh_congratulations.json   # n8n workflow for CNH completion messages
└── README.md                      # Project documentation and architecture overview
```

---

## 🔒 Security & Compliance
- **Data Sanitization:** All sensitive credentials, database passwords, API keys, and environment variables (`.env`) are strictly excluded from this repository.
- **Privacy & LGPD Compliance:** Student phone numbers and personal records are processed dynamically in-memory during workflow execution and are never exposed in public logs or version control.
