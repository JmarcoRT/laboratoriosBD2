# Proyecto SISCOP: Documento de Negocio

**Autores:**
* Carrascal Castro Priscila
* Ccahuana Quiñonez Judith
* Gil Sixi Alberto Luis
* Guevara Chavez Luis
* Medrano Ayma Nikol
* Nuñez Cardenas Ivan
* Rosales Trinidad Jeanmarco

**Versión:** 1.0  
**Fecha:** 27 de abril del 2026

---

## Historial de Revisiones


| Fecha | Versión | Descripción | Autor |
| :--- | :--- | :--- | :--- |
| 27/04/2026 | 1.0 | Versión preliminar del documento de negocio | Jeanmarco Rosales |

---

## 1. Introducción

### 1.1 Propósito
Describir los procesos principales de atención nutricional en la clínica San Fernando para facilitar su comprensión y análisis.

### 1.2 Alcance
Abarca desde la admisión y búsqueda de historia clínica hasta la evaluación, seguimiento y elaboración de informes del paciente.

### 1.3 Definiciones, siglas y abreviaturas
* **Historia clínica:** Registro físico de información médica y nutricional.
* **IMC:** Índice de Masa Corporal.
* **Nutricionista:** Profesional encargado de la evaluación y recomendaciones alimenticias.

---

## 2. Proceso 1: Admisión de Pacientes (PROC-001)

**Responsable:** Personal administrativo  
**Objetivo:** Registrar o validar la información básica del paciente.

### Actividades

| ID | Actividad | Descripción | Rol | Tipo |
| :-- | :--- | :--- | :--- | :--- |
| 1 | Recibir al paciente | Identificación de nuevo ingreso en recepción | Adm. | Manual |
| 2 | Solicitar DI | Pedir DNI o CE para verificación | Adm. | Manual |
| 3 | Verificar existencia | Revisar si ya cuenta con ficha previa | Adm. | Manual |
| 4 | Registrar datos | Crear nueva ficha si el paciente no existe | Adm. | Manual |
| 5 | Actualizar datos | Validar y corregir datos existentes | Adm. | Manual |
| 6 | Generar turno | Incluir al paciente en la lista de atención | Adm. | Manual |

> **Nota:** Para el "Diagrama de proceso", te recomiendo subir la imagen a una carpeta llamada `/img` en tu repo y referenciarla así: `![Diagrama Admisión](./img/diagrama-proc-001.png)`.

---

## 3. Proceso 2: Búsqueda de Historia Clínica (PROC-002)

**Responsable:** Personal administrativo  
**Objetivo:** Localizar y entregar la historia clínica física.


| ID | Actividad | Datos de Entrada | Datos de Salida |
| :-- | :--- | :--- | :--- |
| 1 | Recibir solicitud | Llegada del paciente | Paciente identificado |
| 3 | Buscar en archivo | Criterios de búsqueda | Historia clínica encontrada/no |
| 5 | Entregar historia | Historia clínica encontrada | Documento disponible para nutricionista |

---

## 4. Proceso 3: Atención Inicial del Paciente (PROC-003)

**Responsable:** Nutricionista  
**Objetivo:** Evaluación inicial y definición de tratamiento.

### Pasos Clave:
1. **Entrevista:** Hábitos y antecedentes.
2. **Mediciones:** Peso, talla y perímetro abdominal.
3. **Cálculos:** Determinación del **IMC**.
4. **Diagnóstico:** Definir estado (bajo peso, sobrepeso, etc.).
5. **Indicaciones:** Entrega de recomendaciones y definición de próximo control.

---

## 6. Proceso 5: Elaboración de Informe (PROC-005)

**Objetivo:** Crear un resumen formal de la evolución a solicitud del paciente o profesional.

1. **Revisión:** Análisis de la historia clínica completa.
2. **Redacción:** Síntesis de tendencias y resultados del tratamiento.
3. **Validación:** Control de calidad antes de la entrega.