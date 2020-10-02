#!/bin/bash

# Team A
for i in {1..50} 
do
new=$(printf "eisa%d.json" "$i")
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
{"name":"connectionA%d", "username": "agentA%d", "password": "1", "print-iilang":false, "print-json":false}
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

