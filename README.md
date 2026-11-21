# App Organizadora ITLA - Versión 1

Aplicación móvil en **Flutter (Android)** para estudiantes del ITLA (Instituto Tecnológico de Las Américas), diseñada especialmente para **Hetsel Enrique** y compañeros de clase.

---

## 🎨 Sistema de Diseño (Regla 60-30-10)

- **Modo Claro (Edición Polar):**
  - **60% Fondo:** Blanco Polar `#F1F3F4`
  - **30% Tarjetas:** Azul Glaciar `#9CC6E0`
  - **10% Botones y Alertas:** Rojo Racing `#E4002B`
- **Modo Oscuro (Edición Tormenta):**
  - **60% Fondo:** Gris Tormenta `#5A6068`
  - **30% Tarjetas:** Negro Mate `#1C1D20`
  - **10% Botones y Alertas:** Naranja Seguridad `#FF5F00`

---

## 📱 Las 4 Pantallas Principales

1. **Hoy:**
   - Barra superior con iniciales (HE), fecha actual y saludo (*Hola, Hetsel*) con botón rojo **Actualizar**.
   - Tira interactiva de días de la semana (hoy destacado).
   - Tarjeta de progreso de hoy (*X de Y hechas - Z%*) con barra de llenado.
   - Filtros: **Hoy**, **Próximas** y **Sin fecha**.
   - Tareas urgentes marcadas con etiqueta roja `URGENTE / VENCE HOY`.
   - Tareas completadas se muestran tachadas al tocarlas.
   - Tarjeta oscura *Lo que viene* con el conteo de la siguiente fecha.

2. **Mis cursos:**
   - Las 7 materias actuales (Redacción Castellana excluida por estar retirada):
     1. `ING-001` - Inglés Nivel 1-3
     2. `TDS-001` - Algoritmos
     3. `TI-101` - Fundamentos del Computador
     4. `HIS-101` - Historia Universal
     5. `CBG-010` - Educación Constitucional
     6. `OAI-001` - Orientación Institucional
     7. `MAT-001` - Precálculo
   - Filtros: **Todos**, **Con tareas** y **Sin tareas**.
   - Búsqueda en tiempo real por nombre, código o profesor.
   - Modal con las tareas específicas de cada asignatura.

3. **Agregar tarea (Botón central `+`):**
   - Formulario para registrar tareas presenciales dictadas por el profesor en el aula.
   - Campos: Materia, Tema, Qué hay que hacer, Fecha de entrega y Tipo.
   - Alerta automática inteligente:
     - **Simple:** Notifica 1 día antes.
     - **Con trabajo (video, maqueta, etc.):** Notifica 3 a 4 días antes.

4. **Notas (Apuntes de clase):**
   - Cuaderno libre de apuntes (no calificaciones).
   - Botón `+ Nota` en la esquina superior derecha.
   - Materia como título y texto libre ilimitado.
   - Vista previa con fecha y opción para eliminar.

---

## 🔐 Login y Scraping ITLA

- **Entrar con Microsoft:** Utiliza la cuenta oficial `@itla.edu.do`.
- **Privacidad:** La aplicación **nunca almacena tu contraseña**; solo retiene la sesión activa (`MoodleSession`).
- **Modo Offline:** Si no hay conexión a internet, se muestran de inmediato los últimos datos sincronizados.
- **Manejo de Cloudflare:** Si se detecta un bloqueo o verificación, la app se detiene de forma segura sin saturar de peticiones y muestra: `No pude entrar, entra de nuevo`.

---

## 🚀 Cómo compilar y generar el APK

### Opción 1: En tu computadora (con Flutter instalado)
```bash
flutter pub get
flutter run               # Para probar en tu celular o emulador
flutter build apk --release # Para generar el APK instalable
```
El archivo APK se genera en:
`build/app/outputs/flutter-apk/app-release.apk`

### Opción 2: En la nube (GitHub Actions sin instalar nada en tu PC)
1. Sube este proyecto a tu repositorio de GitHub:
   ```bash
   git init
   git add .
   git commit -m "App ITLA v1"
   git remote add origin <tu-repositorio>
   git push -u origin main
   ```
2. Entra a la pestaña **Actions** en tu GitHub. El flujo de trabajo `Build ITLA Organizer APK` compilará el archivo `.apk` automáticamente y te dejará descargarlo en 3 minutos.
