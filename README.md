# IAM — H1 Laboratorio reproducible (v0.1)

**Naturaleza:** artefacto experimental para iniciar P01 en Windows 11/PowerShell, sin seleccionar IdP ni modificar el repositorio principal. **H0 y G2 siguen sujetos a ratificación**. No es el backend definitivo.

## Prerrequisitos
- Docker Desktop con Docker Compose v2 funcionando (Linux containers).
- PowerShell 7 o Windows PowerShell 5.1.
- Python 3.10+ en PATH para el chequeo P01.
- Conectividad para descargar la imagen oficial de Keycloak.

## Primer candidato (no selección)
- Adopt/Keycloak como **primer laboratorio de referencia**. La versión inicial del tag se declara en `config/candidates.json` y se debe bloquear a **RepoDigest SHA-256** antes de crear contenedores. Se fija el digest observado, no se afirma previamente que esté disponible.
- `start-dev` sin TLS **solo** en `127.0.0.1:18080`; prohibido desplegar fuera de loopback, usar datos reales o reutilizar credenciales del laboratorio.

## Arranque (desde PowerShell, carpeta del repo)
```powershell
python -m unittest discover -s tests -p 'test_*.py' -v
.\scripts\Initialize-Lab.ps1
.\scripts\Lock-Keycloak.ps1
.\scripts\Start-Lab.ps1
.\scripts\Test-Discovery.ps1
.\scripts\Stop-Lab.ps1
```
La prueba P01 usa `http://localhost:18080/realms/master/.well-known/openid-configuration` y el JWKS declarado. **No ejecuta login ni demuestra conformidad OAuth/OIDC**. Registra RUN-id y hash en `evidence/` (gitignore). Si se desea repetir, iniciar de nuevo y conservar manifest de versiones.

## Qué queda pendiente
H0-DEC-01..06, version/digest de restantes candidatos, CPU/RAM reales, seguridad de host, dos clientes de prueba, carga sintética comparable, P02–P08, resultados de S1–S6 y aprobación ADR-001. Un `docker compose up` exitoso no cierra H1 ni justifica Adopt.

## Guía de seguridad
No subir `.local/`, `evidence/`, credenciales, tokens, llaves o logs crudos a Git. Aunque `.local` está excluido, comprobar `git status` antes de publicar. Docker expone variables de entorno a operadores con privilegios sobre el daemon; para uso distinto de un laboratorio local considerar un gestor de secretos. No exponer el puerto fuera de localhost.

## Fuentes
- IAM-DOC-11 v0.1 y H0 v0.1: método y gates.
- https://www.keycloak.org/getting-started/getting-started-docker
- https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/
