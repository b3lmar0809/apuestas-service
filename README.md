# VidalCasino 2.0 - Apuestas Service

Este repositorio contiene el microservicio **apuestas-service** del proyecto **VidalCasino 2.0**, desarrollado para la evaluación EP3 de Introducción a Herramientas DevOps. Este servicio administra los eventos deportivos, permite registrar apuestas realizadas por los usuarios y simula los resultados de los encuentros para liquidar automáticamente las apuestas.

---

# Descripción general

**apuestas-service** permite consultar eventos deportivos con cuotas 1X2, registrar apuestas, visualizar el historial de apuestas del usuario y simular el resultado de los partidos mediante un modelo de Poisson. Una vez finalizada la simulación, el servicio liquida las apuestas actualizando los saldos correspondientes.

El microservicio comparte la base de datos PostgreSQL y el **JWT_SECRET** con **casino-backend**, validando los tokens emitidos por el backend sin contar con un sistema de autenticación propio.

El servicio se ejecuta dentro del clúster de **Amazon EKS** y se expone únicamente mediante un **Service** de tipo **ClusterIP**, siendo consumido por el backend y el frontend a través de las rutas **/api/apuestas**.

---

# Arquitectura del sistema

El sistema **VidalCasino 2.0** está compuesto por los siguientes servicios:

- casino-frontend: interfaz web pública mediante LoadBalancer.
- casino-backend: backend principal encargado de la autenticación y lógica del negocio.
- bonos-service: gestión de bonos y promociones.
- apuestas-service: administración de eventos deportivos y apuestas.
- estadisticas-service: generación de estadísticas y dashboards.
- postgres: base de datos compartida.

---

# Tecnologías utilizadas

- Python
- FastAPI
- PostgreSQL
- Docker
- Kubernetes
- Amazon EKS
- Amazon ECR
- GitHub Actions
- Horizontal Pod Autoscaler (HPA)
- AWS Academy Learner Lab

---

# Endpoints disponibles

| Método | Endpoint | Descripción |
|---------|----------|-------------|
| GET | `/api/apuestas/eventos` | Obtiene los eventos deportivos disponibles con sus cuotas. |
| POST | `/api/apuestas` | Registra una nueva apuesta y descuenta el saldo correspondiente. |
| GET | `/api/apuestas/mis-apuestas` | Consulta el historial de apuestas del usuario autenticado. |
| POST | `/api/apuestas/eventos/{id}/simular` | Simula el resultado del partido y liquida las apuestas. |
| POST | `/api/apuestas/reiniciar` | Regenera la cartelera de eventos deportivos. |

---

# Endpoints de salud

El servicio incorpora sondas de salud para Kubernetes:

- `/livez`
- `/readyz`

### `/livez`

Verifica que el proceso de FastAPI continúa ejecutándose correctamente.

### `/readyz`

Comprueba que el servicio se encuentra listo para recibir tráfico y que mantiene conectividad con la base de datos PostgreSQL.

---

# Despliegue en Kubernetes

Los manifiestos del servicio se encuentran en:

```text
k8s/
```

Archivos principales:

```text
k8s/deployment.yaml
k8s/service.yaml
k8s/hpa.yaml
```

El servicio se despliega con **2 réplicas** y se expone internamente mediante un **Service** de tipo **ClusterIP** en el puerto **8005**.

Además, incorpora un **Horizontal Pod Autoscaler (HPA)** que incrementa o reduce automáticamente la cantidad de Pods según el consumo de CPU.

---

# CI/CD

El despliegue automático se encuentra definido en:

```text
.github/workflows/deploy.yml
```

El workflow se ejecuta al realizar un **push** sobre la rama **deploy**.

El pipeline realiza las siguientes tareas:

- Descarga del código fuente.
- Configuración de credenciales de AWS Academy.
- Inicio de sesión en Amazon ECR.
- Construcción de la imagen Docker.
- Publicación de la imagen con los tags **latest**, **v1.0.1** y el SHA del commit.
- Conexión al clúster de Amazon EKS.
- Actualización del Deployment.
- Verificación del rollout.
- Validación del estado de los Pods.

---

# Ejecución local

Crear el entorno virtual:

```bash
python -m venv .venv
```

Activarlo:

**Linux / macOS**

```bash
source .venv/bin/activate
```

**Windows**

```powershell
.venv\Scripts\activate
```

Instalar dependencias:

```bash
pip install -r requirements.txt
```

Configurar las variables de entorno copiando:

```text
.env.example
```

como

```text
.env
```

---

# Comandos de verificación

```bash
kubectl get deployment apuestas-service

kubectl get svc apuestas-service

kubectl get hpa apuestas-service-hpa

kubectl get pods -l app=apuestas-service -o wide

kubectl describe deployment apuestas-service
```

---

# Estado esperado

- Deployment disponible con 2 réplicas.
- Service interno de tipo ClusterIP.
- Horizontal Pod Autoscaler activo.
- Pods en estado **Running**.
- Imagen desplegada desde Amazon ECR.
- Pipeline de GitHub Actions ejecutado correctamente.
- Servicio respondiendo correctamente a las rutas **/livez**, **/readyz**, **/api/apuestas/eventos**, **/api/apuestas/mis-apuestas** y al registro y liquidación de apuestas.
