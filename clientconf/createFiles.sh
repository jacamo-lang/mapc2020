#!/bin/bash

# Team A
for i in {1..50}
do
new=$(printf "eisA%d.json" "$i")
(printf '{
"scenario":"test40x40",
"host":"agentcontest1.in.tu-clausthal.de",
"port":12300,
"scheduling":false,
"timeout":4000,
"times":false,
"notifications":false,
"queued":false,
"entities": [{"name":"agentA%d", "username": "agentJaCaMo_Builders%d", "password": "8P7bgZhC", "print-iilang":false, "print-json":false}]
}
' "$i" "$i") > $new
done

#For local tests
#"host":"localhost",
#"entities": [{"name":"agentA%d", "username": "agentA%d", "password": "1", "print-iilang":false, "print-json":false}]

#For qualification
#"host":"agentcontest1.in.tu-clausthal.de",
#"entities": [{"name":"agentA%d", "username": "agentJaCaMo_Builders%d", "password": "8P7bgZhC", "print-iilang":false, "print-json":false}]


# Team B
for i in {1..50}
do
new=$(printf "eisB%d.json" "$i")
(printf '{
"scenario":"test40x40",
"host":"agentcontest2.in.tu-clausthal.de",
"port":12300,
"scheduling":false,
"timeout":4000,
"times":false,
"notifications":false,
"queued":false,
"entities": [{"name":"agentB%d", "username": "agentJaCaMo_Builders%d", "password": "8P7bgZhC", "print-iilang":false, "print-json":false}]
}
' "$i" "$i") > $new
done
