
SC_ESCAPE       = 0x01
SC_F1           = 0x3B
SC_F2           = 0x3C
SC_F3           = 0x3D
SC_F4           = 0x3E
SC_F5           = 0x3F
SC_F6           = 0x40
SC_F7           = 0x41
SC_F8           = 0x42
SC_F9           = 0x43
SC_F10          = 0x44
SC_F11          = 0x57
SC_F12          = 0x58

SC_HANZEN       = 0x29
SC_1            = 0x02
SC_2            = 0x03
SC_3            = 0x04
SC_4            = 0x05
SC_5            = 0x06
SC_6            = 0x07
SC_7            = 0x08
SC_8            = 0x09
SC_9            = 0x0A
SC_0            = 0x0B
SC_MINUS        = 0x0C
SC_HAT          = 0x0D
SC_YEN          = 0x7D
SC_BACK         = 0x0E

SC_TAB          = 0x0F
SC_Q            = 0x10
SC_W            = 0x11
SC_E            = 0x12
SC_R            = 0x13
SC_T            = 0x14
SC_Y            = 0x15
SC_U            = 0x16
SC_I            = 0x17
SC_O            = 0x18
SC_P            = 0x19
SC_AT           = 0x1A
SC_LBRACKET     = 0x1B
SC_RETURN       = 0x1C

SC_CAPITAL      = 0x3A
SC_A            = 0x1E
SC_S            = 0x1F
SC_D            = 0x20
SC_F            = 0x21
SC_G            = 0x22
SC_H            = 0x23
SC_J            = 0x24
SC_K            = 0x25
SC_L            = 0x26
SC_SEMICOLON    = 0x27
SC_COLON        = 0x28
SC_RBRACKET     = 0x2B

SC_LSHIFT       = 0x2A
SC_Z            = 0x2C
SC_X            = 0x2D
SC_C            = 0x2E
SC_V            = 0x2F
SC_B            = 0x30
SC_N            = 0x31
SC_M            = 0x32
SC_COMMA        = 0x33
SC_PERIOD       = 0x34
SC_SLASH        = 0x35
SC_BACKSLASH    = 0x73
SC_RSHIFT       = 0x36

SC_LCONTROL     = 0x1D
SC_LWIN         = 0xE05B
SC_LALT         = 0x38
SC_NONCONVERT   = 0x7B
SC_SPACE        = 0x39
SC_CONVERT      = 0x79
SC_KANA         = 0x70
SC_RALT         = 0xE038
SC_RWIN         = 0xE05C
SC_APPS         = 0xE05D
SC_RCONTROL     = 0xE01D

SC_INSERT       = 0xE052
SC_DELETE       = 0xE053
SC_HOME         = 0xE047
SC_END          = 0xE04F
SC_PRIOR        = 0xE049
SC_NEXT         = 0xE051

SC_UP           = 0xE048
SC_LEFT         = 0xE04B
SC_RIGHT        = 0xE04D
SC_DOWN         = 0xE050

SC_NUMLOCK      = 0xE045
SC_DIVIDE       = 0xE035
SC_PULTIPLY     = 0x37
SC_NUMPAD7      = 0x47
SC_NUMPAD8      = 0x48
SC_NUMPAD9      = 0x49
SC_SUBTRACT     = 0x4A
SC_NUMPAD4      = 0x4B
SC_NUMPAD5      = 0x4C
SC_NUMPAD6      = 0x4D
SC_ADD          = 0x4E
SC_NUMPAD1      = 0x4F
SC_NUMPAD2      = 0x50
SC_NUMPAD3      = 0x51
SC_NUMPAD0      = 0x52
SC_DECIMAL      = 0x53
SC_SEPARATOR    = 0xE01C

SC_SCROLL       = 0x46
SC_PAUSE        = 0x45

CHARACTER_KEY_SET = {
  [SC_1]         = true ;
  [SC_2]         = true ;
  [SC_3]         = true ;
  [SC_4]         = true ;
  [SC_5]         = true ;
  [SC_6]         = true ;
  [SC_7]         = true ;
  [SC_8]         = true ;
  [SC_9]         = true ;
  [SC_0]         = true ;
  [SC_MINUS]     = true ;
  [SC_HAT]       = true ;
  [SC_YEN]       = true ;
  [SC_Q]         = true ;
  [SC_W]         = true ;
  [SC_E]         = true ;
  [SC_R]         = true ;
  [SC_T]         = true ;
  [SC_Y]         = true ;
  [SC_U]         = true ;
  [SC_I]         = true ;
  [SC_O]         = true ;
  [SC_P]         = true ;
  [SC_AT]        = true ;
  [SC_LBRACKET]  = true ;
  [SC_A]         = true ;
  [SC_S]         = true ;
  [SC_D]         = true ;
  [SC_F]         = true ;
  [SC_G]         = true ;
  [SC_H]         = true ;
  [SC_J]         = true ;
  [SC_K]         = true ;
  [SC_L]         = true ;
  [SC_SEMICOLON] = true ;
  [SC_COLON]     = true ;
  [SC_RBRACKET]  = true ;
  [SC_Z]         = true ;
  [SC_X]         = true ;
  [SC_C]         = true ;
  [SC_V]         = true ;
  [SC_B]         = true ;
  [SC_N]         = true ;
  [SC_M]         = true ;
  [SC_COMMA]     = true ;
  [SC_PERIOD]    = true ;
  [SC_SLASH]     = true ;
  [SC_BACKSLASH] = true
}

function isCharacterKey(scancode)
  return CHARACTER_KEY_SET[scancode] ~= nil
end

function sendScanStroke(scancode, withShift)
  local STATE_DOWN = false
  local STATE_UP = true
  if withShift then
    ltSendScanCode(SC_LSHIFT, STATE_DOWN)
    ltSendScanCode(scancode, STATE_DOWN)
    ltSendScanCode(scancode, STATE_UP)
    ltSendScanCode(SC_LSHIFT, STATE_UP)
  else
    ltSendScanCode(scancode, STATE_DOWN)
    ltSendScanCode(scancode, STATE_UP)
  end
end

function characterToStroke(char)
  if     char == "あ" then sendScanStroke(SC_A)
  elseif char == "い" then sendScanStroke(SC_I)
  elseif char == "う" then sendScanStroke(SC_U)
  elseif char == "え" then sendScanStroke(SC_E)
  elseif char == "お" then sendScanStroke(SC_O)
  elseif char == "ぁ" then sendScanStroke(SC_L) sendScanStroke(SC_A)
  elseif char == "ぃ" then sendScanStroke(SC_L) sendScanStroke(SC_I)
  elseif char == "ぅ" then sendScanStroke(SC_L) sendScanStroke(SC_U)
  elseif char == "ぇ" then sendScanStroke(SC_L) sendScanStroke(SC_E)
  elseif char == "ぉ" then sendScanStroke(SC_L) sendScanStroke(SC_O)
  elseif char == "か" then sendScanStroke(SC_K) sendScanStroke(SC_A)
  elseif char == "き" then sendScanStroke(SC_K) sendScanStroke(SC_I)
  elseif char == "く" then sendScanStroke(SC_K) sendScanStroke(SC_U)
  elseif char == "け" then sendScanStroke(SC_K) sendScanStroke(SC_E)
  elseif char == "こ" then sendScanStroke(SC_K) sendScanStroke(SC_O)
  elseif char == "が" then sendScanStroke(SC_G) sendScanStroke(SC_A)
  elseif char == "ぎ" then sendScanStroke(SC_G) sendScanStroke(SC_I)
  elseif char == "ぐ" then sendScanStroke(SC_G) sendScanStroke(SC_U)
  elseif char == "げ" then sendScanStroke(SC_G) sendScanStroke(SC_E)
  elseif char == "ご" then sendScanStroke(SC_G) sendScanStroke(SC_O)
  elseif char == "さ" then sendScanStroke(SC_S) sendScanStroke(SC_A)
  elseif char == "し" then sendScanStroke(SC_S) sendScanStroke(SC_I)
  elseif char == "す" then sendScanStroke(SC_S) sendScanStroke(SC_U)
  elseif char == "せ" then sendScanStroke(SC_S) sendScanStroke(SC_E)
  elseif char == "そ" then sendScanStroke(SC_S) sendScanStroke(SC_O)
  elseif char == "ざ" then sendScanStroke(SC_Z) sendScanStroke(SC_A)
  elseif char == "じ" then sendScanStroke(SC_Z) sendScanStroke(SC_I)
  elseif char == "ず" then sendScanStroke(SC_Z) sendScanStroke(SC_U)
  elseif char == "ぜ" then sendScanStroke(SC_Z) sendScanStroke(SC_E)
  elseif char == "ぞ" then sendScanStroke(SC_Z) sendScanStroke(SC_O)
  elseif char == "た" then sendScanStroke(SC_T) sendScanStroke(SC_A)
  elseif char == "ち" then sendScanStroke(SC_T) sendScanStroke(SC_I)
  elseif char == "つ" then sendScanStroke(SC_T) sendScanStroke(SC_U)
  elseif char == "て" then sendScanStroke(SC_T) sendScanStroke(SC_E)
  elseif char == "と" then sendScanStroke(SC_T) sendScanStroke(SC_O)
  elseif char == "だ" then sendScanStroke(SC_D) sendScanStroke(SC_A)
  elseif char == "ぢ" then sendScanStroke(SC_D) sendScanStroke(SC_I)
  elseif char == "づ" then sendScanStroke(SC_D) sendScanStroke(SC_U)
  elseif char == "で" then sendScanStroke(SC_D) sendScanStroke(SC_E)
  elseif char == "ど" then sendScanStroke(SC_D) sendScanStroke(SC_O)
  elseif char == "な" then sendScanStroke(SC_N) sendScanStroke(SC_A)
  elseif char == "に" then sendScanStroke(SC_N) sendScanStroke(SC_I)
  elseif char == "ぬ" then sendScanStroke(SC_N) sendScanStroke(SC_U)
  elseif char == "ね" then sendScanStroke(SC_N) sendScanStroke(SC_E)
  elseif char == "の" then sendScanStroke(SC_N) sendScanStroke(SC_O)
  elseif char == "は" then sendScanStroke(SC_H) sendScanStroke(SC_A)
  elseif char == "ひ" then sendScanStroke(SC_H) sendScanStroke(SC_I)
  elseif char == "ふ" then sendScanStroke(SC_H) sendScanStroke(SC_U)
  elseif char == "へ" then sendScanStroke(SC_H) sendScanStroke(SC_E)
  elseif char == "ほ" then sendScanStroke(SC_H) sendScanStroke(SC_O)
  elseif char == "ば" then sendScanStroke(SC_B) sendScanStroke(SC_A)
  elseif char == "び" then sendScanStroke(SC_B) sendScanStroke(SC_I)
  elseif char == "ぶ" then sendScanStroke(SC_B) sendScanStroke(SC_U)
  elseif char == "べ" then sendScanStroke(SC_B) sendScanStroke(SC_E)
  elseif char == "ぼ" then sendScanStroke(SC_B) sendScanStroke(SC_O)
  elseif char == "ぱ" then sendScanStroke(SC_P) sendScanStroke(SC_A)
  elseif char == "ぴ" then sendScanStroke(SC_P) sendScanStroke(SC_I)
  elseif char == "ぷ" then sendScanStroke(SC_P) sendScanStroke(SC_U)
  elseif char == "ぺ" then sendScanStroke(SC_P) sendScanStroke(SC_E)
  elseif char == "ぽ" then sendScanStroke(SC_P) sendScanStroke(SC_O)
  elseif char == "ま" then sendScanStroke(SC_M) sendScanStroke(SC_A)
  elseif char == "み" then sendScanStroke(SC_M) sendScanStroke(SC_I)
  elseif char == "む" then sendScanStroke(SC_M) sendScanStroke(SC_U)
  elseif char == "め" then sendScanStroke(SC_M) sendScanStroke(SC_E)
  elseif char == "も" then sendScanStroke(SC_M) sendScanStroke(SC_O)
  elseif char == "や" then sendScanStroke(SC_Y) sendScanStroke(SC_A)
  elseif char == "ゆ" then sendScanStroke(SC_Y) sendScanStroke(SC_U)
  elseif char == "よ" then sendScanStroke(SC_Y) sendScanStroke(SC_O)
  elseif char == "ゃ" then sendScanStroke(SC_L) sendScanStroke(SC_Y) sendScanStroke(SC_A)
  elseif char == "ゅ" then sendScanStroke(SC_L) sendScanStroke(SC_Y) sendScanStroke(SC_U)
  elseif char == "ょ" then sendScanStroke(SC_L) sendScanStroke(SC_Y) sendScanStroke(SC_O)
  elseif char == "ら" then sendScanStroke(SC_R) sendScanStroke(SC_A)
  elseif char == "り" then sendScanStroke(SC_R) sendScanStroke(SC_I)
  elseif char == "る" then sendScanStroke(SC_R) sendScanStroke(SC_U)
  elseif char == "れ" then sendScanStroke(SC_R) sendScanStroke(SC_E)
  elseif char == "ろ" then sendScanStroke(SC_R) sendScanStroke(SC_O)
  elseif char == "わ" then sendScanStroke(SC_W) sendScanStroke(SC_A)
  elseif char == "を" then sendScanStroke(SC_W) sendScanStroke(SC_O)
  elseif char == "ん" then sendScanStroke(SC_N) sendScanStroke(SC_N)
  elseif char == "っ" then sendScanStroke(SC_L) sendScanStroke(SC_T) sendScanStroke(SC_U)
  elseif char == "ヵ" then sendScanStroke(SC_L) sendScanStroke(SC_K) sendScanStroke(SC_A)
  elseif char == "ヶ" then sendScanStroke(SC_L) sendScanStroke(SC_K) sendScanStroke(SC_E)
  elseif char == "ゎ" then sendScanStroke(SC_L) sendScanStroke(SC_W) sendScanStroke(SC_A)
  elseif char == "ヴ" then sendScanStroke(SC_V) sendScanStroke(SC_U)
  elseif char == "ゐ" then sendScanStroke(SC_W) sendScanStroke(SC_Y) sendScanStroke(SC_I)
  elseif char == "ゑ" then sendScanStroke(SC_W) sendScanStroke(SC_Y) sendScanStroke(SC_E)
  elseif char == "１" then sendScanStroke(SC_1)
  elseif char == "２" then sendScanStroke(SC_2)
  elseif char == "３" then sendScanStroke(SC_3)
  elseif char == "４" then sendScanStroke(SC_4)
  elseif char == "５" then sendScanStroke(SC_5)
  elseif char == "６" then sendScanStroke(SC_6)
  elseif char == "７" then sendScanStroke(SC_7)
  elseif char == "８" then sendScanStroke(SC_8)
  elseif char == "９" then sendScanStroke(SC_9)
  elseif char == "０" then sendScanStroke(SC_0)
  elseif char == "ー" then sendScanStroke(SC_MINUS)
  elseif char == "－" then sendScanStroke(SC_MINUS)
  elseif char == "＾" then sendScanStroke(SC_HAT)
  elseif char == "￥" then sendScanStroke(SC_YEN)
  elseif char == "＠" then sendScanStroke(SC_AT)
  elseif char == "「" then sendScanStroke(SC_LBRACKET)
  elseif char == "［" then sendScanStroke(SC_LBRACKET)
  elseif char == "；" then sendScanStroke(SC_SEMICOLON)
  elseif char == "：" then sendScanStroke(SC_COLON)
  elseif char == "」" then sendScanStroke(SC_RBRACKET)
  elseif char == "］" then sendScanStroke(SC_RBRACKET)
  elseif char == "、" then sendScanStroke(SC_COMMA)
  elseif char == "，" then sendScanStroke(SC_COMMA)
  elseif char == "。" then sendScanStroke(SC_PERIOD)
  elseif char == "．" then sendScanStroke(SC_PERIOD)
  elseif char == "・" then sendScanStroke(SC_SLASH)
  elseif char == "／" then sendScanStroke(SC_SLASH)
  elseif char == "＼" then sendScanStroke(SC_BACKSLASH)
  elseif char == "！" then sendScanStroke(SC_1, true)
  elseif char == "”" then sendScanStroke(SC_2, true)
  elseif char == "＃" then sendScanStroke(SC_3, true)
  elseif char == "＄" then sendScanStroke(SC_4, true)
  elseif char == "％" then sendScanStroke(SC_5, true)
  elseif char == "＆" then sendScanStroke(SC_6, true)
  elseif char == "’" then sendScanStroke(SC_7, true)
  elseif char == "（" then sendScanStroke(SC_8, true)
  elseif char == "）" then sendScanStroke(SC_9, true)
  elseif char == "＝" then sendScanStroke(SC_MINUS, true)
  elseif char == "～" then sendScanStroke(SC_HAT, true)
  elseif char == "｜" then sendScanStroke(SC_YEN, true)
  elseif char == "｀" then sendScanStroke(SC_AT, true)
  elseif char == "｛" then sendScanStroke(SC_LBRACKET, true)
  elseif char == "＋" then sendScanStroke(SC_SEMICOLON, true)
  elseif char == "＊" then sendScanStroke(SC_COLON, true)
  elseif char == "｝" then sendScanStroke(SC_RBRACKET, true)
  elseif char == "＜" then sendScanStroke(SC_COMMA, true)
  elseif char == "＞" then sendScanStroke(SC_PERIOD, true)
  elseif char == "？" then sendScanStroke(SC_SLASH, true)
  elseif char == "＿" then sendScanStroke(SC_BACKSLASH, true)
  elseif char == "退" then sendScanStroke(SC_BACK)
  elseif char == "挿" then sendScanStroke(SC_INSERT)
  elseif char == "消" then sendScanStroke(SC_DELETE)
  elseif char == "始" then sendScanStroke(SC_HOME)
  elseif char == "終" then sendScanStroke(SC_END)
  elseif char == "前" then sendScanStroke(SC_PRIOR)
  elseif char == "次" then sendScanStroke(SC_NEXT)
  elseif char == "返" then sendScanStroke(SC_RETURN)
  elseif char == "上" then sendScanStroke(SC_UP)
  elseif char == "左" then sendScanStroke(SC_LEFT)
  elseif char == "右" then sendScanStroke(SC_RIGHT)
  elseif char == "下" then sendScanStroke(SC_DOWN)
  elseif char == "空" then sendScanStroke(SC_SPACE)
  elseif char == "変" then sendScanStroke(SC_CONVERT)
  elseif char == "無" then sendScanStroke(SC_NONCONVERT)
  elseif char == "仮" then sendScanStroke(SC_KANA)
  elseif char == "ａ" then sendScanStroke(SC_A)
  elseif char == "ｂ" then sendScanStroke(SC_B)
  elseif char == "ｃ" then sendScanStroke(SC_C)
  elseif char == "ｄ" then sendScanStroke(SC_D)
  elseif char == "ｅ" then sendScanStroke(SC_E)
  elseif char == "ｆ" then sendScanStroke(SC_F)
  elseif char == "ｇ" then sendScanStroke(SC_G)
  elseif char == "ｈ" then sendScanStroke(SC_H)
  elseif char == "ｉ" then sendScanStroke(SC_I)
  elseif char == "ｊ" then sendScanStroke(SC_J)
  elseif char == "ｋ" then sendScanStroke(SC_K)
  elseif char == "ｌ" then sendScanStroke(SC_L)
  elseif char == "ｍ" then sendScanStroke(SC_M)
  elseif char == "ｎ" then sendScanStroke(SC_N)
  elseif char == "ｏ" then sendScanStroke(SC_O)
  elseif char == "ｐ" then sendScanStroke(SC_P)
  elseif char == "ｑ" then sendScanStroke(SC_Q)
  elseif char == "ｒ" then sendScanStroke(SC_R)
  elseif char == "ｓ" then sendScanStroke(SC_S)
  elseif char == "ｔ" then sendScanStroke(SC_T)
  elseif char == "ｕ" then sendScanStroke(SC_U)
  elseif char == "ｖ" then sendScanStroke(SC_V)
  elseif char == "ｗ" then sendScanStroke(SC_W)
  elseif char == "ｘ" then sendScanStroke(SC_X)
  elseif char == "ｙ" then sendScanStroke(SC_Y)
  elseif char == "ｚ" then sendScanStroke(SC_Z)
  elseif char == "Ａ" then sendScanStroke(SC_A, true)
  elseif char == "Ｂ" then sendScanStroke(SC_B, true)
  elseif char == "Ｃ" then sendScanStroke(SC_C, true)
  elseif char == "Ｄ" then sendScanStroke(SC_D, true)
  elseif char == "Ｅ" then sendScanStroke(SC_E, true)
  elseif char == "Ｆ" then sendScanStroke(SC_F, true)
  elseif char == "Ｇ" then sendScanStroke(SC_G, true)
  elseif char == "Ｈ" then sendScanStroke(SC_H, true)
  elseif char == "Ｉ" then sendScanStroke(SC_I, true)
  elseif char == "Ｊ" then sendScanStroke(SC_J, true)
  elseif char == "Ｋ" then sendScanStroke(SC_K, true)
  elseif char == "Ｌ" then sendScanStroke(SC_L, true)
  elseif char == "Ｍ" then sendScanStroke(SC_M, true)
  elseif char == "Ｎ" then sendScanStroke(SC_N, true)
  elseif char == "Ｏ" then sendScanStroke(SC_O, true)
  elseif char == "Ｐ" then sendScanStroke(SC_P, true)
  elseif char == "Ｑ" then sendScanStroke(SC_Q, true)
  elseif char == "Ｒ" then sendScanStroke(SC_R, true)
  elseif char == "Ｓ" then sendScanStroke(SC_S, true)
  elseif char == "Ｔ" then sendScanStroke(SC_T, true)
  elseif char == "Ｕ" then sendScanStroke(SC_U, true)
  elseif char == "Ｖ" then sendScanStroke(SC_V, true)
  elseif char == "Ｗ" then sendScanStroke(SC_W, true)
  elseif char == "Ｘ" then sendScanStroke(SC_X, true)
  elseif char == "Ｙ" then sendScanStroke(SC_Y, true)
  elseif char == "Ｚ" then sendScanStroke(SC_Z, true)
  end
end
