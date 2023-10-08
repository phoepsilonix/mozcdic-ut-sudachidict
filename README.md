---
title: Mozc UT SudachiDict Dictionary
date: 2023-09-27
---

## Overview

Mozc UT SudachiDict Dictionary is a dictionary converted from [SudachiDict](https://github.com/WorksApplications/SudachiDict) for Mozc.

Thanks to the SudachiDict team.

## License

mozcdic-ut-sudachidict.txt: [Apache License, Version 2.0](https://github.com/WorksApplications/SudachiDict/blob/develop/LEGAL)

Source code: Apache License, Version 2.0

## Usage

Add mozcdic-ut-*.txt to dictionary00.txt and build Mozc as usual.

```
tar xf mozcdic-ut-*.txt.tar.bz2
cat mozcdic-ut-*.txt >> ../mozc-master/src/data/dictionary_oss/dictionary00.txt
```

To modify the costs for words or merge multiple UT dictionaries into one, use this tool:

[merge-ut-dictionaries](https://github.com/utuhiro78/merge-ut-dictionaries)

## Update this dictionary with the latest stuff

Requirement(s): ruby, rsync

```
cd src/
sh make.sh
```

[HOME](http://linuxplayers.g1.xrea.com/mozc-ut.html)


## Appendix.

ユーザー辞書形式のファイルについて。  
user_dic-ut-sudachidict.tar.xz: [Apache License, Version 2.0](https://github.com/WorksApplications/SudachiDict/blob/develop/LEGAL)  
MOZCの辞書ツールでインポート可能な形式に変換しています。  
品詞分類の仕方は、UT Dictionaryと多少異なると思います。(userdicディレクトリのスクリプトをご参照ください。)  
```
tar xf user_dic-ut-sudachidict.tar.xz
```
```
user_dic-ut-sudachidict-00.txt
user_dic-ut-sudachidict-01.txt
user_dic-ut-sudachidict-02.txt
```

更新方法
```
cd userdic
./mkdict.sh
```
