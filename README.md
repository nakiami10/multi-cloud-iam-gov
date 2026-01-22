# Multi-Cloud IAM Governance Framework

This repository serves as the centralized **Source of Truth** for managing infrastructure access across **AWS** and **Azure** environments. It uses a **modular, capability-based architecture** to balance developer velocity with strict security compliance.

---

## 1. Core Philosophy: _Composition over Copy-Paste_

Instead of managing massive, redundant policy files for every team, this repository uses a **Composition Engine**.

### Foundation (Shared Components)

- A library of **safe, baseline permissions** required by everyone
- Examples:
  - Monitoring
  - Discovery
  - Support

### Baselines (Team-Specific)

- Each team has a **dedicated file** containing _only_ the permissions unique to their role or function.

### Orchestration

- Deployment logic automatically **stitches shared foundations into team baselines**
- A single edit to a shared component (e.g., new auditing requirement) propagates instantly to **all teams**
- Eliminates duplication and reduces policy drift

---

## 2. Team Hierarchy & Access Levels

The framework uses an **Additive Inheritance Model** to enforce separation of duties while minimizing maintenance overhead.

### Internal DevOps (The Authority)

- **Clearance:** Full lifecycle management
- **Logic:** Bypasses shared constraints
- **Scope:**
  - Identity
  - Network
  - Compute

---

### Level 2: Senior Contractor (Elevated Ops)

- **Inheritance:** Includes all Level 1 (Junior) capabilities
- **Leeway:**
  - Scaling resources
  - Modifying configurations (e.g., database instance sizes)
- **Safety Catch:**
  - Destructive actions are allowed
  - **Strictly gated by MFA**

---

### Level 1: Junior Contractor (Triage & Ops)

- **Clearance:** Operational triage only
- **Restrictions:**
  - Read
  - Start
  - Stop
- **No:**
  - Creation
  - Deletion
- **Guardrails:**
  - Access limited to resources explicitly tagged for their clearance level

---

### SRE & Developer Teams

#### SRE

- Observability
- Alerting
- Maintenance windows

#### Developers

- Scoped to **application-specific resources**
- Examples:
  - S3 buckets
  - Container App namespaces

---

## 3. Security & Governance Guardrails

### No-Wildcard Mandate

- Avoids `*` permissions to minimize blast radius
- Every action is **explicitly defined**
  - Example: `ec2:RunInstances` instead of `ec2:*`

---

### Tag-Based Access Control (TBAC/ Tentative Implementation)

- External contractor permissions are **pinned to resource tags**
- Even with stop permissions, actions are denied unless the resource carries the correct **Clearance tag**

---

### Safe-Delete Enforcement (Azure)

- Junior roles use `notActions` blocks
- Prevents deletion even if broad roles (e.g., `Contributor`) are assigned in non-production environments

---

### MFA-Protected Destruction (AWS)

- Policies include conditions requiring a **recent MFA token**
- Destructive actions without MFA are automatically rejected by the cloud provider

---

## 4. Environment Awareness

The framework distinguishes between **Production** and **Non-Production** environments.

### Production

- Strict adherence to **granular custom roles**
- No elevated shortcuts

### Non-Production

- Allows controlled **leeway**
- Developers can:
  - Experiment
  - Delete resources to manage costs
- No need for production-grade policy updates

---

## 5. Maintenance Workflow

### Global Updates

- Edit shared components
- Changes propagate to all teams automatically

### Team Updates

- Modify team-specific files:
  - JSON (AWS)
  - YAML (Azure)

### Verification

- All changes must be validated via **Terraform Plan**
- Plan output shows the final **composed permissions** before application

---

**Result:**  
A scalable, auditable, and secure IAM framework that enforces least privilege _without slowing teams down_.

##

│
├── main.tf # Main Orchestrator
├── providers.tf # AWS & Azure provider config
│
├── /aws_policies
│ ├── devops-internal.json # Full Admin (Internal)
│ ├── devops-ext-l1.json # Senior Contractor (No Delete)
│ ├── devops-ext-l2.json # Junior Contractor (Ops Only)
│ ├── sre-team.json # Observability & Metrics
│ └── dev-team.json # Application Devs
│
└── /azure_roles
├── devops-internal.yaml # Full Owner (Internal)
├── devops-ext-l1.yaml # Contributor (No Delete)
├── devops-ext-l2.yaml # Reader + Ops (No Delete)
└── sre-team.yaml # Insights & Maintenance
