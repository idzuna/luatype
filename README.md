﻿# LuaType
汎用スクリプト言語 [Lua](https://www.lua.org/) によって自由にカスタマイズできる Windows 用キー入れ替えツールです．
たとえば以下のような使い方ができます．
* 機能キーを好きな場所に配置する
* 通常のキーボードで Dvorak 配列を実現する
* 親指シフトや漢字直接入力のエミュレーションを行う
* アプリケーションによってキー配列や機能を変える
* 特定のキーの組み合わせで定型文の入力を行う

LuaType はリモート デスクトップに対応しています（LuaType を起動している PC にリモートから接続しても正しく動作します）．

## 動作環境
* Windows 10 x64 で動作確認をしています．

## 使い方
* `luatype_x64.exe` または `luatype_x86.exe` を実行するとプログラムが起動します
* プログラムが起動すると，同ディレクトリ内の `main.lua` が読み込まれ，それに従ってプログラムが動作します
* 動作の設定は `main.lua` を編集して行います
* `examples` ディレクトリ内に `main.lua` のサンプルがあるので，それをそのままコピーしたり，編集して使用してください
* Lua の文法については公式サイトやオンライン上の資料などを参照してください
* LuaType 固有の関数については[プログラミング マニュアル](docs/programming_manual.md)を参照してください

## ビルド方法
LuaType をソースコードからビルドしたい場合は以下の手順で行います．ビルドには Visual Studio 2019 以降が必要です．通常使う際にはソースコードからビルドする必要はありません．
1. LuaType のソース コードをダウンロード・展開する
1. Lua ソース コードをダウンロードし・展開する（Lua 5.3.5 で動作確認しています）
1. Lua の `src/` 内のファイルを，`lua.c`, `luac.c` を除いて `luatype/lua/` 以下へコピーする
1. Visual Studio 2019 で `luatype.sln` を開いてビルドする

## 更新履歴
* 2020/05/15 1.1.0
  * 現在前面にあるウィンドウタイトルを取得する関数を追加
  * 現在前面にあるアプリケーションの実行ファイル名を取得する関数を追加
  * プログラミングマニュアル追記
  * サンプルスクリプト修正
* 2020/05/06 1.0.1
  * プログラミングマニュアル修正
* 2020/05/06 1.0.0
  * 初版
