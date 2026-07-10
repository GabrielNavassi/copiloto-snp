# Copiloto SNP — Entorno de IA Local

Asistente de inteligencia artificial **100% local** especializado en el Sistema Nacional de Planificación (SNP) de Guatemala. Responde consultas técnicas con base en los documentos oficiales de los 7 ciclos del SNP, citando documento y página, con un grafo de conocimiento interactivo como interfaz — sin internet y sin que ningún dato salga del equipo del usuario.

Producto del taller final (Sprint 3) del **I Encuentro Nacional de Planificación 2026**, primer entregable de la **Red Nacional de Planificadores**.
Desarrollado por la DFCSNP — SEGEPLAN, con aportes de Red Ciudadana.

## Arquitectura

| Componente | Tecnología |
|---|---|
| Motor de modelos | [Ollama](https://ollama.com) (local) |
| Modelo de lenguaje | llama3.2:3b (intercambiable: Gemma, Qwen, GLM…) |
| Embeddings | nomic-embed-text |
| RAG y grafo | Aplicación en un solo archivo HTML (D3.js, pdf.js, IndexedDB) |
| Distribución | Kit USB con instalador automático (`INSTALAR.bat`) |

## Instalación rápida (desarrollo)

1. Instalar [Ollama](https://ollama.com/download/windows) y ejecutar:
   ```
   ollama pull llama3.2:3b
   ollama pull nomic-embed-text
   setx OLLAMA_ORIGINS "*"
   ```
   Reiniciar Ollama después del último comando.
2. Abrir `4_Aplicacion/Copiloto_SNP.html` en Chrome o Edge.
3. Cargar los PDF del SNP (o importar un contexto vectorizado) y consultar.

Para el kit USB completo de distribución (instalador silencioso + modelos sin descarga), ver `5_Documentacion/`.

## Qué NO contiene este repositorio

Por límites de tamaño de GitHub y licencias de terceros:
- `OllamaSetup.exe` → descargar de ollama.com
- Carpeta de modelos (~2.3 GB) → generar con `ollama pull` (instrucciones en `2_Modelos_IA/`)
- `corpus_vectorizado.json` → se genera con el botón «Exportar contexto» de la app

## Cómo contribuir

1. Abrir un *issue* describiendo la mejora o el problema (con capturas si aplica).
2. Para cambios de código: *fork* → rama descriptiva → *pull request* con explicación breve.
3. Para proponer documentos del corpus: abrir un *issue* con el ciclo del SNP correspondiente, el nombre oficial del documento y su fuente.

## Licencia

Por definir con SEGEPLAN. Componentes de terceros: Ollama (MIT), D3.js (ISC), pdf.js (Apache 2.0), modelos según su licencia respectiva.
