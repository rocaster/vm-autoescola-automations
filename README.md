# vm-autoescola-automations
Complete automation stack for driving schools, featuring n8n workflows, Odoo 17 CRM integration, Evolution API WhatsApp notifications, and automated daily Docker infrastructure backups to Google Drive.


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

## 🛠️ Tech Stack
- **Orchestration & Automation:** n8n (Self-hosted)
- **ERP & CRM:** Odoo 17
- **Communication:** Evolution API (WhatsApp)
- **Cloud Synchronization:** Rclone + Google Drive
- **Database:** PostgreSQL 15
