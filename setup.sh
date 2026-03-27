#!/bin/bash

# Kingless Adblocker 快速启动脚本
# 这是一个完整的 iOS 广告拦截器项目，使用 Xcodegen 生成跨端编译架构

set -e

echo "🎉 Kingless Adblocker 项目初始化"
echo "================================="

# 检查是否安装了必要的工具
echo "🔧 检查依赖工具..."

if ! command -v xcodegen &> /dev/null; then
    echo "❌ 未安装 Xcodegen，正在安装..."
    brew install xcodegen
else
    echo "✅ Xcodegen 已安装"
fi

if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 未安装 Xcode 命令行工具，请先安装 Xcode"
    echo "💡 提示：可以从 App Store 安装 Xcode"
    exit 1
else
    echo "✅ Xcode 命令行工具已安装"
fi

echo ""
echo "📁 项目结构概览："
echo "=================="
find . -type f -name "*.yml" -o -name "*.swift" -o -name "*.plist" -o -name "*.storyboard" | sort | head -20
echo "..."

echo ""
echo "🚀 生成 Xcode 工程..."
echo "====================="

# 清理旧的工程文件
rm -rf KinglessAdblocker.xcodeproj

# 生成新的工程
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ Xcode 工程生成成功！"
    ls -la KinglessAdblocker.xcodeproj/
else
    echo "❌ Xcode 工程生成失败"
    exit 1
fi

echo ""
echo "🔧 验证项目配置..."
echo "=================="

# 检查配置文件
if [ -f "project.yml" ]; then
    echo "✅ project.yml 配置文件存在"
else
    echo "❌ project.yml 配置文件不存在"
    exit 1
fi

# 检查源代码
if [ -d "Sources/App" ]; then
    echo "✅ App 源代码目录存在"
    echo "   包含文件:"
    find Sources/App -name "*.swift" -o -name "*.plist" | sort
else
    echo "❌ App 源代码目录不存在"
    exit 1
fi

if [ -d "Sources/Extension" ]; then
    echo "✅ Extension 源代码目录存在"
    echo "   包含文件:"
    find Sources/Extension -name "*.swift" -o -name "*.plist" | sort
else
    echo "❌ Extension 源代码目录不存在"
    exit 1
fi

echo ""
echo "🌐 网络扩展配置检查..."
echo "====================="

# 检查网络扩展配置文件
EXTENSION_PLIST="Sources/Extension/Info.plist"
if [ -f "$EXTENSION_PLIST" ]; then
    echo "✅ 网络扩展 Info.plist 存在"
    # 检查关键配置
    if grep -q "com.apple.networkextension-filter" "$EXTENSION_PLIST"; then
        echo "✅ NSExtensionPointIdentifier 配置正确"
    else
        echo "❌ NSExtensionPointIdentifier 配置可能不正确"
    fi
else
    echo "❌ 网络扩展 Info.plist 不存在"
fi

echo ""
echo "📱 应用功能说明"
echo "==============="
echo "主应用功能："
echo "  • 提供用户界面，显示广告拦截状态"
echo "  • 控制网络扩展的启动和停止"
echo "  • 显示拦截统计和日志"
echo ""
echo "网络扩展功能："
echo "  • 拦截广告域名请求"
echo "  • 过滤追踪器和分析脚本"
echo "  • 保护用户隐私"
echo ""
echo "🔧 支持的广告域名："
echo "  • Google 广告服务 (googleadservices.com, doubleclick.net)"
echo "  • Facebook/Meta 广告 (facebook.com, fbcdn.net)"
echo "  • 亚马逊广告 (amazon-adsystem.com)"
echo "  • 百度广告 (baidu.com, bdstatic.com)"
echo "  • 腾讯广告 (qq.com, gtimg.com)"
echo "  • 阿里系广告 (alibaba.com, alicdn.com)"
echo "  • 以及其他主流广告网络"

echo ""
echo "⚙️ 编译选项..."
echo "=============="

echo "建议的编译方式："
echo ""
echo "1. 打开 Xcode 工程"
echo "   open KinglessAdblocker.xcodeproj"
echo ""
echo "2. 选择 Scheme:"
echo "   • KinglessAdblocker (主应用)"
echo "   • KinglessAdblockerExtension (网络扩展)"
echo ""
echo "3. 目标设备："
echo "   • 任何 iOS 15.0+ 设备"
echo "   • iOS Simulator (仅限主应用测试)"
echo ""
echo "4. 编译配置："
echo "   • Debug: 调试版本，包含调试信息"
echo "   • Release: 发布版本，优化性能"

echo ""
echo "🚀 快速启动命令："
echo "================="
echo "打开工程："
echo "  open KinglessAdblocker.xcodeproj"
echo ""
echo "重新生成工程："
echo "  rm -rf KinglessAdblocker.xcodeproj && xcodegen generate"
echo ""
echo "清理项目："
echo "  xcodebuild clean -project KinglessAdblocker.xcodeproj"
echo ""
echo "编译主应用："
echo "  xcodebuild build -project KinglessAdblocker.xcodeproj -scheme KinglessAdblocker"
echo ""
echo "云端打包 IPA："
echo "  推送到 GitHub 后，GitHub Actions 会自动打包 IPA"
echo "  详见 .github/workflows/build-ipa.yml"

echo ""
echo "⚠️  注意事项："
echo "============="
echo "1. 网络扩展需要用户授权"
echo "2. iOS 系统限制："
echo "   - 不能拦截 HTTPS 内容"
echo "   - 只能看到域名，不能看到完整 URL 路径"
echo "   - 对网络扩展有严格的资源限制"
echo "3. 广告拦截效果取决于域名匹配规则"
echo "4. 可能需要更新广告域名列表以应对新的广告服务"

echo ""
echo "📚 更多信息："
echo "============"
echo "• 查看详细文档： cat README.md | more"
echo "• 查看拦截规则： grep -n \"adDomains\" Sources/Extension/FilterPacketProvider.swift"
echo "• 查看 CI/CD 配置： cat .github/workflows/build-ipa.yml"

echo ""
echo "🎉 初始化完成！"
echo "================"
echo "现在可以使用以下命令打开项目："
echo "  open KinglessAdblocker.xcodeproj"
echo ""
echo "或者查看项目文档："
echo "  less README.md"

exit 0