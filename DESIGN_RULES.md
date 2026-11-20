# Reglas de Diseño Visual y Arquitectura Roblox (Luau)

1. **Estética de UI (Simulator Moderno):**
   - Nunca uses `Frame` planos sin estilo. Toda tarjeta o botón debe incluir `UICorner` (12-16px), `UIStroke` (2px a 3px con contraste brillante) y `UIGradient` vertical o diagonal.
   - Usa la fuente `Enum.Font.GothamBlack` para títulos/números y `Enum.Font.GothamBold` para etiquetas.
   - Añade siempre feedback táctil ("Juice"): escala al hacer hover (`1.04x`) y rebote (`TweenService` con `Enum.EasingStyle.Back`) al hacer clic.
   - Evita la esquina superior derecha (`UDim2.new(1, -240, 0, 0)`) para no chocar con el Leaderboard nativo de Roblox.

2. **Construcción de Mapas y Modelos 3D Procedurales:**
   - Usa materiales variados (`SmoothPlastic` para estilo cartoon limpio, `Neon` para detalles de energía/portales, `Grass` y `Slate` para terreno).
   - Agrupa cada estructura en un `Model` con `PrimaryPart` asignado y `Anchored = true`.
   - Añade iluminación ambiental (`Atmosphere`, `BloomEffect`, `ColorCorrectionEffect`) en `Lighting` para lograr colores vibrantes.

3. **Estándar de Código Luau:**
   - Entrega siempre archivos completos de principio a fin sin omitir bloques con comentarios.
   - Guarda todo en UTF-8 sin BOM.