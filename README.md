# 📚 SII UTH - Módulo de Admisión

**Sistema de Información Institucional de la Universidad Tecnológica de Huejotzingo (SII UTH)**  
**Módulo: Admisión**  
**Frontend:** Flutter | **Backend/API:** Laravel  

---

## 📝 Descripción

Este repositorio corresponde al **módulo de Admisión** del **SII UTH**, una plataforma digital que busca optimizar y homologar trámites institucionales de la Universidad Tecnológica de Huejotzingo.  

El módulo de Admisión tiene como objetivo centralizar y automatizar el registro de nuevos estudiantes, evitando la **recaptura de datos**, reduciendo los pasos burocráticos y conectando de forma segura con otros sistemas internos y externos (Servicios Escolares, SEP, RENAPO).

---

## 🎯 Objetivo del módulo

- **Digitalizar el proceso de admisión** para estudiantes de nuevo ingreso.  
- **Eliminar la recaptura de información** entre departamentos.  
- **Validar documentos y datos** con fuentes oficiales (RENAPO, SEP).  
- **Garantizar trazabilidad** con notificaciones y comprobantes digitales (QR).  
- **Alinear procesos** a la Ley Nacional de Simplificación y Digitalización y el Plan México.

---

## 🛠️ Tecnologías

### **Frontend**
- [Flutter](https://flutter.dev/) (Aplicación móvil y web responsiva)
  - Gestión de formularios dinámicos
  - Integración con API REST
  - Notificaciones en tiempo real

### **Backend/API**
- [Laravel](https://laravel.com/) 11 (API REST)
  - Autenticación JWT / Laravel Sanctum
  - Validación de documentos
  - Integración con APIs externas (RENAPO, SEP)
  - Arquitectura MVC y controladores de servicio
  - Base de datos: MySQL/MariaDB

---

## 🔗 Integraciones previstas

- **RENAPO** → Validación de CURP y datos personales  
- **SEP** → Verificación de historial académico  
- **Correo institucional UTH** → Envío de confirmaciones y notificaciones  
- **Sistema interno SII UTH** → Interoperabilidad con módulos de Servicios Escolares y Finanzas

---