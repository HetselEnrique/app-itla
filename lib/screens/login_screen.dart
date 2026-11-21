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
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    return Scaffold(
      body: SafeArea(
        child: _showWebView
            ? Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://plataformavirtual.itla.edu.do/login/index.php'),
                    ),
                    onLoadStop: (controller, url) async {
                      // Al completar el login, capturar la cookie de sesión MoodleSession
                      final cookieManager = CookieManager.instance();
                      final cookies = await cookieManager.getCookies(
                        url: WebUri('https://plataformavirtual.itla.edu.do'),
                      );

                      for (final cookie in cookies) {
                        if (cookie.name == 'MoodleSession') {
                          await appState.loginWithMicrosoft(
                            cookie: cookie.value,
                            name: 'Hetsel Enrique',
                            initials: 'HE',
                            email: 'hetsel@itla.edu.do',
                          );
                          if (mounted) {
                            setState(() => _showWebView = false);
                          }
                          break;
                        }
                      }
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _showWebView = false),
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    // Logo / Icono ITLA
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.35),
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
                          color: accentColor.withOpacity(0.12),
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
                        setState(() => _showWebView = true);
                      },
                      icon: const Icon(Icons.account_circle_outlined, size: 24),
                      label: const Text(
                        'Entrar con Microsoft',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Modo sin conexión / ver datos guardados
                    if (appState.tasks.isNotEmpty)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Abre la app con los últimos datos guardados
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        child: const Text('Ver últimos datos guardados (Offline)'),
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
