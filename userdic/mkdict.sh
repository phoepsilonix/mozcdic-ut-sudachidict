#!/bin/sh

latest_date=$(curl -s 'http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/' | grep -o '<td>[0-9]*</td>' | grep -o '[0-9]*' | sort -n | tail -n 1)

if [[ -e upstream ]]
then
  rm -rf upstream
fi
mkdir -p upstream

if [[ -e src ]]
then
  rm -rf src
fi
mkdir -p src

#print http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/20230110/core_lex.zip
#print http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$date/core_lex.zip

curl -s "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$latest_date/core_lex.zip" -o upstream/core_lex.zip
curl -s "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/$latest_date/notcore_lex.zip" -o upstream/notcore_lex.zip

(
  cd upstream
  for i in *.zip
  do
    unzip -d ../src $i
  done
) > /dev/null

echo $@

USERDIC=user_dic-ut-sudachidict
ruby user_dict.rb -f src/core_lex.csv -f src/notcore_lex.csv > ${USERDIC}
split -d -l 1000000 --additional-suffix=.txt $USERDIC $USERDIC-
rm $USERDIC

[[ -e ../${USERDIC}.tar.xz ]] && rm ../${USERDIC}*.xz

tar cf ../${USERDIC}.tar ${USERDIC}-*.txt
xz -9 ../${USERDIC}.tar

rm $USERDIC-*.txt
rm -rf src upstream
