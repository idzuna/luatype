# Lua プログラミング マニュアル
* LuaType は，ユーザーからのキー入力をすべて横取りし，その情報を InputArray に格納します
* それと同時に，LuaType は `main.lua` 内に定義された `main` 関数を実行します
* `main` 関数の役目は，InputArray の内容を読み出して，必要であればキー入れ替えなどの処理を行ってから，他のアプリケーションへ送り出すことです
* `main` 関数で何もしないと，ユーザーからのキー入力はすべて捨てられて，キー入力が効かなくなります
* 以下の例は，ユーザーからのキー入力に対して，何も加工せずに他のアプリケーションに送り出します
  ```lua
  function main()
    if ltGetInputArraySize() > 0 then
      vkcode, scancode, state, time = ltGetInputArrayItem(1)
      ltSendVkCode(vkcode, state)
      ltEraseInputArrayItem(1)
    end
  end
  ```
* 以下の例は，キーボードの A が押されると B を，B が押されると「漢」という文字を入力します．
  ```lua
  function main()
    if ltGetInputArraySize() > 0 then
      vkcode, scancode, state, time = ltGetInputArrayItem(1)
      if vkcode == string.byte("A") then
        ltSendVkCode(string.byte("B"), state)
      elseif vkcode == string.byte("B") then
        ltSendUnicodeCharacter(utf8.codepoint("漢"), state)
      else
        ltSendVkCode(vkcode, state)
      end
      ltEraseInputArrayItem(1)
    end
  end
  ```
* 以上で示した組み込み関数の詳細な説明や，その他の関数については，以下の API リファレンスを参照してください．

## LuaType API リファレンス

### main
この関数は main.lua 内で必ず定義する必要があります．
LuaType が動作している間，この関数は繰り返し呼び出されます．

#### 引数
なし

#### 返り値
なし

--------------------------------------------------------------------------------

### ltSleep
指定した時間，処理を停止します．

#### 書式
```lua
ltSleep(ms)
```

#### 引数
<dl>
<dt>ms</dt>
<dd>処理を停止する時間をミリ秒単位で指定します．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltGetTime
現在時刻を取得します．

#### 書式
```lua
ms = ltGetTime()
```

#### 引数
なし

#### 返り値
<dl>
<dt>ms</dt>
<dd>現在時刻の相対値をミリ秒単位で返します．</dd>
</dl>

--------------------------------------------------------------------------------

### ltGetInputArraySize
InputArray に格納されたキー入力情報の数を取得します．

#### 書式
```lua
size = ltGetInputArraySize()
```

#### 引数
なし

#### 返り値
<dl>
<dt>size</dt>
<dd>キー入力情報の数を返します．</dd>
</dl>

--------------------------------------------------------------------------------

### ltGetInputArrayItem
InputArray に格納されたキー入力情報を取得します．

#### 書式
```lua
vkCode, scanCode, state, time = ltGetInputArrayItem(position)
```

#### 引数
<dl>
<dt>position</dt>
<dd>読み出すキー入力情報の，InputArray 内での位置を指定します．
指定できる値は 1 以上 ltGetInputArraySize() 以下の整数です．
新しいキー入力情報は InputArray の後ろに追加されていくので，番号が小さいほど古く，番号が大きいほど新しい入力情報になります．</dd>
</dl>

#### 返り値
<dl>
<dt>vkCode</dt>
<dd>入力されたキーに対応する仮想キー コードを返します．</dd>
<dt>scanCode</dt>
<dd>入力されたキーに対応するスキャン コードを返します．</dd>
<dt>state</dt>
<dd>キーが押下されたなら false, キーが離されたなら true を返します．</dd>
<dt>time</dt>
<dd>キー入力情報を受け取った時刻をミリ秒単位で返します．この値は，ltGetTime 関数で得られる値と同じ系列のものです．</dd>
</dl>

--------------------------------------------------------------------------------

### ltEraseInputArrayItem
InputArray に格納されたキー入力情報を消去します．

#### 書式
```lua
ltEraseInputArrayItem(position)
```

#### 引数:
<dl>
<dt>position</dt>
<dd>消去するキー入力情報の，InputArray 内での位置を指定します．
指定できる値は 1 以上 ltGetInputArraySize() 以下の整数です．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltSendMouseInput
マウスボタン入力を送ります．

#### 書式
```lua
ltSendMouseInput(vkCode, state)
```

#### 引数
<dl>
<dt>vkCode</dt>
<dd>マウスボタンを表す仮想キー コードを指定します．</dd>
<dt>state</dt>
<dd>ボタンを押下するなら false, ボタンを離すなら true を指定します．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltSendVkCode
仮想キー コードを送ります．

#### 書式
```lua
ltSendVkCode(vkCode, state)
```

#### 引数
<dl>
<dt>vkCode</dt>
<dd>送信する仮想キー コードを指定します．</dd>
<dt>state</dt>
<dd>キーを押下するなら false, キーを離すなら true を指定します．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltSendScanCode
スキャン コードを送ります．

#### 書式
```lua
ltSendScanCode(scanCode, state)
```

#### 引数
<dl>
<dt>scanCode</dt>
<dd>送信するスキャン コードを指定します．</dd>
<dt>state</dt>
<dd>キーを押下するなら false, キーを離すなら true を指定します．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltSendUnicodeCharacter
ユニコード文字を送ります．

#### 書式
```lua
ltSendUnicodeCharacter(character, state)
```

#### 引数
<dl>
<dt>character</dt>
<dd>送信する文字に対応する Unicode のコード ポイントを指定します．</dd>
<dt>state</dt>
<dd>キーを押下するなら false, キーを離すなら true を指定します．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltGetImeEnabled
インプット メソッドの有効・無効を取得します．

#### 書式
```lua
status = ltGetImeEnabled()
```

#### 引数
なし

#### 返り値
<dl>
<dt>status</dt>
<dd>日本語入力が有効なら true, 無効なら false を返します．</dd>
</dl>

--------------------------------------------------------------------------------

### ltSetImeEnabled
インプット メソッドの有効・無効を設定します．

#### 書式
```lua
ltSetImeEnabled(status)
```

#### 引数
<dl>
<dt>status</dt>
<dd>日本語入力を有効にする場合は true, 無効にする場合は false を指定します．</dd>
</dl>

#### 返り値
なし

--------------------------------------------------------------------------------

### ltGetForegroundWindowTitle
現在前面にあるウィンドウのタイトルを取得します．

#### 書式
```lua
title = ltGetForegroundWindowTitle()
```

#### 引数
なし

#### 返り値
<dl>
<dt>title</dt>
<dd>ウィンドウのタイトルを UTF-8 文字列で返します．
スクリプトの文字エンコーディングを UTF-8 にしておくと，スクリプト内で定義した文字列との比較ができます．</dd>
</dl>

--------------------------------------------------------------------------------

### ltGetForegroundModuleName
現在前面にあるアプリケーションの実行ファイル名を取得します．

#### 書式
```lua
path = ltGetForegroundModuleName()
```

#### 引数
なし

#### 返り値
<dl>
<dt>path</dt>
<dd>実行ファイル名のフルパスを UTF-8 文字列で返します．
スクリプトの文字エンコーディングを UTF-8 にしておくと，スクリプト内で定義した文字列との比較ができます．</dd>
</dl>
