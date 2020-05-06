
#pragma comment(lib, "winmm.lib")
#pragma comment(lib, "imm32.lib")

#include <Windows.h>
#include <hidusage.h>
#include <iostream>
#include <cstring>

#include "lockfree_queue.hpp"
#include "luathread.hpp"
#include "resource.h"

#define WM_NOTIFYICON (WM_APP + 1)

constexpr char CLASS_NAME[] = "LUATYPE DEFAULT CLASS";
constexpr char WINDOW_NAME[] = "LUATYPE DEFAULT WINDOW";
constexpr char MUTEX_NAME[] = "LUATYPE RUNNING MUTEX";

lockfree_queue<KBDLLHOOKSTRUCT, 16> g_inputBuffer;
static HWND g_hMainWindow = NULL;
static bool g_isHooking = false;
static HHOOK g_hKeyHook = NULL;
constexpr UINT NOTIFYICON_ID = 1;

static LRESULT CALLBACK LowLevelKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);

static void RegisterHook()
{
  if (g_hKeyHook == NULL) {
    g_hKeyHook = SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardProc, GetModuleHandle(NULL), NULL);
  }
}

static void UnregisterHook()
{
  if (g_hKeyHook) {
    UnhookWindowsHookEx(g_hKeyHook);
    g_hKeyHook = NULL;
  }
}

static void RegisterNotifyIcon(UINT id)
{
  NOTIFYICONDATA nid;
  nid.cbSize = sizeof(nid);
  nid.hWnd = g_hMainWindow;
  nid.uID = NOTIFYICON_ID;
  nid.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  nid.uCallbackMessage = WM_NOTIFYICON;
  nid.hIcon = LoadIcon(GetModuleHandle(NULL), reinterpret_cast<LPCSTR>(static_cast<UINT_PTR>(id)));
  LoadString(GetModuleHandle(NULL), IDS_APPNAME, nid.szTip, sizeof(nid.szTip));
  Shell_NotifyIcon(NIM_ADD, &nid);
}

static void UpdateNotifyIcon(UINT id)
{
  NOTIFYICONDATA nid;
  nid.cbSize = sizeof(nid);
  nid.hWnd = g_hMainWindow;
  nid.uID = NOTIFYICON_ID;
  nid.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  nid.uCallbackMessage = WM_NOTIFYICON;
  nid.hIcon = LoadIcon(GetModuleHandle(NULL), reinterpret_cast<LPCSTR>(static_cast<UINT_PTR>(id)));
  LoadString(GetModuleHandle(NULL), IDS_APPNAME, nid.szTip, sizeof(nid.szTip));
  Shell_NotifyIcon(NIM_MODIFY, &nid);
}

static void UnregisterNotifyIcon()
{
  NOTIFYICONDATA nid;
  nid.cbSize = sizeof(nid);
  nid.hWnd = g_hMainWindow;
  nid.uID = NOTIFYICON_ID;
  Shell_NotifyIcon(NIM_DELETE, &nid);
}

static void ShowPopupMenu()
{
  TCHAR buf[128];
  POINT pos;
  GetCursorPos(&pos);
  HMENU hMenu = CreatePopupMenu();
  MENUITEMINFO mii;
  mii.cbSize = sizeof(mii);
  mii.fMask = MIIM_ID | MIIM_TYPE | MIIM_STATE;

  LoadString(GetModuleHandle(NULL), IDS_MENU_CLOSE, buf, sizeof(buf));
  mii.fType = MFT_STRING;
  mii.fState = 0;
  mii.wID = IDS_MENU_CLOSE;
  mii.dwTypeData = buf;
  InsertMenuItem(hMenu, 0, FALSE, &mii);

  mii.fType = MFT_SEPARATOR;
  mii.fState = 0;
  InsertMenuItem(hMenu, 0, FALSE, &mii);

  LoadString(GetModuleHandle(NULL), IDS_MENU_RELOAD, buf, sizeof(buf));
  mii.fType = MFT_STRING;
  mii.fState = 0;
  mii.wID = IDS_MENU_RELOAD;
  mii.dwTypeData = buf;
  InsertMenuItem(hMenu, 0, FALSE, &mii);

  LoadString(GetModuleHandle(NULL), IDS_MENU_PAUSE, buf, sizeof(buf));
  mii.fType = MFT_STRING;
  mii.fState = g_isHooking ? 0 : MFS_CHECKED;
  mii.wID = IDS_MENU_PAUSE;
  mii.dwTypeData = buf;
  InsertMenuItem(hMenu, 0, FALSE, &mii);

  mii.fType = MFT_SEPARATOR;
  mii.fState = 0;
  InsertMenuItem(hMenu, 0, FALSE, &mii);

  LoadString(GetModuleHandle(NULL), IDS_MENU_EXIT, buf, sizeof(buf));
  mii.fType = MFT_STRING;
  mii.fState = 0;
  mii.wID = IDS_MENU_EXIT;
  mii.dwTypeData = buf;
  InsertMenuItem(hMenu, 0, FALSE, &mii);

  SetForegroundWindow(g_hMainWindow);
  switch (TrackPopupMenu(hMenu, TPM_RETURNCMD, pos.x, pos.y, 0, g_hMainWindow, NULL)) {
  case IDS_MENU_RELOAD:
    StartLuaThread("main.lua");
    break;
  case IDS_MENU_PAUSE:
    if (g_isHooking) {
      UnregisterHook();
      g_isHooking = false;
      UpdateNotifyIcon(IDI_DISABLED);
    } else {
      RegisterHook();
      g_isHooking = true;
      UpdateNotifyIcon(IDI_ENABLED);
    }
    break;
  case IDS_MENU_EXIT:
    DestroyWindow(g_hMainWindow);
    break;
  }
}

static LRESULT CALLBACK LowLevelKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
  LPKBDLLHOOKSTRUCT lpHook = reinterpret_cast<LPKBDLLHOOKSTRUCT>(lParam);
  if (nCode >= 0 && (lpHook->flags & (LLKHF_LOWER_IL_INJECTED | LLKHF_INJECTED)) == 0) {
    g_inputBuffer.enqueue(*lpHook);
    return 1;
  }
  return CallNextHookEx(0, nCode, wParam, lParam);
}

static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  static UINT taskbarCreated = 0;

  switch (uMsg) {
  case WM_CREATE:
    taskbarCreated = RegisterWindowMessage("TaskbarCreated");
    break;
  case WM_DESTROY:
    UnregisterNotifyIcon();
    PostQuitMessage(0);
    break;
  case WM_CLOSE:
    return 0;
  case WM_NOTIFYICON:
    switch (lParam) {
    case WM_LBUTTONDOWN:
    case WM_RBUTTONDOWN:
      ShowPopupMenu();
      break;
    }
    break;
  default:
    if (uMsg == taskbarCreated) {
      RegisterNotifyIcon(g_hKeyHook ? IDI_ENABLED : IDI_DISABLED);
    }
    break;
  }
  return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
  SetProcessDPIAware();

  const BOOL console = AttachConsole(ATTACH_PARENT_PROCESS);
  if (console) {
    FILE* fpOut = NULL;
    freopen_s(&fpOut, "CONOUT$", "w", stdout);
    std::cout << std::endl;
  }

  HANDLE hMutex = CreateMutex(NULL, TRUE, MUTEX_NAME);
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    TCHAR appname[128];
    TCHAR message[128];
    LoadString(hInstance, IDS_APPNAME, appname, sizeof(appname));
    LoadString(hInstance, IDS_ERROR_DUPLICATE, message, sizeof(message));
    MessageBox(NULL, message, appname, MB_OK);
    return -1;
  }

  WNDCLASS wc;
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc = WindowProc;
  wc.cbClsExtra = 0;
  wc.cbWndExtra = 0;
  wc.hInstance = hInstance;
  wc.hIcon = NULL;
  wc.hCursor = NULL;
  wc.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_BACKGROUND + 1);
  wc.lpszMenuName = NULL;
  wc.lpszClassName = CLASS_NAME;
  RegisterClass(&wc);

  g_hMainWindow = CreateWindow(CLASS_NAME, WINDOW_NAME, WS_OVERLAPPEDWINDOW,
    100, 100, 100, 100, NULL, NULL, hInstance, NULL);

  RegisterHook();
  g_isHooking = true;
  RegisterNotifyIcon(IDI_ENABLED);

  StartLuaThread("main.lua");

  MSG uMsg;
  while (GetMessage(&uMsg, NULL, 0, 0)) {
    DispatchMessage(&uMsg);
  }
  return 0;
}
