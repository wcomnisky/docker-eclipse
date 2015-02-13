#!/bin/sh

ECLIPSE_BINARY="$(dirname $0)/eclipse"
ECLIPSE_ARGS_PREFIX="-clean -purgeHistory -application org.eclipse.equinox.p2.director -noSplash" 
ECLIPSE_ARGS_POSTFIX="-vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true"

# call eclipse, forwarding the passed parameters
$ECLIPSE_BINARY $ECLIPSE_ARGS_PREFIX $@ $ECLIPSE_ARGS_POSTFIX

