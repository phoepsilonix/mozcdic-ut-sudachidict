#! /usr/bin/env python
# coding: utf-8

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

import jaconv
import re
import urllib.request
from zipfile import ZipFile

url = "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/"
with urllib.request.urlopen(url) as response:
	date = response.read().decode().split("/core_lex.zip")[0].split("'")[-1]

urllib.request.urlretrieve(f"{url}{date}/small_lex.zip", "small_lex.zip")
urllib.request.urlretrieve(f"{url}{date}/core_lex.zip", "core_lex.zip")
urllib.request.urlretrieve(f"{url}{date}/notcore_lex.zip", "notcore_lex.zip")

with ZipFile("small_lex.zip") as zip_ref:
	with zip_ref.open("small_lex.csv") as file:
		lines = file.read().decode()
with ZipFile("core_lex.zip") as zip_ref:
	with zip_ref.open("core_lex.csv") as file:
		lines = lines + file.read().decode()
with ZipFile("notcore_lex.zip") as zip_ref:
	with zip_ref.open("notcore_lex.csv") as file:
		lines = lines + file.read().decode()

lines = lines.splitlines()

dicname = "mozcdic-ut-sudachidict.txt"

# Mozc の一般名詞のID
url = "https://raw.githubusercontent.com/google/mozc/master/src/data/dictionary_oss/id.def"
with urllib.request.urlopen(url) as response:
	id_mozc = response.read().decode()
	id_mozc = id_mozc.split(" 名詞,一般,")[0].split("\n")[-1]

l2 = []

for i in range(len(lines)):
	# https://github.com/WorksApplications/Sudachi/blob/develop/docs/user_dict.md
	# 見出し (TRIE 用),左連接ID,右連接ID,コスト,\
	# 見出し (解析結果表示用),品詞1,品詞2,品詞3,品詞4,品詞 (活用型),品詞 (活用形),
	# 読み,正規化表記,辞書形ID,分割タイプ,A単位分割情報,B単位分割情報,※未使用

	# little glee monster,4785,4785,5000,
	# Little Glee Monster,名詞,固有名詞,一般,*,*,*,
	# リトルグリーモンスター,Little Glee Monster,*,A,*,*,*,*

	# アイアンマイケル,5144,4788,9652,
	# アイアンマイケル,名詞,固有名詞,人名,一般,*,*,
	# アイアンマイケル,アイアン・マイケル,*,C,*,*,*,*

	entry = lines[i].split(",")

	# 「読み」を読みにする
	yomi = entry[11].replace("=", "")
	yomi = yomi.replace("・", "")

	# 「見出し (解析結果表示用)」を表記にする
	hyouki = entry[4]

	# 読みが2文字以下の場合はスキップ
	# 表記が1文字の場合はスキップ
	# 表記が26文字以上の場合はスキップ。候補ウィンドウが大きくなりすぎる
	# 表記が英数字のみの場合はスキップ
	# 表記と entry[0] が異なる場合はスキップ
	# 名詞以外の場合はスキップ
	# 地名をスキップ。地名は郵便番号ファイルから生成する
	# 名をスキップ
	if len(yomi) < 3 or \
	len(hyouki) < 2 or \
	len(hyouki) > 25 or \
	len(hyouki) == len(hyouki.encode()) or \
	hyouki != entry[0] or \
	entry[5] != "名詞" or \
	entry[7] == "地名" or \
	entry[8] == "名":
		continue

	# 読みのカタカナをひらがなに変換
	yomi = jaconv.kata2hira(yomi)
	yomi = yomi.replace('ゐ', 'い').replace('ゑ', 'え')

	# 読みがひらがな以外を含む場合はスキップ
	if yomi != ''.join(re.findall('[ぁ-ゔー]', yomi)):
		continue

	cost = int(entry[3])

	# コストが 0 未満の場合は 0 にする
	if cost < 0:
		cost = 0
	# コストが 10000 以上の場合は 9999 にする
	elif cost > 9999:
		cost = 9999

	# 全体のコストを 8000 台にする
	cost = 8000 + (cost // 10)

	# 読み, 表記, コスト の順に並べる
	entry = [yomi, hyouki, str(cost)]
	l2.append("\t".join(entry))

lines = l2
l2 = []
lines.sort()

for i in range(len(lines)):
	entry1 = lines[i].split("\t")
	entry2 = lines[i - 1].split("\t")

	# [読み, 表記] が重複するエントリをスキップ
	if entry1[0:2] == entry2[0:2]:
		continue

	# [読み, id_mozc, id_mozc, コスト, 表記] の順に並べる
	entry1 = [entry1[0], id_mozc, id_mozc, entry1[2], entry1[1]]
	l2.append("\t".join(entry1) + "\n")

lines = l2
l2 = []

with open(dicname, "w", encoding="utf-8") as dicfile:
	dicfile.writelines(lines)
