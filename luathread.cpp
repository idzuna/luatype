
#include "luathread.hpp"

#include <thread>
#include <vector>
#include <string>
#include <Windows.h>
#include <imm.h>
#include "lua/lua.hpp"
#include "lockfree_queue.hpp"
#include "resource.h"

#define IMC_GETOPENSTATUS 5
#define IMC_SETOPENSTATUS 6

extern lockfree_queue<KBDLLHOOKSTRUCT, 16> g_inputBuffer;
static std::vector<KBDLLHOOKSTRUCT> g_inputArray;
static std::thread g_luaThread;
static volatile bool g_terminateFlag;

static void updateInputArray()
{
  while (!g_inputBuffer.empty()) {
    g_inputArray.push_back(g_inputBuffer.dequeue().value());
  }
}

//-------------------------------------------
//  timer
//-------------------------------------------

static int ltSleep(lua_State* L)
{
  lua_Integer time = lua_tointeger(L, 1);
  if (time > 0) Sleep(static_cast<DWORD>(time));
  return 0;
}

static int ltGetTime(lua_State* L)
{
  lua_pushinteger(L, static_cast<lua_Integer>(timeGetTime()));
  return 1;
}

//-------------------------------------------
//  input
//-------------------------------------------

static int ltGetInputArraySize(lua_State* L)
{
  updateInputArray();
  lua_pushinteger(L, static_cast<lua_Integer>(g_inputArray.size()));
  return 1;
}

static int ltGetInputArrayItem(lua_State* L)
{
  updateInputArray();
  lua_Integer position = lua_tointeger(L, 1) - 1;
  auto& input = g_inputArray.at(position);
  lua_pushinteger(L, input.vkCode);
  lua_pushinteger(L, input.scanCode | (input.flags & LLKHF_EXTENDED ? 0xe000 : 0));
  lua_pushboolean(L, input.flags & LLKHF_UP);
  lua_pushinteger(L, input.time);
  return 4;
}

static int ltEraseInputArrayItem(lua_State* L)
{
  updateInputArray();
  lua_Integer position = lua_tointeger(L, 1) - 1;
  g_inputArray.erase(g_inputArray.begin() + position);
  return 0;
}

//-------------------------------------------
//  output
//-------------------------------------------

static int ltSendMouseInput(lua_State* L)
{
  lua_Integer vkcode = lua_tointeger(L, 1);
  BOOL state = lua_toboolean(L, 2);
  INPUT input;
  input.type = INPUT_MOUSE;
  input.mi.dx = 0;
  input.mi.dy = 0;
  input.mi.mouseData = 0;
  input.mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
  input.mi.time = 0;
  input.mi.dwExtraInfo = 0;
  switch (vkcode)
  {
  case VK_LBUTTON:
    input.mi.dwFlags = state ? MOUSEEVENTF_LEFTUP : MOUSEEVENTF_LEFTDOWN;
    break;
  case VK_RBUTTON:
    input.mi.dwFlags = state ? MOUSEEVENTF_RIGHTUP : MOUSEEVENTF_RIGHTDOWN;
    break;
  case VK_MBUTTON:
    input.mi.dwFlags = state ? MOUSEEVENTF_MIDDLEUP : MOUSEEVENTF_MIDDLEDOWN;
    break;
  case VK_XBUTTON1:
    input.mi.dwFlags = state ? MOUSEEVENTF_XUP : MOUSEEVENTF_XDOWN;
    input.mi.mouseData = XBUTTON1;
    break;
  case VK_XBUTTON2:
    input.mi.dwFlags = state ? MOUSEEVENTF_XUP : MOUSEEVENTF_XDOWN;
    input.mi.mouseData = XBUTTON2;
    break;
  default:
    return 0;
  }
  SendInput(1, &input, sizeof(input));
  return 0;
}

static int ltSendVkCode(lua_State* L)
{
  lua_Integer vkcode = lua_tointeger(L, 1);
  BOOL state = lua_toboolean(L, 2);
  INPUT input;
  input.type = INPUT_KEYBOARD;
  input.ki.wVk = static_cast<WORD>(vkcode);
  input.ki.wScan = 0;
  input.ki.dwFlags = state ? KEYEVENTF_KEYUP : 0;
  input.ki.time = 0;
  input.ki.dwExtraInfo = 0;
  SendInput(1, &input, sizeof(input));
  return 0;
}

static int ltSendScanCode(lua_State* L)
{
  lua_Integer scancode = lua_tointeger(L, 1);
  BOOL state = lua_toboolean(L, 2);
  INPUT input;
  input.type = INPUT_KEYBOARD;
  input.ki.wVk = 0;
  input.ki.wScan = static_cast<WORD>(scancode & 0x00FF);
  input.ki.dwFlags = KEYEVENTF_SCANCODE;
  input.ki.dwFlags |= state ? KEYEVENTF_KEYUP : 0;
  input.ki.dwFlags |= (scancode & 0xE000) ? KEYEVENTF_EXTENDEDKEY : 0;
  input.ki.time = 0;
  input.ki.dwExtraInfo = 0;
  SendInput(1, &input, sizeof(input));
  return 0;
}

static int ltSendUnicodeCharacter(lua_State* L)
{
  lua_Integer character = lua_tointeger(L, 1);
  BOOL state = lua_toboolean(L, 2);
  INPUT input;
  input.type = INPUT_KEYBOARD;
  input.ki.wVk = 0;
  input.ki.wScan = static_cast<WORD>(character);
  input.ki.dwFlags = KEYEVENTF_UNICODE;
  input.ki.dwFlags |= state ? KEYEVENTF_KEYUP : 0;
  input.ki.time = 0;
  input.ki.dwExtraInfo = 0;
  SendInput(1, &input, sizeof(input));
  return 0;
}

//-------------------------------------------
//  IME
//-------------------------------------------

static int ltGetImeEnabled(lua_State* L)
{
  lua_pushboolean(L, static_cast<BOOL>(
    SendMessage(ImmGetDefaultIMEWnd(GetForegroundWindow()), WM_IME_CONTROL, IMC_GETOPENSTATUS, 0)));
  return 1;
}

static int ltSetImeEnabled(lua_State* L)
{
  const BOOL enabled = lua_toboolean(L, 1);
  SendMessage(ImmGetDefaultIMEWnd(GetForegroundWindow()), WM_IME_CONTROL, IMC_SETOPENSTATUS, enabled);
  return 0;
}

static void LuaThreadMain(const std::string& filename)
{
  try {
    lua_State* L;
    L = luaL_newstate();
    luaL_openlibs(L);
    lua_register(L, "ltGetTime", ltGetTime);
    lua_register(L, "ltSleep", ltSleep);
    lua_register(L, "ltGetInputArraySize", ltGetInputArraySize);
    lua_register(L, "ltGetInputArrayItem", ltGetInputArrayItem);
    lua_register(L, "ltEraseInputArrayItem", ltEraseInputArrayItem);
    lua_register(L, "ltSendMouseInput", ltSendMouseInput);
    lua_register(L, "ltSendVkCode", ltSendVkCode);
    lua_register(L, "ltSendScanCode", ltSendScanCode);
    lua_register(L, "ltSendUnicodeCharacter", ltSendUnicodeCharacter);
    lua_register(L, "ltGetImeEnabled", ltGetImeEnabled);
    lua_register(L, "ltSetImeEnabled", ltSetImeEnabled);
    if (luaL_dofile(L, filename.c_str())) {
      throw "";
    }
    while (!g_terminateFlag) {
      Sleep(1);
      updateInputArray();
      lua_getglobal(L, "main");
      if (lua_pcall(L, 0, 0, 0)) {
        throw "";
      }
    }
  } catch (...) {
    TCHAR appname[128];
    TCHAR message[128];
    LoadString(GetModuleHandle(NULL), IDS_APPNAME, appname, sizeof(appname));
    LoadString(GetModuleHandle(NULL), IDS_ERROR_SCRIPT, message, sizeof(message));
    MessageBox(NULL, message, appname, 0);
  }
  return;
}

void StartLuaThread(const char* filename)
{
  EndLuaThread();
  g_terminateFlag = false;
  g_luaThread = std::thread(LuaThreadMain, std::string(filename));
}

void EndLuaThread()
{
  if (g_luaThread.joinable()) {
    g_terminateFlag = true;
    g_luaThread.join();
  }
}
