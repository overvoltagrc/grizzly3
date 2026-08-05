<p align="center">
  <img src="grizzly3_logo.png" alt="Grizzly3 Logo" width="500">
</p>

# Grizzly3 — Winch Controller per verricelli R/C

Grizzly3 è una centralina elettronica per il pilotaggio di verricelli (winch) su modelli R/C (crawler, scaler, ecc.), progettata originariamente nel 2017 e ora rilasciata come progetto open source.

La scheda riceve un segnale PPM standard da un canale del ricevitore R/C e lo converte in un comando bidirezionale a PWM per pilotare il motore del verricello in avanti, indietro, con frenata attiva (drag brake) in folle.

## 1. Il progetto

Grizzly3 è composto da tre parti:

- **Firmware** (`/fw`): codice sorgente e file `.hex` compilato per il microcontrollore PIC che gestisce la logica di lettura del comando radio e di pilotaggio del ponte a MOSFET del motore.
- **PCB** (`/brd`): file del circuito stampato disegnato in Eagle CAD, completi di file Gerber pronti per la produzione.
- **Documentazione** (`/man`, `/ref`, `/assembling`): manuale utente (IT/EN), datasheet dei componenti principali e distinta base per l'assemblaggio.

### Caratteristiche principali

- Controllo motore bidirezionale (avanti/indietro) tramite ponte H a MOSFET
- Drag brake attivo quando il comando è a riposo
- Due modalità di funzionamento selezionabili via jumper hardware:
  - **3POS**: comando proporzionale centrato (stick tipo throttle bidirezionale, es. canale motore standard)
  - **2POS**: comando a corsa singola con inversione di direzione ad ogni ripartenza dallo zero (tipico di alcuni radiocomandi con canale dedicato al verricello)
- Segnalatore acustico (buzzer) integrato
- Basato su microcontrollore PIC12F629

## 2. Funzionamento del firmware

Il firmware (`/fw/grizzly3.c`) è scritto in C per PIC a 8 bit e lavora in questo modo:

1. **Lettura del segnale PPM**: un interrupt on-change sul pin `GP3` misura, tramite Timer0, la durata dell'impulso PPM in ingresso (tipicamente 900–2100 µs).
2. **Calibrazione automatica dell'oscillatore interno**: all'avvio il firmware legge il valore di calibrazione di fabbrica memorizzato nell'ultima locazione di memoria del PIC e lo carica nel registro `OSCCAL`. Questa operazione è automatica e non richiede alcun intervento manuale.
3. **Sincronizzazione iniziale (`syncPPM`)**: alla partenza la scheda attende di ricevere un certo numero di frame PPM validi consecutivi prima di considerare il segnale radio stabile, come protezione contro segnali disturbati o glitch iniziali.
4. **Lettura del jumper JP**: in base allo stato del jumper `JP` (`GP2`), il firmware sceglie se entrare in modalità `grizzly3_3POS()` o `grizzly3_2POS()`.
5. **Generazione del PWM**: un secondo interrupt, gestito da Timer1, genera un PWM software a ~488 Hz con rampa graduale (soft-start/soft-stop) tra il valore corrente e il valore comandato, per evitare strappi meccanici sul verricello.
6. **Pilotaggio uscite**: a seconda di direzione/freno/PWM, il firmware pilota le 4 uscite verso il ponte MOSFET (`GPIO_FWD`, `GPIO_REV`, `GPIO_BRK`, `GPIO_OFF`).

## 3. Compilatore

Il firmware è scritto per essere compilato con **mikroC PRO for PIC** di [MikroElektronika](https://www.mikroe.com/mikroc-pic).

Il progetto compilato occupa circa **617 word di programma su 1024 disponibili (~60%)** sul PIC12F629, quindi rientra ampiamente nel limite di 2 KByte di codice compilato previsto dalla **licenza gratuita** di mikroC PRO for PIC. Non è quindi necessaria alcuna licenza a pagamento per compilare o modificare questo firmware.

## 4. Programmazione della scheda

**Non è necessario mettere mano al codice sorgente.** Per programmare la scheda è sufficiente:

1. Collegare il PIC12F629 montato sulla scheda (o prima del montaggio, tramite lo zoccolo/i pad ICSP) a un programmatore compatibile, ad esempio un **PICkit 2/3/4**.
2. Caricare il file **`/fw/grizzly3.hex`** già compilato, presente in questo repository.

Non sono richieste procedure di calibrazione, taratura o test iniziali successivi al flashing: la calibrazione dell'oscillatore interno è gestita automaticamente dal firmware a ogni accensione (vedi punto 2). Una volta caricato l'hex e collegata la scheda al ricevitore, la centralina è pronta all'uso — basta selezionare la modalità 2POS/3POS desiderata tramite il jumper JP prima di alimentarla.

## 5. Il PCB

Il circuito stampato è stato disegnato in **Eagle CAD** (file sorgente: `/brd/grizzly3.brd`).

Nella cartella `/brd/gerber` sono presenti tutti i file Gerber (e uno `.zip` già pronto con l'intero pacchetto) necessari per far produrre il PCB su un servizio di fabbricazione esterno, ad esempio [JLCPCB](https://jlcpcb.com/), [PCBWay](https://www.pcbway.com/) o simili: è sufficiente caricare l'archivio `.zip` (o i singoli file Gerber) nel loro configuratore online per ottenere un preventivo e ordinare le schede.

Nella cartella `/assembling` è presente la distinta componenti (`componenti.xls`) e un'immagine di riferimento per il posizionamento dei componenti SMD.

## Struttura del repository

```
grizzly3/
├── assembling/     # Distinta base (BOM) e immagine di assemblaggio
├── brd/            # Progetto Eagle CAD (.brd) e file Gerber per la produzione del PCB
├── fw/              # Sorgente firmware (mikroC) e .hex già compilato, pronto da flashare
├── man/             # Manuale utente IT/EN
├── ref/             # Datasheet dei componenti principali (PIC12F629, MOSFET, transistor)
└── grizzly3_logo.png
```

## Licenza

Questo progetto è distribuito con licenza **MIT** — vedi il file [LICENSE](LICENSE).
