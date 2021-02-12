#!/bin/bash

# Team A
for i in {1..50} 
do
new=$(printf "eisA%d.json" "$i")
(printf '{
"scenario":"test40x40",
"host":"localhost",
"port":12300,
"scheduling":false,
"timeout":4000,
"times":false,
"notifications":false,
"queued":false,
"entities": [{"name":"agentJaCaMo_Builders%d", "username": "agentA%d", "password": "1", "print-iilang":false, "print-json":false}]
}
' "$i" "$i") > $new
done

#For qualification
#"host":"agentcontest1.in.tu-clausthal.de",
#"entities": [{"name":"agentA%d", "username": "agentJaCaMo_Builders%d", "password": "8P7bgZhC", "print-iilang":false, "print-json":false}]


# Team B
for i in {1..50} 
do
new=$(printf "eisB%d.json" "$i")
(printf '{
"scenario":"test40x40",
"host":"localhost",
"port":12300,
"scheduling":false,
"timeout":4000,
"times":false,
"notifications":false,
"queued":false,
"entities": [
{"name":"connectionB%d", "username": "agentB%d", "password": "1", "print-iilang":false, "print-json":false}
  ]
}
' "$i" "$i") > $new
done

