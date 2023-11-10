#!/bin/sh

latest_date=$(curl -s 'http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/' | grep -o '<td>[0-9]*</td>' | grep -o '[0-9]*' | sort -n | tail -n 1)

#if [[ -e upstream ]] then;
#  rm -rf upstream;
#fi
mkdir -p upstream

if [[ -e src ]]; then rm -rf src; fi
mkdir -p src

#print http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/20230110/core_lex.zip
#print http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$date/core_lex.zip

[ -n upstream/small_lex.zip ] && curl -s "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$latest_date/small_lex.zip" -o upstream/small_lex.zip
[ -n upstream/core_lex.zip ] && curl -s "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$latest_date/core_lex.zip" -o upstream/core_lex.zip
[ -n upstream/notcore_lex.zip ] && curl -s "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$latest_date/notcore_lex.zip" -o upstream/notcore_lex.zip

(
  cd upstream
  for i in *.zip
  do
    unzip -d ../src $i
  done
) > /dev/null

echo $@
USERDIC=user_dic-ut-sudachidict
ruby user_dict.rb -E -f src/small_lex.csv -f src/core_lex.csv -f src/notcore_lex.csv > ${USERDIC}.tmp
ruby uniqword.rb ${USERDIC}.tmp > ${USERDIC}
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt $USERDIC $USERDIC-
rm $USERDIC $USERDIC.tmp

mkdir -p ../release
[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz

tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

rm $USERDIC-*.txt
rm -rf src upstream
