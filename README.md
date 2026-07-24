# Turnos Web (Connect IQ)

Aplicación **Connect IQ** para relojes Garmin que permite **consultar entrenamientos** publicados en [Turnos Web Lite](https://play.google.com/store/apps/details?id=com.turnosweb.lite&hl=es_AR) desde la muñeca. Es un **cliente Garmin con funcionalidad reducida**: login, listado de workouts, listado de entrenamientos y visualización del detalle.

## Requisito previo: cuenta Turnos Web

Necesitas una cuenta activa en el servicio Turnos Web de tu gimnasio o centro (la misma que usarías con la app móvil oficial). Esta app de reloj **no sustituye** el alta ni la gestión completa del servicio; solo expone la consulta de entrenamientos.

- **Turnos Web Lite (Google Play):** https://play.google.com/store/apps/details?id=com.turnosweb.lite&hl=es_AR

En el reloj configurarás **dominio**, **usuario** y **contraseña** (los mismos datos de acceso al servicio).

## Funcionalidad

### Pantallas y navegación

1. **Configuración inicial** — Si no hay dominio, usuario y contraseña guardados, la app permite ingresarlos en el reloj con el `TextPicker` nativo de Garmin (también configurables desde Garmin Connect IQ en el teléfono).
2. **Lista de workouts** — Tras un login válido, se obtiene `panelmensajes` y se listan los elementos del array `w`. El usuario selecciona uno con el botón **Start/Stop** estándar.
3. **Lista de entrenamientos** — Con el workout elegido, se llama a `listtraining` y se listan los entrenamientos. Nueva selección con **Start/Stop**.
4. **Detalle del entrenamiento** — Se llama a `getplani` y se muestran `titulo` y `detalle` (HTML limpiado a texto legible).

**Atrás:** botón **Back/Stop** estándar del reloj.

**Menú (mantener Up/Menu):** opciones **Actualizar** (repetir la petición de la pantalla actual) y **Cerrar sesión** (borrar caché y credenciales para volver a iniciar sesión).

### Caché y conectividad

Para todas las peticiones **excepto el login**, la app usa estrategia **network-first / stale-while-revalidate**:

1. Intentar la petición en red.
2. Si tiene éxito → guardar en caché local y mostrar los datos.
3. Si falla → usar la caché anterior.
4. Si no hay caché → mostrar error.

El login valida las credenciales y persiste `ck` para las demás llamadas.

### Idiomas

Español por defecto; también inglés. Cadenas en `resources/strings/` (inglés) y `resources-spa/strings/` (español), según el mecanismo estándar de recursos Connect IQ.

## API

Referencia de endpoints, cuerpos de petición y campos de respuesta: [docs/API.md](docs/API.md).

## Requisitos de desarrollo

1. **Garmin Connect IQ SDK** (`monkeyc`, simulador, `monkeydo`):
   - [Connect IQ SDK Manager / descargas](https://developer.garmin.com/connect-iq/sdk/)
2. Documentación útil:
   - [Guía del programador Connect IQ](https://developer.garmin.com/connect-iq/programmers-guide/)
   - [Referencia de la API (Monkey C)](https://developer.garmin.com/connect-iq/api-docs/)
3. **Clave de firma** del desarrollador en formato **DER PKCS#8** (`private_key.der`). No la subas a repositorios públicos:

```bash
openssl genrsa -out private_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in private_key.pem -out private_key.der -nocrypt
```

El proyecto ignora `private_key.der` y `private_key.pem` mediante `.gitignore`.

## Estructura del proyecto

```
source/           Código Monkey C
resources/        Recursos base (inglés) y ajustes Connect IQ
resources-spa/    Cadenas en español
docs/API.md       Referencia de endpoints
Makefile          Compilación y empaquetado Connect IQ
```

## Compilar

El `Makefile` apunta por defecto a una ruta de SDK bajo `~/.Garmin/ConnectIQ/Sdks/...`. Puedes sobrescribirla:

```bash
export SDK=/ruta/al/connectiq-sdk-lin-...
make build
```

`manifest.xml` se genera desde `manifest.template.xml` con el app id según el canal:

```bash
# Beta (id histórico, por defecto)
make build

# Producción (app id distinto en Connect IQ Store)
make build VARIANT=prod
```

La lista de productos está en `manifest.template.xml`. `minSdkVersion` es `3.1.0` (AnimationLayer). Íconos no-40×40: `make icons`. Animaciones: `make animations` (requiere los device packs instalados en el SDK Manager).

Equivalente manual (tras generar el manifest):

```bash
monkeyc -f monkey.jungle -o TurnosWeb.prg -y private_key.der -d fenix7s -w
```

## Regenerar animación de carga

El loading usa `WatchUi.AnimationLayer` con un GIF fuente convertido a Monkey Motion. No edites los `.mm` a mano: se generan desde `resources-anim/animations/loading-spinner.gif`. En `fr55` no hay animación: solo texto centrado.

```bash
make animations
```

Esto actualiza `resources-anim/animations/loading-spinner.mmm` y los `.mm` correspondientes a `COMMON_DEVICES` en `Makefile`. `resources-anim/` se incluye vía `monkey.jungle` (excepto `fr55`).

Empaquetado para la tienda Connect IQ:

```bash
make release              # → TurnosWeb-beta.iq
make release VARIANT=prod # → TurnosWeb-prod.iq
```

## Simulador

1. Arranca el simulador (en una terminal aparte):

   ```bash
   make simulator
   ```

2. Con el simulador en marcha, construye y carga la app:

   ```bash
   make run
   ```

`make run` compila y ejecuta `monkeydo` pasando el archivo **`*-settings.json`** al almacenamiento virtual del simulador; en **Linux** evita el error *«No settings file found for this app»* al editar ajustes desde el menú del simulador.

En el simulador, configura **dominio**, **usuario** y **contraseña** en **Archivo → Editar almacenamiento persistente → Editar datos de Application.properties**.

**Nota:** En reloj real las peticiones HTTPS suelen salir vía **Garmin Connect Mobile**; en el simulador el tráfico sale desde el equipo anfitrión.

## Configurar la cuenta

En el reloj, abre el menú de configuración y completa **dominio**, **usuario** y **contraseña**. La entrada de texto usa el `TextPicker` nativo del dispositivo.

También puedes hacerlo desde el móvil:

Para introducir **dominio**, **usuario** y **contraseña** en el reloj, hazlo desde la app **Garmin Connect IQ** en el teléfono:

1. Abre **Garmin Connect IQ**.
2. Pulsa **More** (más / menú, según versión).
3. **Garmin Devices** → elige tu **reloj**.
4. Entra en **Activities & Applications**.
5. Busca **Turnos Web** en la lista y abre sus **ajustes**.

Los nombres exactos de los menús pueden variar según idioma o versión de Garmin Connect IQ.

## Instalar en el reloj

1. Empareja el reloj con **Garmin Connect** y mantén el Bluetooth activo.
2. Genera `TurnosWeb.prg` firmado con tu clave.
3. Instala la app (extensión Connect IQ para VS Code, herramientas del SDK o publicación en la tienda Connect IQ).
4. Configura la cuenta en el móvil y sincroniza para que los ajustes lleguen al reloj.
5. Abre **Turnos Web** desde el menú de aplicaciones del reloj.

## Aviso legal (no oficial)

- Esta aplicación es un **proyecto independiente** desarrollado por terceros. **No tiene relación, atribución ni vínculo alguno** con Turnos Web, su empresa titular ni con ninguna de sus filiales o representantes.
- **No es una aplicación oficial** de Turnos Web ni de Garmin.
- **Garmin**, **Connect IQ**, **Garmin Connect** y los nombres o logotipos relacionados son **marcas comerciales** de Garmin Ltd. o de sus filiales. Esta app **no está respaldada, patrocinada ni aprobada** por Garmin.
- **Turnos Web**, **Turnos Web Lite** y los servicios o marcas asociados pertenecen a sus respectivos titulares. Esta app **no está respaldada, patrocinada ni aprobada** por Turnos Web.
- El software se ofrece **«tal cual»**, **sin garantía** de ningún tipo (incluidos el funcionamiento ininterrumpido, la exactitud de los datos o la compatibilidad con todos los dispositivos o versiones del sistema). **El uso es bajo tu propia responsabilidad.**
- El autor o los colaboradores del repositorio **no asumen responsabilidad** por daños directos o indirectos, pérdida de datos, incumplimiento de servicios de terceros o conflictos con las condiciones de uso de Garmin, Turnos Web u otros proveedores.
- Al usar la app debes cumplir las **condiciones de uso** y la **legislación aplicable** (incluidas las de Garmin Connect IQ, la tienda Connect IQ si publicas allí, y las del servicio Turnos Web / API que utilices).

## Licencia

Este repositorio es software de terceros pensado para integrarse con APIs y ecosistemas de Garmin y Turnos Web. Respeta las licencias del **SDK Connect IQ** de Garmin y las condiciones de uso de los servicios que emplees para compilar o distribuir la aplicación.
