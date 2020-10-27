/**
 * Currently origin(Origin) stores and atom but gps_map(X,Y,O,Origin) has
 * Origin as a string. To avoid too much conversion, for instance, on every goto
 * It is being stored in another belief origin_str(Origin) in which Origin is a string
 * to match with gps_map format.
 * 
 * Please, remove me when fixed. I guesse, the easier way to fix it should be using 
 * string on origin(Origin). Another possibility which I guess is harder
 * to implement but seems to be the best is to change gps_map to use atom.
 */
//TODO: Change O of origin(O) and gps_map(_,_,_,O) to be both as atom or both as string
+origin(Origin) :
    .term2string(Origin,OriginStr)
    <-
    -+origin_str(OriginStr);
    setOrigin(OriginStr);
.
