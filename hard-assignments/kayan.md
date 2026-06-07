# Kayan Yazı (kayan.asm) — Açıklama

Bu dosya `kayan.asm`'in **ne yaptığını**, **algoritmasını** ve **satır satır** çalışmasını anlatır.

## Ne yapar

Bir metni ekranda **büyük simgelerle** (renkli elmaslar, ♦) **kayan yazı** olarak gösterir. Metin sürekli yatay olarak akar; bir tuşa basınca çıkar. Dolu pikseller açık **cyan**, boş pikseller **mavi**.

Rakam/harf şekilleri için `clock` gibi **BIOS ROM font'unu** kullanır (her karakterin 8×16 bitmap'i). Fark: clock sabit rakamları çiziyordu; burada metin **kayar**.

> Mesaj kaynakta sabittir (`'BILGISAYAR '`) — referans Pascal da öyle yapıyor. Sonundaki boşluk, döngü tekrar başlarken araya bir boşluk koyar. (İstersen klavyeden okuma eklenebilir; en basit hâli için sabit tutuldu.)

## Temel fikir: kayan pencere

Tüm metni 16 satırlık, **`genis` sütun** genişliğinde bir piksel ızgarası gibi düşün (`genis = karakter_sayısı * 8`, çünkü her karakter 8 piksel geniş). Ekranda bu ızgaranın **80 sütunluk bir penceresini** gösteririz. Her karede pencerenin başlangıç noktası (`ofs`) bir kayar → metin akıyormuş gibi görünür.

**Matris dizisi kurmuyoruz** (sadeleştirme): ekrandaki bir sütunun hangi piksele denk geldiğini anında hesaplıyoruz:
- `matcol = ofs + ekran_sütunu` (taşarsa `genis` çıkarılır → döngü başa sarar)
- `karakter indeksi = matcol / 8`  (yani `matcol >> 3`)
- `bit indeksi    = matcol mod 8`  (yani `matcol AND 7`)

## Algoritma

```
ekranı temizle, imleci gizle
ROM 8x16 font adresini al
ofs = 0
sonsuz döngü:
    her ekran sütunu (0..79) için:
        matcol = ofs + sütun   (genis'i geçerse başa sar)
        bu sütunun karakterini ve bitini bul
        16 satır için: o bit doluysa cyan, boşsa mavi elmas çiz
    biraz bekle
    ofs--  (başa sararak)   -> metin SOLDAN SAĞA kayar
    tuşa basıldıysa çık
```

## Satır satır

### Veri
```asm
foff/fseg        ; ROM font adresi
ofs              ; kaydırma ofseti (ekran sütunu 0'da görünen matris sütunu)
matcol           ; o an çizilen matris sütunu
colbase          ; o sütunun karakterinin font adres tabanı
maske            ; bu sütunun font baytındaki biti
crow,kol         ; piksel satırı (0..15) ve ekran sütunu (0..79)
mesaj            ; kayan metin (sonunda boşluk = döngü arası)
uzunluk = $-mesaj    ; karakter sayısı (derleme anında hesaplanır)
genis   = uzunluk*8  ; matrisin sütun genişliği
```
> Veriler kodun **önünde** (`jmp begin` ile atlanıyor). Mutlak adres kullandığımız için (`mesaj[bx]`, font okuma) `org 100h` şart.

### Kurulum
```asm
mov ax,0003h    ; metin modu (ekranı temizler)
int 10h
mov ah,01h      ; imleci gizle
mov cx,2000h
int 10h
mov ax,1130h    ; ROM 8x16 font -> ES:BP
mov bx,0600h
int 10h
mov foff,bp     ; font adresini sakla
mov ax,es
mov fseg,ax
mov es,ax       ; ES = font segmenti (tüm font okumaları için sabit kalır)
mov ofs,0
```
> `ES`'i font segmentine kurup öyle bırakıyoruz; çizimde font'u `es:[si]` ile okuyoruz. Çıktı `int 10h` ile yapıldığı için ES'e dokunan başka bir şey yok (segment karışıklığı yok).

### Bir karede tüm pencereyi çiz
```asm
ana:
mov kol,0       ; ekran sütunu 0..79
sutun:
mov al,kol      ; matcol = ofs + kol
xor ah,ah
add ax,ofs
cmp ax,genis    ; sona taştı mı?
jb w1
sub ax,genis    ; evet -> başa sar
w1:
mov matcol,ax
```
Her ekran sütunu için, gösterilecek matris sütununu `ofs + kol` ile bulur; `genis`'i geçtiyse `genis` çıkararak başa sarar (döngü).

```asm
mov bx,ax       ; karakter indeksi = matcol / 8
mov cl,3
shr bx,cl
mov al,mesaj[bx]; bu sütunun ait olduğu karakter
mov ah,16
mul ah          ; ax = karakter * 16
add ax,foff     ; ax = o karakterin font tabanı
mov colbase,ax
```
`matcol / 8` (= `>> 3`) hangi karakterde olduğumuzu verir; `karakter*16 + foff` o karakterin 8×16 bitmap'inin font'taki adresidir.

```asm
mov ax,matcol   ; maske = 80h >> (matcol AND 7)
and ax,7
mov cl,al
mov al,80h
shr al,cl
mov maske,al
```
`matcol mod 8` (= `AND 7`) karakter içindeki **kaçıncı sütun** olduğumuzu verir. Font baytında bit7 = en sol; o yüzden maske `80h`'i o kadar sağa kaydırarak elde edilir.

```asm
mov crow,0      ; bu sütunun 16 satırını çiz
satir:
mov ah,02h      ; imleci (5+crow, kol) hücresine taşı
xor bh,bh
mov dh,5
add dh,crow
mov dl,kol
int 10h
mov si,colbase  ; font baytı = font[colbase + crow]
mov bl,crow
xor bh,bh
add si,bx
mov al,es:[si]
test al,maske   ; bu piksel dolu mu?
jz s_off
mov bl,0Bh      ; dolu = cyan
jmp s_koy
s_off:
mov bl,01h      ; boş = mavi
s_koy:
mov ah,09h      ; imlece renkli karakter yaz
mov al,04h      ; elmas (♦)
xor bh,bh
mov cx,1
int 10h
inc crow
cmp crow,16
jb satir
inc kol
cmp kol,80
jae kolbitti    ; 80 sütun bitti -> ileri (kısa) atla
jmp sutun       ; değilse döngüye dön (jmp uzağa gidebilir)
kolbitti:
```
İç içe iki döngü: her sütunun 16 satırını çizer, sonra sonraki sütuna geçer. Pencerenin tamamı (80×16) her karede yeniden çizilir → bir önceki kareyi siler.

> **Neden `jae kolbitti / jmp sutun`?** Sütun döngüsünün gövdesi (16 satırlık iç döngü dâhil) 128 baytı aştığı için, geriye `sutun:`'a **koşullu** atlama (`jb sutun`) menzil dışı kalır (MASM: `A2053 Jump out of range`). Çözüm: koşulu **ters çevirip** yakına atla (`jae kolbitti`), asıl geri-atlamayı menzili sınırsız olan **`jmp sutun`** ile yap.

### Kaydır ve devam et
```asm
call bekle      ; kayma hızını yavaşlat

mov ax,ofs      ; ofs-- (0 ise genis-1'e sar)
or ax,ax
jnz d1
mov ax,genis
d1:
dec ax
mov ofs,ax      ; ofs azalır -> metin soldan sağa akar

mov ah,01h      ; tuş var mı?
int 16h
jnz cikis
jmp ana
cikis:
mov ah,00h      ; tuşu tüket, imleci geri getir, çık
int 16h
mov ah,01h
mov cx,0607h
int 10h
int 20h
```
> **Yön:** `ofs` her karede **azalır**. Bu, her ekran sütununun bir önceki matris sütununu göstermesini sağlar → içerik **sağa** kayar (soldan sağa). Ters yön (sağdan sola) için `ofs`'u artırman yeterli.

### Gecikme
```asm
bekle proc near
mov cx,0        ; cx=0 -> loop 65536 kez döner (kısa gecikme)
gecikme:
loop gecikme
ret
bekle endp
```
Kayma hızını ayarlar. `cx`'i büyütürsen yavaşlar (ama `mov cx,0` zaten 65536 ile maksimum tek-tur gecikmedir).

## Kilit kavramlar

| Kavram | İş |
|---|---|
| `int 10h, ax=1130h, bh=06h` | ROM 8×16 font adresini al (ES:BP) |
| `matcol = ofs + kol` (+ wrap) | kayan pencere → kaydırma |
| `matcol >> 3` / `matcol AND 7` | sütun → karakter indeksi / karakter içi bit |
| `80h >> bit` | font baytında doğru biti seçen maske |
| `int 10h, ah=09h` | imlece **renkli** karakter yaz |
| `ofs--` (wrap) | soldan sağa yön |
| sondaki boşluklar | döngü tekrarları arasına boşluk koyar |

## Notlar (dürüst)
- Bu sürüm **test edilmedi**; en basit kod hedeflendi.
- Her kare 80×16 hücreyi `int 10h` ile yeniden çizdiği için **biraz titreyebilir/yavaş olabilir**. Daha akıcı için: tüm metni bir matrise kurup **doğrudan video belleğine (B800h)** yazmak gerekir (daha hızlı, titremesiz) — ama daha çok kod. Önce bunu derleyip görmek mantıklı.
- Derleme (COM): `masm kayan;` → `link kayan;` → `exe2bin kayan.exe kayan.com` → `kayan`.
