#!/bin/bash

# Team A
for i in {1..50} 
do
new=$(printf "eisa%d.json" "$i")
(printf '{
"scenario":"test40x40",
"host":"agentcontest2.in.tu-clausthal.de",
"port":12300,
"scheduling":false,
"timeout":4000,
"times":false,
"notifications":false,
"queued":false,
"entities": [
{"name":"agentJaCaMo_Builders%d", "username": "agent%d", "password": "8P7bgZhC", "print-iilang":false, "print-json":false}
  ]
}
' "$i" "$i") > $new
done

# Team B
for i in {1..50} 
do
new=$(printf "eisb%d.json" "$i")
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

