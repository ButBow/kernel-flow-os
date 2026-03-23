-- Kernel Flow OS — Seed Data
-- Migration: 002
-- Date: 2026-03-23
-- Run AFTER 001_initial_schema.sql
-- WARNING: This file contains business data. Do not share publicly.

-- ============================================================
-- CLIENTS
-- ============================================================
insert into clients (name, client_id, status, branche, kontaktperson, tier, email, telefon, adresse) values
  ('GLP', 'CL-001', 'Aktiv', 'Politik', 'Tobias Meier Kern', 'Standard', null, null, null),
  ('Sportanlagen AG Wallisellen', 'CL-002', 'Potenziell', 'Sport', 'Oliver Galliker', 'Standard', 'oliver.galliker@sportanlagen-wallisellen.ch', '+41 44 830 43 40', 'Alte Winterthurerstrasse 62, 8304 Wallisellen'),
  ('Gaphiland', 'CL-003', 'Aktiv', 'Design', null, 'Standard', null, null, null),
  ('SIUC', 'CL-004', 'Potenziell', 'Sonstiges', 'Marianne', 'One-off', null, null, null),
  ('Klang.Vibes', 'CL-005', 'Potenziell', 'Musik/Events', 'Sandra Schöb-Brunner', 'One-off', 'welcome@klang-vibes.ch', null, null),
  ('HUGG', 'CL-006', 'Potenziell', 'Sonstiges', null, 'One-off', null, null, null);

-- ============================================================
-- SERVICES
-- ============================================================
insert into services (name, service_id, kategorie, preis_von, aufwand_stunden, vor_ort_minuten, nachbearbeitung_stunden, status, beschreibung, lieferumfang) values
  ('Social Media Video 15 Sek. – Light Packet', 'S-001', 'Video', 300, 3, 30, 1, 'Aktiv',
    '15 Sek Social Media Video – Perfekt für schnelle, knackige Content-Snippets. Inkl. 30 Min Dreh, 1h Schnitt, 1 Korrekturschleife.',
    '1x 15 Sek Video (Instagram/TikTok ready)' || chr(10) || '1 Korrekturschleife' || chr(10) || 'Rohaufnahmen optional'),
  ('Social Media Video 30 Sek. – Medium Packet', 'S-002', 'Video', 425, 4, 45, 1.5, 'Aktiv',
    '30 Sek Social Media Video – Ideal für ausführlichere Stories. Inkl. 45 Min Dreh, 1.5h Schnitt, 2 Korrekturschleifen.',
    '1x 30 Sek Video' || chr(10) || '2 Korrekturschleifen'),
  ('Social Media Video 45 Sek. – Large Packet', 'S-003', 'Video', 540, 5, 60, 2, 'Aktiv',
    '45 Sek Social Media Video – Für umfangreiche Content-Pieces. Inkl. 60 Min Dreh, 2h Schnitt, 2 Korrekturschleifen.',
    '1x 45 Sek Video' || chr(10) || '2 Korrekturschleifen'),
  ('Social Media Video 60 Sek. – Premium Packet', 'S-004', 'Video', 650, 6, 75, 2.5, 'Aktiv',
    '60 Sek Social Media Video – Premium-Qualität für maximale Wirkung. Inkl. 75 Min Dreh, 2.5h Schnitt, 3 Korrekturschleifen.',
    '1x 60 Sek Video' || chr(10) || '3 Korrekturschleifen'),
  ('Event Begleitung – Bild und Video', 'S-005', 'Event', 800, 8, 240, 4, 'Aktiv',
    'Professionelle Event-Begleitung mit Foto & Video. Dokumentation deines Events mit hochwertigen Aufnahmen.',
    'Bearbeitetes Video (3-5 Min Highlight)' || chr(10) || '20-30 bearbeitete Fotos' || chr(10) || 'Alle Rohaufnahmen' || chr(10) || '1 Korrekturschleife'),
  ('Sponsoren Suche, Vermittlung, Verhandlung', 'S-006', 'Consulting', null, null, null, null, 'Aktiv', null, null),
  ('IT Support', 'S-007', 'IT-Support', null, null, null, null, 'Entwurf', null, null),
  ('AI Crashkurs (GPT richtig im Alltag einsetzen)', 'S-008', 'AI-Automation', null, null, null, null, 'Entwurf', null, null),
  ('AI Workflows', 'S-009', 'AI-Automation', null, null, null, null, 'Entwurf', null, null),
  ('Webseite Unterhalt', 'S-010', 'Sonstiges', null, null, null, null, 'Entwurf', null, null);

-- ============================================================
-- PARTNER
-- ============================================================
insert into partner (name, email, telefon, status) values
  ('Fasson', 'vb@fasoon.ch', '+41 71 523 12 57', 'Potenziell');

-- ============================================================
-- LEADS
-- ============================================================
insert into leads (name, anfrageart, quelle, budget_schaetzung, status, eingangsdatum, notizen) values
  ('dfddf (test)', 'Projektanfrage', 'Website', 1000, 'Neu', '2026-01-06', 'Social Media Shortform Video Interesse. Test-Eintrag.');

-- ============================================================
-- CONTENT
-- ============================================================
insert into content_items (titel, plattform, format, status, fuer_eigene, script) values
  ('Introduction Video', ARRAY['Instagram', 'TikTok', 'YouTube'], 'Short', 'Idee', true, 'Vorstellung von Floris und Kernel Flow GmbH – wer wir sind, was wir machen, warum wir anders sind.');

-- ============================================================
-- ROADMAP
-- ============================================================
insert into roadmap (ziel, phase, kategorie, status, erfolgsmetrik, prioritaet) values
  -- Phase 1
  ('Firmengründung abschliessen', 'Phase 1 (M1-2)', 'Legal', 'In Progress', 'GmbH im Handelsregister eingetragen', 'Hoch'),
  ('Basis-Website live', 'Phase 1 (M1-2)', 'Marketing', 'Erreicht', 'kernelflow.ch online und professionell', 'Hoch'),
  ('2-3 Stammkunden Video Editing', 'Phase 1 (M1-2)', 'Revenue', 'In Progress', 'CHF 2.500–3.500/Monat Grundeinkommen', 'Hoch'),
  ('Fiverr-Profil aufsetzen', 'Phase 1 (M1-2)', 'Marketing', 'Geplant', 'Profil aktiv mit 3 Paketen', 'Mittel'),
  ('Portfolio mit bestehenden Arbeiten aufbauen', 'Phase 1 (M1-2)', 'Marketing', 'In Progress', '5+ Projekte im Portfolio sichtbar', 'Mittel'),
  -- Phase 2
  ('Erstes AI-Automation Projekt verkaufen', 'Phase 2 (M3-4)', 'Revenue', 'Geplant', 'CHF 300–600 eingenommen', 'Hoch'),
  ('LinkedIn/Twitter Präsenz aufbauen', 'Phase 2 (M3-4)', 'Marketing', 'Geplant', '500+ Follower, wöchentliche Posts', 'Mittel'),
  ('Micro-SaaS Idee validieren', 'Phase 2 (M3-4)', 'Produkt', 'Geplant', 'Prototyp gebaut, 3 Tester gewinnen', 'Mittel'),
  ('CHF 3.500–5.000/Monat erreichen', 'Phase 2 (M3-4)', 'Revenue', 'Geplant', 'Monatlicher Revenue über CHF 3.500', 'Hoch'),
  -- Phase 3
  ('SaaS Beta Launch', 'Phase 3 (M5-6)', 'Produkt', 'Geplant', 'Erste zahlende Nutzer', 'Hoch'),
  ('Pro AI Workspace Paket anbieten (CHF 1.200–3.000)', 'Phase 3 (M5-6)', 'Revenue', 'Geplant', '2+ Kunden mit Pro-Paket', 'Hoch'),
  ('Monthly Maintenance Model einführen', 'Phase 3 (M5-6)', 'Revenue', 'Geplant', 'CHF 60–150/Monat pro Kunde, mind. 5 Kunden', 'Mittel'),
  ('CHF 5.000–7.000/Monat erreichen', 'Phase 3 (M5-6)', 'Revenue', 'Geplant', 'Monatlicher Revenue über CHF 5.000', 'Hoch');

-- ============================================================
-- PROJECTS (insert after clients so FK works)
-- ============================================================
do $$
declare
  glp_id uuid;
  sport_id uuid;
begin
  select id into glp_id from clients where client_id = 'CL-001';
  select id into sport_id from clients where client_id = 'CL-002';

  insert into projects (titel, auftrags_nr, kunde_id, status, typ, prioritaet, startdatum) values
    ('Werbekampagne Tobias Meier', 'KF-001', glp_id, 'In Arbeit', 'Video', 'Hoch', '2026-01-19'),
    ('Sportanlagen Eis Disco', 'KF-002', sport_id, 'Anfrage', 'Event', 'Standard', null),
    ('GLP Vorstands Foto', 'KF-003', glp_id, 'Anfrage', 'Foto', 'Standard', null),
    ('Airbnb Website', 'KF-004', null, 'Anfrage', 'Website', 'Standard', null);
end $$;
