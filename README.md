# Proxmox Zamba – Playbook Suite

Diese Repository-Dokumentation ist **kanonisch** (Single Source of Truth) für alle Playbooks `01`–`15`.
Sie ersetzt ältere, verstreute Dokumente. Alle inhaltlichen Änderungen sollten **nur** hier gepflegt werden.

## Ordnerstruktur
```
/root/temp
├─ README.md                  # Einstieg & Quickstart
├─ .gitignore                 # Konsistente Ignorierregeln
└─ docs/
   ├─ DOCS_OVERVIEW.md        # Überblick & Betriebsmodell
   ├─ PLAYBOOK_REFERENCE.md   # Referenz: alle Playbooks 01–15
   └─ MAINTENANCE_GUIDE.md    # Betrieb, Prüfungen, Troubleshooting
```

## Quickstart
1. **Dokumente ausrollen** (dieses Paket entpacken) und bestehende Files ersetzen.
2. **Aufräumen**: `scripts/cleanup_docs.sh` ausführen (entfernt alte/verstreute Docs).
3. **Committen**:
   ```bash
   git add -A
   git commit -m "docs: replace with canonical docs set and purge legacy files"
   git push
   ```

## Warum dieser Schritt?
- Es existierten **alte, inkonsistente** `.md`-Dateien.
- Dieses Set ist komplett und deckt **alle Playbooks** ab.
- Ein Cleanup-Skript entfernt alte Dateien zuverlässig (inkl. `git rm` für getrackte Files).
