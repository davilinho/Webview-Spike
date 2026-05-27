# WebView Spike 🌐

Un proyecto spike completo para explorar y optimizar el funcionamiento de `WKWebView` en iOS usando SwiftUI.

## 📋 Descripción

Este proyecto es un spike de investigación que explora patrones de arquitectura, optimización de rendimiento y mejores prácticas para integrar WebViews en aplicaciones iOS modernas.

### Características principales

- **Optimización de WebView**: Implementación optimizada de `WKWebView` con mejora de rendimiento
- **Pool de WebViews**: Sistema de pool para reutilizar instancias de WebView
- **Content Blocker**: Bloqueo de contenido no deseado en WebViews
- **Local Assets Handler**: Manejo de assets locales a través de esquemas personalizados
- **Coordinador Pattern**: Implementación del patrón Coordinator para navegación y ciclo de vida
- **Factory Pattern**: Factory para la creación de WebViews
- **Cobertura de Tests**: Suite completa de tests unitarios y UI tests

## 🏗️ Arquitectura

### Componentes principales

- **`WebViewCoordinator.swift`**: Gestiona el ciclo de vida y la navegación del WebView
- **`WebViewFactory.swift`**: Factory para crear instancias configuradas de WebView
- **`WebViewPool.swift`**: Implementa un pool reutilizable de WebViews
- **`OptimizedWebView.swift`**: Wrapper optimizado de WKWebView
- **`LocalAssetsSchemeHandler.swift`**: Handler personalizado para cargar assets locales
- **`ContentBlocker.swift`**: Implementa reglas de bloqueo de contenido
- **`RootView.swift`**: Vista raíz con la interfaz principal
- **`WebScreen.swift`**: Pantalla de WebView

## 🧪 Tests

El proyecto incluye una suite completa de tests:

- **Unitarios**: 
  - `ContentBlockerTests.swift`
  - `WebViewCoordinatorTests.swift`
  - `WebViewFactoryTests.swift`
  - `WebViewPoolTests.swift`
  - `LocalAssetsSchemeHandlerTests.swift`

- **UI Tests**:
  - `WebViewSpikeUITests.swift`
  - `WebViewSpikeUITestsLaunchTests.swift`

## 🚀 Primeros pasos

### Requisitos

- macOS 12.0+
- Xcode 13.0+
- iOS 14.0+
- Swift 5.5+

### Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/davilinho/Webview-Spike.git
cd WebViewSpike
```

2. Abrir el proyecto en Xcode:
```bash
open WebViewSpike.xcodeproj
```

3. Compilar y ejecutar:
```bash
Cmd + R en Xcode
```

## 📚 Estructura del proyecto

```
WebViewSpike/
├── Fuentes principales/
│   ├── WebViewSpikeApp.swift           # Entry point de la app
│   ├── RootView.swift                  # Vista raíz
│   ├── WebScreen.swift                 # Pantalla de WebView
│   ├── OptimizedWebView.swift          # WebView optimizado
│   ├── WebViewCoordinator.swift        # Coordinador
│   ├── WebViewFactory.swift            # Factory de WebView
│   ├── WebViewPool.swift               # Pool de WebViews
│   ├── LocalAssetsSchemeHandler.swift  # Handler de assets
│   ├── ContentBlocker.swift            # Bloqueador de contenido
│   ├── Item.swift                      # Modelo de datos
│   └── Assets.xcassets/                # Recursos visuales
├── Tests/
│   ├── WebViewSpikeTests/              # Tests unitarios
│   └── WebViewSpikeUITests/            # UI Tests
└── WebViewSpike.xcodeproj/             # Configuración del proyecto
```

## 🎯 Patrones utilizados

- **Coordinator Pattern**: Para gestionar navegación y flujos
- **Factory Pattern**: Creación de WebViews configurados
- **Object Pool Pattern**: Reutilización de WebViews
- **Wrapper Pattern**: Encapsulación de WKWebView

## ⚙️ Configuración

### Variables de entorno

El proyecto no requiere variables de entorno especiales, pero se pueden extender fácilmente.

### Configuración de WebView

Consulta `WebViewFactory.swift` para personalizar:
- User agents
- Configuración de JavaScript
- Políticas de caché
- Configuración de cookies

## 📝 Notas de desarrollo

- **Performance**: El pool de WebViews reduce la latencia de creación
- **Memory**: Las WebViews se reutilizan para optimizar memoria
- **Security**: ContentBlocker proporciona control sobre el contenido cargado
- **Local Assets**: LocalAssetsSchemeHandler permite servir recursos locales

## 🔗 Enlaces útiles

- [GitHub Repository](https://github.com/davilinho/Webview-Spike)
- [Apple WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

## 📄 Licencia

Este proyecto es un spike de investigación. Usa libremente para aprender y experimentar.

## 👤 Autor

David Martin - [@davilinho](https://github.com/davilinho)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios significativos, abre un issue primero para discutir qué te gustaría cambiar.

---

**Última actualización**: Mayo 2026
