# Kreiranje objekta simulatora (inicijalizacija raspoređivača događaja)
set ns [new Simulator]

# Definisanje različitih boja za podatkovne tokove (za NAM fajl)
$ns color 1 Blue
$ns color 2 Red

# Uključivanje trace procesa (kreiranje trace datoteke za vizualizaciju)
set nf [open out2.nam w]
$ns namtrace-all $nf

# Otvaranje trace datoteke za upis značajnih podataka o simulaciji
set tf [open out2.tr w]
$ns trace-all $tf

# Definisanje finish procedure
proc finish {} {
        global ns nf tf
        $ns flush-trace
        # Zatvaranje NAM trace datoteke za vizualizaciju
        close $nf
        # Zatvaranje trace datoteke
        close $tf
        # Izvršavanje NAMa na trace datoteci
        exec nam out2.nam &
        exit 0
}

# Kreiranje četiri čvora
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Nodes Color
$n0 color Green
$n1 color Green
$n2 color Green
$n3 color Green

#Ime čvora
$n0 label "Pošiljaoc_1"
$n0 label-color magenta
$n1 label "Pošiljaoc_2"
$n1 label-color magenta
$n2 label Ruter
$n2 label-color magenta
$n3 label Prijemnik
$n3 label-color magenta


# Povezivanje čvorova duplex linkovima
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

# Postavljanje limita na veličinu reda čekanja (na link između čvorova 2 i 3) na 10
$ns queue-limit $n2 $n3 10

# Postavljanje pozicije čvorova (za NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n1 $n2 orient right-up

# Nadgledanje reda čekanja za link n2-n3 (za NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5

# Kreiranje TCP transportnih agenata
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

# Postavljanje FTP generatora saobraćaja
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP


# Kreiranje UDP transportnih agenata
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 2


# Postavljanje CBR generatora saobracaja
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false



# Postavljanje scenarija simulacije
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"





# Pozivanje finish procedure nakon 5 sekundi simulacije
$ns at 5.0 "finish"

puts "CBR packet size = [$cbr set packet_size_] "
puts "CBR interval = [$cbr set interval_] "

# Pokretanje simulacije
$ns run

