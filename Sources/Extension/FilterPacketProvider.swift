import NetworkExtension
import Foundation

class FilterPacketProvider: NEFilterPacketProvider {

    /// 广告域名黑名单 (全网主流广告服务商)
    private let adDomains: Set<String> = [
        // Google 广告服务
        "googleadservices.com",
        "googlesyndication.com",
        "google-analytics.com",
        "doubleclick.net",
        "adservice.google.com",

        // Facebook/Meta 广告
        "facebook.com",
        "fbcdn.net",
        "fbsbx.com",

        // 亚马逊广告
        "amazon-adsystem.com",

        // 腾讯广告
        "qq.com",
        "gtimg.com",

        // 百度广告
        "baidu.com",
        "bdstatic.com",

        // 阿里/淘宝广告
        "alibaba.com",
        "alicdn.com",
        "taobao.com",

        // 字节跳动广告
        "bytedance.com",
        "toutiao.com",
        "douyin.com",

        // 其他主流广告网络
        "adsystem.com",
        "adnxs.com",
        "rubiconproject.com",
        "openx.net",
        "pubmatic.com",
        "criteo.com",
        "taboola.com",
        "outbrain.com",

        // 通用广告域名模式
        "*.ads.*",
        "*ad.*",
        "ads.*",
        "adserver.*",
        "adservice.*",
        "advertisement.*",
        "tracking.*",
        "analytics.*"
    ]

    /// 需要放行的安全域名
    private let safeDomains: Set<String> = [
        "apple.com",
        "icloud.com",
        "microsoft.com",
        "github.com",
        "stackoverflow.com",
        "wikipedia.org",
        "gov.cn",
        "edu.cn"
    ]

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        NSLog("[KinglessAdblocker] Filter started")
        completionHandler(nil)
    }

    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("[KinglessAdblocker] Filter stopped with reason: \(reason.rawValue)")
        completionHandler()
    }

    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // 获取流量的相关信息
        guard let url = flow.url else {
            return .allow()
        }

        // 检查是否是安全域名
        if isSafeDomain(url.host) {
            NSLog("[KinglessAdblocker] Allowing safe domain: \(url.host ?? "unknown")")
            return .allow()
        }

        // 检查是否是广告域名
        if isAdDomain(url.host) {
            NSLog("[KinglessAdblocker] Blocking ad domain: \(url.host ?? "unknown")")
            return .drop()
        }

        // 检查是否为追踪器
        if isTracker(url) {
            NSLog("[KinglessAdblocker] Blocking tracker: \(url.absoluteString)")
            return .drop()
        }

        // 默认放行
        NSLog("[KinglessAdblocker] Allowing: \(url.absoluteString)")
        return .allow()
    }

    override func handleInboundData(from flow: NEFilterFlow,
                                  readBytesStartOffset offset: Int,
                                  readBytes: Data) -> NEFilterDataVerdict {
        // 可以在这里检查数据内容
        return .allow()
    }

    override func handleOutboundData(from flow: NEFilterFlow,
                                   readBytesStartOffset offset: Int,
                                   readBytes: Data) -> NEFilterDataVerdict {
        // 可以在这里检查数据内容
        return .allow()
    }

    override func handleInboundDataComplete(for flow: NEFilterFlow) -> NEFilterDataVerdict {
        return .allow()
    }

    override func handleOutboundDataComplete(for flow: NEFilterFlow) -> NEFilterDataVerdict {
        return .allow()
    }

    // MARK: - 域名检查逻辑

    private func isSafeDomain(_ host: String?) -> Bool {
        guard let host = host?.lowercased() else { return false }

        for safeDomain in safeDomains {
            if host == safeDomain || host.hasSuffix(".\(safeDomain)") {
                return true
            }
        }
        return false
    }

    private func isAdDomain(_ host: String?) -> Bool {
        guard let host = host?.lowercased() else { return false }

        // 检查完全匹配
        if adDomains.contains(host) {
            return true
        }

        // 检查通配符匹配
        for domainPattern in adDomains {
            if domainPattern.hasPrefix("*.") {
                let pattern = String(domainPattern.dropFirst(2)) // 移除 "*."
                if host == pattern || host.hasSuffix(".\(pattern)") {
                    return true
                }
            } else if domainPattern.hasSuffix(".*") {
                let pattern = String(domainPattern.dropLast(2)) // 移除 ".*"
                if host.hasPrefix("\(pattern).") {
                    return true
                }
            } else if domainPattern.contains("*.*") {
                // 处理 *ad.* 这样的模式
                let parts = domainPattern.components(separatedBy: "*")
                if parts.count == 2,
                   host.contains(parts[0]),
                   host.contains(parts[1]),
                   host.range(of: "\(parts[0]).*?\(parts[1])", options: .regularExpression) != nil {
                    return true
                }
            }
        }

        // 检查常见广告关键词
        let adKeywords = ["ad", "ads", "adv", "advert", "banner", "track", "analytics"]
        for keyword in adKeywords {
            if host.contains(keyword) {
                return true
            }
        }

        return false
    }

    private func isTracker(_ url: URL) -> Bool {
        guard let query = url.query?.lowercased() else { return false }

        let trackingParams = ["utm_", "fbclid", "gclid", "msclkid", "trk", "tracking", "ref", "campaign"]
        for param in trackingParams {
            if query.contains(param) {
                return true
            }
        }
        return false
    }
}