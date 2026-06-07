# Assembly Notes

## DOS functions (int 21h)
Pick the task, put its number in AH, set the inputs, then call `int 21h`.

| Task | AH | Input | Output |
|------|----|-------|--------|
| Read one key from keyboard | 01h | -- | AL = key as ASCII (echoes, waits for a keypress) |
| Read one key, NO echo | 08h | -- | AL = key as ASCII (not shown on screen -- for passwords) |
| Print one character | 02h | DL = char | char on screen |
| Backspace (cursor left, no erase) | 02h | DL = 08h | cursor moves one position left, over the char |
| Print a string | 09h | DS:DX -> `$`-terminated string | string on screen |

## Program termination (different for COM vs EXE)
- **.COM**: `int 20h`
- **.EXE**: `mov ah,4Ch` + `int 21h`  (AL = exit code)

## ASCII offsets
- **30h**: offset from a raw value to its ASCII digit. Boundary: `0 -> '0'` (00h -> 30h) ... `9 -> '9'` (09h -> 39h)
- **07h**: bridges the gap between digits and letters. Boundary: `3Ah -> 41h`, i.e. from just-after-'9' up to 'A'

## ASCII hex-digit table
```
nibble:    0    1    2   ...   9  |  A    B    C    D    E    F
+30h:     30h  31h  32h  ...  39h | 3Ah  3Bh  3Ch  3Dh  3Eh  3Fh
char:     '0'  '1'  '2'  ...  '9' |  :    ;    <    =    >    ?
                            ^     |  ^
                       last digit |  first WRONG char (needs +07h)
```

## Shift / rotate count (8086)
- Counts other than `1` must be in `CL` (`rol bx,cl`). Hardware limitation of the 8086.

## jcxz
- `jcxz label`: jumps when CX is 0 (tests CX directly, not a flag) -- guards a `loop` against the CX=0 -> 65536 wraparound.

## cbw (convert byte to word)
- Sign-extends AL into AX: AL's sign bit (bit 7) is copied across all of AH
- `AL=05h -> AX=0005h`  |  `AL=FBh -> AX=FFFBh`

## mul (unsigned multiply)
- Works only on the accumulator: `mul cx` means AX = AX * CX (16-bit result in DX:AX)
- Operand must be a register/memory, never an immediate number
- Example: `mov cx,7` + `mul cx` -> AX = AX * 7

## div (unsigned divide)
- 8-bit divisor (e.g. BL): divides AX        -> AL = quotient, AH = remainder
- 16-bit divisor (e.g. CX): divides DX:AX    -> AX = quotient, DX = remainder
- DX:AX = one 32-bit number across two registers: DX = high 16 bits, AX = low 16 bits.
  Zero DX first when the number you want to divide only lives in AX.
```
mov ax,65       ; 8-bit divide (divisor BL)
mov bl,10
div bl          ; AL = 6 (65/10), AH = 5 (65 mod 10)

xor dx,dx       ; 16-bit divide: make DX:AX = just AX (clear the high half)
mov ax,1234
mov cx,10
div cx          ; AX = 123 (1234/10), DX = 4 (1234 mod 10)
```

## Zeroing a register (xor shortcut)
- `xor cx,cx`  ; CX = 0  (a register XOR itself is always 0; shorter/faster than `mov cx,0`)

## LEA and pointers (SI / [SI])
- `SI` holds an address; `[SI]` is the value at that address (like C's `p` vs `*p`)
- `LEA SI, buf` -> SI = address of buf (same as `MOV SI, OFFSET buf`)
- `MOV AL,[SI]` reads, `MOV [SI],AL` writes; `INC SI` moves to the next byte

## PC speaker (sound)
```
    in  al,61h          ; read the speaker port
    and al,11111100b    ; take control: clear bits 0 and 1
tone:
    xor al,2            ; flip the speaker bit
    out 61h,al          ; send it -> cone moves
    mov cx,500          ; delay (smaller = higher pitch)
delay:
    loop delay
    jmp tone            ; repeat -> sound
```
