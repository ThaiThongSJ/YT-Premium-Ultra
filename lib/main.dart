// ==========================================
// VERSION: 2.6.0-JungleDiamond-SmartPause
// AUTHOR: ThaiThongSj@gmail.com & Gemini
// OPTIMIZATION: Smart Physical Pause, Event-Driven Ad Shield, Zero-Lag 60FPS
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YT Premium Ultra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WebViewScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 55, color: Colors.red),
              ),
              const SizedBox(height: 24),
              const Text(
                'YT PREMIUM ULTRA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ThaiThongSj@gmail.com',
                style: TextStyle(fontSize: 13, color: Colors.grey[500], letterSpacing: 0.5),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  Orientation? _lastOrientation;

  // LÕI THUẬT TOÁN V2.6.0 NÂNG CẤP CHẠM VẬT LÝ VÀ PHÂN BIỆT LUỒNG CHẠY NGẦM THÔNG MINH
  final String pureThreeCoreScript = r"""
(function() {
    'use strict';

    // Biến trạng thái toàn cục để kiểm soát hành vi nhấn Pause vật lý của người dùng
    window.userManuallyPaused = false;

    // 1. CHẶN QUẢNG CÁO HIỂN THỊ CỐ ĐỊNH (Xử lý trực tiếp bằng Hardware Accelerated CSS - 0% CPU)
    const injectStaticShield = () => {
        if (document.getElementById('pure-ad-shield')) return;
        const css = `
            ytm-ad-slot, ytd-ad-slot-renderer, .ytp-ad-module, .ytp-ad-overlay-container,
            #player-ads, .ad-showing, .ad-interrupting, square-image-layout-view-model,
            ad-image-view-model, ytm-promoted-sparkles-web-renderer, .companion-ad-container,
            .ytm-open-app-button, .compact-app-bar, ytm-pivot-bar-renderer-fast-forward-button,
            ytm-statement-banner-renderer, ytm-compact-promoted-item-renderer {
                display: none !important; visibility: hidden !important; height: 0 !important; width: 0 !important;
            }
        `;
        const style = document.createElement('style');
        style.id = 'pure-ad-shield';
        style.textContent = css;
        (document.head || document.documentElement).appendChild(style);
    };
    injectStaticShield();

    // 2. BỎ QUA QUẢNG CÁO VIDEO SIÊU TỐC (Chỉ dùng MutationObserver + Event, Tuyệt đối không dùng timeupdate)
    const fastForwardVideoAds = () => {
        const video = document.querySelector('video');
        if (!video) return;

        const isAd = document.querySelector('.ad-showing, .ad-interrupting');

        if (isAd) {
            video.muted = true;
            if (isFinite(video.duration) && video.duration > 0) {
                video.currentTime = video.duration;
            } else {
                video.playbackRate = 16;
            }
            
            const skipBtn = document.querySelector('.ytp-ad-skip-button, .ytp-skip-ad-button, .ytm-ad-skip-button, button[aria-label*="Skip"], button[aria-label*="Bỏ qua"]');
            if (skipBtn) skipBtn.click();
        }
    };

    if (!window.pureAdObserver) {
        window.pureAdObserver = new MutationObserver(() => fastForwardVideoAds());
        window.pureAdObserver.observe(document.body, {
            childList: true,
            subtree: true,
            attributeFilter: ['class']
        });
    }

    // Lắng nghe trạng thái phát để quản lý cờ Tạm dừng vật lý
    document.addEventListener('play', () => {
        window.userManuallyPaused = false; // Khi video phát, reset trạng thái dừng bằng tay
        fastForwardVideoAds();
    }, true);
    
    document.addEventListener('playing', fastForwardVideoAds, true);

    // BẮT CHÍNH XÁC SỰ KIỆN TẠM DỪNG VẬT LÝ CỦA NGƯỜI DÙNG
    document.addEventListener('pause', () => {
        // Nếu màn hình đang hiển thị (người dùng chủ động tương tác chạm để pause)
        if (document.hasFocus()) {
            window.userManuallyPaused = true;
        }
    }, true);


    // 3. THUẬT TOÁN CHẠY NGẦM THÔNG MINH - KHÔNG XUNG ĐỘT NÚT PAUSE VÀ KHÔNG LÀM CHẬM LUỒNG TẢI
    const patchBackgroundEngine = () => {
        if (window.pureBackgroundPatched) return;
        window.pureBackgroundPatched = true;

        Object.defineProperty(document, 'hidden', { get: () => false, configurable: true });
        Object.defineProperty(document, 'visibilityState', { get: () => 'visible', configurable: true });
        Object.defineProperty(document, 'webkitHidden', { get: () => false, configurable: true });
        Object.defineProperty(document, 'webkitVisibilityState', { get: () => 'visible', configurable: true });
        
        window.addEventListener('visibilitychange', (e) => e.stopImmediatePropagation(), true);
        window.addEventListener('webkitvisibilitychange', (e) => e.stopImmediatePropagation(), true);
        window.addEventListener('pagehide', (e) => e.stopImmediatePropagation(), true);
        window.addEventListener('blur', (e) => e.stopImmediatePropagation(), true);

        window.IntersectionObserver = class IntersectionObserver {
            constructor(callback) { this.callback = callback; }
            observe(element) {
                setTimeout(() => {
                    if (typeof this.callback === 'function') {
                        this.callback([{
                            isIntersecting: true,
                            target: element,
                            intersectionRatio: 1.0,
                            boundingClientRect: element.getBoundingClientRect(),
                            intersectionRect: element.getBoundingClientRect(),
                            rootBounds: {}
                        }]);
                    }
                }, 50);
            }
            unobserve() {}
            disconnect() {}
        };

        if (navigator.mediaSession) {
            navigator.mediaSession.setActionHandler('pause', () => {
                // Nếu ứng dụng đang chạy ngầm, nuốt chửng lệnh pause của hệ thống.
                // Nếu người dùng đang mở app và bấm dừng trực tiếp, cho phép xử lý bình thường.
                if (!document.hasFocus()) return;
            });
        }

        const originalPause = HTMLMediaElement.prototype.pause;
        HTMLMediaElement.prototype.pause = function() {
            // Nếu người dùng đang mở app bấm dừng vật lý -> cho dừng thoải mái
            if (document.hasFocus() || window.userManuallyPaused) {
                return originalPause.apply(this, arguments);
            }
            // Chỉ chặn lệnh pause nếu lệnh đó tự động kích hoạt từ hệ thống khi ẩn ứng dụng xuống nền
            return Promise.resolve();
        };

        // VÒNG BẢO HIỂM GIỮ LUỒNG: Chỉ can thiệp khi chạy ngầm ẩn màn hình
        setInterval(() => {
            const video = document.querySelector('video');
            // ĐIỀU KIỆN CHẶT CHẼ: Video bị đứng ngoài ý muốn, KHÔNG phải do người dùng tự bấm pause, và ứng dụng KHÔNG có tiêu điểm (đang chạy ngầm)
            if (video && video.paused && !video.ended && !window.userManuallyPaused && !document.hasFocus()) {
                if (!document.querySelector('.ad-showing, .ad-interrupting')) {
                    video.play().catch(() => {});
                }
            }
        }, 1000);
    };
    patchBackgroundEngine();

    // 4. THEO DÕI XOAY MÀN HÌNH TỰ ĐỘNG
    const checkFullscreenEngine = () => {
        if (document.fullscreenElement || document.webkitFullscreenElement) {
            if (window.PureRotationChannel) window.PureRotationChannel.postMessage('landscape');
        } else {
            if (window.PureRotationChannel) window.PureRotationChannel.postMessage('portrait');
        }
    };
    document.addEventListener('fullscreenchange', checkFullscreenEngine);
    document.addEventListener('webkitfullscreenchange', checkFullscreenEngine);
})();
""";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 14; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _controller.runJavaScript(pureThreeCoreScript).catchError((_) {});
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _controller.runJavaScript(pureThreeCoreScript).catchError((_) {});
          },
        ),
      )
      ..addJavaScriptChannel(
        'PureRotationChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'landscape') {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else if (message.message == 'portrait') {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
          }
        },
      );

    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.loadRequest(Uri.parse('https://m.youtube.com'));
  }

  void _syncSystemUI(Orientation orientation) {
    if (_lastOrientation == orientation) return;
    _lastOrientation = orientation;

    if (orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    _syncSystemUI(orientation);
    final bool isLandscape = orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !isLandscape,
          bottom: !isLandscape,
          left: false,
          right: false,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.red, strokeWidth: 3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}