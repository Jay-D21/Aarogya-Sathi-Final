# Database Schema

## [Table Name]
```sql
CREATE TABLE [table_name] (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- [columns]
  created_at TIMESTAMPTZ DEFAULT now()
);
```
**Purpose**: [What this table stores]
**Relationships**: [Foreign keys, references]
**Referenced by**: [Which modules/tables reference this]

---

_Add a section for each table._