#!/bin/sh

latest_date=$(curl -s 'http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/' | grep -o '<td>[0-9]*</td>' | grep -o '[0-9]*' | sort -n | tail -n 1)

#if [[ -e upstream ]] then;
#  rm -rf upstream;
#fi
mkdir -p upstream

if [[ -e src ]]; then rm -rf src; fi
mkdir -p src

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
SYSTEMDIC=mozcdic-ut-sudachidict
USERDIC=user_dic-ut-sudachidict
rustup target list --installed | grep $(rustc -vV | sed -e 's|host: ||' -e 's|-gnu||p' -n) | grep -v musl && TARGET=$(rustup target list --installed | grep $(rustc -vV | sed -e 's|host: ||' -e 's|-gnu||p' -n)|grep -v musl|head -n1) || TARGET=$(rustup target list --installed | grep $(rustc -vV | sed -e 's|host: ||' -e 's|-gnu||p' -n)|grep musl|head -n1)
#TARGET="${target_arch}-${target_vendor}-${target_os}-${target_env}"
unset RUSTC
cargo build --release --target $TARGET
PROG=$(find .. -name dict-to-mozc)
echo "PROG=" $PROG

cat src/small_lex.csv src/core_lex.csv src/notcore_lex.csv > all.csv
wget -nc https://github.com/google/mozc/raw/refs/heads/master/src/data/dictionary_oss/id.def
# ut dic
$PROG -i ./id.def -f ./all.csv -s > ./$SYSTEMDIC.txt 2>error.log
$PROG -i ./id.def -f ./all.csv -s -U > ./$USERDIC 2>error2.log
ls -la $SYSTEMDIC* $USERDIC*
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt $USERDIC $USERDIC-

mkdir -p ../release
[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz

tar cf ../release/${SYSTEMDIC}.tar ${SYSTEMDIC}.txt ../LICENSE
xz -9 -e ../release/${SYSTEMDIC}.tar
tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

rm $USERDIC $USERDIC-*.txt $SYSTEMDIC.txt
rm -rf src upstream
