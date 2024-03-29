# properties-merger

[![Build Status](https://travis-ci.org/adrienbricchi/properties-merger.svg?branch=master)](https://travis-ci.org/adrienbricchi/properties-merger)

A Shell script to merge some old .properties file values with a sample one.

## Synopsis

Let's take a brand new `.properties` file :
```
# Properties for v3
value.1=default value
value.2=default value
value.3=default value
```

... and an old one, from a previous version, with obsolete, poorly-ordered, and missing values :
```
# Properties for v2
value.2=bar
value.1=default value
value.old=plop 
```

What we want, is the new model, keeping already existing values, in a new file :
```
# Properties for v3
value.1=foo
value.2=bar
value.3=default value
```

## Installation

```bash
$ wget https://raw.githubusercontent.com/adrienbricchi/properties-merger/master/properties-merger.sh
```

## Code Example

First, you may run the test, to see which properties will be restored from the input file :
```bash
$ ./properties-merger.sh --input old.properties --sample sample.properties --test
```
```
[COMMENT] # Properties for v3
[INPUT  ] value.1=foo¶
[SAME   ] value.2=default value¶
[SAMPLE ] value.3=default value¶
[DELETED] value.old=plop ¶
```

If the results suits you, you can write it in an output file, using a direct output :
```bash
$ ./properties-merger.sh -i old.properties -s sample.properties -o output.properties
```

Unset output will echo-ing the result directly. You may want to redirect the output yourself.  
Additionnally, we're going to keep the input file's deleted values here :
```bash
$ ./properties-merger.sh -i old.properties -s sample.properties --append-deleted-values
```

For any other option :   
```bash
$ ./properties-merger.sh --help
```


