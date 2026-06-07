# Assembly Örnekleri — Açıklamalar

Bu dosya `examples/` klasöründeki her `.asm` örneğinin **ne yaptığını**, **algoritmasını** ve **satır satır** açıklamasını içerir. Kod dosyalarına dokunulmamıştır; tüm açıklamalar burada.

## İçindekiler
1. [ascii.asm](#1-asciiasm)
2. [binbin.asm](#2-binbinasm)
3. [binquad.asm](#3-binquadasm)
4. [binheks.asm](#4-binheksasm)
5. [desibin.asm](#5-desibinasm)
6. [kalp.asm](#6-kalpasm)
7. [gurultu.asm](#7-gurultuasm)
8. [sifre.asm](#8-sifreasm)
9. [tufek.asm](#9-tufekasm)

## Sık geçen kavramlar (kısa)
- **`int 21h, ah=02h`** → DL'deki karakteri ekrana basar.
- **`int 21h, ah=01h`** → klavyeden bir karakter okur (AL'ye, echo'lu).
- **`int 20h`** → `.COM` programını bitirir.
- **ASCII:** `'0'=30h … '9'=39h`, `'A'=41h`. Bir rakamı yazdırmak için `+30h`.
- **8086 kuralı:** `rol`/`shr` döndürme sayısı yalnızca **`1`** veya **`CL`** olabilir.
- **8-bit yarılar:** AX, BX, CX, DX register'larının üst/alt 8-bit yarıları vardır — örn. CX = CH (üst) + CL (alt).

---

## 1) ascii.asm

**Ne yapar:** 0'dan 255'e kadar **tüm karakterleri** (DOS/CP437 karakter seti) ekrana basar.

**Algoritma:**
```
DL = 0
256 kez:
    DL'deki karakteri bas
    DL = DL + 1
dur
```

**Satır satır:**
```asm
mov cx,100h   ; CX = 256 (döngü sayacı, 100h = 256)
mov dl,0      ; DL = 0  -> basılacak ilk karakter kodu
dondur:
mov ah,02h    ; "ekrana karakter bas" fonksiyonu
int 21h       ; DL'deki karakteri yazar
inc dl        ; sonraki karaktere geç
loop dondur   ; CX'i 1 azalt; 0 değilse başa dön
int 20h       ; bitir
```
> Not: 7 (bip), 8 (geri), 10 (alt satır), 13 (satır başı) gibi kodlar kontrol karakteridir; glif basmak yerine imleci oynatırlar.

---

## 2) binbin.asm

**Ne yapar:** `bx`'teki sayının **16-bit ikilik (binary)** gösterimini basar. `bx=43690` (=`AAAAh`) için çıktı: `1010101010101010`.

**Algoritma:** Bitleri soldan (MSB) sağa basmak için her turda sayıyı 1 bit sola döndür; döndürünce en soldaki bit en sağa sarar, o biti oku ve `'0'`/`'1'` bas. 16 kez.

**Satır satır:**
```asm
mov bx,43690  ; basılacak sayı (= AAAAh)
mov ch,16     ; CH = 16 (16 bit basacağız)  -> döngü sayacı
dondur:
mov cl,01h    ; döndürme miktarı = 1
rol bx,cl     ; BX'i 1 bit sola döndür: en sol bit (bit15) en sağa (bit0) sarar
mov al,bl     ; BX'in alt baytını AL'ye al
and al,01h    ; sadece en alttaki biti bırak (gerisini sıfırla)
add al,30h    ; 0/1 -> '0'/'1' (ASCII)
mov dl,al
mov ah,02h
int 21h       ; biti bas
dec ch        ; sayacı azalt
jnz dondur    ; CH 0 değilse devam
int 20h
```
> Püf nokta: CX iki işe bölünmüş — **CL** döndürme miktarı (1), **CH** döngü sayacı. Bu yüzden `loop` (tüm CX'i kullanır) yerine elle `dec ch / jnz`. `jnz`, CX'e değil, `dec ch`'nin kurduğu **Zero Flag'e** bakar.

---

## 3) binquad.asm

**Ne yapar:** `bx`'teki sayının **4'lük taban (base-4)** gösterimini basar. `bx=228` için çıktı: `00003210` (8 hane, her hane 2 bit).

**Algoritma:** `binbin` ile aynı, sadece her turda **2 bit** işlenir: 2 bit döndür, alttaki 2 biti maskele (`03h`), `'0'..'3'` bas. 16/2 = 8 tur.

**Satır satır:**
```asm
mov bx,228    ; basılacak sayı (= 3210 base-4)
mov ch,8h     ; 8 hane -> 8 tur
dondur:
mov cl,2h     ; her turda 2 bit döndür
rol bx,cl
mov al,bl
and al,03h    ; alttaki 2 biti bırak (0..3)
add al,30h    ; -> '0'..'3'
mov dl,al
mov ah,02h
int 21h
dec ch
jnz dondur
int 20h
```
> Harf düzeltmesi yok: 4'lük tabanda haneler yalnız 0–3, hepsi `'0'..'3'` aralığında.

---

## 4) binheks.asm

**Ne yapar:** `bx`'teki sayının **onaltılık (hex)** gösterimini basar. `bx=43981` (=`ABCDh`) için çıktı: `ABCD` (4 hane, her hane 4 bit = bir nibble).

**Algoritma:** Her turda 4 bit döndür, alttaki 4 biti (nibble) maskele (`0Fh`), `+30h` ile ASCII'ye çek; sonuç `'9'`'dan büyükse (A–F bölgesi) `+7` daha ekle. 16/4 = 4 tur.

**Satır satır:**
```asm
mov bx,43981  ; = ABCDh
mov ch,4h     ; 4 hane -> 4 tur
dondur:
mov cl,04h    ; her turda 4 bit döndür (1 nibble)
rol bx,cl
mov al,bl
and al,0Fh    ; alttaki 4 biti bırak (0..15)
add al,30h    ; '0' tabanına çek
cmp al,3Ah    ; sonuç '0'..'9' mu? (3Ah = '9'+1, eşik)
jl ekrana     ; evet -> olduğu gibi bas
add al,07h    ; hayır -> A..F için boşluğu atla ('9' ile 'A' arası 7'dir)
ekrana:
mov dl,al
mov ah,02h
int 21h
dec ch
jnz dondur
int 20h
```
> `3Ah` neden eşik: `'9'=39h`, bir sonrası `3Ah` artık rakam değil. `'9'(39h)` ile `'A'(41h)` arasında 7 birim boşluk var; `+07h` bu boşluğu atlatır.

---

## 5) desibin.asm

**Ne yapar:** Klavyeden bir **ondalık sayı** okur ve değerini **BX**'te (ikilik olarak) biriktirir — yani "decimal → binary". Rakam olmayan bir tuşa (Enter dâhil) basınca durur. (Sonucu ekrana yazmaz; BX'te tutar.)

**Algoritma:** `toplam = 0`; her gelen rakam için `toplam = toplam*10 + rakam`. Rakam dışı tuşta dur.

**Satır satır:**
```asm
mov bx,0h     ; BX = 0 (biriktirici / toplam)
giris:
mov ah,01h    ; klavyeden 1 karakter oku (echo'lu)
int 21h       ; AL = karakter
sub al,30h    ; ASCII rakam -> sayı ('5'->5)  [+30h'nin tersi]
cmp al,0
jl program_sonu  ; < 0 ise ('0'dan küçük tuş) -> çık
cmp al,9
jg program_sonu  ; > 9 ise ('9'dan büyük tuş) -> çık
cbw           ; AL'yi AX'e genişlet (mul AX ile çalışır; rakam pozitif -> AH=0)
xchg ax,bx    ; takas: AX=eski toplam, BX=yeni rakam
mov cx,10
mul cx        ; AX = AX*10 (toplam*10)
xchg ax,bx    ; geri takas: AX=rakam, BX=toplam*10
add bx,ax     ; BX = toplam*10 + rakam
jmp giris     ; sonraki karaktere
program_sonu:
int 20h
```
> `cbw`: AL'yi işaret genişleterek AX yapar (rakam 0–9 pozitif olduğu için AH=0).
> `xchg` "dansı": `mul` çarpanı AX'te ister ama toplam BX'tedir; takas ile toplamı AX'e alıp çarpıyor, sonra geri takas edip topluyoruz. (`xchg` = swap.)
> `jl`/`jg` işaretli karşılaştırmadır; `sub` negatif sonuç verebildiği için işaretli olmaları gerekir.

---

## 6) kalp.asm

**Ne yapar:** Ekrana tek bir **kalp sembolü** basar. CP437'de **kod 3 = ♥**.

**Satır satır:**
```asm
mov dl,03h   ; DL = 3  (CP437 kalp karakteri)
mov ah,02h   ; "ekrana karakter bas"
int 21h      ; ♥ basar
int 20h      ; bitir
```
> `ascii.asm`'in tek karaktere indirgenmiş hâli: döngü yok, sadece 03h basılıyor.

---

## 7) gurultu.asm

**Ne yapar:** PC hoparlöründen **gürültü/cızırtı** çıkarır. **Sonsuz döngüdedir** (kendiliğinden bitmez; DOSBox'ı resetlemen gerekir).

**Algoritma:**
```
hoparlörü manuel kontrole al
sonsuza dek:
    hoparlör zarını ters çevir (toggle)      -> ses
    bir sonraki bekleme süresini RASTGELE üret  -> gürültü (sabit olsa düz nota olurdu)
    o kadar bekle
```

**Satır satır:**
```asm
basla:
mov dx,300h        ; PRNG tohumu (rastgele gecikme + ses çekirdeği)
in al,61h          ; 61h portunu OKU (hoparlör kontrol portu)
and al,11111100b   ; bit0 + bit1'i sıfırla -> timer'ı ayır, manuel kontrol al
ses:
xor al,2           ; bit1'i TERS çevir (hoparlör zarını oynat)
out 61h,al         ; AL'yi porta YAZ -> hoparlör hareket eder
add dx,1649h       ; PRNG-1: tohuma sabit ekle
mov cl,3
ror dx,cl          ; PRNG-2: DX'i 3 bit sağa döndür (bitleri karıştır)
mov cx,dx          ; karışmış tohumu CX'e al (gecikme sayacı)
and cx,01FFh       ; üst sınır: 0..511 (gecikme çok uzamasın)
or  cx,10          ; alt sınır: CX 0 olmasın (loop'ta 65536'ya sarmasın)
bekle:
loop bekle         ; CX kez boşta dön = zaman gecikmesi
jmp ses            ; sonsuza dek baştan
```
> **Port 61h:** bit0 = timer-2 kapısı, bit1 = hoparlör verisi (zar konumu). `and 11111100b` ile timer'ı devreden çıkarıp bit1'i elle toggle ederek ses üretiyoruz.
> **Bit işlemleri:** AND **sıfırlar**, OR **set eder (1 yapar)**, XOR **ters çevirir (toggle)**.
> **`or cx,10` neden:** `loop` önce CX'i azaltır; CX=0 ile girilirse 0FFFFh'e sarar ve 65536 kez döner (devasa gecikme). OR ile CX'in asla 0 olmaması garanti edilir.

---

## 8) sifre.asm

**Ne yapar:** Klavyeden **4 karakter** okur, doğru şifre `'1234'` ile **bayt bayt** karşılaştırır; hepsi tutarsa `YES`, biri bile tutmazsa `NO` yazar.

**Önemli — bu bir `.EXE`:** Diğerleri `.COM` (elle segment, `int 20h`); bu ise `.MODEL`/`.DATA`/`.CODE` direktiflerini kullanan `.EXE`. Farkları: ayrı veri/yığın segmenti var, **DS'i kendin ayarlarsın**, bitiş `int 21h/4Ch` ile yapılır, ve **exe2bin gerekmez** (doğrudan `sifre.exe`).

**Algoritma:**
```
1. 4 karakter oku, 'input' tamponuna yaz
2. input ile password'ü teker teker karşılaştır
3. hepsi eşit -> "YES", biri farklı -> "NO"
```

**Satır satır:**
```asm
.MODEL SMALL
.STACK 100H
.DATA
    password DB '1234'      ; doğru şifre (4 bayt)
    input DB 4 DUP(?)       ; kullanıcının girişi için 4 boş bayt (DUP = "şu kadar tane")
    msgYes DB 13,10,'YES$'  ; CR,LF + "YES" + '$' (09h'ın bitiş işareti)
    msgNo  DB 13,10,'NO$'
.CODE
MAIN PROC
    MOV AX, @DATA      ; @DATA = veri segmentinin adresi
    MOV DS, AX         ; DS'i veri segmentine kur (.EXE'de şart)

    MOV CX, 4          ; 4 karakter
    LEA SI, input      ; SI = input'un ADRESİ (işaretçi)
READ_LOOP:
    MOV AH, 01H
    INT 21H            ; klavyeden 1 karakter -> AL
    MOV [SI], AL       ; AL'yi SI'nin gösterdiği yere yaz
    INC SI             ; işaretçiyi ilerlet
    LOOP READ_LOOP

    MOV CX, 4
    LEA SI, input      ; SI -> input
    LEA DI, password   ; DI -> password
COMPARE_LOOP:
    MOV AL, [SI]       ; input'un baytı
    CMP AL, [DI]       ; password'ün baytıyla karşılaştır
    JNE WRONG          ; farklıysa -> NO
    INC SI
    INC DI
    LOOP COMPARE_LOOP

CORRECT:
    MOV AH, 09H        ; "string yazdır" ($'e kadar)
    LEA DX, msgYes
    INT 21H
    JMP EXIT
WRONG:
    MOV AH, 09H
    LEA DX, msgNo
    INT 21H
EXIT:
    MOV AH, 4CH        ; .EXE bitirme
    INT 21H
MAIN ENDP
END MAIN
```
> **İşaretçi:** `SI` adresi tutar, `[SI]` o adresteki değerdir (C'deki `p` ve `*p` gibi). `LEA SI, input` = `MOV SI, OFFSET input`.
> **`int 21h, ah=09h`:** DS:DX'in gösterdiği `$`-sonlu metni basar (tek karakter değil, tüm string).

---

## 9) tufek.asm

**Ne yapar:** **Makineli tüfek sesi** çıkarır: 40 kısa "patlama", aralarında sessizlik. `.COM` (elle segment + `org 100h`).

**Algoritma:**
```
40 mermi için:
    bir atış sesi çıkar (kısa gürültü patlaması)
    kısa bir süre sessiz kal
dur
```
Üç parça: **ana_program** (yönetici döngü), **ates** (tek atış = kısaltılmış gurultu), **sessizlik** (gecikme).

**Satır satır — ana_program:**
```asm
basla:
mov cx,40            ; CX = 40 mermi
ates_et:
push cx              ; mermi sayacını YIĞINA kaydet (ates onu bozacak)
call ates            ; 1 atış sesi çıkar, sonra dön
mov si,4             ; boşluk için iç sayaç = 4
iki_atis_arasi:
cmp si,0             ; SI = 0 mı?
je iki_atis_arasi_sonu
call sessizlik       ; bir gecikme bekle
dec si
jmp iki_atis_arasi   ; (sessizlik'i 4 kez çağırır)
iki_atis_arasi_sonu:
pop cx               ; mermi sayacını YIĞINDAN geri al
loop ates_et         ; CX--; 0 değilse sonraki mermiye
int 20h
```
> **call / ret:** `call` alt programa zıplar ve **geri dönüş adresini yığına iter**; `ret` o adresi geri alır. Gerçek fonksiyon mantığı.
> **push/pop neden:** mermi sayacı CX'te; ama `ates`/`sessizlik` içeride CX'in üzerine yazıyor. `push cx` ile çağrı öncesi kaydedip `pop cx` ile geri alıyoruz (yığın = LIFO).
> İç döngü **SI** kullanır (CX meşgul olduğu için), `loop` yerine elle `cmp/je/dec/jmp`.

**Satır satır — ates (kısa patlama = sınırlı gurultu):**
```asm
ates proc near
mov dx,300h          ; PRNG tohumu
mov bx,20h           ; PATLAMA UZUNLUĞU: 32 toggle sonra dur
in al,61h
and al,11111100b     ; manuel kontrol
ses:
xor al,2             ; ┐
out 61h,al           ; │ gurultu ile AYNI:
add dx,1649h         ; │ toggle + PRNG + clamp + bekle
mov cl,3             ; │
ror dx,cl            ; │
mov cx,dx            ; │
and cx,01FFh         ; │
or cx,10             ; ┘
bekle:
loop bekle           ; değişken gecikme
dec bx               ; patlama sayacını azalt
jnz ses              ; bx (32) kez dön (gurultu'daki sonsuz jmp YERİNE)
and al,11111100b     ; patlama bitti: hoparlörü KAPAT
out 61h,al
ret                  ; çağırana dön
ates endp
```
> `gurultu`'dan tek farkı: `jmp ses` (sonsuz) yerine `dec bx / jnz ses` (32 turla **sınırlı** kısa patlama) + sonunda hoparlörü susturup `ret`.

**Satır satır — sessizlik (boşluk gecikmesi):**
```asm
sessizlik proc near
mov cx,4000h         ; CX = 16384
ara_ver:
loop ara_ver         ; boşta dön -> bekle
ret
sessizlik endp
```
> Ana döngü bunu mermi başına 4 kez çağırır -> iki atış arası boşluk ≈ 4 × 16384 tur.
