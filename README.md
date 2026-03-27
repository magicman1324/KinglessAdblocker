# Kingless Adblocker - iOS 广告拦截器

一个基于 Network Extension 的 iOS 全网广告拦截应用。使用 Xcodegen 生成跨端编译架构，支持云端打包。

## 功能特性

### 🛡️ 核心功能
- **全网广告拦截**：拦截主流广告服务商域名
- **隐私保护**：阻止追踪器和分析脚本
- **无痕浏览**：过滤广告内容，提升浏览体验
- **智能识别**：基于域名的广告识别算法
- **低功耗设计**：高效的过滤器实现

### 🔧 技术架构
- **Xcodegen**：跨端编译架构生成
- **Network Extension**：iOS 网络扩展框架
- **Swift 原生开发**：性能优化的原生体验
- **云端 CI/CD**：GitHub Actions 自动打包
- **无签名打包**：可直接安装的 IPA 文件

## 支持的广告域名

### 🌍 全球广告网络
- **Google 广告**：googleadservices.com, doubleclick.net
- **Facebook/Meta**：facebook.com, fbcdn.net
- **亚马逊广告**：amazon-adsystem.com
- **字节跳动**：toutiao.com, douyin.com
- **其他主流**：pubmatic.com, criteo.com, taboola.com

### 🇨🇳 中国特色广告
- **百度广告**：baidu.com, bdstatic.com
- **腾讯广告**：qq.com, gtimg.com
- **阿里系广告**：alibaba.com, alicdn.com, taobao.com

### 🔧 通配符匹配
- `*.ads.*` - 所有包含 "ads" 的域名
- `*ad.*` - 所有包含 "ad" 的域名
- `adserver.*` - 广告服务器域名
- `tracking.*` - 追踪器域名
- `analytics.*` - 分析脚本域名

## 开发环境要求

### 📱 平台要求
- **系统版本**：iOS 15.0+
- **Xcode 版本**：15.0+
- **开发语言**：Swift 5.0+

### 🔧 工具依赖
- **Xcodegen**：`brew install xcodegen`
- **macOS**：用于编译 iOS 应用
- **GitHub Actions**：用于云端打包

## 项目结构

```
KinglessAdblocker/
├── project.yml                    # Xcodegen 配置文件
├── Sources/
│   ├── App/                      # 主应用代码
│   │   ├── AppDelegate.swift     # 应用入口
│   │   ├── ViewController.swift  # 主界面
│   │   ├── Assets.xcassets/      # 资源文件
│   │   ├── Base.lproj/           # 本地化资源
│   │   └── Info.plist           # 应用配置
│   └── Extension/                # 网络扩展
│       ├── FilterPacketProvider.swift
│       └── Info.plist           # 扩展配置
└── .github/workflows/           # CI/CD 流水线
```

## 本地开发

### 1. 环境准备
```bash
# 安装 Xcodegen
brew install xcodegen

# 生成 Xcode 工程
xcodegen generate
```

### 2. 打开项目
```bash
# 使用 Xcode 打开生成的工程
open KinglessAdblocker.xcodeproj
```

### 3. 编译运行
1. 在 Xcode 中选择目标设备
2. 选择 `KinglessAdblocker` scheme
3. 点击运行按钮或按 `Cmd + R`

## 云端打包

项目使用 GitHub Actions 进行云端自动打包，无需本地开发环境。

### 打包流程
1. **生成工程**：使用 Xcodegen 生成 Xcode 工程
2. **编译应用**：使用 xcodebuild 编译 iOS 应用
3. **构建 IPA**：创建 Payload 文件夹并打包
4. **上传成果物**：将 IPA 上传至 GitHub Artifacts

### 获取 IPA 文件
1. 进入 GitHub Actions 页面
2. 选择最新的构建工作流
3. 在 Artifacts 部分下载 `KinglessAdblocker.ipa`

## 安装说明

### 企业证书安装
1. 下载 `KinglessAdblocker.ipa` 文件
2. 使用企业签名工具签名
3. 通过 iTunes 或其他安装工具安装

### 开发者安装
1. 使用 Xcode 编译项目
2. 连接 iOS 设备
3. 选择开发者证书进行签名安装

## 使用方法

### 1. 启动广告拦截
1. 打开 KinglessAdblocker 应用
2. 点击 "启动广告拦截" 按钮
3. 系统会要求安装网络扩展（需要用户确认）

### 2. 验证拦截效果
1. 打开 Safari 或其他浏览器
2. 访问包含广告的网站
3. 广告内容将被自动过滤

### 3. 查看拦截日志
在 Xcode 控制台中查看拦截日志：
```
[KinglessAdblocker] Blocking ad domain: googleadservices.com
[KinglessAdblocker] Allowing safe domain: apple.com
```

## 拦截原理

### 域名匹配算法
```swift
// 1. 检查安全域名（白名单）
if isSafeDomain(url.host) {
    return .allow()
}

// 2. 检查广告域名（黑名单）
if isAdDomain(url.host) {
    return .drop()
}

// 3. 检查追踪器参数
if isTracker(url) {
    return .drop()
}

// 4. 默认放行
return .allow()
```

### 域名匹配策略
1. **完全匹配**：精确匹配已知广告域名
2. **后缀匹配**：匹配域名后缀（如 `.doubleclick.net`）
3. **通配符匹配**：支持 `*.ads.*` 等通配符模式
4. **关键词匹配**：检查域名是否包含广告关键词

## 性能优化

### 🚀 高效算法
- **哈希集合**：使用 Set 进行快速域名查找
- **前缀匹配**：优化后缀匹配算法
- **内存管理**：最小化内存占用

### 🔋 低功耗设计
- **事件驱动**：仅在需要时处理网络流量
- **批处理**：优化数据包处理逻辑
- **资源管理**：及时释放不需要的资源

## 安全考虑

### 🔒 安全域名
以下域名始终放行：
- **苹果服务**：apple.com, icloud.com
- **政府网站**：gov.cn
- **教育网站**：edu.cn
- **开发工具**：github.com, stackoverflow.com

### ⚠️ 注意事项
- **不能拦截 HTTPS 内容**：Network Extension 只能看到域名，不能解密 HTTPS 内容
- **需要用户授权**：首次使用需要用户安装网络扩展的权限
- **系统限制**：iOS 对网络扩展有严格的资源限制

## 扩展自定义

### 添加自定义规则
在 `FilterPacketProvider.swift` 中修改：

```swift
// 添加广告域名
private let adDomains: Set<String> = [
    "your-ad-domain.com",
    // ... 其他域名
]

// 添加安全域名
private let safeDomains: Set<String> = [
    "your-safe-domain.com",
    // ... 其他域名
]
```

### 修改拦截逻辑
可以重写以下方法：
- `handleNewFlow(_:)` - 处理新网络流
- `handleInboundData(from:)` - 处理入站数据
- `handleOutboundData(from:)` - 处理出站数据

## 问题和故障排除

### 常见问题

#### Q: 为什么有些广告没有被拦截？
A: 可能的原因：
1. 广告使用 HTTPS 且域名不在黑名单中
2. 广告通过第一方域名提供服务
3. 域名匹配规则需要更新

#### Q: 如何查看拦截日志？
A: 在 Xcode 控制台中查看 NSLog 输出。

#### Q: 为什么需要安装网络扩展？
A: iOS 要求所有网络过滤功能必须通过系统网络扩展实现。

### 故障排除

#### 1. 编译错误
```bash
# 清理并重新生成
rm -rf KinglessAdblocker.xcodeproj
xcodegen generate
```

#### 2. 运行错误
- 确保选择了正确的 scheme：`KinglessAdblocker`
- 检查开发者证书和团队设置
- 确认设备已信任开发者证书

## 贡献指南

### 报告问题
请在 GitHub Issues 中报告问题，包括：
- iOS 版本
- 复现步骤
- 预期行为
- 实际行为

### 提交代码
1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 创建 Pull Request

### 编码规范
- 使用 Swift 官方编码规范
- 添加适当的注释
- 编写单元测试（如果有）
- 更新文档

## 许可证

本项目使用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 免责声明

本工具仅用于技术学习和研究目的。请在合法范围内使用，遵守当地法律法规和网站服务条款。

## 更新日志

### v1.0.0 (2026-03-27)
- 🎉 初始版本发布
- 🛡️ 实现基础广告拦截功能
- 🔧 集成 Xcodegen 跨端架构
- ☁️ 添加 GitHub Actions 云端打包
- 📱 支持 iOS 15.0+ 系统

---

**注意**：本项目使用 Network Extension 框架，属于系统级功能。在实际使用前，请确保了解相关授权和隐私政策。苹果对网络扩展应用有严格的审核要求，可能需要特殊权限才能在 App Store 上架。