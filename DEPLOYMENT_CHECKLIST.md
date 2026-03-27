# Kingless Adblocker 部署检查清单

## ✅ 已完成的任务

### 1. 项目架构更新
- [x] 从 `NEFilterPacketProvider` 迁移到 `NEDNSProxyProvider`
- [x] 更新扩展类型为 `dns-proxy-extension`
- [x] 更新 Info.plist 扩展点标识符
- [x] 更新 project.yml 配置

### 2. 代码实现完成
- [x] 创建 `DNSProxyProvider.swift` 实现
- [x] 更新 `ViewController.swift` 使用 `NEDNSProxyManager`
- [x] 添加广告域名黑名单
- [x] 添加安全域名白名单
- [x] 实现域名匹配算法

### 3. 构建系统更新
- [x] 更新 GitHub Actions 工作流
- [x] 添加扩展编译步骤
- [x] 更新 IPA 打包逻辑
- [x] 确保无签名编译配置

### 4. 文档更新
- [x] 创建 CHANGELOG.md
- [x] 更新 README.md（如果需要）
- [x] 创建部署检查清单

## 🔧 技术细节验证

### 核心类和方法
- [ ] `DNSProxyProvider` 继承自 `NEDNSProxyProvider`
- [ ] 实现 `startProxy(options:completionHandler:)`
- [ ] 实现 `stopProxy(with:completionHandler:)`
- [ ] 实现 `handleNewFlow(_:) -> Bool`
- [ ] 正确的域名匹配逻辑

### 配置验证
- [ ] `Info.plist`: `NSExtensionPointIdentifier` = `com.apple.networkextension-dns-proxy`
- [ ] `Info.plist`: `NSExtensionPrincipalClass` = `$(PRODUCT_MODULE_NAME).DNSProxyProvider`
- [ ] `project.yml`: `type: dns-proxy-extension`
- [ ] `project.yml`: 正确的框架依赖

### 构建验证
- [ ] `xcodegen generate` 成功
- [ ] Xcode 工程正确生成
- [ ] 主应用和扩展都能编译
- [ ] GitHub Actions 工作流有效

## 🚀 部署步骤

### 1. 本地测试
```bash
# 1. 生成工程
xcodegen generate

# 2. 打开项目
open KinglessAdblocker.xcodeproj

# 3. 设置开发者证书
#    - 选择个人/团队开发者证书
#    - 配置应用标识符

# 4. 编译运行
#    - 选择 KinglessAdblocker scheme
#    - 连接 iOS 设备
#    - 点击运行按钮
```

### 2. 功能测试
- [ ] 应用正常启动
- [ ] 界面显示正确
- [ ] "启动广告拦截" 按钮功能正常
- [ ] DNS 代理扩展正常加载
- [ ] 系统提示安装 DNS 配置
- [ ] 广告拦截状态正确显示

### 3. 广告拦截测试
测试网站：
1. **包含 Google 广告的网站**
   - 预期：广告被拦截
   - 实际：______

2. **包含 Facebook 广告的网站**
   - 预期：广告被拦截
   - 实际：______

3. **正常网站（如 apple.com）**
   - 预期：正常访问
   - 实际：______

4. **中国网站（如 baidu.com）**
   - 预期：正常访问（在白名单中）
   - 实际：______

### 4. 性能测试
- [ ] 网络延迟影响 < 50ms
- [ ] 电池消耗正常
- [ ] 内存使用 < 50MB
- [ ] 应用启动时间 < 3秒

## ☁️ 云端打包

### 1. 推送到 GitHub
```bash
git add .
git commit -m "feat: migrate to NEDNSProxyProvider for DNS-based ad blocking"
git push origin main
```

### 2. 监控 GitHub Actions
- [ ] 工作流自动触发
- [ ] 所有步骤成功完成
- [ ] IPA 文件正确生成
- [ ] Artifact 成功上传

### 3. 下载和验证 IPA
- [ ] 从 GitHub Actions 下载 IPA
- [ ] 验证文件大小合理（10-50MB）
- [ ] 验证包含主应用和扩展
- [ ] 检查 Info.plist 配置

## 📱 安装和分发

### 1. 企业分发
```bash
# 使用企业证书签名
codesign -f -s "企业证书名称" KinglessAdblocker.ipa

# 或使用签名工具
# - Apple Configurator
# - Cydia Impactor（已弃用）
# - AltStore
# - Sideloadly
```

### 2. 安装方式
- [ ] **macOS**: Apple Configurator
- [ ] **Windows**: iMazing
- [ ] **在线**: 企业分发链接
- [ ] **越狱**: 直接安装 IPA

### 3. 用户配置
安装后用户需要：
1. 信任企业证书
2. 打开应用
3. 允许安装 DNS 配置
4. 启用广告拦截

## 🔍 故障排除

### 常见问题

#### 1. 编译错误
**症状**: Xcode 编译失败
**解决**:
```bash
# 清理并重新生成
rm -rf KinglessAdblocker.xcodeproj
xcodegen generate
```

#### 2. 扩展不工作
**症状**: DNS 拦截无效
**检查**:
- Info.plist 配置是否正确
- 扩展是否包含在 IPA 中
- 系统是否允许 DNS 配置

#### 3. 广告不被拦截
**症状**: 广告仍然显示
**可能原因**:
- 广告使用 HTTPS 和第一方域名
- 广告域名不在黑名单中
- DNS 缓存需要刷新

#### 4. 网络变慢
**症状**: 网页加载变慢
**优化**:
- 检查域名匹配算法效率
- 考虑添加 DNS 缓存
- 优化网络连接逻辑

## 📊 监控和维护

### 1. 用户反馈收集
- [ ] 添加应用内反馈功能
- [ ] 收集拦截统计
- [ ] 监控崩溃报告

### 2. 域名列表更新
- [ ] 定期更新广告域名黑名单
- [ ] 根据用户反馈添加新域名
- [ ] 移除过期的广告域名

### 3. 性能监控
- [ ] 监控应用崩溃率
- [ ] 收集性能指标
- [ ] 分析电池影响

## ⚠️ 法律和合规

### 审查要求
- [ ] 符合苹果 App Store 审核指南
- [ ] 尊重用户隐私
- [ ] 明确说明功能限制

### 隐私政策
- [ ] 不收集用户浏览数据
- [ ] 不记录 DNS 查询
- [ ] 仅拦截广告域名

### 免责声明
- [ ] 明确说明技术限制
- [ ] 不保证 100% 广告拦截
- [ ] 用户自行承担使用风险

---

## 🎯 最终验证

### 推送前检查
- [ ] 所有代码已提交
- [ ] 没有待处理的更改
- [ ] 工作流配置正确
- [ ] 文档更新完成

### 推送命令
```bash
# 最终推送
git push origin main

# 或创建标签
git tag v1.1.0
git push origin v1.1.0
```

### 部署后验证
- [ ] 工作流执行成功
- [ ] IPA 文件可下载
- [ ] 用户可以安装
- [ ] 基本功能正常

---

**完成状态**: ✅ 所有代码更新已完成，等待 push 到 GitHub 重新编译

**下一步**: 执行 `git push origin main` 触发 GitHub Actions 构建