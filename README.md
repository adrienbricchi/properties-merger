# properties-merger

[![Build Status](https://travis-ci.org/adrienbricchi/properties-merger.svg?branch=master)](https://travis-ci.org/adrienbricchi/properties-merger)

A Shell script to merge a sample .properties file with an old one, merging existing values.

## Synopsis

Let's take a brand new `.properties` file :
```shell
# Properties for v3
value.1=default value
value.2=default value
value.3=default value
```

... and an old one, from a previous version, with obsolete, poorly-ordered, and missing values :
```shell
# Properties for v2
value.2=bar
value.1=foo
value.old=plop
```

What we want, is the new model, keeping already existing values, in a new file :
```shell
# Properties for v3
value.1=foo
value.2=bar
value.3=default value
```

## Installation

```
# wget https://raw.githubusercontent.com/adrienbricchi/properties-merger/master/propertiesMerger.sh
```

## Code Example

First, you may run the test, to see which properties will be restored from the input file :
```
# ./propertiesMerger.sh --input old.properties --sample sample.properties --test
```
>```
[COMMENT] # Properties for v3
[INPUT  ] value.1=foo
[INPUT  ] value.2=bar
[SAMPLE ] value.3=default value
[DELETED] value.old=plop
```

If the results suits you, you can write it in an output file, using a direct output :
```
# ./propertiesMerger.sh -i old.properties -s sample.properties -o output.properties
```

Unset output will echo-ing the result directly. You may want to redirect the output yourself.  
Let's keep the input file's deleted value in the output :
```
# ./propertiesMerger.sh -i old.properties -s sample.properties --append-deleted-values
```

For any other option :   
```
# ./propertiesMerger.sh --help
```

## License

License GPLv3+ : GNU GPL version 3 or later \<<http://gnu.org/licenses/gpl.html>\>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.

