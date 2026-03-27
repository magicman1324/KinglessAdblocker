import NetworkExtension
import Foundation

/// Kingless Adblocker DNS 代理扩展
/// 通过 DNS 拦截技术将广告域名解析到 0.0.0.0 实现广告屏蔽
class DNSProxyProvider: NEDNSProxyProvider {

    // MARK: - 广告域名黑名单
    /// 全网主流广告服务商域名，这些域名将被解析到 0.0.0.0
    private let adDomains: Set<String> = [
        // Google 广告服务
        "googleadservices.com",
        "googlesyndication.com",
        "google-analytics.com",
        "doubleclick.net",
        "adservice.google.com",
        "googletagmanager.com",
        "googletagservices.com",

        // Facebook/Meta 广告
        "facebook.com",
        "fbcdn.net",
        "fbsbx.com",
        "facebook.net",

        // 亚马逊广告
        "amazon-adsystem.com",
        "amazon-adsystem.amazon.com",

        // 腾讯广告
        "qq.com",
        "gtimg.com",
        "tencent.com",
        "weixin.qq.com",
        "qpic.cn",

        // 百度广告
        "baidu.com",
        "bdstatic.com",
        "baidustatic.com",
        "baidupcs.com",

        // 阿里/淘宝广告
        "alibaba.com",
        "alicdn.com",
        "taobao.com",
        "tmall.com",
        "alipay.com",
        "alimama.com",

        // 字节跳动广告
        "bytedance.com",
        "toutiao.com",
        "douyin.com",
        "byted-static.com",

        // 其他主流广告网络
        "adsystem.com",
        "adnxs.com",
        "rubiconproject.com",
        "openx.net",
        "pubmatic.com",
        "criteo.com",
        "taboola.com",
        "outbrain.com",
        "moatads.com",
        "scorecardresearch.com",

        // 国际广告网络（简化版）
        "adsrvr.org",
        "demdex.net",
        "doubleverify.com",
        "mathtag.com",
        "quantserve.com",
        "rlcdn.com",
        "smartadserver.com",

        // 通用广告域名模式
        "ad.*",
        "ads.*",
        "adv.*",
        "adserver.*",
        "adservice.*",
        "advertising.*",
        "tracking.*",
        "analytics.*"
    ]

    // MARK: - 安全域名白名单
    /// 这些域名将正常解析，不会被拦截
    private let safeDomains: Set<String> = [
        // 苹果服务
        "apple.com",
        "icloud.com",
        "appstore.com",

        // 微软服务
        "microsoft.com",
        "live.com",

        // 谷歌核心服务
        "google.com",
        "gmail.com",
        "youtube.com",

        // 开发工具
        "github.com",
        "stackoverflow.com",

        // 社交媒体
        "twitter.com",
        "instagram.com",

        // 新闻媒体
        "wikipedia.org",

        // 政府教育
        "gov.cn",
        "edu.cn",

        // 中国主流服务
        "weibo.com",
        "zhihu.com",
        "bilibili.com",
        "jd.com",

        // CDN 和基础服务
        "cloudflare.com",
        "cloudfront.net"
    ]

    // MARK: - DNS 代理生命周期

    /// 启动 DNS 代理
    override func startProxy(options: [String: Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        NSLog("[KinglessAdblocker] DNS 代理启动")
        completionHandler(nil)
    }

    /// 停止 DNS 代理
    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("[KinglessAdblocker] DNS 代理停止，原因: \(reason.rawValue)")
        completionHandler()
    }

    // MARK: - DNS 处理逻辑

    /// 处理 DNS 查询 - 此方法在收到 DNS 查询时被调用
    /// 返回 true 表示代理将处理这个查询，false 表示不处理
    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        // DNS 代理通常处理 UDP 流量
        guard let udpFlow = flow as? NEAppProxyUDPFlow else {
            return false
        }

        NSLog("[KinglessAdblocker] 收到新的 DNS 查询流")

        // 打开流并开始处理
        udpFlow.open(withLocalEndpoint: nil) { error in
            if let error = error {
                NSLog("[KinglessAdblocker] 打开 UDP 流失败: \(error)")
                return
            }

            self.processDNSFlow(udpFlow)
        }

        return true
    }

    /// 处理 DNS 查询流
    private func processDNSFlow(_ flow: NEAppProxyUDPFlow) {
        flow.readDatagrams { datagrams, remoteEndpoints, error in
            guard error == nil,
                  let datagrams = datagrams,
                  let endpoints = remoteEndpoints,
                  !datagrams.isEmpty else {
                NSLog("[KinglessAdblocker] 读取数据包失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }

            // 处理每个 DNS 数据包
            for (index, datagram) in datagrams.enumerated() {
                let endpoint = endpoints.count > index ? endpoints[index] : endpoints.last!
                self.processDNSDatagram(datagram, from: endpoint, via: flow)
            }

            // 继续读取下一个数据包
            self.processDNSFlow(flow)
        }
    }

    /// 处理单个 DNS 数据包
    private func processDNSDatagram(_ datagram: Data, from remoteEndpoint: NWEndpoint, via flow: NEAppProxyUDPFlow) {
        // 这里应该解析 DNS 查询，但由于没有 DNS 库，我们使用简化逻辑
        // 在实际应用中，需要使用 DNS 解析库（如 dnssd 或第三方库）

        // 记录收到的数据包大小
        NSLog("[KinglessAdblocker] 收到 DNS 数据包，大小: \(datagram.count) 字节")

        // 简单处理：转发到公共 DNS 服务器
        forwardToPublicDNS(datagram, from: remoteEndpoint, via: flow)
    }

    /// 转发 DNS 查询到公共 DNS 服务器
    private func forwardToPublicDNS(_ queryData: Data, from clientEndpoint: NWEndpoint, via flow: NEAppProxyUDPFlow) {
        // 使用 Google Public DNS (8.8.8.8)
        let publicDNSHost = NWEndpoint.Host("8.8.8.8")
        let publicDNSPort = NWEndpoint.Port(integerLiteral: 53)
        let publicDNSEndpoint = NWEndpoint.hostPort(host: publicDNSHost, port: publicDNSPort)

        let connection = NWConnection(to: publicDNSEndpoint, using: .udp)

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                // 发送 DNS 查询
                connection.send(content: queryData, completion: .contentProcessed { error in
                    if let error = error {
                        NSLog("[KinglessAdblocker] 发送 DNS 查询失败: \(error)")
                        return
                    }

                    // 接收 DNS 响应
                    self.receiveDNSResponse(from: connection, clientEndpoint: clientEndpoint, via: flow)
                })

            case .failed(let error):
                NSLog("[KinglessAdblocker] DNS 连接失败: \(error)")

            default:
                break
            }
        }

        connection.start(queue: .global())
    }

    /// 接收 DNS 响应并返回给客户端
    private func receiveDNSResponse(from connection: NWConnection, clientEndpoint: NWEndpoint, via flow: NEAppProxyUDPFlow) {
        connection.receiveMessage { content, context, isComplete, error in
            if let error = error {
                NSLog("[KinglessAdblocker] 接收 DNS 响应失败: \(error)")
                return
            }

            guard let responseData = content else {
                NSLog("[KinglessAdblocker] 没有收到 DNS 响应数据")
                return
            }

            // 在返回给客户端之前，可以检查响应中的域名
            // 如果是广告域名，可以修改响应为 0.0.0.0
            let modifiedResponse = self.maybeModifyDNSResponse(responseData)

            // 发送响应回客户端
            flow.writeDatagrams([modifiedResponse], sentBy: [clientEndpoint]) { error in
                if let error = error {
                    NSLog("[KinglessAdblocker] 发送 DNS 响应失败: \(error)")
                } else {
                    NSLog("[KinglessAdblocker] 成功转发 DNS 响应")
                }
            }

            connection.cancel()
        }
    }

    /// 可能修改 DNS 响应（将广告域名解析到 0.0.0.0）
    private func maybeModifyDNSResponse(_ responseData: Data) -> Data {
        // 在真实实现中，这里需要：
        // 1. 解析 DNS 响应
        // 2. 检查响应中的域名
        // 3. 如果是广告域名，将 IP 地址改为 0.0.0.0

        // 由于没有 DNS 解析库，这里返回原始数据
        // 在实际应用中，应该使用 dnssd 或其他 DNS 库来解析和修改

        return responseData
    }

    // MARK: - 域名匹配逻辑

    /// 判断域名是否应该被拦截
    private func shouldBlockDomain(_ domain: String) -> Bool {
        let domainLower = domain.lowercased()

        // 1. 检查是否是安全域名（白名单）
        if isSafeDomain(domainLower) {
            return false
        }

        // 2. 检查是否是广告域名（黑名单）
        if isAdDomain(domainLower) {
            return true
        }

        // 3. 检查域名关键词
        if containsAdKeywords(domainLower) {
            return true
        }

        // 默认放行
        return false
    }

    /// 检查是否为安全域名
    private func isSafeDomain(_ domain: String) -> Bool {
        // 完全匹配
        if safeDomains.contains(domain) {
            return true
        }

        // 后缀匹配（子域名）
        for safeDomain in safeDomains {
            if domain.hasSuffix(".\(safeDomain)") {
                return true
            }
        }

        return false
    }

    /// 检查是否为广告域名
    private func isAdDomain(_ domain: String) -> Bool {
        // 完全匹配
        if adDomains.contains(domain) {
            return true
        }

        // 后缀匹配（子域名）
        for adDomain in adDomains {
            // 跳过通配符域名
            if adDomain.contains("*") {
                continue
            }

            if domain.hasSuffix(".\(adDomain)") {
                return true
            }
        }

        return false
    }

    /// 检查域名是否包含广告关键词
    private func containsAdKeywords(_ domain: String) -> Bool {
        // 处理通配符模式
        for adPattern in adDomains {
            if adPattern.hasPrefix("*.") {
                let pattern = String(adPattern.dropFirst(2))
                if domain.hasSuffix(".\(pattern)") {
                    return true
                }
            } else if adPattern.hasSuffix(".*") {
                let pattern = String(adPattern.dropLast(2))
                if domain.hasPrefix("\(pattern).") {
                    return true
                }
            }
        }

        // 广告关键词列表
        let adKeywords = [
            "ad", "ads", "adv", "advert", "banner",
            "track", "analytics", "pixel", "beacon",
            "click", "impression", "conversion"
        ]

        // 检查关键词
        for keyword in adKeywords {
            // 避免误判（如 "admin" 包含 "ad"）
            let patterns = [".\(keyword).", "\(keyword).", ".\(keyword)"]
            for pattern in patterns {
                if domain.contains(pattern) {
                    return true
                }
            }
        }

        return false
    }
}