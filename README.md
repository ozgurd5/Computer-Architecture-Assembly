# Computer-Architecture-Assembly

8086 Assembly programs for a computer architecture course, assembled with **MASM** and run on **DOSBox**. The collection grows step by step — from printing characters to the screen, to making noise on the PC speaker, to showing the system clock as big digital digits, to scrolling marquee text.

> **A note on language:** the source-code comments are in English, but the explanation files (`*.md`) and many in-code labels are in **Turkish**, because the course is taught in Turkish.

---

## 📁 Repository layout

| Path | Contents |
|------|----------|
| `MASM.EXE`, `LINK.EXE`, `EXE2BIN.EXE`, `debug.exe` | DOS toolchain (included in the repo) |
| `notes.md` | Quick-reference notes (DOS functions, ASCII offsets, instructions) |
| `examples/` | Basic examples + `aciklamalar.md` |
| `assignments/` | Assignment solutions + `aciklamalar.md` |
| `hard-assignments/` | Harder assignments (clock, kayan) + a `.md` for each |
| `legacy/` | Old / archived files (not part of active work) |

---

## 🔧 Requirements

- **DOSBox** — to emulate the 8086 + DOS environment.
- **MASM 5.0**, **LINK**, **EXE2BIN** — all included in the repo root; nothing else to download.

---

## 🚀 Getting started in DOSBox

Mount the repo as a drive, then switch into the folder you want to work in. Because the tools live in the root, we point `PATH` at the root so `masm`/`link` can be found from any subfolder:

```
mount c "C:\path\to\Computer-Architecture-Assembly"
c:
path c:\
cd examples
```

> `mount` makes the repo the `C:` drive inside DOSBox. `path c:\` lets the assemblers be called from any subfolder. Output files are written to the current folder.

---

## ⚙️ Building and running

Most programs are `.COM` — build them in three steps (assemble, link, convert to a flat binary):

```
masm prog;
link prog;
exe2bin prog.exe prog.com
prog
```

- `masm prog;` → assembles `prog.asm` into `prog.obj`. (The trailing **`;`** accepts the defaults for all prompts.)
- `link prog;` → produces `prog.exe`. (A `no stack segment` warning is normal — ignore it.)
- `exe2bin prog.exe prog.com` → strips the EXE header into a flat `.COM`.
- `prog` → runs it.

**`sifre` and `sifre2` are `.EXE` programs** — skip the `exe2bin` step and just run them after linking:

```
masm sifre;
link sifre;
sifre
```

---

## 📚 Contents

### `examples/` — Basics

| Program | What it does | Type |
|---------|--------------|------|
| `ascii` | Prints all 256 characters | COM |
| `binbin` | Prints a number in **binary** | COM |
| `binquad` | Prints a number in **base-4** | COM |
| `binheks` | Prints a number in **hexadecimal** | COM |
| `desibin` | Reads a decimal number from the keyboard into a register | COM |
| `kalp` | Prints a heart symbol (♥) | COM |
| `gurultu` | Produces noise on the PC speaker | COM |
| `sifre` | Checks a 4-character password (YES/NO) | **EXE** |
| `tufek` | Machine-gun sound (40 shots) | COM |

### `assignments/` — Assignment solutions

| Program | What it does | Type |
|---------|--------------|------|
| `everydec` | Prints the ASCII table as `binary , decimal , hex : char` | COM |
| `bindec` | Prints a 16-bit number in **decimal** | COM |
| `sifre2` | Reads a masked (`*`) password, compares it to 2026 (TAMAM/HATA) | **EXE** |
| `reverse` | Reverses a typed string using the **stack** | COM |
| `gizle` | Shows a typed char for 1 s, then replaces it with `*` | COM |

### `hard-assignments/` — Harder assignments

| Program | What it does | Type |
|---------|--------------|------|
| `clock` | Shows the system time as **big colored digital digits** | COM |
| `kayan` | Scrolls a message as **big symbols** (marquee) | COM |

> `clock` and `kayan` read the BIOS **ROM character font** (`int 10h, AX=1130h`) and draw each character large, out of colored diamonds.

---

## 📖 Documentation

- **`notes.md`** (root) — a short reference for the most-used ideas: interrupts, ASCII offsets, `div`/`mul`/`cbw`, LEA/pointers, the PC speaker.
- **`examples/aciklamalar.md`** and **`assignments/aciklamalar.md`** — algorithm + line-by-line explanation of every program in that folder (in Turkish).
- **`hard-assignments/clock.md`** and **`hard-assignments/kayan.md`** — detailed write-ups of those two harder programs.

---

## ℹ️ Note

`legacy/` holds old / archived files and is not part of the active work.
