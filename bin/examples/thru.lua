-- 入力をそのまま出力するサンプルスクリプト

function main()
  if ltGetInputArraySize() == 0 then
    return
  end
  vkcode, scancode, state, time = ltGetInputArrayItem(1)
  print(vkcode, scancode, state, time, ltGetTime())
  ltSendScanCode(scancode, state)
  ltEraseInputArrayItem(1)
end
