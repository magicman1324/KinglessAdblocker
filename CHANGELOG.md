# Kingless Adblocker 更新日志

## 2026-03-27: 从 NEFilterPacketProvider 迁移到 NEDNSProxyProvider

### 主要变更

#### 1. **网络扩展架构重构**
- **旧**: `NEFilterPacketProvider` (内容过滤器)
- **新**: `NEDNSProxyProvider` (DNS 代理)
- **原因**: DNS 代理更适合广告拦截，可以在 DNS 层面拦截广告域名

#### 2. **拦截方式变更**
- **旧**: 检查网络流量内容，基于 URL 过滤
- **新**: 拦截 DNS 查询，将广告域名解析到 `0.0.0.0`
- **优势**:
  - 更高效：在 DNS 层面拦截
  - 更彻底：防止广告域名解析
  - 更低功耗：不需要检查所有网络数据

#### 3. **代码文件更新**

##### 已创建/更新的文件：
1. **`Sources/Extension/DNSProxyProvider.swift`**
   - 新的 DNS 代理提供者实现
   - 包含广告域名黑名单和安全域名白名单
   - 实现 DNS 查询处理和转发逻辑

2. **`Sources/Extension/Info.plist`**
   - 更新扩展点标识符：`com.apple.networkextension-dns-proxy`
   - 更新主类名：`DNSProxyProvider`

3. **`Sources/App/ViewController.swift`**
   - 更新使用 `NEDNSProxyManager` 替代 `NEFilterManager`
   - 更新启动/停止 DNS 代理的逻辑

4. **`project.yml`**
   - 更新扩展类型：`dns-proxy-extension`
   - 添加必要的框架依赖：`NetworkExtension.framework`, `Foundation.framework`

5. **`.github/workflows/build-ipa.yml`**
   - 添加扩展编译步骤
   - 更新 IPA 打包逻辑以包含扩展

##### 已删除的文件：
1. **`Sources/Extension/FilterPacketProvider.swift`**
   - 旧的过滤器实现，已不再使用

#### 4. **拦截域名列表增强**

##### 广告域名黑名单 (新增)：
- **Google 广告**: `googletagmanager.com`, `googletagservices.com`
- **国际广告网络**: `adsrvr.org`, `demdex.net`, `mathtag.com`
- **字节跳动**: `byted-static.com`

##### 安全域名白名单 (新增)：
- **苹果服务**: `apple-cloudkit.com`
- **谷歌核心服务**: `googleapis.com`, `gstatic.com`
- **开发工具**: `githubusercontent.com`
- **CDN服务**: `cloudfront.net`, `aliyuncs.com`

#### 5. **域名匹配算法**

新的匹配算法包含三个层级：
1. **安全域名检查** (白名单优先)
2. **广告域名检查** (黑名单匹配)
3. **关键词检查** (通配符模式)

#### 6. **DNS 处理逻辑**

新的 DNS 代理处理流程：
1. **接收 DNS 查询** → 处理 UDP 数据流
2. **检查域名** → 判断是否需要拦截
3. **拦截逻辑** → 广告域名返回 `0.0.0.0`
4. **转发逻辑** → 正常域名转发到 Google DNS
5. **返回响应** → 修改或转发 DNS 响应

### 技术架构对比

#### 旧架构 (NEFilterPacketProvider)
```
App → NetworkExtension → 检查所有流量 → 过滤广告内容
优点: 可以检查 HTTPS 流量内容
缺点: 性能开销大，不能解密 HTTPS
```

#### 新架构 (NEDNSProxyProvider)
```
App → DNSProxy → 拦截 DNS 查询 → 广告域名 → 0.0.0.0
                    ↓
                正常域名 → Google DNS → 真实 IP
优点: 高效，低功耗，拦截彻底
缺点: 不能检查具体流量内容
```

### 使用注意事项

#### 1. **DNS 代理限制**
- 只能拦截 DNS 查询，不能检查 HTTPS 内容
- 需要配置 DNS 服务器设置
- 用户需要授权安装 DNS 配置

#### 2. **编译要求**
- 需要使用 `dns-proxy-extension` 目标类型
- 需要 `NetworkExtension.framework`
- 最低 iOS 版本：15.0

#### 3. **测试建议**
1. 测试 DNS 拦截功能
2. 验证广告域名被正确解析到 `0.0.0.0`
3. 检查正常域名不受影响
4. 测试网络性能影响

### 未来改进方向

#### 短期 (v1.1)
1. **添加 DNS 缓存** - 提高性能
2. **支持自定义规则** - 用户可添加自己的广告域名
3. **添加统计功能** - 显示拦截的广告数量

#### 中期 (v1.5)
1. **支持多个 DNS 服务器** - 故障转移
2. **添加白名单管理** - 用户可以管理安全域名
3. **性能优化** - 降低功耗和内存使用

#### 长期 (v2.0)
1. **智能学习** - 自动识别新的广告域名
2. **社区规则** - 共享和下载广告域名列表
3. **高级过滤** - 结合其他过滤技术

### 已知问题

1. **DNS 解析库**
   - 当前实现使用简化的 DNS 处理
   - 在实际部署中需要完整的 DNS 解析库

2. **IPv6 支持**
   - 需要添加 IPv6 广告域名拦截
   - 需要处理 AAAA 记录

3. **企业分发**
   - 需要企业证书签名
   - 用户需要信任企业证书

### 部署指南

#### 1. 本地编译
```bash
# 生成 Xcode 工程
xcodegen generate

# 打开项目
open KinglessAdblocker.xcodeproj

# 编译运行
# 选择 KinglessAdblocker scheme
# 连接 iOS 设备
# 点击运行
```

#### 2. 云端打包
```bash
# 推送到 GitHub
git push origin main

# GitHub Actions 会自动：
# 1. 安装 Xcodegen
# 2. 生成 Xcode 工程
# 3. 编译应用和扩展
# 4. 打包 IPA 文件
# 5. 上传 artifacts
```

#### 3. 安装使用
1. 下载 IPA 文件
2. 使用企业证书签名
3. 安装到 iOS 设备
4. 打开应用，启用广告拦截

### 性能指标

#### 预期效果
- **广告拦截率**: 85-95% (主流广告网络)
- **DNS 延迟**: +5-15ms (由于代理处理)
- **电池影响**: <1% 额外消耗
- **内存使用**: <30MB

#### 实际测试
需要在实际设备上进行性能测试：
1. 广告拦截效果测试
2. 网络性能基准测试
3. 电池消耗测试
4. 内存使用监控

---

**注意**: 此更新将项目的拦截机制从内容过滤升级为 DNS 拦截，提供了更高效、更彻底的广告拦截方案。确保在进行实际部署前充分测试所有功能。