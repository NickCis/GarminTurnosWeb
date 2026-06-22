# API Turnos Web (referencia interna)

Documentación de los endpoints utilizados por la app. Las URLs siguen el patrón `https://<dominio>.turnosweb.com/...`, donde `<dominio>` es el subdominio configurado por el usuario (por ejemplo, `mi-gimnasio`).

Todas las peticiones POST incluyen el header:

```
X-Requested-With: com.turnosweb.lite
```

Los campos `app1`, `app2` e `id` son **datos sensibles de sesión**; no deben publicarse ni commitearse con valores reales.

---

## Login

`POST https://<dominio>.turnosweb.com/pwa/login`

**Cuerpo:**

```json
{
  "username": "<usuario>",
  "password": "<contraseña>",
  "en": 0
}
```

**Respuesta relevante:** almacenar el objeto `ck` (credenciales de sesión para el resto de peticiones).

```json
{
  "ok": true,
  "err": "",
  "ck": {
    "0": "<app1>",
    "1": "<app2>"
  },
  "user": { "...": "..." }
}
```

(`ck["0"]` → `app1` numérico; `ck["1"]` → `app2` cadena.)

---

## Panel de mensajes (workouts)

`POST https://<dominio>.turnosweb.com/pwa2/panelmensajes`

**Cuerpo:**

```json
{
  "app1": "<app1>",
  "app2": "<app2>",
  "cookieios": "",
  "en": 0
}
```

(`app1` y `app2` provienen de `ck`.)

**Respuesta relevante:** array `w` con los workouts disponibles.

```json
{
  "w": [
    {
      "id": "<workout_id>",
      "detalle": "Nombre del workout",
      "bg": "6"
    }
  ]
}
```

---

## Listado de entrenamientos

`POST https://<dominio>.turnosweb.com/pwa3/listtraining`

**Cuerpo:**

```json
{
  "id": "<workout_id>",
  "app1": "<app1>",
  "app2": "<app2>",
  "cookieios": "",
  "en": 0
}
```

(`id` es el identificador del workout seleccionado en `w`.)

**Respuesta relevante:** array `l` con los entrenamientos.

```json
{
  "l": [
    {
      "id": "<training_id>",
      "titulo": "Dia 1",
      "detalle": "Nombre del workout",
      "wod": "2026-06-12",
      "tipo_wod": "<workout_id>"
    }
  ]
}
```

---

## Detalle del entrenamiento

`POST https://<dominio>.turnosweb.com/pwa3/getplani`

**Cuerpo:**

```json
{
  "id": "<training_id>",
  "wod": "2026-06-12",
  "tipo_wod": "<workout_id>",
  "tipo": 1,
  "app1": "<app1>",
  "app2": "<app2>",
  "cookieios": "",
  "en": 0
}
```

**Respuesta relevante:** en `l[0]` (o el elemento correspondiente), los campos `titulo` y `detalle`. El campo `detalle` llega en HTML y debe limpiarse antes de mostrarse en el reloj.

Ejemplo de `detalle` (HTML):

```html
<p>2x10 2x8 2x6 sentadilla</p>
<p>4x 8 peso muerto</p>
```

La limpieza debe extraer el texto útil (listas, párrafos) y descartar etiquetas, estilos y comentarios condicionales de Word/Office.
