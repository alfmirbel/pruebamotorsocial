# SDD - Social Graph
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/motorsocial/social_graph`

## 1. Requerimientos Ubicuarios

1. El sistema deberá modelar relaciones, grupos e invitaciones sociales.
2. El sistema deberá exponer contratos para contactos y grafos sociales.
3. El sistema deberá ofrecer páginas de contactos, grupos e invitaciones.

## 2. Requerimientos Controlados por Eventos

1. Cuando se solicite agregar un contacto, el sistema deberá crear una relación social.
2. Cuando se envíe una invitación, el sistema deberá persistirla y notificar al destinatario.
3. Cuando se acepte una invitación, el sistema deberá convertirla en relación y grupo.
4. Cuando se inicialice `SocialGraphEngine`, el sistema deberá cargar relaciones iniciales del repositorio.

## 3. Requerimientos Controlados por Estados

1. Mientras el usuario tenga invitaciones pendientes, el sistema deberá mostrarlas en `InvitationsPage`.
2. Mientras el usuario pertenezca a grupos, el sistema deberá listarlos en `GroupPages`.
3. Mientras una relación esté activa, el sistema deberá reflejarla en `ContactsPage`.

## 4. Requerimientos de Comportamiento No Deseado

1. Si la invitación ya fue aceptada, entonces el sistema deberá evitar duplicados.
2. Si el grupo no existe, entonces el sistema deberá exponer un estado vacío o de error controlado.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `social_graph`, el sistema deberá exponer `SocialGraphEngine` y contratos de grafos.
2. Donde el sistema incluya `invitations_repository`, el sistema deberá persistir invitaciones.
3. Donde el sistema incluya widgets sociales, el sistema deberá proveer tiles reutilizables para contactos y grupos.
