-- =============================================================================
-- active_leads_filter.sql
-- Lists active driving school students from the Odoo 17 CRM pipeline
-- ("Gestão de Alunos"), excluding those who already finished the process
-- (stage "Concluído / CNH Emitida").
--
-- Pipeline stages:
--   Matrícula > Exames (Psicotécnico e Médico) > Curso Teórico (CFC) >
--   Prova Teórica Detran > Aulas Práticas > Prova Prática Detran >
--   Concluído / CNH Emitida
--
-- Used by n8n (Postgres node) to feed WhatsApp notifications.
-- Note: in Odoo 17, crm_stage.name is JSONB (translatable), hence ->> 'pt_BR'.
-- =============================================================================

SELECT
    l.id                                             AS lead_id,
    l.name                                           AS student_name,
    COALESCE(l.mobile, l.phone)                      AS phone,
    COALESCE(s.name ->> 'pt_BR', s.name ->> 'en_US') AS stage,
    STRING_AGG(t.name ->> 'en_US', ', ')             AS categories,  -- e.g. "Adição B"
    l.expected_revenue                               AS amount
FROM crm_lead l
JOIN crm_stage s              ON s.id = l.stage_id
LEFT JOIN crm_tag_rel tr      ON tr.lead_id = l.id
LEFT JOIN crm_tag t           ON t.id = tr.tag_id
WHERE l.active = TRUE
  AND COALESCE(s.name ->> 'pt_BR', s.name ->> 'en_US') <> 'Concluído / CNH Emitida'
GROUP BY l.id, l.name, l.mobile, l.phone, s.name, s.sequence, l.expected_revenue
ORDER BY s.sequence, l.name;
