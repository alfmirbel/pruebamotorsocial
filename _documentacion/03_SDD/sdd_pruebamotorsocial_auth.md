# SDD — Feature: Auth

## 1. Repositorio
No existe repo propio; se usa `motorSocialBridgeProvider` con identity engine in-memory.

## 2. UI
- `LoginPage`: formulario identifier + secret, simula login con token_local, guarda `userId/token` en `sessionProvider`, navega a `MainShell`. Muestra error y loading.

## 3. Observaciones
- Registro, recovery y refresh existen solo como contratos en repo bridge.
- No hay validaciones, timeout ni captcha.

## 4. Requisitos
| ID | Requisito | Evidencia |
|-----|-----------|-----------|
| RF-AUTH-01 | Iniciar sesión desde formulario. | `LoginPage` con controllers. |
| RF-AUTH-02 | Persistir sesión mínima userId/token. | `sessionProvider` actualizado. |
| RF-AUTH-03 | Navegar al shell principal post-login. | `Navigator.pushReplacement(MainShell(...))`. |
| RF-AUTH-04 | Mostrar estado loading y error. | `_loading`, `_error`. |
