# Kernel Kontrolle

Arbeitsverzeichnis für das **Kernel Flow OS** Projekt.

## Was ist das?

Ein internes Business-Betriebssystem für Kernel Flow GmbH.
Gebaut mit Lovable.dev — ersetzt Notion als Single Source of Truth.

## Ordnerstruktur

```
Kernel_Kontrolle/
├── _Lovable_Prompt/          ← Fertiger Prompt für Lovable (hier kopieren!)
│   └── KERNEL_FLOW_OS_PROMPT.md
├── _Data_Exports/            ← CSV / JSON Exporte aus Notion oder anderen Tools
├── _Assets/                  ← Logos, Bilder, Branding-Dateien für den Upload
├── Kernel_Home_Export_Notion/ ← Notion Export hier reinkopieren
└── README.md                 ← Diese Datei
```

## Nächste Schritte

1. **Lovable starten:**
   - lovable.dev → New Project
   - Inhalt von `_Lovable_Prompt/KERNEL_FLOW_OS_PROMPT.md` kopieren & einfügen
   - Generieren lassen (~20-30 Credits für den Basis-Build)

2. **Supabase verbinden:**
   - supabase.com → New Project (kostenlos)
   - In Lovable unter "Supabase" verbinden
   - Früh machen damit Daten persistieren!

3. **Notion Export einfügen:**
   - Notion → Settings → Export → "Markdown & CSV"
   - ZIP entpacken in `Kernel_Home_Export_Notion/`
   - Claude kann dann die CSVs lesen und Daten aufbereiten

4. **Iterieren in dieser Reihenfolge:**
   - Dashboard Layout
   - Finanzen Charts
   - Aufträge Kanban (drag-and-drop)
   - Open Loops (Sortierung + Age-Highlighting)
   - Prompts (Copy-to-clipboard)
   - Content Kalender
   - Global Search (Cmd+K)
   - Mobile

## Bestehende Lovable Website (SEPARAT)

Das ist ein anderes Projekt! Nicht vermischen.
- URL: lovable.dev/projects/2f472bd5-babf-494d-8861-be61f5483ed3
- GitHub: github.com/ButBow/kernel-gmbh
- Lokal: C:\Users\flori\Desktop\Webseiten_Kernel_Flow\kernel-gmbh\
