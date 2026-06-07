# Clock — Açıklama

Bu dosya `clock.asm`'in **ne yaptığını**, **algoritmasını** ve **satır satır** çalışmasını anlatır.

## Ne yapar

Sistem saatini okuyup ekrana **dijital, büyük rakamlar** halinde `HH : MM : SS` olarak yazar. Rakamlar küçük renkli **elmaslardan (♦)** oluşur: dolu pikseller açık **cyan**, boş pikseller **mavi**. Her saniye kendini günceller; bir tuşa basınca çıkar.

Kilit fikir: rakamların şeklini elle tanımlamıyoruz — **BIOS'un ROM karakter font'unu** kullanıyoruz. Her karakterin 8×16'lık bitmap'ini BIOS'tan alıp, her bitini bir elmas olarak büyük çiziyoruz.

## Algoritma

```
ekran modunu kur (temizle), imleci gizle
BIOS ROM 8x16 font'unun adresini al (ES:BP)

sonsuz döngü:
    sistem saatini oku (saat, dakika, saniye)
    saniye bir öncekiyle aynıysa  -> sadece tuş kontrol et (yeniden çizme)
    saniye değiştiyse:
        saat/dakika/saniyeyi 6 rakama böl (her biri ASCII bir karakter)
        6 rakamı sütun tablosundaki yerlerine büyük çiz
        aralara iki ':' çiz
    tuşa basıldıysa çık
```

Bir karakteri "büyük çizmek" demek: o karakterin 8×16'lık font bitmap'ini al, **her satır için** 8 bitini soldan sağa gez; bit 1 ise cyan elmas, 0 ise mavi elmas bas.

## Veri

```asm
foff/fseg     ; ROM font'unun adresi (offset:segment)
son_sn        ; en son çizilen saniye (FFh -> ilk turda kesin çiz)
sutun         ; 6 rakamın ekran sütunları: 1,10,30,40,60,70
hane          ; 6 rakam karakteri: H H M M S S
cchar,gx      ; o an çizilen karakter ve başlangıç sütunu
crow,ccol     ; çizimde o anki piksel satır/sütunu
fbyte,cmask   ; o anki font satır baytı ve bit maskesi
```
> Veriler kodun **önünde** tanımlı (`jmp begin` üzerinden atlanıyor). Bu program **mutlak adres** kullandığı için (`hane[di]`, font okuma) `org 100h` ve verinin önceden tanımlı olması şart.

## Satır satır

### Kurulum
```asm
mov ax,0003h    ; 80x25 metin modu (ekranı temizler)
int 10h
mov ah,01h      ; imleci gizle
mov cx,2000h
int 10h
mov ax,1130h    ; font bilgisi al (AL=30h)
mov bx,0600h    ; BH=06h -> ROM 8x16 font
int 10h         ; ES:BP = font tablosunun adresi
mov foff,bp     ; adresi sakla (offset + segment)
mov ax,es
mov fseg,ax
```
`int 10h / AX=1130h / BH=06h` BIOS'un 8×16 font tablosunun adresini **ES:BP**'de verir. Karakter N'in bitmap'i `ES:[BP + N*16]`'da, 16 bayt (her bayt bir satır, bit7 = en sol).

### Ana döngü
```asm
ana:
mov ah,2Ch      ; saati oku -> CH=saat CL=dakika DH=saniye
int 21h
cmp dh,son_sn   ; saniye değişti mi?
jne yeni        ; değiştiyse -> çiz
jmp tus         ; değişmediyse -> sadece tuş kontrol
yeni:
mov son_sn,dh   ; bu saniyeyi hatırla
```
Saniye değişmediyse hiç çizmeyiz (titremeyi önler, gereksiz iş yapmaz). Değiştiyse aşağıda yeniden çizeriz.

> `jne yeni / jmp tus` neden? Koşullu atlama (`je`) yalnızca ±127 bayt gidebilir; "tus" etiketi çizim bloğunun çok uzağında. O yüzden koşulu **ters çevirip** yakına (`jne yeni`) atlıyor, asıl uzağa atlamayı **`jmp`** (sınırsız menzil) ile yapıyoruz.

```asm
mov al,ch       ; saati iki ASCII rakama böl
aam             ; AH=onlar AL=birler
add ax,3030h    ; 0..9 -> '0'..'9'  (hem AH hem AL'ye 30h ekler)
mov hane[0],ah
mov hane[1],al
mov al,cl       ; dakika
aam
add ax,3030h
mov hane[2],ah
mov hane[3],al
mov al,dh       ; saniye
aam
add ax,3030h
mov hane[4],ah
mov hane[5],al
```
`aam` bir sayıyı 10'a bölüp **onlar (AH)** ve **birler (AL)** olarak ayırır. `add ax,3030h` ile ikisini birden ASCII'ye çeviriyoruz (`'0'=30h`). Sonuç: `hane` dizisinde 6 rakam karakteri.

```asm
xor di,di       ; di = rakam indeksi 0..5
cizdongu:
mov al,hane[di] ; çizilecek rakam karakteri
mov cchar,al
mov al,sutun[di]; ekrandaki sütunu
mov gx,al
call ciz_rakam  ; bu rakamı büyük çiz
inc di
cmp di,6
jb cizdongu

mov cchar,58    ; iki ':' ayracı (char 58)
mov gx,20
call ciz_rakam
mov cchar,58
mov gx,50
call ciz_rakam
```
6 rakamı, `sutun` tablosundaki konumlarına tek tek çizer; sonra HH/MM ve MM/SS arasına iki `:` koyar.

> İndeks neden **DI**? Çünkü `ciz_rakam` içeride **SI**'yi kullanıyor; aynı register'ı dış döngüde de kullansaydık çizimden sonra indeks bozulurdu. `ciz_rakam` DI'ye dokunmaz, o yüzden güvenli.

```asm
tus:
mov ah,01h      ; bekleyen tuş var mı?
int 16h
jnz cikis       ; varsa -> çık
jmp ana         ; yoksa -> saat çalışmaya devam
cikis:
mov ah,00h      ; tuşu tüket, imleci geri getir, çık
int 16h
mov ah,01h
mov cx,0607h
int 10h
int 20h
```

### `ciz_rakam` — bir karakteri 8×16 renkli elmas olarak çiz
```asm
ciz_rakam proc near
mov ax,fseg     ; ES = font segmenti (bitmap'i buradan okuruz)
mov es,ax
mov crow,0      ; en üst piksel satırından başla
satir:
mov al,cchar    ; font baytı adresi = foff + cchar*16 + crow
mov ah,16
mul ah          ; ax = cchar * 16
add ax,foff
mov bl,crow
xor bh,bh
add ax,bx
mov si,ax
mov al,es:[si]  ; al = bu satırın 8 pikseli (bit7 = en sol)
mov fbyte,al
mov cmask,80h   ; maske en soldan (bit7) başlar
mov ccol,0
kolon:
mov ah,02h      ; imleci (5+crow, gx+ccol) hücresine taşı
xor bh,bh
mov dh,5
add dh,crow
mov dl,gx
add dl,ccol
int 10h
mov al,fbyte    ; bu piksel dolu mu?
test al,cmask
jz sonmus
mov bl,0Bh      ; dolu = açık cyan
jmp koy
sonmus:
mov bl,01h      ; boş = mavi
koy:
mov ah,09h      ; imlecin olduğu yere karakter + renk yaz
mov al,04h      ; elmas karakteri (♦)
xor bh,bh
mov cx,1
int 10h
shr cmask,1     ; maskeyi sonraki sütuna kaydır
inc ccol
cmp ccol,8
jb kolon
inc crow        ; sonraki piksel satırı
cmp crow,16
jb satir
ret
ciz_rakam endp
```
İki iç içe döngü: **dış** (16 satır), **iç** (8 sütun). Her piksel için:
1. İmleci doğru hücreye taşı (`int 10h / AH=02h`).
2. Font baytının o bitine bak (`test al,cmask`).
3. Dolu ise cyan, boş ise mavi renkle bir **elmas** yaz (`int 10h / AH=09h`).
4. Maskeyi sağa kaydır, sonraki sütun/satır.

## Kullanılan kilit kavramlar

| Kavram | İş |
|---|---|
| `int 21h, ah=2Ch` | sistem saatini oku (CH/CL/DH) |
| `int 10h, ax=1130h, bh=06h` | ROM 8×16 font adresini al (ES:BP) |
| `aam` | sayıyı onlar/birlere böl (tek komutta) |
| `int 10h, ah=02h` | imleci konumla |
| `int 10h, ah=09h` | imlece **renkli** karakter yaz (`int 21h` renk veremezdi) |
| `es:[si]` | font'u başka segmentten oku |
| `son_sn` karşılaştırma | sadece saniye değişince çiz (titreme/yük azalır) |
| `org 100h` + veri başta | mutlak adresleme şart (font + `hane` dizisi) |
| `jne X / jmp Y` | uzağa koşullu atlama yerine: ters çevir + `jmp` |

> Renk için `int 21h` yetmez; o yüzden her piksel **doğrudan BIOS'a** (`int 10h, ah=09h`) renk baytıyla yazılır. Dolu pikseller cyan, boşlar mavi → fotoğraftaki noktalı-renkli görünüm.
