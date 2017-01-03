#!/bin/sh

testMergeEcho() {
    expected=`cat ./output.properties`
    out=`../propertiesMerger.sh --input ./input.properties --sample ./sample.properties`
    assertEquals "Return code" "$?" "0"
    assertEquals "${out}" "${expected}"
}

testMergeEchoAppendDeletedValues() {
    expected=`cat ./output-append-deleted-values.properties`
    out=`../propertiesMerger.sh -i ./input.properties -s ./sample.properties --append-deleted-values`
    assertEquals "Return code" "$?" "0"
    assertEquals "${out}" "${expected}"
}

testMergeOutput() {
    `rm -f test-output.properties`
    expected=`cat ./output.properties`
    `../propertiesMerger.sh --input input.properties --sample sample.properties --output test-output.properties`
    assertEquals "Return code" "$?" "0"
    out=`cat ./output.properties`
    assertEquals "${out}" "${expected}"
    `rm -f test-output.properties`
}

testMergeOutputAppendDeletedValues() {
    `rm -f ./test-output-a.properties`
    expected=`cat ./output-append-deleted-values.properties`
    `../propertiesMerger.sh -i input.properties -s sample.properties -o test-output-a.properties -a`
    assertEquals "Return code" "$?" "0"
    out=`cat ./test-output-a.properties`
    assertEquals "${out}" "${expected}"
    `rm -f ./test-output-a.properties`
}

. shunit2-2.1.6/src/shunit2
