# 快递取件 iOS App（含桌面小组件 + 通知）· 生成 IPA 的完整步骤

这是一个完整的 SwiftUI iOS 工程：**App + 桌面小组件（WidgetKit）+ 本地通知**。

因为 IPA 必须在 macOS + Xcode 上编译，这台 Windows 做不了，所以这里配了一套
**GitHub Actions 自动构建**：把代码传到 GitHub，点一下，云端 macOS 机器帮你编译出
未签名的 IPA，下载后再用 **Sideloadly** 在 Windows 上签名装到 iPhone。

---

## 一、目录结构

```
PickupIOS/
├─ .github/workflows/build-ipa.yml     GitHub Actions 自动构建配置
├─ ios/PickupHelper/
│  ├─ project.yml                       XcodeGen 工程描述（免手写 .xcodeproj）
│  ├─ Shared/                           App 和小组件共用的模型/存储/通知
│  │  ├─ PackageItem.swift
│  │  ├─ SharedStore.swift              App Group 文件存储
│  │  ├─ PackageStore.swift             增删改查
│  │  └─ NotificationScheduler.swift    每天定时提醒 + 角标
│  ├─ PickupApp/                        App 本体（SwiftUI）
│  │  ├─ PickupApp.swift
│  │  ├─ ContentView.swift
│  │  ├─ AddView.swift
│  │  ├─ Info.plist / *.entitlements / Assets.xcassets
│  └─ PickupWidget/                     桌面小组件
│     ├─ PickupWidget.swift
│     └─ Info.plist / *.entitlements
└─ README.md
```

---

## 二、把代码放到 GitHub（约 10 分钟）

1. 注册 / 登录 https://github.com （免费）
2. 右上角「+」→「New repository」→ 名字随意（比如 `pickup-ios`）→ Private 或 Public 都行 →
   不要勾选任何初始化文件 →「Create repository」
3. 装 **GitHub Desktop**（https://desktop.github.com），登录你的 GitHub 账号
4. GitHub Desktop →「File」→「Add local repository」→ 选 `D:\PickupIOS`
   （提示 not a git repository 时点「create a repository」，然后 Publish）
5. 点「Publish repository」→ 代码就上去了（记得勾选包含 `.github` 目录）

> 也可以用命令行：`git init` → `git add .` → `git commit -m init` → 建仓库后
> `git remote add origin <地址>` → `git push -u origin main`。

---

## 三、让 GitHub 编译出 IPA（约 5 分钟）

1. 打开你的仓库页面 → 顶部「**Actions**」标签
2. 左边选「**Build IPA**」→ 右边「**Run workflow**」→ 绿色按钮运行
3. 等 3～6 分钟，刷新页面，点进这次运行 → 底部「**Artifacts**」→ 下载
   `PickupHelper-ipa`（是个 zip，里面是 `PickupHelper.ipa`）
4. 如果构建失败：把红色错误日志复制发我，我来改代码

---

## 四、Windows 上装到 iPhone（Sideloadly）

1. 下载 **Sideloadly**：https://sideloadly.io（免费）
2. 用数据线连 iPhone，手机上点「信任此电脑」
3. 打开 Sideloadly，把 `PickupHelper.ipa` 拖进去
4. 「Apple ID」填你的 Apple ID（建议先在 https://appleid.apple.com 生成一个**App 专用密码**，
   不要用主密码）
5. 点「Start」→ 输入密码 → 等进度条走完
6. 手机上：设置 → 通用 → VPN与设备管理 → 找到你的 Apple ID →「信任」
7. 回到桌面，App 就装好了

---

## 五、加小组件、开通知

1. 长按桌面空白处 → 左上角「+」→ 搜索「**快递取件**」→ 选小号/中号 → 添加
2. 第一次打开 App 会请求通知权限，点「允许」
3. 默认每天 **18:00** 提醒还有几件没取（可在 `NotificationScheduler.swift` 里改 `reminderHour`）
4. App 里改了数据后，小组件会立刻刷新；系统后台每 30 分钟也会刷一次

---

## 六、必须知道的限制（很重要）

| 限制 | 说明 |
| --- | --- |
| **7 天过期** | 免费 Apple ID 签的 App 只能用 7 天，到期后要重新用 Sideloadly 签名安装 |
| **最多 3 个 App** | 免费账号同时最多装 3 个自签 App |
| **App Group 可能不可用** | 小组件和 App 共享数据依赖 App Group，**免费 Apple ID 通常不开放**，现象是小组件一直显示 0。付费开发者账号（¥688/年）可解决；App 本身和通知不受影响 |
| **小组件不是真实时** | iOS 对小组件刷新有限流，最快十几分钟一次；App 内改数据会立即触发刷新 |
| **通知要授权** | 不点允许就收不到提醒；角标也依赖通知权限 |

> 想长期稳定用（1 年不掉签 + 小组件正常）：申请付费 Apple Developer 账号（¥688/年），
> 用 Xcode 直接跑或者用 Sideloadly 配付费证书签名。

---

## 七、如果你以后有 Mac

1. 装 Xcode（App Store）
2. `brew install xcodegen`
3. 进 `ios/PickupHelper` 目录执行 `xcodegen generate`，得到 `PickupHelper.xcodeproj`
4. 双击打开，选自己的 Team，连手机直接 Run

---

## 八、常见问题

**Q：Actions 里报 `xcodegen: command not found`？**
工作流里已经 `brew install xcodegen`，如果失败把日志发我。

**Q：Sideloadly 签名失败 / 报 `Invalid credentials`？**
用 App 专用密码；确认 Apple ID 没开「双重认证限制」；换根数据线或重启 Sideloadly。

**Q：装完打开就闪退？**
多半是签名没带扩展。先在 Sideloadly 里勾选「Enable extensions」或确认它自动处理了
`PlugIns/PickupWidgetExtension.appex`；再不行把日志发我。

**Q：小组件显示 0 但 App 里有数据？**
就是 App Group 权限问题（免费账号不支持），见上面第六条。

**Q：想改提醒时间？**
`Shared/NotificationScheduler.swift` 里的 `reminderHour`，默认 18 点。

**Q：想加 iCloud 同步？**
需要付费账号 + CloudKit，跟我说，我给你加。
