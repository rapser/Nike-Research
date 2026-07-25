/// Estado de una pantalla que carga datos de la API.
///
/// Antes solo se distinguía vacío / no-vacío leyendo la caché del servicio, que arranca
/// en `[]`. El efecto era que el empty state ("no tienes favoritos") se mostraba
/// *durante* toda la petición —hasta 90s en un cold start de Render— y el usuario creía
/// haber perdido sus datos. `loading` es lo que faltaba para poder distinguir
/// "todavía no sé" de "sé que está vacío".
enum LoadState {
    case loading
    case loaded
    case empty
    case failed
}
