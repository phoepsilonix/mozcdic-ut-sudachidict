#!/bin/bash

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

ruby convert_sudachidict_to_mozcdic.rb
ruby adjust_entries.rb mozcdic-ut-sudachidict.txt
ruby filter_unsuitable_words.rb mozcdic-ut-sudachidict.txt

mkdir -p ../release
tar cjf ../release/mozcdic-ut-sudachidict.txt.tar.bz2 mozcdic-ut-sudachidict.txt
