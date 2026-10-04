# Evidence: Tarsier 1.6.2 on Windows, with and without the desktop-SQLite fix

Built 2026-10-04 on GitHub Actions `windows-2022` (VS 2022), Flutter 3.47.6, from
`dimpart/tarsier@5799358` (v1.6.2) and `demo-flutter@4951123` (v1.6.2) — unpatched vs. with
dimpart/demo-flutter PR "dim_flutter: enable SQLite on Windows and Linux". Each build was
launched for 45 s, then the runner was searched for the app databases and screenshotted.

| | databases created | screen |
|---|---|---|
| unpatched | **0** | stuck on the loading spinner — `windows-1.6.2-unpatched.png` |
| patched | `mkm.db`, `.dkd/app.db` in `%APPDATA%\chat.dim\tarsier\databases\` | Register Account — `windows-1.6.2-patched.png` |

Note: on `windows-latest` (VS 2026, MSVC 14.51) both variants fail to compile:
`flutter_inappwebview_windows` includes `<experimental/coroutine>`, which VS 2026 removed (STL1011).
