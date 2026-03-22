# DVD Ripper — Agent Guide

This repo contains scripts for ripping DVDs to a Jellyfin media server using MakeMKV.

## System

| Item | Value |
|------|-------|
| MakeMKV binary | `/snap/bin/makemkvcon` |
| Drive 0 (sr0) | `/dev/sr0` — HL-DT-ST DVD+-RW GHB0N (has RPC region issues on some discs) |
| Drive 1 (sr1) | `/dev/sr1` — ATAPI iHAS124 B (more reliable, better region bypass) |
| Jellyfin movies | `/mnt/media/jellyfin/movies/` |
| Rip logs | `/tmp/dvd-ripper-logs/` |

## Workflow

### 1. Scan a disc
```bash
./scan.sh <drive_number>
```
This shows all titles with runtime, size, and audio track count.

**Identifying the main feature:**
- Longest runtime is usually the main film
- If runtimes are similar, the title with the most audio tracks is the main feature
- Skip any title whose runtime ≈ sum of all other titles (it's a merged/combined title — waste of time)
- Titles under ~5 minutes are extras/menus, ignore them

### 2. Rip the main title
```bash
./rip.sh <drive_number> <title_number> <temp_folder_name>
```
- Always use a unique temp folder name per disc to avoid filename conflicts
- Use descriptive names: `newhope_tmp`, `deerhunter_tmp`, etc.
- The rip runs with `nohup` so it survives SSH disconnects

```bash
# Example: rip title 0 from drive 1
./rip.sh 1 0 newhope_tmp
```

### 3. Check status
```bash
./status.sh
```

### 4. Finalize (rename + move to Jellyfin)
```bash
# Single movie
./finalize.sh <temp_folder> "<Movie Title (Year)>"

# Multi-part movie (flipper discs, 2-disc sets)
./finalize.sh amadeus_a_tmp "Amadeus (1984)" 1
./finalize.sh amadeus_b_tmp "Amadeus (1984)" 2
```

## Jellyfin Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Single movie | `Movie Title (Year).mkv` | `The Deer Hunter (1978).mkv` |
| Multi-part | `Movie Title (Year) - part1.mkv` | `Amadeus (1984) - part1.mkv` |

Jellyfin will auto-match movies by title and year. Use the theatrical release year.

## Drive Notes

- **sr0 (HL-DT-ST GHB0N)** has hard RPC region protection that blocks some discs. If a rip from sr0 produces ILLEGAL REQUEST / scrambled sector errors, move the disc to sr1.
- **sr1 (iHAS124 B)** reliably works around region protection via direct disc access mode.
- If a disc fails to scan entirely (empty output), try ejecting and reseating, or moving it to sr1.

## Common Issues

| Problem | Fix |
|---------|-----|
| Scan returns nothing | Disc still spinning up — retry after 10s, or reseat |
| RPC / ILLEGAL REQUEST errors | Move disc from sr0 to sr1 |
| File is too small after rip | Rip was interrupted — re-run `rip.sh` |
| Merged title detected | Skip it — rip individual titles by number instead |
| Bonus-only disc (all titles <30min) | No main movie — need the other disc in the set |
| 2-sided flipper disc | Rip each side separately, finalize as part1 / part2 |

## Ripping Two Discs Simultaneously

Always use different temp folder names. Never rip two discs to the same folder — MakeMKV generates generic filenames that will overwrite each other.

```bash
./rip.sh 0 0 movie_a_tmp &
./rip.sh 1 0 movie_b_tmp &
```
