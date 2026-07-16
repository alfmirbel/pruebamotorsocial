# SDD — Feature: Feed

## 1. Resumen
Pantalla genérica de activity derivada de `ActivityContract`.

## 2. Datos
- Recupera `config.activity` del bridge para mostrar título condicional y verbos habilitados.
- Placeholder sin lista real de actividades.

## 3. Contrato
- Muestra `enabledVerbs` desde el contrato de actividad.

## 4. Requisitos
| ID | Requisito | Evidencia |
|-----|-----------|-----------|
| RF-FEED-01 | Renderizar feed basado en contrato. | Lectura de `config.activity`, título y verbos. |
