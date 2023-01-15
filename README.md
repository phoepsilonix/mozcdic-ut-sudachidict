---
title: Mozc UT SudachiDict Dictionary
date: 2023-01-15
---

## Overview

Mozc UT SudachiDict Dictionary is a dictionary converted from the [SudachiDict](https://github.com/WorksApplications/SudachiDict) for Mozc.

Thanks to the SudachiDict team.

## License

mozcdic-ut-sudachidict.txt: [Apache License, Version 2.0](https://github.com/WorksApplications/SudachiDict/blob/develop/LICENSE-2.0.txt)

Source code: Apache License, Version 2.0

## Usage

Add mozcdic-ut-*.txt to dictionary00.txt and build Mozc as usual.

```
tar xf mozcdic-ut-*.txt.tar.bz2
cat ../mozc-master/src/data/dictionary_oss/dictionary00.txt mozcdic-ut-*.txt > dictionary00.txt.new
mv dictionary00.txt.new ../mozc-master/src/data/dictionary_oss/dictionary00.txt
```

Except for mozcdic-ut-jawiki, the costs are not modified by jawiki-latest-all-titles.

To modify the costs or merge multiple UT dictionaries into one, use the following tool:

[merge-ut-dictionaries](https://github.com/utuhiro78/merge-ut-dictionaries)

## If you create your own UT dictionary

Requirement(s): ruby, rsync

```
gem install bzip2-ffi parallel

cd src/
sh make.sh
```

[HOME](http://linuxplayers.g1.xrea.com/mozc-ut.html)
