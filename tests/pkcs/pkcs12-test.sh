#!/bin/bash

if [ ! -d ./certs/ ]; then
    #return 77 to indicate to automake that the test was skipped
    exit 77
fi

RESULT=`./wolfssl pkcs12 -nodes -passin pass:"wolfSSL test" -passout pass: -in ./certs/test-servercert.p12 2>&1`
echo "$RESULT" | grep "Recompile wolfSSL with PKCS12 support"
if [ $? == 0 ]; then
    #return 77 to indicate to automake that the test was skipped
    exit 77
fi

run() {
    if [ -z "$2" ]; then
        RESULT=`eval $1`
    else
        RESULT=`echo "$2" | ./wolfssl $1`
    fi
    if [ $? != 0 ]; then
        echo "Failed on test \"./wolfssl $1\""
        exit 99
    fi
}

run "pkcs12 -nodes -nocerts -passin stdin -passout pass: -in ./certs/test-servercert.p12" "wolfSSL test"

#check that no certs were printed
echo $RESULT | grep "CERTIFICATE"
if [ $? == 0 ]; then
    echo "ERROR found a cert with -nocerts option"
    exit 99
fi

run "pkcs12 -nokeys -passin stdin -passout pass: -in ./certs/test-servercert.p12" "wolfSSL test"

#check that no keys were printed
echo $RESULT | grep "KEY"
if [ $? == 0 ]; then
    echo "ERROR found a key with -nokeys option"
    exit 99
fi

run "./wolfssl pkcs12 -nodes -passin pass:\"wolfSSL test\" -passout pass: -in ./certs/test-servercert.p12"

echo "Done"
exit 0
