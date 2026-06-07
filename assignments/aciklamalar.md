# Ödevler — Açıklamalar

Bu dosya `assignments/` klasöründeki her `.asm` çözümünün **görevini**, **ne yaptığını**, **algoritmasını** ve **satır satır** açıklamasını içerir. Kod dosyalarına dokunulmamıştır. (`clock` örneği bilerek dışarıda tutulmuştur.)

## İçindekiler
1. [everydec.asm](#1-everydecasm)
2. [bindec.asm](#2-bindecasm)
3. [sifre2.asm](#3-sifre2asm)
4. [reverse.asm](#4-reverseasm)
5. [gizle.asm](#5-gizleasm)

## Sık geçen kavramlar (kısa)
- **`aam`** → AL'yi 10'a böler: AH = onlar, AL = birler (değer < 100 için). "10'a bölme" tek komutta.
- **`div` (işaretsiz bölme):** 8-bit bölen → AX'i böler (AL=bölüm, AH=kalan). 16-bit bölen → **DX:AX**'i böler (AX=bölüm, DX=kalan). `DX:AX` = iki register'ın oluşturduğu 32-bit sayı (DX üst, AX alt) → 16-bit bölmede önce `xor dx,dx`.
- **Yığın (stack) = LIFO:** `push` ile ittiğin şeyleri `pop` ile **ters sırada** geri alırsın. Sıra çevirmenin doğal yolu.
- **`int 21h, ah=08h`** → klavyeden karakter okur ama **ekranda göstermez** (şifre girişi için).
- **`int 21h, ah=02h` + `DL=08h`** → backspace: imleci bir sola alır (silmez); üzerine yazıp karakteri değiştirebilirsin.
- **`int 1Ah, ah=00h`** → BIOS tik sayacı (saniyede ~18.2 tik); gerçek zaman gecikmesi için.
- **`jcxz etiket`** → CX=0 ise atlar (doğrudan CX'e bakar). `loop`'un CX=0'da 65536'ya sarmasını engellemek için.

---

## 1) everydec.asm

**Görev:** "ASCII karakter tablosunu `binary , decimal , hex : karakter` olacak şekilde alt alta yazdır." Örnek: `A` → `01000001 , 65 , 41 : A`.

**Ne yapar:** Her kod için bir satır basar: 8-bit ikilik, onluk, 2-hane onaltılık ve karakterin kendisi. (Şu anki kodda `di` 65'ten başlayıp 75'e kadar gider — yani `A`–`J` test aralığı. **Tüm tablo** için `mov di,0` + `cmp di,256` yapılır.)

**Algoritma:**
```
di = kod
her kod için:
    ikili yaz, " , "
    onluk yaz, " , "
    onaltılık yaz, " : "
    karakteri yaz
    alt satıra geç
di++
```
Kod **temiz alt programlara** bölünmüş; ana döngü görev listesi gibi okunur. `di` paylaşılan değişkendir, hiçbir alt program onu bozmaz.

**Satır satır — ana döngü:**
```asm
mov di,65        ; di = o anki kod (65='A'; tam tablo için 0)
ana_dongu:
call ikili       ; ikilik bas
mov dl,','
call ara         ; " , "
call onluk       ; onluk bas
mov dl,','
call ara
call onaltili    ; hex bas
mov dl,':'
call ara         ; " : "
call karakter    ; karakterin kendisi
call satir       ; alt satır
inc di
cmp di,75        ; di < 75 ise devam (tam tablo için 256)
jb ana_dongu
int 20h
```

**`yaz`** — DL'deki karakteri basan temel alt program (hepsi bunu kullanır):
```asm
yaz proc near
mov ah,02h
int 21h
ret
yaz endp
```

**`ara`** — `" " + DL + " "` basar (hem `,` hem `:` için):
```asm
ara proc near
mov dh,dl    ; ayracı sakla (dl birazdan ' ' olacak)
mov dl,' '
call yaz
mov dl,dh    ; ayracı geri al
call yaz
mov dl,' '
call yaz
ret
ara endp
```

**`ikili`** — `di`'yi 8-bit ikilik basar (`binbin`'in 8-bit hali):
```asm
ikili proc near
mov bx,di      ; bl = kod (di'nin alt baytı)
mov ch,08h     ; 8 bit -> 8 tur
mov cl,01h     ; döndürme = 1
i_dongu:
rol bl,cl      ; 1 bit sola döndür: en sol bit en sağa sarar (MSB önce)
mov dl,bl
and dl,01h     ; en alttaki biti bırak
add dl,30h     ; 0/1 -> '0'/'1'
call yaz
dec ch
jnz i_dongu
ret
ikili endp
```

**`onluk`** — `di`'yi onluk basar (`div` + yığınla ters çevirme):
```asm
onluk proc near
mov ax,di
mov bl,10
xor cx,cx      ; basamak sayacı
o_bol:
xor ah,ah      ; bölmeden önce AX = AL
div bl         ; AL = AX/10, AH = kalan (bir rakam)
push ax        ; rakamı yığına sakla
inc cx
cmp al,0       ; bölüm bitti mi?
jnz o_bol
o_yaz:
pop ax         ; LIFO -> ters sırada geri al (en yüksek basamak önce)
mov dl,ah
add dl,30h
call yaz
loop o_yaz
ret
onluk endp
```
> Neden ters? Kalanlar **birler, onlar...** sırasıyla çıkar; yığın LIFO olduğu için pop ederken doğru sıraya döner.

**`onaltili`** — `di`'yi 2-hane hex basar (`binheks`'in 8-bit hali):
```asm
onaltili proc near
mov bx,di
mov ch,02h     ; 2 hane
mov cl,04h     ; 4 bit döndür (nibble)
h_dongu:
rol bl,cl
mov dl,bl
and dl,0Fh     ; alttaki 4 bit (0..15)
add dl,30h
cmp dl,3Ah     ; '0'..'9' mu?
jl h_yaz
add dl,07h     ; A..F düzeltmesi
h_yaz:
call yaz
dec ch
jnz h_dongu
ret
onaltili endp
```

**`karakter`** — kodun karakterini basar:
```asm
karakter proc near
mov dx,di      ; dl = kodun alt baytı = karakter
call yaz
ret
karakter endp
```

**`satir`** — alt satıra geçer:
```asm
satir proc near
mov dl,13      ; CR
call yaz
mov dl,10      ; LF
call yaz
ret
satir endp
```

---

## 2) bindec.asm

**Görev:** 16-bit bir sayıyı **onluk** olarak ekrana yazdır.

**Ne yapar:** `ax=12345` sayısını onluk basar → `12345`. (everydec'teki `onluk`'un **16-bit** hali.)

**Algoritma:** 10'a tekrar böl, her kalanı (bir rakam) yığına it; bölüm 0 olunca dur; sonra yığından ters çek ve bas.

**Satır satır:**
```asm
mov ax,12345   ; basılacak 16-bit sayı
mov bx,10      ; bölen
xor cx,cx      ; basamak sayacı
bol:
xor dx,dx      ; üst yarıyı temizle (bölünen DX:AX -> sadece AX)
div bx         ; AX = AX/10, DX = kalan (rakam)
push dx        ; rakamı sakla
inc cx
cmp ax,0       ; bölüm bitti mi?
jnz bol
yaz:
pop dx         ; LIFO -> ters sırada geri al
add dl,30h     ; rakam -> ASCII
mov ah,02h
int 21h
loop yaz
int 20h
```
> 8-bit `onluk`'tan farkı: `div bx` (16-bit) **DX:AX**'i böler → bölmeden önce `xor dx,dx` şart; kalan **DX**'te gelir (8-bit'te AH'deydi). Aralık 0–65535 (5 haneye kadar).

---

## 3) sifre2.asm

**Görev:** Sadece rakamlardan oluşan 4 uzunluklu şifreyi okurken **basılan karakteri gösterme, yerine `*` bas**; giriş bitince şifreyi **2026** ile karşılaştır, doğruysa `TAMAM`, yanlışsa `HATA` yaz.

**Ne yapar:** 4 karakter okur (her tuşta `*` görünür), `'2026'` ile karşılaştırır, sonucu yazar. `.EXE` (`.MODEL`/`.DATA`/`.CODE`).

**Algoritma:**
```
1. 4 karakter oku (ekranda göstermeden), her birine karşılık '*' bas, tampona kaydet
2. tamponu '2026' ile teker teker karşılaştır
3. hepsi eşit -> "TAMAM", biri farklı -> "HATA"
```

**Satır satır:**
```asm
.MODEL SMALL
.STACK 100H
.DATA
    password DB '2026'      ; doğru şifre
    input DB 4 DUP(?)       ; girilen şifre için 4 boş bayt
    msgTamam DB 13,10,'TAMAM$'
    msgHata  DB 13,10,'HATA$'
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX             ; DS'i veri segmentine kur (.EXE'de şart)

    MOV CX, 4
    LEA SI, input         ; SI -> input tamponu
READ_LOOP:
    MOV AH, 08H           ; klavyeden oku, EKRANDA GÖSTERME (echo yok)
    INT 21H               ; AL = gerçek karakter
    MOV [SI], AL          ; gerçek karakteri tampona yaz
    MOV DL, '*'           ; ekrana onun yerine yıldız bas
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP READ_LOOP

    MOV CX, 4
    LEA SI, input
    LEA DI, password
COMPARE_LOOP:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE WRONG             ; bir bayt bile farklıysa -> HATA
    INC SI
    INC DI
    LOOP COMPARE_LOOP
CORRECT:
    MOV AH, 09H
    LEA DX, msgTamam
    INT 21H
    JMP EXIT
WRONG:
    MOV AH, 09H
    LEA DX, msgHata
    INT 21H
EXIT:
    MOV AH, 4CH           ; .EXE bitirme
    INT 21H
MAIN ENDP
END MAIN
```
> Maskelemenin püf noktası: **`AH=08H`** (echo'suz okuma) + gerçek karakteri sakla + ekrana **kendimiz `'*'`** basıyoruz. `AH=01H` olsaydı gerçek karakter ekranda görünürdü.
> `.EXE` olduğu için exe2bin yok: `masm sifre2;` → `link sifre2;` → `sifre2.exe`.

---

## 4) reverse.asm

**Görev:** Kullanıcının Enter ile bitirdiği alfanümerik katarı **tersten** yazdır. Çözümü **STACK (push/pop)** ile yap.

**Ne yapar:** Enter'a kadar karakter okur (yığına iter), sonra yığından çekip basar → katar ters çıkar. (Tampon bile yok; tek depo yığın.)

**Algoritma:**
```
Enter'a kadar: her karakteri yığına it, say
sonra: sayı kadar pop et ve bas  (LIFO -> ters)
```

**Satır satır:**
```asm
mov cx,0       ; karakter sayacı
oku:
mov ah,01h     ; klavyeden oku (echo'lu)
int 21h
cmp al,13      ; Enter (CR) mı?
je yazdir      ; evetse okumayı bitir
push ax        ; karakteri YIĞINA it
inc cx         ; say
jmp oku
yazdir:
mov dl,13      ; alt satıra geç (CR)
mov ah,02h
int 21h
mov dl,10      ; LF
mov ah,02h
int 21h
jcxz son       ; hiç karakter yoksa (cx=0) atla -> loop sarmasını önler
ters:
pop ax         ; LIFO: en son giren ilk çıkar -> ters sıra
mov dl,al
mov ah,02h
int 21h
loop ters      ; cx kez
son:
int 20h
```
> Ters çevirme tamamen **yığının LIFO doğası** sayesinde olur. `jcxz son`: boş giriş (cx=0) olduğunda `loop`'un 0→FFFFh'e sarıp 65536 kez dönmesini engeller.

---

## 5) gizle.asm

**Görev:** Kullanıcının girdiği karakteri **1 saniye ekranda göster**, sonra sil ve yerine `*` yaz; giriş Enter ile bitsin.

**Ne yapar:** Enter'a kadar her karakteri okur; karakter 1 sn görünür, sonra backspace ile geri gidip üzerine `*` yazar.

**Algoritma:**
```
Enter'a kadar her karakter için:
    karakteri oku (ekranda görünür)
    1 saniye bekle
    backspace ile imleci geri al, üzerine '*' yaz
```

**Satır satır — ana döngü:**
```asm
oku:
mov ah,01h     ; klavyeden oku (echo'lu -> karakter görünür)
int 21h
cmp al,13      ; Enter mı?
je son
call bekle     ; ~1 saniye bekle
mov ah,02h
mov dl,08h     ; backspace: imleç bir sola, karakterin üzerine gelir
int 21h
mov dl,'*'     ; o pozisyona '*' yaz -> eski karakteri ezer
int 21h
jmp oku
son:
int 20h
```

**Satır satır — `bekle` (BIOS zamanlayıcısıyla ~1 sn):**
```asm
bekle proc near
mov ah,00h
int 1Ah        ; BIOS saat: DX = tik sayısının alt word'ü (gece yarısından beri)
mov bx,dx      ; başlangıç tikini sakla
b_dongu:
mov ah,00h
int 1Ah        ; tik sayısını tekrar oku
sub dx,bx      ; DX = geçen tik (şimdi - başlangıç)
cmp dx,18      ; 18 tik ~= 1 saniye (18 / 18.2)
jb b_dongu     ; 18'den azsa beklemeye devam
ret            ; ~1 saniye geçti -> dön
bekle endp
```
> **Backspace (`DL=08h`)** imleci silmeden bir sola alır; sonra `'*'` o hücreye yazılınca karakter değişir.
> **`int 1Ah`** CPU hızından bağımsız **gerçek** 1 saniye verir (boş `loop` gecikmesi DOSBox cycles ayarına göre değişirdi).
