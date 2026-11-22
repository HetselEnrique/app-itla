import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showWebView = false;
  bool _isLoadingWeb = true;

  static const String itlaLoginUrl = 'https://aulavirtual.itla.edu.do/lgnx';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    return Scaffold(
      body: SafeArea(
        child: _showWebView
            ? Column(
                children: [
                  // Barra superior del WebView con botón de cierre
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1D20) : Colors.white,
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _showWebView = false),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Iniciar sesión con Microsoft',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        if (_isLoadingWeb)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accentColor,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Navegador WebView
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(itlaLoginUrl)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        databaseEnabled: true,
                        thirdPartyCookiesEnabled: true,
                        userAgent:
                            'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                        useShouldOverrideUrlLoading: true,
                        mixedContentMode:
                            MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      ),
                      onLoadStart: (controller, url) {
                        setState(() => _isLoadingWeb = true);
                      },
                      onLoadStop: (controller, url) async {
                        setState(() => _isLoadingWeb = false);

                        if (url != null) {
                          final cookieManager = CookieManager.instance();
                          final cookies = await cookieManager.getCookies(
                            url: WebUri('https://aulavirtual.itla.edu.do'),
                          );

                          for (final cookie in cookies) {
                            if (cookie.name == 'MoodleSession') {
                              // Sesión capturada con éxito
                              await appState.loginWithMicrosoft(
                                cookie: cookie.value,
                                name: 'Hetsel Enrique',
                                initials: 'HE',
                                email: 'hetsel@itla.edu.do',
                              );
                              if (!context.mounted) return;
                              setState(() => _showWebView = false);
                              Navigator.of(context)
                                  .pushReplacementNamed('/home');
                              return;
                            }
                          }
                        }
                      },
                      onReceivedError: (controller, request, error) {
                        setState(() => _isLoadingWeb = false);
                      },
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    // Logo ITLA
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ITLA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'App Organizadora ITLA',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus tareas y cursos de la semana en un solo lugar',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    const Spacer(),

                    // Alerta si la sesión venció o Cloudflare bloqueó
                    if (appState.statusBanner != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentColor),
                        ),
                        child: Text(
                          appState.statusBanner!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    // Botón único grande: Entrar con Microsoft
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showWebView = true;
                          _isLoadingWeb = true;
                        });
                      },
                      icon: const Icon(Icons.account_circle_outlined, size: 24),
                      label: const Text(
                        'Entrar con Microsoft',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Entrar directo (Modo Offline o demostración)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      child:
                          const Text('Entrar a la app (Modo Offline / Local)'),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      '• Abre Office 365 con tu cuenta @itla.edu.do\n'
                      '• La app NO guarda tu contraseña, solo la sesión.\n'
                      '• Si no hay internet, muestra los últimos datos guardados.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
