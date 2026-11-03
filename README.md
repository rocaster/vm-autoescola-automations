![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![n8n](https://img.shields.io/badge/n8n-EA4B71?style=for-the-badge&logo=n8n&logoColor=white)
![Odoo](https://img.shields.io/badge/Odoo%2017-714B67?style=for-the-badge&logo=odoo&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

# vm-autoescola-automations
Complete automation stack for driving schools, featuring n8n workflows, Odoo 17 CRM integration, Evolution API WhatsApp notifications, and automated daily Docker infrastructure backups to Google Drive.

---

# 🚀 VM Autoescola - Automations & Infrastructure

Centralized repository containing documentation, n8n workflows, database scripts, and backup routines for the VM Autoescola infrastructure.

---

## 📅 Chronological Implementation History

### 1. Odoo 17 Integration & Active Leads Filtering
- **Objective:** Dynamically query the Odoo database to extract active students only, excluding those who have already completed the process (`Concluído / CNH Emitida`).
- **Implementation:** Custom SQL query utilizing subqueries and null handling in PostgreSQL to join the `crm_lead` and `crm_stage` tables.

### 2. WhatsApp Automations via Evolution API (n8n)
- **Holiday Notifications:**  
  * Integrated with **Google Calendar** to detect scheduled holidays.
  * Uses a `Switch` node to route messages based on the student's gender (`M` / Female / Neutral).
  * Phone number sanitization with special character removal (`replace(/\D/g, '')`) and dynamic extraction of the first name (`split(' ')[0]`) to personalize communication.
- **Completion Congratulations:**
  * Automated daily workflow that checks for students moved to the completion stage on the previous day and dispatches a personalized congratulatory message for their driver's license (CNH) issuance.

### 3. Backup & Security Infrastructure (Docker & Rclone)
- **Architecture:** Linux Docker server hosting **Odoo 17**, **n8n**, **Evolution API**, **Redis**, and **PostgreSQL**.
- **Daily Backup Strategy (19:00):**
  * Automated script (`/opt/backup.sh`) configured via `cron`.
  * Performs a complete PostgreSQL database dump (`pg_dumpall`).
  * Compresses Docker configuration directories and volumes.
  * Securely uploads the encrypted package to a dedicated folder in **Google Drive** using **Rclone**.

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

### 3. Evolution API (WhatsApp Gateway)
- **Role:** Multi-device WhatsApp instance manager for automated outbound notifications.
- **Configuration:**
  - Containerized deployment communicating with n8n HTTP Request nodes.
  - Payload structure utilizing regex sanitization (`replace(/\D/g, '')`) for phone numbers and dynamic first-name extraction.

### 4. Rclone & Google Drive Backup Strategy
- **Role:** Cloud disaster recovery and automated storage synchronization.
- **Configuration:**
  - Configured via `rclone config` using the Google Drive remote (`gdrive:`).
  - Automated cron job executed daily at 19:00 (`0 19 * * * /bin/bash /opt/backup.sh`) combining database dumps and Docker directory archives (`/home/suporte/vm-autoescola`).
