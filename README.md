# Procurement Management System

A full-stack procurement system built with Ruby on Rails 8, unifying vendor management, inventory tracking, and role-based approval workflows.

## Features

- Purchase Order Workflow — 7-stage lifecycle (Draft → Pending Approval → Approved → In Progress → Delivered) with state machine automation
- Vendor Management — Vendor onboarding, blacklisting, document tracking, and performance ratings
- Inventory Tracking — Product catalog with low stock alerts, reorder points, and category management
- Role-Based Access Control — Admin, Approver, and Procurement Officer roles with scoped data access
- Reports & Analytics — Vendor performance, procurement trends, spending analysis, and delivery performance dashboards
- Email Notifications — Automated emails at every workflow stage (approval, rejection, delivery, cancellation)
- Audit Trail — Full change history on purchase orders via PaperTrail

## Tech Stack

- Ruby 3.3.8
- Rails 8.0.2
- PostgreSQL
- Devise (Authentication)
- Pundit (Authorization)
- AASM (State Machine)
- Ransack (Search & Filtering)
- Kaminari (Pagination)
- PaperTrail (Audit Logging)
- Chartkick + Groupdate (Charts)
- Stimulus.js + Turbo (Frontend)
- Bootstrap 5

## Getting Started

### Prerequisites

- Ruby 3.3.8
- PostgreSQL
- Bundler

### Setup

```bash
# Install dependencies
bundle install

# Create and migrate the database
rails db:create db:migrate

# Seed sample data
rails db:seed

# Start the server
rails server
