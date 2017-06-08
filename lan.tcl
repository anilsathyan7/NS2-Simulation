set ns [new Simulator]
set f [open out.tr w]
$ns trace-all $f


setmyNAM [open out.nam w]
 $ns namtrace-all $myNAM

proc finish {} {
global ns f myNAM
       $ns flush-trace
close $f
close $myNAM
execnamout.nam&

exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

set n6 [$ns node]
set n5 [$ns node]
set n9 [$ns node]


set lan1 [$ns newLan "$n0 $n2 $n1" 10Mb 40ms LL Queue/DropTail Mac/Csma/Cd Channel]

set lan2 [$ns newLan "$n5 $n6 $n9" 1Mb 40ms LL Queue/DropTail Mac/Csma/Cd Channel]


#lan1
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $n2 $udp1

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 100
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 100
$cbr1 set interval_ 0.01
$cbr1 attach-agent $udp1

set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

$ns connect $udp0 $null0
$ns connect $udp1 $null0

#lan2
set udp3 [new Agent/UDP]
$ns attach-agent $n6 $udp3

set udp4 [new Agent/UDP]
$ns attach-agent $n5 $udp4

set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 1000
$cbr3 set interval_ 0.01
$cbr3 attach-agent $udp3

set cbr4 [new Application/Traffic/CBR]
$cbr4 set packetSize_ 500
$cbr4 set interval_ 0.001
$cbr4 attach-agent $udp4

set null1 [new Agent/Null]
$ns attach-agent $n9 $null1

$ns connect $udp3 $null1
$ns connect $udp4 $null1


$ns at 0.5 "$cbr0 start"
$ns at 0.7 "$cbr1 start"
$ns at 4.2 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"

$ns at 0.8 "$cbr3 start"
$ns at 0.5 "$cbr4 start"
$ns at 4.0 "$cbr4 stop"
$ns at 4.2 "$cbr3 stop"

$ns at 5.0 "finish"
$ns run
