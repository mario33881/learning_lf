#import "@preview/note-me:0.5.0": *

#set text(
  font: "New Computer Modern",
  size: 12pt
)

#set heading(
  numbering: "1."
)

#align(
  center,
  text(17pt)[
    *LEARNING LINGUA FRANCA*
  ]
)

#align(
  center,
  text(12pt)[
    Stefano Zenaro
  ]
)

#outline(
  title: "Indice"
)


= Introduzione

Lingua Franca (LF) e' un linguaggio di "coordinazione": ingloba altri linguaggi di programmazione (C, C++, python, TypeScript, Rust) per permettere l'esecuzione concorrente ma comunque deterministica dei programmi.

#note(
  text[E' anche possibile sviluppare programmi distribuiti.],
  title: "Nota"
)

I programmi in Lingua Franca sono composti da "Reactor":
- Possono avere trigger di reaction: porte input, action, timer.
- Possono avere porte di output, stato, parametri, lista di reazioni.
- reagiscono a eventi/messaggi. Gli eventi sono "trigger" di reaction, ovvero di funzioni. I messaggi hanno un tag/timestamp.
I messaggi possono avere parametri che verranno passati alla funzione richiamata.
- possiedono uno "state" (stato) che puo' essere modificato.
- La logica delle reaction/funzioni e' scritta nel linguaggio "target" (il linguaggio inglobato in LF).

  Devono specificare quali sono i input e i output.

  Dal punto di vista di esecuzione il tempo logico di esecuzione di una reaction e' istantaneo.

  La stessa reaction invocata piu' volte viene eseguita in tempi logici diversi.

  Due reaction dello stesso reactor sono mutualmente esclusive.

  Due reaction attivate nello stesso istante vengono evocate in ordine di definizione nel reactor, evitando il problema delle race condition se devono accedere allo stesso stato.

  Due reaction che non sono dipendenti fra di loro possono essere eseguite in parallelo su piu' core e, se permesso dal linguaggio target, anche su piu' macchine in un sistema distribuito.

- Possono contenere altri reactor.
- La comunicazione tra due reactor puo' essere effettuata solo se sono contenuti dallo stesso reactor o se hanno una relazione diretta padre-figlio.
- una porta di output puo' essere connessa a piu' input. Una porta di input non puo' ricevere da piu' di un output.


= Installazione

== Prerequisiti

- Installare Java 17 o superiore.
- Installare quello che e' necessario per permettere il supporto al linguaggio target.

== Installare LF

Seguire la documentazione ufficiale per installare il compilatore per LF e l'estensione per Visual Studio Code.


= Hello World

```lf
target Python

main reactor {
  reaction(startup) {=
    print("Hello World.")
  =}
}
```

L'istruzione `target Python` indica che il linguaggio delle reaction e' codice python. Il codice target e' contenuto nelle reaction tra `{= ... =}`.

#note(
  text[
    La prima istruzione del programma deve specificare il linguaggio target.
  ],
  title: "Nota"
)

Il `main reactor` e' il reactor principale, che contiene tutta la gerarchia dei reactor che compongono il programma.

Il reactor ha una funzione/reaction che viene eseguita quando parte il programma dall'evento trigger `startup`.

I file sorgenti hanno estensione `.lf` e sono contenuti in una cartella `src`.


= Reactor

I reactor:
- reagiscono a eventi: input, timer, eventi interni
- ha variabili di stato private
- ha reaction che possono modificare lo stato, inviare messaggi ad altri reactor, ecc...

I reactor principali sono i `main reactor` e i `federated reactor` (per programmi distribuiti). Questi reactor sono istanziati automaticamente dagli eseguibili generati dopo la compilazione.

Un file puo' definire piu' `reactor`. I `reactor` possono essere importati da altri file.

#note(
  text[
    I `main reactor` non vengono importati quando si fa l'import dei file.
    
    Questo permette di definire in modo semplice le librerie di reactor.
  ]
)

Un reactor viene definito dalla keyword `reactor` seguito dal suo nome. I `main reactor` e i `federated reactor` devono avere lo stesso nome del file (se specificato).

I `reactor` possono estendere altri `reactor` con la keyword `extends`.

Un reactor puo' essere parametrizzato se, dopo il nome, ha le parentesi tonde contenenti:

```
reactor <name>(<param_name> = <default_value>) {
  ...
}
```

I parametri devono avere valori di default. Il valore di default puo' essere cambiato quando viene istanziato il reactor.

#note(
  text[
    Il modo con cui si accede ai parametri e' dipendente dal linguaggio target.
  ],
  title: "Note"
)

I valori di default dei parametri possono essere numberi, stringhe, valori di tempo, liste di valori oppure codice nel linguaggio target incluso tra `{= ... =}`.

== Input e Output

Gli input e gli output dei reactor vengono definiti al loro interno con:

```lf
input <name> [: <type>]
output <name> [: <type>]
```

#note(
  text[
    Il tipo non e' presente se il linguaggio target e' Python.

    I tipi validi dipendono dal linguaggio target.
  ],
  title: "Nota"
)

Per leggere gli input e scrivere gli output sono presenti diverse sintassi a seconda del linguaggio target scelto.

Gli output scritti fanno eseguire le reaction "triggerate" nello stesso istante di tempo logico.

Se in istante di tempo logico lo stesso output viene scritto piu' volte, il suo valore finale sara' l'ultimo valore assegnato.

#note(
  text[
    Due reaction eseguite nello stesso tempo logico vengono eseguite nell'ordine in cui sono definite dentro al reactor.
  ],
  title: "Nota"
)

== Reaction

Le reaction sono "funzioni" dei reactor.

#note(
  text[
    Non sono propriamente funzioni: non possono essere chiamate esplicitamente come negli altri linguaggi di programmazione.

    Possono essere richiamate solo da eventi trigger.
  ]
)

Hanno una lista di trigger (simile alla sensitivity list dei linguaggi di descrizione dell'harware come verilog) e una lista di potenziali effect (come la modifica di un output):
```
reaction <name> (<trigger>) -> <effect> {=
  <body>
=}
```

Il linguaggio permette di verificare se un input e' presente in quell'istante di tempo.

Con la stessa sintassi e' possibile vedere se un output e' gia' stato impostato in quell'istante di tempo da un altra reaction.

#note(
  text[
    In python si puo' usare l'attributo `is_present` sull'input/output.
  ],
  title: "Nota"
)

Gli input sono immutabili di default ma possono essere resi mutabili definendoli con le keyword `mutable input`.

== State

Le variabili di stato vengono definite con:

```lf
state <name> [: <type>] = <value>
```
Dove il tipo deve essere specificato o meno a seconda del linguaggio target.

Alla variabile di stato viene dato un valore iniziale.

I valori iniziali possono essere numberi, stringhe, valori di tempo, liste di valori oppure codice nel linguaggio target incluso tra `{= ... =}`.

I modi per accedere e modificare i valori delle variabili di stato dipendono dal linguaggio target.

Nei "modal reactor", e' possibile definire variabili `reset state`. In questo caso la variabile puo' essere resettata al valore iniziale quando viene effettuato il reset.


= Tempo logico e tempo fisico

Tutti gli eventi in Lingua Franca vengono eseguiti ad un certo istante di tempo logico.

Il linguaggio cerca di mantenere allineati, per quanto possibile, il tempo logico e il tempo fisico della macchina.

La differenza tra i due tempi si chiama lag e di default e' un valore sempre non negativo e che si desidera essere il piu' vicino possibile allo zero. 

Se si vuole permettere l'esecuzione piu' veloce possibile, ignorando il vincolo di avere il lag positivo, bisogna impostare la proprieta' del linguaggio target `fast`.


= Timer

I timer vengono usati per invocare reaction in modo periodico.


= Action

Le action permettono di lanciare eventi per attivare le reaction. Possono contenere dati. Sono visibili solo all'interno del reactor che le definisce.

In LF ci sono due tipi di action: le action "logiche" e le action "fisiche".

#note(
  text[
    Se una reaction puo' essere attivata da piu' action, e' possibile utilizzare lo stesso meccanismo per verificare la presenza degli input anche per controllare quale action ha attivato la reaction.

    Se il target e' Python, si puo' utilizzare l'attributo `is_present`.
  ],
  title: "Nota"
)

== Action logiche

Le action logiche sono definite con:

```
logical action <name>;
```

e permettono di attivare un trigger dopo un certo intervallo di tempo logico (il delay).

Per attivare il trigger bisogna richiamare all'interno del codice target il metodo `schedule` sul nome della action (passando il delay tra parentesi) per lanciarla.

#note(
  text[
    Una reaction viene eseguita a tempo logico 0.
    
    La reaction fa lo scheduling di una action logica con 10 secondi di delay.
    
    Le reaction che vengono invocate dall'evento saranno eseguite a tempo logico "10 secondi".
  ],
  title: "Esempio"
)

Se la action deve contenere dati (payload), questi devono essere specificati come secondo parametro di `schedule`.

La reaction che fa lo schedule deve indicare tra i suoi effect la action.

== Action fisiche

Le action fisiche sono definite con:

```
physical action <name>;
```

e servono per attivare reaction in un tempo logico che dipende dal tempo fisico della macchina.

#note(
  text[
    Una reaction viene eseguita a tempo fisico 100.
    
    La reaction fa lo scheduling di una action fisica con 10 secondi di delay.
    
    Le reaction che vengono invocate dall'evento saranno eseguite a tempo logico "110 secondi".
  ],
  title: "Esempio"
)

Le action fisiche possono essere schedulate sia dentro ad una reaction ma anche da codice che e' fuori da Lingua Franca: permettono di ricevere dati dall'esterno di Lingua Franca.
