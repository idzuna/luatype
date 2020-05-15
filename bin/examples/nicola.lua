-- 日本語キーボード -> NICOLA（親指シフト）変換スクリプト

dofile("examples/common_constants.lua")
dofile("examples/common_scancode_jp109.lua")

-- 文字キーを押した後親指キーが押されたときに同時押しと判定される時間
MAX_DELAY = 500

-- 親指キーの割り当て
SC_XL = SC_NONCONVERT
SC_XR = SC_CONVERT

-- 変換表
MAP_FROM = {
  SC_1, SC_2, SC_3, SC_4, SC_5, SC_6, SC_7, SC_8, SC_9, SC_0, SC_MINUS, SC_HAT, SC_YEN,
  SC_Q, SC_W, SC_E, SC_R, SC_T, SC_Y, SC_U, SC_I, SC_O, SC_P, SC_AT, SC_LBRACKET,
  SC_A, SC_S, SC_D, SC_F, SC_G, SC_H, SC_J, SC_K, SC_L, SC_SEMICOLON, SC_COLON, SC_RBRACKET,
  SC_Z, SC_X, SC_C, SC_V, SC_B, SC_N, SC_M, SC_COMMA, SC_PERIOD, SC_SLASH, SC_BACKSLASH
}
MAP_IMEON_SINGLE = {
  "１","２","３","４","５","６","７","８","９","０","－","　","￥",
  "。","か","た","こ","さ","ら","ち","く","つ","，","、","゛",
  "う","し","て","け","せ","は","と","き","い","ん","　","　",
  "．","ひ","す","ふ","へ","め","そ","ね","ほ","・","　"
}
MAP_IMEON_SHIFT = {
  "！","”","＃","＄","％","＆","’","（","）","　","＝","～","｜",
  "。","か","た","こ","さ","ら","ち","く","つ","，","、","゛",
  "う","し","て","け","せ","ぱ","と","き","い","ん","　","　",
  "．","ぴ","す","ぷ","ぺ","め","そ","ね","ぽ","・","　"
}
MAP_IMEON_XL = {
  "？","／","～","「","」","　","　","　","　","　","　","　","　",
  "ぁ","え","り","ゃ","れ","ぱ","ぢ","ぐ","づ","ぴ","　","　",
  "を","あ","な","ゅ","も","ば","ど","ぎ","ぽ","　","　","　",
  "ぅ","ー","ろ","や","ぃ","ぷ","ぞ","ぺ","ぼ","　","　"
}
MAP_IMEON_XR = {
  "　","　","　","　","　","［","］","（","）","　","　","　","　",
  "　","が","だ","ご","ざ","よ","に","る","ま","ぇ","　","゛",
  "　","じ","で","げ","ぜ","み","お","の","ょ","っ","　","　",
  "　","び","ず","ぶ","べ","ぬ","ゆ","む","わ","ぉ","　"
}
MAP_IMEOFF_SINGLE = {
  "１","２","３","４","５","６","７","８","９","０","－","＾","￥",
  "ｑ","ｗ","ｅ","ｒ","ｔ","ｙ","ｕ","ｉ","ｏ","ｐ","＠","［",
  "ａ","ｓ","ｄ","ｆ","ｇ","ｈ","ｊ","ｋ","ｌ","；","：","］",
  "ｚ","ｘ","ｃ","ｖ","ｂ","ｎ","ｍ","，","．","／","￥"
}
MAP_IMEOFF_SHIFT = {
  "！","”","＃","＄","％","＆","’","（","）","　","＝","～","｜",
  "Ｑ","Ｗ","Ｅ","Ｒ","Ｔ","Ｙ","Ｕ","Ｉ","Ｏ","Ｐ","｀","｛",
  "Ａ","Ｓ","Ｄ","Ｆ","Ｇ","Ｈ","Ｊ","Ｋ","Ｌ","＋","＊","｝",
  "Ｚ","Ｘ","Ｃ","Ｖ","Ｂ","Ｎ","Ｍ","＜","＞","？","＿"
}
MAP_IMEOFF_XL = {
  "！","”","＃","＄","％","　","　","　","　","　","　","　","　",
  "Ｑ","Ｗ","Ｅ","Ｒ","Ｔ","　","　","　","　","　","　","　",
  "Ａ","Ｓ","Ｄ","Ｆ","Ｇ","　","　","　","　","　","　",
  "Ｚ","Ｘ","Ｃ","Ｖ","Ｂ","　","　","　","　","　","　"
}
MAP_IMEOFF_XR = {
  "　","　","　","　","　","＆","’","（","）","　","＝","～","｜",
  "　","　","　","　","　","Ｙ","Ｕ","Ｉ","Ｏ","Ｐ","｀","｛",
  "　","　","　","　","　","Ｈ","Ｊ","Ｋ","Ｌ","＋","＊","｝",
  "　","　","　","　","　","Ｎ","Ｍ","＜","＞","？","＿"
}

--------------------------------------------------------------------------------

XL = false
XR = false
XL_single = false
XR_single = false

LSHIFT = false
RSHIFT = false
LCONTROL = false
RCONTROL = false
LWIN = false
RWIN = false
LALT = false
RALT = false

-- 配列 array の中から item を探し，見つかればそのインデックスを，見つからなければ 0 を返します
function find(array, item)
  for i = 1, #array do
    if array[i] == item then
      return i
    end
  end
  return 0
end

-- スキャンコード scancode を変換テーブル from, to にしたがって変換してキー入力を送信します
function translateStroke(scancode, from, to)
  local i = find(from, scancode)
  if i == 0 then
    sendScanStroke(scancode)
  else
    characterToStroke(to[i])
  end
end

function isModifierKey(scancode)
  return scancode == SC_LSHIFT   or
         scancode == SC_RSHIFT   or
         scancode == SC_LCONTROL or
         scancode == SC_RCONTROL or
         scancode == SC_LWIN     or
         scancode == SC_RWIN     or
         scancode == SC_LALT     or
         scancode == SC_RALT
end

function processModifierKey(scancode, state)
  if     scancode == SC_LSHIFT    then LSHIFT   = not state
  elseif scancode == SC_RSHIFT    then RSHIFT   = not state
  elseif scancode == SC_LCONTROL  then LCONTROL = not state
  elseif scancode == SC_RCONTROL  then RCONTROL = not state
  elseif scancode == SC_LWIN      then LWIN     = not state
  elseif scancode == SC_RWIN      then RWIN     = not state
  elseif scancode == SC_LALT      then LALT     = not state
  elseif scancode == SC_RALT      then RALT     = not state
  else
    return
  end
  ltSendScanCode(scancode, state)
end

function isModifierKeyPressed()
  return LSHIFT or RSHIFT or LCONTROL or RCONTROL or LWIN or RWIN or LALT or RALT
end

function isCommandKeyPressed()
  return LCONTROL or RCONTROL or LWIN or RWIN or LALT or RALT
end

function processCharacterKey(scancode, state)
  if state == STATE_UP then
    return
  end
  if isCommandKeyPressed() then
    sendScanStroke(scancode, LSHIFT or RSHIFT)
    return
  end
  if ltGetImeEnabled() then
    if LSHIFT or RSHIFT then
      if LSHIFT then ltSendScanCode(SC_LSHIFT, STATE_UP) end
      if RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_UP) end
      translateStroke(scancode, MAP_FROM, MAP_IMEON_SHIFT)
      if LSHIFT then ltSendScanCode(SC_LSHIFT, STATE_DOWN) end
      if RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_DOWN) end
    elseif XL_single then
      translateStroke(scancode, MAP_FROM, MAP_IMEON_XL)
    elseif XR_single then
      translateStroke(scancode, MAP_FROM, MAP_IMEON_XR)
    else
      translateStroke(scancode, MAP_FROM, MAP_IMEON_SINGLE)
    end
  else
    if LSHIFT or RSHIFT then
      if LSHIFT then ltSendScanCode(SC_LSHIFT, STATE_UP) end
      if RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_UP) end
      translateStroke(scancode, MAP_FROM, MAP_IMEOFF_SHIFT)
      if LSHIFT then ltSendScanCode(SC_LSHIFT, STATE_DOWN) end
      if RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_DOWN) end
    elseif XL_single then
      translateStroke(scancode, MAP_FROM, MAP_IMEOFF_XL)
    elseif XR_single then
      translateStroke(scancode, MAP_FROM, MAP_IMEOFF_XR)
    else
      translateStroke(scancode, MAP_FROM, MAP_IMEOFF_SINGLE)
    end
  end
end

function isThumbKey(scancode)
  return scancode == SC_XL or scancode == SC_XR
end

function processThumbKey(scancode, state)
  if scancode == SC_XL then
    XL        = not state
    XL_single = not state
  elseif scancode == SC_XR then
    XR        = not state
    XR_single = not state
  end
end

-- true を返した場合，そのキー情報は処理済みとして消される
-- false を返した場合，そのキー情報は保留され，後で再び呼ばれる
function forEachInput(scancode, state, time)
  -- Shift, Ctrl, Alt, Win の処理
  if isModifierKey(scancode) then
    processModifierKey(scancode, state)
    goto leave
  end
  -- 親指キーの処理
  if isThumbKey(scancode) then
    processThumbKey(scancode, state)
    return true
  end
  -- 文字キーの処理
  if isCharacterKey(scancode) then
    if state == STATE_UP then
      return true
    end
    -- すでに親指や装飾キーが押されていればすぐに出力
    if XL_single or XR_single or isModifierKeyPressed() then
      processCharacterKey(scancode, state)
      goto leave
    end
    -- 親指キーが押されていない場合はその後 MAX_DELAY 時間の間に親指キーが押さていないか探索する
    for i = 2, ltGetInputArraySize() do
      i_vkcode, i_scancode, i_state, i_time = ltGetInputArrayItem(i)
      -- 文字キー押下から MAX_DELAY 時間経過したら探索終了
      if i_time > time + MAX_DELAY then
        processCharacterKey(scancode, state)
        goto leave
      end
      -- MAX_DELAY 時間内に親指キーの押下があれば親指シフト処理
      if i_state == STATE_DOWN and isThumbKey(i_scancode) then
        processThumbKey(i_scancode, i_state)
        ltEraseInputArrayItem(i)
      end
      -- キーが離されたり他のキーが押されたりしたら探索終了
      if i_scancode == scancode or i_state == STATE_DOWN then
        processCharacterKey(scancode, state)
        goto leave
      end
    end
    -- 文字キー押下から MAX_DELAY 時間経過したらそのまま出力
    if ltGetTime() > time + MAX_DELAY then
      processCharacterKey(scancode, state)
      goto leave
    end
    -- まだ MAX_DELAY 時間経過していないので保留（false を返す）
    return false
  end
  -- その他のキーの処理
  if state == STATE_DOWN then
    if LSHIFT or RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_DOWN) end
    ltSendScanCode(scancode, state)
    if LSHIFT or RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_UP) end
  end
::leave::
  if state == STATE_DOWN then
    XL_single = false
    XR_single = false
  end
  return true
end

function main()
  if ltGetInputArraySize() == 0 then
    return
  end
  vkcode, scancode, state, time = ltGetInputArrayItem(1)
  if forEachInput(scancode, state, time) then
    ltEraseInputArrayItem(1)
  end
end
