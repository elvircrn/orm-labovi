# Kreiranje objekta simulatora (inicijalizacija raspoređivača događaja)
set ns [new Simulator]

# Uključivanje trace procesa (kreiranje trace datoteke za vizualizaciju)
set nf [open out1.nam w]
$ns namtrace-all $nf

# Otvaranje trace datoteke za upis značajnih podataka o simulaciji
set tf [open out1.tr w]
$ns trace-all $tf

#Define a 'finish' procedure
proc finish {} {
        global ns nf tf
        $ns flush-trace
        # Zatvaranje NAM trace datoteke za vizualizaciju
        close $nf
        # Zatvaranje trace datoteke
        close $tf
        # Izvršavanje NAMa na trace datoteci
        exec nam out1.nam &
        exit 0
}

# Kreiranje čvorova
set n0 [$ns node]
set n1 [$ns node]


# Nodes Label
$n0 label "Čvor 0"
$n1 label "Čvor 1"

#Izgledi čvorova
$n0 color Red
$n1 color Green


# Povezivanje čvorova duplex linkom
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

#Položaj čvorova za izgled u NAM-u
$ns duplex-link-op $n0 $n1 orient right

# Kreiranje UDP transportnih agenata
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n1 $null
$ns connect $udp $null

# Postavljanje CBR generatora saobra¢aja
set cbr [new Application/Traffic/CBR]
$cbr set type_ CBR
$cbr set packet_size_ 500
$cbr set interval_ 0.005
$cbr attach-agent $udp

# Postavljanje scenarija simulacije
$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

# Pokretanje simulacije
$ns run

