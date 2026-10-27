# Uart Connection

I thought it would be fun to write a uart bridge in verilog as it deals with asychronuous clock speed.

This is an unrealistic application as you are unlikely to do chip to chip communication this way and you probably won't be making both rx and the connecting tx, so the tick and tick_mid approach is fundementally flawed. Something I only realise after building it.

That being said it was fun if frustraiting.
