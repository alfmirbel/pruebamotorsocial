import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final docsDir = Directory('docs');
  if (!await docsDir.exists()) {
    await docsDir.create(recursive: true);
  }

  final agents = [
    {
      "id": "MotorSocialBridge",
      "type": "orchestrator",
      "path": "../motorsocial/lib/core/motorsocial_bridge/bridge.dart",
      "name": "MotorSocialBridge",
      "capabilities": [
        "Integra todos los módulos del motor social",
        "Reinicialización en runtime",
        "Configuración por contrato JSON"
      ],
      "skills": [
        "Composición de engines/repos inyectables",
        "reinitialize(config, activityRepository, databaseModule)",
        "motorSocialBridgeProvider Riverpod"
      ],
      "authentication": {"owned": false, "delegates_to": ["SocialIdentityEngine", "AuthRepository"]}
    },
    {
      "id": "MotorSocialBridgeNotifier",
      "type": "state",
      "path": "../motorsocial/lib/core/motorsocial_bridge/bridge.dart",
      "name": "MotorSocialBridgeNotifier",
      "capabilities": [
        "Gestiona ciclo de vida global del bridge",
        "Reinicializa componentes en caliente"
      ],
      "skills": ["Riverpod NotifierProvider", "Swap de config y motor en runtime"],
      "authentication": {"owned": false, "inherits_from": "MotorSocialBridge"}
    },
    {
      "id": "SocialIdentityEngine",
      "type": "domain",
      "path": "../motorsocial/lib/identity/social_identity_engine.dart",
      "name": "SocialIdentityEngine",
      "capabilities": [
        "Login / registro parametrizado",
        "Resumen de sesión previa",
        "Configurable por SocialIdentityContract"
      ],
      "skills": [
        "identifierRules validation",
        "defaultRoles resolution",
        "LoginPage/RegisterPage builders",
        "resumeSession()"
      ],
      "authentication": {
        "owned": true,
        "mechanism": "JWT / generic token",
        "state_fields": ["accessToken", "refreshToken", "userId", "role", "availableRoles"],
        "repository_required": "AuthRepository"
      }
    },
    {
      "id": "CatalogEngine",
      "type": "domain",
      "path": "../motorsocial/lib/catalog/engine/catalog_engine.dart",
      "name": "CatalogEngine",
      "capabilities": [
        "Búsqueda paginada y ordenada",
        "CRUD de SocialObject",
        "Exportación configurable",
        "Indexación semántica Qdrant"
      ],
      "skills": [
        "CatalogQuery filters",
        "DocumentExporter PDF",
        "ActivityRepository integration"
      ],
      "authentication": {"owned": false, "governed_by": "creatorId"}
    },
    {
      "id": "SocialGraphEngine",
      "type": "domain",
      "path": "../motorsocial/lib/social_graph/engine/social_graph_engine.dart",
      "name": "SocialGraphEngine",
      "capabilities": [
        "Contactos y relaciones",
        "Grupos y membresías",
        "Invitaciones"
      ],
      "skills": [
        "SocialQuery parametrizada",
        "Límite configurable de miembros",
        "RelationshipRepository / GroupRepository / InvitationRepository"
      ],
      "authentication": {"owned": false, "context_actor": "actorId"}
    },
    {
      "id": "ActivityEngine",
      "type": "domain",
      "path": "../motorsocial/lib/activity/engine/activity_engine.dart",
      "name": "ActivityEngine",
      "capabilities": [
        "Feed unificado",
        "Reacciones y DM",
        "Notificaciones"
      ],
      "skills": [
        "Verbs: view, like, share, message, comment, price_change",
        "ActivityQuery filtering",
        "TTL policy",
        "DirectMessageRepository / ReactionRepository / ShareRepository"
      ],
      "authentication": {"owned": false, "context_actor": "actorId"}
    },
    {
      "id": "SecurityEngine",
      "type": "domain",
      "path": "../motorsocial/lib/security/engine/security_engine.dart",
      "name": "SecurityEngine",
      "capabilities": [
        "Auditoría y detección de anomalías",
        "Tracking de dispositivo",
        "Rate limiting"
      ],
      "skills": ["onLogin hook", "onSuspiciousActivity hook", "SecurityRepository emitEvent"],
      "authentication": {"owned": false, "binds_to": "userId"}
    },
    {
      "id": "DesignEngine",
      "type": "domain",
      "path": "../motorsocial/lib/design/engine/design_engine.dart",
      "name": "DesignEngine",
      "capabilities": ["Temas visuales parametrizados", "Tokens de diseño configurables"],
      "skills": ["DesignTokenSet", "ThemeRepository"],
      "authentication": {"owned": false, "protected_by": "external_session"}
    },
    {
      "id": "LocationEngine",
      "type": "domain",
      "path": "../motorsocial/lib/location/engine/location_engine.dart",
      "name": "LocationEngine",
      "capabilities": [
        "Geolocalización",
        "Lookup de código postal",
        "Selector de ubicación"
      ],
      "skills": ["GPS habilitado por LocationContract", "Map provider configurable"],
      "authentication": {"owned": false}
    },
    {
      "id": "MediaEngine",
      "type": "domain",
      "path": "../motorsocial/lib/media/engine/media_engine.dart",
      "name": "MediaEngine",
      "capabilities": [
        "Biblioteca multimedia",
        "Slideshow y álbumes",
        "Selector de assets"
      ],
      "skills": [
        "maxFileSizeMb / maxDimension",
        "Formatos image: jpg,png,webp | video: mp4,mov,webm",
        "maxAssetsPerOwner",
        "MediaRepository"
      ],
      "authentication": {"owned": false, "bound_to": "owner_document_id"}
    },
    {
      "id": "DatabaseModule",
      "type": "persistence",
      "path": "../motorsocial/lib/core/database/database_module.dart",
      "name": "DatabaseModule",
      "capabilities": [
        "Persistencia adaptable",
        "CouchDB remota",
        "Qdrant vectorial",
        "Memoria RAM (demo)"
      ],
      "skills": ["inMemory() / fromConfig", "Design docs CouchDB", "Colecciones Qdrant con índices payload"],
      "authentication": {
        "owned": true,
        "mode": {"demo": "inMemory", "production": "CouchDB + Qdrant"},
        "notes": "Credenciales esperadas en configuración de producción"
      }
    }
  ];

  final vectorCollections = [
    {
      "id": "motorsocial_users",
      "size": 384,
      "distance": "Cosine",
      "payload_indexes": [
        "creatorId",
        "type",
        "status",
        "visibility",
        "location.country",
        "location.city",
        "createdAt"
      ]
    },
    {
      "id": "motorsocial_objects",
      "size": 384,
      "distance": "Cosine",
      "payload_indexes": [
        "creatorId",
        "type",
        "status",
        "labels.*",
        "location.country",
        "location.city",
        "createdAt"
      ]
    },
    {
      "id": "motorsocial_activities",
      "size": 384,
      "distance": "Cosine",
      "payload_indexes": ["actorId", "verb", "objectType", "createdAt"]
    }
  ];

  final authSchema = {
    "state": "AuthState",
    "fields": {
      "userId": "String?",
      "accessToken": "String?",
      "refreshToken": "String?",
      "role": "RoleProfile?",
      "availableRoles": "List<RoleProfile>"
    },
    "contract": "SocialIdentityContract",
    "default_role": "user",
    "repository": "AuthRepository",
    "session_repository": "SessionRepository",
    "notes": "Demo actual: MemoryAuthRepository sin validación real"
  };

  final output = {
    "agents": agents,
    "vector_collections": vectorCollections,
    "auth_schema": authSchema
  };

  final jsonPath = '${docsDir.path}/AGENT_GUIDE.json';
  await File(jsonPath).writeAsString(const JsonEncoder.withIndent('  ').convert(output));
  print('WROTE $jsonPath');

  try {
    final result = await Process.run('python3', [
      Directory.current.path + '/docs/update_agent_graph.py',
    ]);
    print(result.stdout.toString().trim());
    if (result.exitCode != 0) {
      print(result.stderr.toString().trim());
    }
  } on ProcessException catch (e) {
    print('WARN: graph generator not available: $e');
  }
}
