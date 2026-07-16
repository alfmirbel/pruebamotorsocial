# SDD — Feature: Catalog

## 1. Resumen
Pantalla de catálogo social integrado conectada al bridge.

## 2. UI
- `CatalogPage`: muestra ticket de integración con `bridge.catalog`, y banner de staging.

## 3. Datos
- Lee `motorSocialBridgeProvider` y usa `bridge.catalog.runtimeType` como respaldo visual.

## 4. Requisitos
| ID | Requisito | Evidencia |
|-----|-----------|-----------|
| RF-CAT-01 | Presentar catálogo integrado del motor. | `CatalogPage` lee del bridge. |
