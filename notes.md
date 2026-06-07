# Assembly Notes

## DOS functions (int 21h)
Pick the task, put its number in AH, set the inputs, then call `int 21h`.

| Task | AH | Input | Output |
|------|----|-------|--------|
| Read one key from keyboard | 01h | -- | AL = key as ASCII (echoes, waits for a keypress) |
| Print one character | 02h | DL = char | char on screen |
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

## cbw (convert byte to word)
- Sign-extends AL into AX: AL's sign bit (bit 7) is copied across all of AH
- `AL=05h -> AX=0005h`  |  `AL=FBh -> AX=FFFBh`

## mul (unsigned multiply)
- Works only on the accumulator: `mul cx` means AX = AX * CX (16-bit result in DX:AX)
- Operand must be a register/memory, never an immediate number
- Example: `mov cx,7` + `mul cx` -> AX = AX * 7

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
