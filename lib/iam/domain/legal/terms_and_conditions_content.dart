/// Structured legal section for TerraTech Terms and Conditions.
class TermsSection {
  const TermsSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// Official Terms and Conditions text aligned between TerraTech Mobile App
/// and `LandingPage-TerraTech` (`terratech-terminos-y-condiciones.pdf`).
abstract final class TermsAndConditionsContent {
  static const String documentTitle = 'Términos y Condiciones de TerraTech';
  static const String subtitle =
      'Condiciones de uso de la plataforma web y aplicación móvil TerraTech';
  static const String lastUpdated =
      'Última actualización: 24 de noviembre de 2026';
  static const String providerNotice = 'Desarrollado por NovaTech · TerraTech';

  static const List<TermsSection> sections = <TermsSection>[
    TermsSection(
      title: '1. Objeto y aceptación de las condiciones',
      body:
          'Estas condiciones regulan el acceso y uso del ecosistema TerraTech, '
          'desarrollado por NovaTech, incluyendo la aplicación móvil y los '
          'servicios conectados de monitoreo, catálogo y comunidad agrícola. '
          'Al registrarte y utilizar la plataforma, aceptas íntegramente estas '
          'condiciones de servicio.',
    ),
    TermsSection(
      title: '2. Descripción del servicio',
      body:
          'TerraTech permite gestionar perfiles agrícolas y parcelas, consultar '
          'mediciones IoT de humedad, temperatura y nutrientes del suelo, '
          'explorar el catálogo comercial con trazabilidad verificada, '
          'configurar preferencias de interés y recibir notificaciones sobre '
          'productos, disponibilidad y alertas de demanda.',
    ),
    TermsSection(
      title: '3. Registro y uso de la cuenta',
      body:
          'Para crear una cuenta debes proporcionar información veraz, mantener '
          'la confidencialidad de tus credenciales de acceso y utilizar '
          'únicamente cuentas, parcelas, inventarios y dispositivos sobre los '
          'que cuentes con autorización legítima. Eres responsable de toda '
          'actividad realizada desde tu sesión autenticada.',
    ),
    TermsSection(
      title: '4. Uso aceptable del servicio',
      body:
          'Te comprometes a utilizar TerraTech de manera lícita y respetuosa. '
          'No está permitido intentar acceder sin autorización a sistemas o '
          'datos de otros usuarios, interferir con la disponibilidad de la '
          'plataforma, enviar reseñas o alertas fraudulentas ni suplantar la '
          'identidad de otros productores o del equipo NovaTech.',
    ),
    TermsSection(
      title: '5. Propiedad intelectual',
      body:
          'El software, interfaces, textos, marcas, logotipos y recursos '
          'visuales de TerraTech pertenecen a NovaTech o se utilizan bajo sus '
          'respectivas licencias. El acceso a la aplicación o al sitio web no '
          'transfiere derechos de propiedad intelectual al usuario.',
    ),
    TermsSection(
      title: '6. Privacidad y tratamiento de datos',
      body:
          'Los datos personales y agrícolas registrados (nombre completo, '
          'correo electrónico, teléfono de contacto, ubicación de fundo, '
          'preferencias de productos y tokens de sesión almacenados de forma '
          'cifrada en el dispositivo) se emplean exclusivamente para prestar '
          'las funcionalidades contratadas y proteger el acceso a tu cuenta.',
    ),
    TermsSection(
      title: '7. Limitación de responsabilidad',
      body:
          'Las métricas de sensores, pronósticos y alertas comerciales actúan '
          'como herramienta de apoyo y no sustituyen el criterio de un '
          'profesional agrónomo ni garantizan rendimientos comerciales. Las '
          'lecturas pueden variar según calibración, conectividad y vigencia.',
    ),
    TermsSection(
      title: '8. Cambios a las condiciones',
      body:
          'NovaTech podrá actualizar estos Términos y Condiciones para '
          'reflejar mejoras funcionales o cambios normativos. La fecha de '
          'última actualización permanecerá visible en la aplicación y en el '
          'documento PDF publicado en la landing page.',
    ),
    TermsSection(
      title: '9. Contacto y soporte',
      body:
          'Si tienes consultas sobre estos términos, el tratamiento de tu '
          'cuenta o el funcionamiento de TerraTech, puedes comunicarte con '
          'el equipo NovaTech mediante los canales oficiales de atención y el '
          'enlace de contacto disponible en la landing page.',
    ),
  ];
}
