#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

#Open the nam trace file
set f [open out.tr w] 
$ns trace-all $f 
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	#Close the trace file
        close $nf
	#Execute nam on the trace file
        exec nam out.nam &
        exit 0
}

#Create twelve nodes
for {set i 0} {$i<12} {incr i} {
    set n($i) [$ns node]
}
#Attacker node:command and control server
set atck [$ns node]
$atck shape "square"
$atck color "blue"

$n(4) color "red"
$n(11) shape "hexagon"
$n(11) color "red"
$n(10) color "brown"


#Create links between the nodes
for {set i 0} {$i<10} {incr i} {
$ns duplex-link $n($i) $n(10) 1Mb 10ms DropTail
}

#Create links between the nodes for attacker
for {set i 0} {$i<4} {incr i} {
$ns duplex-link $n($i) $atck 1Mb 10ms RED
$ns duplex-link-op $n($i) $atck color "blue"
}
for {set i 5} {$i<10} {incr i} {
$ns duplex-link $n($i) $atck 1Mb 10ms RED
$ns duplex-link-op $n($i) $atck color "blue"
}


#node 4 is normal user

$ns duplex-link $n(10) $n(11) 7Mb 10ms SFQ

$ns queue-limit $n(10) $n(11) 200

#set normal data flow link color
$ns duplex-link-op $n(4) $n(10) color "red"
$ns duplex-link-op $n(10) $n(11) color "red"



#orient nodes
$ns duplex-link-op $n(0) $n(10) orient 50deg
$ns duplex-link-op $n(1) $n(10) orient 80deg
$ns duplex-link-op $n(2) $n(10) orient 110deg
$ns duplex-link-op $n(3) $n(10) orient 140deg
$ns duplex-link-op $n(4) $n(10) orient 170deg
$ns duplex-link-op $n(5) $n(10) orient 200deg
$ns duplex-link-op $n(6) $n(10) orient 230deg
$ns duplex-link-op $n(7) $n(10) orient 260deg
$ns duplex-link-op $n(8) $n(10) orient 290deg
$ns duplex-link-op $n(9) $n(10) orient 320deg



$ns duplex-link-op $n(10) $n(11) orient left

$ns duplex-link-op $atck $n(5) orient 30deg
$ns duplex-link-op $atck $n(0) orient 60deg
$ns duplex-link-op $atck $n(9) orient 0deg


#Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $n(10) $n(11) queuePos 0.5

#Create a UDP agents and attach it to node n0-n9 i.e normal connection
for {set i 0} {$i<10} {incr i} {
set udp($i) [new Agent/UDP]
$udp($i) set class_ 1
$ns attach-agent $n($i) $udp($i)
}

#make normal flow green
$udp(4) set class_ 3




# Create a CBR traffic sources and attach it to udp0-udp9
for {set i 0} {$i<10} {incr i} {
set cbr($i) [new Application/Traffic/CBR]
$cbr($i) set packetSize_ 500
$cbr($i) set interval_ 0.005
$cbr($i) attach-agent $udp($i)
}



#####################################################

#Botmaster UDP creating and attaching (nodes:0->4,5->9)
for {set i 0} {$i<4} {incr i} {
set udpb($i) [new Agent/UDP]
$udpb($i) set class_ 2
$ns attach-agent $atck $udpb($i)
}
for {set i 5} {$i<10} {incr i} {
set udpb($i) [new Agent/UDP]
$udpb($i) set class_ 2
$ns attach-agent $atck $udpb($i)
}

# Create a CBR traffic sources and attach it to udpb($i)(nodes:0->4,5->9)
for {set i 0} {$i<4} {incr i} {
set cbrb($i) [new Application/Traffic/CBR]
$cbrb($i) set packetSize_ 100
$cbrb($i) set interval_ 0.05
$cbrb($i) attach-agent $udpb($i)
}
for {set i 5} {$i<10} {incr i} {
set cbrb($i) [new Application/Traffic/CBR]
$cbrb($i) set packetSize_ 100
$cbrb($i) set interval_ 0.2
$cbrb($i) attach-agent $udpb($i)
}
####################################################





#Create a Null agent (a traffic sink) and attach it to node n11
set null0 [new Agent/Null]
$ns attach-agent $n(11) $null0

#Connect the traffic sources with the traffic sink
for {set i 0} {$i<10} {incr i} {
$ns connect $udp($i) $null0  
}





#########################################################################

#Create a Null agent (a traffic sink) and attach it to node n0-n3 & n5-n9
for {set i 0} {$i<4} {incr i} {
set nullb($i) [new Agent/Null]
$ns attach-agent $n($i) $nullb($i)
}

for {set i 5} {$i<10} {incr i} {
set nullb($i) [new Agent/Null]
$ns attach-agent $n($i) $nullb($i)
}

#Connect the traffic sources with the traffic sink
for {set i 0} {$i<4} {incr i} {
$ns connect $udpb($i) $nullb($i)  
}
for {set i 5} {$i<10} {incr i} {
$ns connect $udpb($i) $nullb($i)  
}

##########################################################################

#Connect the traffic sources with the traffic sink
for {set i 0} {$i<10} {incr i} {
$ns connect $udp($i) $null0  
}



#labelling nodes: Normal nodes
$ns at 0.0 "$atck label Bot_Herder"
$ns at 0.0 "$n(10) label Router"
$ns at 0.0 "$n(4) label Sender"
$ns at 0.0 "$n(11) label Receiver"

#labelling nodes: Botnets
$ns at 0.0 "$n(0) label Zombie_Bot"
$ns at 0.0 "$n(1) label Zombie_Bot"
$ns at 0.0 "$n(2) label Zombie_Bot"
$ns at 0.0 "$n(3) label Zombie_Bot"
$ns at 0.0 "$n(4) label Normal_User"
$ns at 0.0 "$n(5) label Zombie_Bot"
$ns at 0.0 "$n(6) label Zombie_Bot"
$ns at 0.0 "$n(7) label Zombie_Bot"
$ns at 0.0 "$n(8) label Zombie_Bot"
$ns at 0.0 "$n(9) label Zombie_Bot"




#Schedule events for the CBR agents----Full Traffic:- 3.4 to 7.0
$ns at 0.5 "$cbrb(0) start"
$ns at 0.6 "$cbrb(1) start"
$ns at 0.7 "$cbrb(2) start"
$ns at 0.8 "$cbrb(3) start"
$ns at 0.9 "$cbrb(5) start"
$ns at 1.0 "$cbrb(6) start"
$ns at 1.1 "$cbrb(7) start"
$ns at 1.2 "$cbrb(8) start"
$ns at 1.3 "$cbrb(9) start"


$ns at 1.5 "$cbr(0) start"
$ns at 1.7 "$cbr(1) start"
$ns at 1.9 "$cbr(2) start"
$ns at 2.1 "$cbr(3) start"
$ns at 2.3 "$cbr(4) start"
$ns at 2.5 "$cbr(5) start"
$ns at 2.7 "$cbr(6) start"
$ns at 2.9 "$cbr(7) start"
$ns at 3.1 "$cbr(8) start"
$ns at 3.3 "$cbr(9) start"

$ns at 7.1 "$cbr(0) stop"
$ns at 7.3 "$cbr(1) stop"
$ns at 7.5 "$cbr(2) stop"
$ns at 7.7 "$cbr(3) stop"
$ns at 7.9 "$cbr(4) stop"
$ns at 8.1 "$cbr(5) stop"
$ns at 7.7 "$cbr(6) stop"
$ns at 7.9 "$cbr(7) stop"
$ns at 8.1 "$cbr(8) stop"
$ns at 8.3 "$cbr(9) stop"

$ns at 8.5 "$cbrb(0) stop"
$ns at 8.6 "$cbrb(1) stop"
$ns at 8.7 "$cbrb(2) stop"
$ns at 8.8 "$cbrb(3) stop"
$ns at 8.9 "$cbrb(5) stop"
$ns at 9.0 "$cbrb(6) stop"
$ns at 9.1 "$cbrb(7) stop"
$ns at 9.2 "$cbrb(8) stop"
$ns at 9.3 "$cbrb(9) stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 9.5 "finish"

#Run the simulation
$ns run
