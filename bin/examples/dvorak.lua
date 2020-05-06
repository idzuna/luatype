-- 日本語キーボード -> Dvorak 配列変換スクリプト

dofile("examples/common_constants.lua")
dofile("examples/common_scancode_jp109.lua")

-- 変換表
MAP_FROM = {
  SC_1, SC_2, SC_3, SC_4, SC_5, SC_6, SC_7, SC_8, SC_9, SC_0, SC_MINUS, SC_HAT, SC_YEN,
  SC_Q, SC_W, SC_E, SC_R, SC_T, SC_Y, SC_U, SC_I, SC_O, SC_P, SC_AT, SC_LBRACKET,
  SC_A, SC_S, SC_D, SC_F, SC_G, SC_H, SC_J, SC_K, SC_L, SC_SEMICOLON, SC_COLON, SC_RBRACKET,
  SC_Z, SC_X, SC_C, SC_V, SC_B, SC_N, SC_M, SC_COMMA, SC_PERIOD, SC_SLASH, SC_BACKSLASH
}
MAP_SINGLE = {
  "１","２","３","４","５","６","７","８","９","０","［","］","￥",
  "’","，","．","ｐ","ｙ","ｆ","ｇ","ｃ","ｒ","ｌ","／","＝",
  "ａ","ｏ","ｅ","ｕ","ｉ","ｄ","ｈ","ｔ","ｎ","ｓ","－","返",
  "；","ｑ","ｊ","ｋ","ｘ","ｂ","ｍ","ｗ","ｖ","ｚ","｀"
 
}
MAP_SHIFT = {
  "！","＠","＃","＄","％","＾","＆","＊","（","）","｛","｝","｜",
  "”","＜","＞","Ｐ","Ｙ","Ｆ","Ｇ","Ｃ","Ｒ","Ｌ","？","＋",
  "Ａ","Ｏ","Ｅ","Ｕ","Ｉ","Ｄ","Ｈ","Ｔ","Ｎ","Ｓ","＿","返",
  "：","Ｑ","Ｊ","Ｋ","Ｘ","Ｂ","Ｍ","Ｗ","Ｖ","Ｚ","～"
}

--------------------------------------------------------------------------------

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
  elseif scancode == SC_LCONTROL  then LCONTROL = not state ltSendScanCode(scancode, state)
  elseif scancode == SC_RCONTROL  then RCONTROL = not state ltSendScanCode(scancode, state)
  elseif scancode == SC_LWIN      then LWIN     = not state ltSendScanCode(scancode, state)
  elseif scancode == SC_RWIN      then RWIN     = not state ltSendScanCode(scancode, state)
  elseif scancode == SC_LALT      then LALT     = not state ltSendScanCode(scancode, state)
  elseif scancode == SC_RALT      then RALT     = not state ltSendScanCode(scancode, state)
  end
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
  if LSHIFT or RSHIFT then
    translateStroke(scancode, MAP_FROM, MAP_SHIFT)
  else
    translateStroke(scancode, MAP_FROM, MAP_SINGLE)
  end
end

function forEachInput(scancode, state)
  -- Shift, Ctrl, Alt, Win の処理
  if isModifierKey(scancode) then
    processModifierKey(scancode, state)
    return true
  end
  if isCharacterKey(scancode) then
    processCharacterKey(scancode, state)
    return true
  end
  if LSHIFT or RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_DOWN) end
  ltSendScanCode(scancode, state)
  if LSHIFT or RSHIFT then ltSendScanCode(SC_RSHIFT, STATE_UP) end
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
