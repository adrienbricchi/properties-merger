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

testTestMode() {
    expected=`cat ./output-test-mode.properties`
    out=`../propertiesMerger.sh -i input.properties -s sample.properties --test -a --no-color`
    assertEquals "Return code" "$?" "0"
    assertEquals "${out}" "${expected}"
}

testMan() {
    out=`../propertiesMerger.sh --help`
    assertEquals "Help return code" "$?" "0"
    out=`../propertiesMerger.sh --version`
    assertEquals "Version return code" "$?" "0"
}

testErrors() {
    out=`../propertiesMerger.sh -i input.properties -s sample.properties --unknown-argument`
    assertEquals "Unknown arg" "$?" "1"
    out=`../propertiesMerger.sh -i missing.properties -s sample.properties`
    assertEquals "Missing input" "$?" "2"
    out=`../propertiesMerger.sh -i input.properties -s missing.properties`
    assertEquals "Missing sample" "$?" "3"
    out=`../propertiesMerger.sh -i input.properties -s input.properties`
    assertEquals "Incoherent input" "$?" "4"
    out=`../propertiesMerger.sh -i input.properties -s sample.properties -o output.properties`
    assertEquals "Output overwiting something" "$?" "5"
}


. shunit2-2.1.6/src/shunit2
