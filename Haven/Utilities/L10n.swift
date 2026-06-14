import Foundation

// MARK: - Localization helper
// Usage: L10n.t(.tabFindHelp) — reads from AppState.shared.preferredLanguage

struct L10n {
    static func t(_ key: Key) -> String {
        let lang = AppState.shared.preferredLanguage
        return table[lang]?[key] ?? table[.english]![key]!
    }

    enum Key {
        // Tabs
        case tabFindHelp, tabMyDocs, tabPathway, tabAskAI, tabProfile
        // Nav titles
        case navHousingPathway, navAIAssistant, navMyProfile, navMyDocuments, navSupportGroups
        // Login
        case welcomeToHaven, loginSubtitle
        case aboutYou, yourSituation, yourArea
        case fullName, phoneNumber, emailOptional, occupation, homeStatus, cityZip
        case preferredLanguage, locationHint, privacyNote, getStarted
        case namePlaceholder, phonePlaceholder, emailPlaceholder, cityPlaceholder
        // Common
        case done, cancel, clear, signOut, errorTitle, ok
        // Map
        case searchPlaceholder, getDirections, callNumber, whatIsThis, reExplain
        // AI
        case howCanIHelp, askAboutHousing, askAQuestion
        case tools, translateDoc, safeProfile, caseSummary
        case askAnything, typingIndicator
        // Profile
        case phone, area, showingNearby, findSupportGroup, supportGroupSub
        // Vault
        case addDocument, noDocuments, noDocumentsHint
        // Pathway
        case aiRoadmap, generateRoadmap, regenerate, housingGoalPlaceholder
        case stepsComplete, reachedStableHousing, askAIGuidance
        // Support groups
        case howToJoin, visitWebsite, national
    }

    // MARK: - English (source of truth)
    private static let en: [Key: String] = [
        .tabFindHelp: "Find Help",         .tabMyDocs: "My Docs",
        .tabPathway: "Pathway",            .tabAskAI: "Ask AI",
        .tabProfile: "Profile",
        .navHousingPathway: "Housing Pathway",
        .navAIAssistant: "AI Assistant",   .navMyProfile: "My Profile",
        .navMyDocuments: "My Documents",   .navSupportGroups: "Support Groups",
        .welcomeToHaven: "Welcome to Haven",
        .loginSubtitle: "Your guide to housing support and local resources.",
        .aboutYou: "About You",            .yourSituation: "Your Situation",
        .yourArea: "Your Area",
        .fullName: "Full Name",            .phoneNumber: "Phone Number",
        .emailOptional: "Email (optional)",.occupation: "Occupation",
        .homeStatus: "Current Home Status",.cityZip: "City, State or ZIP Code",
        .preferredLanguage: "Preferred Language",
        .locationHint: "Haven will show all resources and sort them by distance from your area.",
        .privacyNote: "Your information stays on your device and is used only to personalize Haven.",
        .getStarted: "Get Started",
        .namePlaceholder: "Your name",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "you@gmail.com",
        .cityPlaceholder: "e.g. Austin, TX or 78701",
        .done: "Done",                     .cancel: "Cancel",
        .clear: "Clear",                   .signOut: "Sign Out",
        .errorTitle: "Error",              .ok: "OK",
        .searchPlaceholder: "Search shelter, food, healthcare…",
        .getDirections: "Get Directions",  .callNumber: "Call",
        .whatIsThis: "What is this place?",.reExplain: "Re-explain",
        .howCanIHelp: "How can I help you?",
        .askAboutHousing: "Ask about housing, documents, or services near you.",
        .askAQuestion: "Ask a question",
        .tools: "Tools",                   .translateDoc: "Translate",
        .safeProfile: "Safe Profile",      .caseSummary: "Case Summary",
        .askAnything: "Ask anything about housing…",
        .typingIndicator: "Thinking…",
        .phone: "Phone",                   .area: "Primary Area",
        .showingNearby: "Showing all resources, sorted by your area",
        .findSupportGroup: "Find a Support Group",
        .supportGroupSub: "Browse real organizations and learn how to apply or join.",
        .addDocument: "Add Document",      .noDocuments: "No documents yet",
        .noDocumentsHint: "Tap + to add your first document.",
        .aiRoadmap: "AI Roadmap",          .generateRoadmap: "Generate My Roadmap",
        .regenerate: "Regenerate",
        .housingGoalPlaceholder: "e.g. Get into transitional housing within 60 days",
        .stepsComplete: "steps complete",  .reachedStableHousing: "You've reached stable housing!",
        .askAIGuidance: "Ask AI for guidance",
        .howToJoin: "How to Apply / Join", .visitWebsite: "Visit Website",
        .national: "National"
    ]

    // MARK: - Spanish
    private static let es: [Key: String] = [
        .tabFindHelp: "Buscar Ayuda",      .tabMyDocs: "Mis Docs",
        .tabPathway: "Camino",             .tabAskAI: "Preguntar IA",
        .tabProfile: "Perfil",
        .navHousingPathway: "Camino de Vivienda",
        .navAIAssistant: "Asistente IA",   .navMyProfile: "Mi Perfil",
        .navMyDocuments: "Mis Documentos", .navSupportGroups: "Grupos de Apoyo",
        .welcomeToHaven: "Bienvenido a Haven",
        .loginSubtitle: "Tu guía para apoyo de vivienda y recursos locales.",
        .aboutYou: "Sobre Ti",             .yourSituation: "Tu Situación",
        .yourArea: "Tu Área",
        .fullName: "Nombre Completo",      .phoneNumber: "Número de Teléfono",
        .emailOptional: "Correo (opcional)",.occupation: "Ocupación",
        .homeStatus: "Estado de Vivienda", .cityZip: "Ciudad, Estado o Código Postal",
        .preferredLanguage: "Idioma Preferido",
        .locationHint: "Haven mostrará todos los recursos ordenados por distancia desde tu área.",
        .privacyNote: "Tu información permanece en tu dispositivo y solo se usa para personalizar Haven.",
        .getStarted: "Comenzar",
        .namePlaceholder: "Tu nombre",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "tú@gmail.com",
        .cityPlaceholder: "ej. Miami, FL o 33101",
        .done: "Listo",                    .cancel: "Cancelar",
        .clear: "Borrar",                  .signOut: "Cerrar Sesión",
        .errorTitle: "Error",              .ok: "OK",
        .searchPlaceholder: "Buscar refugio, comida, salud…",
        .getDirections: "Obtener Dirección",.callNumber: "Llamar",
        .whatIsThis: "¿Qué es este lugar?",.reExplain: "Volver a explicar",
        .howCanIHelp: "¿Cómo puedo ayudarte?",
        .askAboutHousing: "Pregunta sobre vivienda, documentos o servicios cercanos.",
        .askAQuestion: "Hacer una pregunta",
        .tools: "Herramientas",            .translateDoc: "Traducir",
        .safeProfile: "Perfil Seguro",     .caseSummary: "Resumen del Caso",
        .askAnything: "Pregunta sobre vivienda…",
        .typingIndicator: "Pensando…",
        .phone: "Teléfono",                .area: "Área Principal",
        .showingNearby: "Mostrando todos los recursos, ordenados por tu área",
        .findSupportGroup: "Encontrar Grupo de Apoyo",
        .supportGroupSub: "Explora organizaciones reales y aprende cómo unirte.",
        .addDocument: "Añadir Documento",  .noDocuments: "Sin documentos aún",
        .noDocumentsHint: "Toca + para añadir tu primer documento.",
        .aiRoadmap: "Hoja de Ruta IA",     .generateRoadmap: "Generar Mi Hoja de Ruta",
        .regenerate: "Regenerar",
        .housingGoalPlaceholder: "ej. Conseguir vivienda en 60 días",
        .stepsComplete: "pasos completados",.reachedStableHousing: "¡Has alcanzado una vivienda estable!",
        .askAIGuidance: "Pedir orientación a IA",
        .howToJoin: "Cómo Solicitar / Unirse",.visitWebsite: "Visitar Sitio Web",
        .national: "Nacional"
    ]

    // MARK: - Chinese (Simplified)
    private static let zh: [Key: String] = [
        .tabFindHelp: "寻找帮助",           .tabMyDocs: "我的文档",
        .tabPathway: "路径",               .tabAskAI: "问AI",
        .tabProfile: "个人资料",
        .navHousingPathway: "住房路径",
        .navAIAssistant: "AI助手",          .navMyProfile: "我的资料",
        .navMyDocuments: "我的文件",         .navSupportGroups: "支持小组",
        .welcomeToHaven: "欢迎来到 Haven",
        .loginSubtitle: "您的住房支持和本地资源指南。",
        .aboutYou: "关于您",               .yourSituation: "您的情况",
        .yourArea: "您的地区",
        .fullName: "全名",                 .phoneNumber: "电话号码",
        .emailOptional: "邮箱（可选）",      .occupation: "职业",
        .homeStatus: "当前住房状况",         .cityZip: "城市、州或邮编",
        .preferredLanguage: "首选语言",
        .locationHint: "Haven 将显示所有资源，并按您所在地区的距离排序。",
        .privacyNote: "您的信息保存在设备上，仅用于个性化 Haven。",
        .getStarted: "开始",
        .namePlaceholder: "您的姓名",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "您@gmail.com",
        .cityPlaceholder: "例如：旧金山, CA 或 94102",
        .done: "完成",                     .cancel: "取消",
        .clear: "清除",                    .signOut: "退出登录",
        .errorTitle: "错误",               .ok: "好",
        .searchPlaceholder: "搜索庇护所、食物、医疗…",
        .getDirections: "获取路线",          .callNumber: "拨打",
        .whatIsThis: "这是什么地方？",        .reExplain: "重新解释",
        .howCanIHelp: "我能帮您什么？",
        .askAboutHousing: "询问住房、文件或附近服务的问题。",
        .askAQuestion: "提问",
        .tools: "工具",                    .translateDoc: "翻译",
        .safeProfile: "安全档案",           .caseSummary: "案例摘要",
        .askAnything: "询问有关住房的任何问题…",
        .typingIndicator: "思考中…",
        .phone: "电话",                    .area: "主要地区",
        .showingNearby: "显示所有资源，按您所在地区排序",
        .findSupportGroup: "寻找支持小组",
        .supportGroupSub: "浏览真实组织并了解如何申请或加入。",
        .addDocument: "添加文件",           .noDocuments: "暂无文件",
        .noDocumentsHint: "点击 + 添加第一个文件。",
        .aiRoadmap: "AI路线图",             .generateRoadmap: "生成我的路线图",
        .regenerate: "重新生成",
        .housingGoalPlaceholder: "例如：在60天内进入过渡性住房",
        .stepsComplete: "步骤已完成",        .reachedStableHousing: "您已实现稳定住房！",
        .askAIGuidance: "向AI寻求指导",
        .howToJoin: "如何申请/加入",         .visitWebsite: "访问网站",
        .national: "全国性"
    ]

    // MARK: - Hindi
    private static let hi: [Key: String] = [
        .tabFindHelp: "सहायता खोजें",      .tabMyDocs: "मेरे दस्तावेज़",
        .tabPathway: "मार्ग",              .tabAskAI: "AI से पूछें",
        .tabProfile: "प्रोफाइल",
        .navHousingPathway: "आवास मार्ग",
        .navAIAssistant: "AI सहायक",       .navMyProfile: "मेरी प्रोफाइल",
        .navMyDocuments: "मेरे दस्तावेज़",  .navSupportGroups: "सहायता समूह",
        .welcomeToHaven: "Haven में आपका स्वागत है",
        .loginSubtitle: "आवास सहायता और स्थानीय संसाधनों के लिए आपका मार्गदर्शक।",
        .aboutYou: "आपके बारे में",         .yourSituation: "आपकी स्थिति",
        .yourArea: "आपका क्षेत्र",
        .fullName: "पूरा नाम",             .phoneNumber: "फ़ोन नंबर",
        .emailOptional: "ईमेल (वैकल्पिक)", .occupation: "व्यवसाय",
        .homeStatus: "वर्तमान आवास स्थिति",.cityZip: "शहर, राज्य या ZIP कोड",
        .preferredLanguage: "पसंदीदा भाषा",
        .locationHint: "Haven आपके क्षेत्र से दूरी के अनुसार सभी संसाधन दिखाएगा।",
        .privacyNote: "आपकी जानकारी आपके डिवाइस पर रहती है और केवल Haven को व्यक्तिगत बनाने के लिए उपयोग की जाती है।",
        .getStarted: "शुरू करें",
        .namePlaceholder: "आपका नाम",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "आप@gmail.com",
        .cityPlaceholder: "जैसे: दिल्ली या 110001",
        .done: "हो गया",                  .cancel: "रद्द करें",
        .clear: "साफ़ करें",               .signOut: "साइन आउट",
        .errorTitle: "त्रुटि",             .ok: "ठीक है",
        .searchPlaceholder: "आश्रय, भोजन, स्वास्थ्य खोजें…",
        .getDirections: "दिशा निर्देश पाएं",.callNumber: "कॉल करें",
        .whatIsThis: "यह जगह क्या है?",    .reExplain: "फिर से समझाएं",
        .howCanIHelp: "मैं आपकी कैसे सहायता कर सकता हूं?",
        .askAboutHousing: "आवास, दस्तावेज़ या नज़दीकी सेवाओं के बारे में पूछें।",
        .askAQuestion: "एक सवाल पूछें",
        .tools: "उपकरण",                  .translateDoc: "अनुवाद करें",
        .safeProfile: "सुरक्षित प्रोफाइल", .caseSummary: "केस सारांश",
        .askAnything: "आवास के बारे में कुछ भी पूछें…",
        .typingIndicator: "सोच रहा हूं…",
        .phone: "फ़ोन",                    .area: "प्राथमिक क्षेत्र",
        .showingNearby: "आपके क्षेत्र के अनुसार सभी संसाधन दिखाए जा रहे हैं",
        .findSupportGroup: "सहायता समूह खोजें",
        .supportGroupSub: "वास्तविक संगठन ब्राउज़ करें और आवेदन करना सीखें।",
        .addDocument: "दस्तावेज़ जोड़ें",   .noDocuments: "अभी तक कोई दस्तावेज़ नहीं",
        .noDocumentsHint: "+ टैप करें अपना पहला दस्तावेज़ जोड़ने के लिए।",
        .aiRoadmap: "AI रोडमैप",           .generateRoadmap: "मेरा रोडमैप बनाएं",
        .regenerate: "फिर से बनाएं",
        .housingGoalPlaceholder: "जैसे: 60 दिनों में स्थायी आवास पाना",
        .stepsComplete: "चरण पूर्ण",       .reachedStableHousing: "आपने स्थायी आवास प्राप्त कर लिया!",
        .askAIGuidance: "AI से मार्गदर्शन लें",
        .howToJoin: "आवेदन / शामिल होने का तरीका",.visitWebsite: "वेबसाइट देखें",
        .national: "राष्ट्रीय"
    ]

    // MARK: - Arabic
    private static let ar: [Key: String] = [
        .tabFindHelp: "البحث عن مساعدة",   .tabMyDocs: "مستنداتي",
        .tabPathway: "المسار",             .tabAskAI: "اسأل الذكاء",
        .tabProfile: "الملف الشخصي",
        .navHousingPathway: "مسار الإسكان",
        .navAIAssistant: "مساعد الذكاء",   .navMyProfile: "ملفي الشخصي",
        .navMyDocuments: "مستنداتي",        .navSupportGroups: "مجموعات الدعم",
        .welcomeToHaven: "مرحباً بك في Haven",
        .loginSubtitle: "دليلك لدعم السكن والموارد المحلية.",
        .aboutYou: "عنك",                  .yourSituation: "وضعك",
        .yourArea: "منطقتك",
        .fullName: "الاسم الكامل",          .phoneNumber: "رقم الهاتف",
        .emailOptional: "البريد الإلكتروني (اختياري)",.occupation: "المهنة",
        .homeStatus: "الوضع السكني الحالي",.cityZip: "المدينة أو الرمز البريدي",
        .preferredLanguage: "اللغة المفضلة",
        .locationHint: "سيعرض Haven جميع الموارد مرتبة حسب المسافة من منطقتك.",
        .privacyNote: "تبقى معلوماتك على جهازك وتُستخدم فقط لتخصيص Haven.",
        .getStarted: "ابدأ",
        .namePlaceholder: "اسمك",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "أنت@gmail.com",
        .cityPlaceholder: "مثال: الرياض أو 11564",
        .done: "تم",                       .cancel: "إلغاء",
        .clear: "مسح",                     .signOut: "تسجيل الخروج",
        .errorTitle: "خطأ",                .ok: "حسناً",
        .searchPlaceholder: "البحث عن مأوى، طعام، رعاية صحية…",
        .getDirections: "الحصول على الاتجاهات",.callNumber: "اتصال",
        .whatIsThis: "ما هذا المكان؟",     .reExplain: "إعادة الشرح",
        .howCanIHelp: "كيف يمكنني مساعدتك؟",
        .askAboutHousing: "اسأل عن السكن والمستندات والخدمات القريبة.",
        .askAQuestion: "اطرح سؤالاً",
        .tools: "الأدوات",                 .translateDoc: "ترجمة",
        .safeProfile: "ملف آمن",           .caseSummary: "ملخص الحالة",
        .askAnything: "اسأل أي شيء عن السكن…",
        .typingIndicator: "جاري التفكير…",
        .phone: "الهاتف",                  .area: "المنطقة الرئيسية",
        .showingNearby: "عرض جميع الموارد مرتبة حسب منطقتك",
        .findSupportGroup: "العثور على مجموعة دعم",
        .supportGroupSub: "تصفح المنظمات الحقيقية وتعلم كيفية التقدم أو الانضمام.",
        .addDocument: "إضافة مستند",        .noDocuments: "لا توجد مستندات بعد",
        .noDocumentsHint: "اضغط + لإضافة مستندك الأول.",
        .aiRoadmap: "خريطة طريق الذكاء",   .generateRoadmap: "إنشاء خريطة طريقي",
        .regenerate: "إعادة الإنشاء",
        .housingGoalPlaceholder: "مثال: الحصول على سكن انتقالي خلال 60 يوماً",
        .stepsComplete: "خطوات مكتملة",    .reachedStableHousing: "لقد حققت سكناً مستقراً!",
        .askAIGuidance: "اطلب توجيهاً من الذكاء",
        .howToJoin: "كيفية التقدم / الانضمام",.visitWebsite: "زيارة الموقع",
        .national: "وطني"
    ]

    // MARK: - French
    private static let fr: [Key: String] = [
        .tabFindHelp: "Trouver de l'aide", .tabMyDocs: "Mes Docs",
        .tabPathway: "Chemin",             .tabAskAI: "Demander IA",
        .tabProfile: "Profil",
        .navHousingPathway: "Parcours de Logement",
        .navAIAssistant: "Assistant IA",   .navMyProfile: "Mon Profil",
        .navMyDocuments: "Mes Documents",  .navSupportGroups: "Groupes de Soutien",
        .welcomeToHaven: "Bienvenue sur Haven",
        .loginSubtitle: "Votre guide pour le soutien au logement et les ressources locales.",
        .aboutYou: "À Propos de Vous",     .yourSituation: "Votre Situation",
        .yourArea: "Votre Zone",
        .fullName: "Nom Complet",          .phoneNumber: "Numéro de Téléphone",
        .emailOptional: "E-mail (facultatif)",.occupation: "Profession",
        .homeStatus: "Situation de Logement",.cityZip: "Ville, État ou Code Postal",
        .preferredLanguage: "Langue Préférée",
        .locationHint: "Haven affichera toutes les ressources triées par distance depuis votre zone.",
        .privacyNote: "Vos informations restent sur votre appareil et ne servent qu'à personnaliser Haven.",
        .getStarted: "Commencer",
        .namePlaceholder: "Votre nom",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "vous@gmail.com",
        .cityPlaceholder: "ex. Paris ou 75001",
        .done: "Terminé",                  .cancel: "Annuler",
        .clear: "Effacer",                 .signOut: "Se Déconnecter",
        .errorTitle: "Erreur",             .ok: "OK",
        .searchPlaceholder: "Rechercher abri, nourriture, santé…",
        .getDirections: "Obtenir l'itinéraire",.callNumber: "Appeler",
        .whatIsThis: "Qu'est-ce que c'est ?", .reExplain: "Ré-expliquer",
        .howCanIHelp: "Comment puis-je vous aider ?",
        .askAboutHousing: "Posez des questions sur le logement, documents ou services proches.",
        .askAQuestion: "Poser une question",
        .tools: "Outils",                  .translateDoc: "Traduire",
        .safeProfile: "Profil Sécurisé",   .caseSummary: "Résumé du Cas",
        .askAnything: "Posez n'importe quelle question sur le logement…",
        .typingIndicator: "Réflexion…",
        .phone: "Téléphone",               .area: "Zone Principale",
        .showingNearby: "Affichage de toutes les ressources triées par votre zone",
        .findSupportGroup: "Trouver un Groupe de Soutien",
        .supportGroupSub: "Parcourez des organisations réelles et apprenez comment rejoindre.",
        .addDocument: "Ajouter un Document",.noDocuments: "Aucun document pour l'instant",
        .noDocumentsHint: "Appuyez sur + pour ajouter votre premier document.",
        .aiRoadmap: "Feuille de Route IA", .generateRoadmap: "Générer Ma Feuille de Route",
        .regenerate: "Régénérer",
        .housingGoalPlaceholder: "ex. Intégrer un logement de transition en 60 jours",
        .stepsComplete: "étapes terminées", .reachedStableHousing: "Vous avez atteint un logement stable !",
        .askAIGuidance: "Demander des conseils à l'IA",
        .howToJoin: "Comment Postuler / Rejoindre",.visitWebsite: "Visiter le Site",
        .national: "National"
    ]

    // MARK: - Portuguese
    private static let pt: [Key: String] = [
        .tabFindHelp: "Encontrar Ajuda",   .tabMyDocs: "Meus Docs",
        .tabPathway: "Caminho",            .tabAskAI: "Perguntar IA",
        .tabProfile: "Perfil",
        .navHousingPathway: "Caminho de Habitação",
        .navAIAssistant: "Assistente IA",  .navMyProfile: "Meu Perfil",
        .navMyDocuments: "Meus Documentos",.navSupportGroups: "Grupos de Apoio",
        .welcomeToHaven: "Bem-vindo ao Haven",
        .loginSubtitle: "Seu guia para suporte habitacional e recursos locais.",
        .aboutYou: "Sobre Você",           .yourSituation: "Sua Situação",
        .yourArea: "Sua Área",
        .fullName: "Nome Completo",        .phoneNumber: "Número de Telefone",
        .emailOptional: "E-mail (opcional)",.occupation: "Ocupação",
        .homeStatus: "Status de Moradia Atual",.cityZip: "Cidade, Estado ou CEP",
        .preferredLanguage: "Idioma Preferido",
        .locationHint: "Haven mostrará todos os recursos classificados por distância da sua área.",
        .privacyNote: "Suas informações ficam no seu dispositivo e são usadas apenas para personalizar o Haven.",
        .getStarted: "Começar",
        .namePlaceholder: "Seu nome",
        .phonePlaceholder: "(555) 000-0000",
        .emailPlaceholder: "você@gmail.com",
        .cityPlaceholder: "ex. São Paulo ou 01001",
        .done: "Concluído",                .cancel: "Cancelar",
        .clear: "Limpar",                  .signOut: "Sair",
        .errorTitle: "Erro",               .ok: "OK",
        .searchPlaceholder: "Buscar abrigo, comida, saúde…",
        .getDirections: "Obter Rotas",     .callNumber: "Ligar",
        .whatIsThis: "O que é este lugar?",.reExplain: "Re-explicar",
        .howCanIHelp: "Como posso te ajudar?",
        .askAboutHousing: "Pergunte sobre habitação, documentos ou serviços próximos.",
        .askAQuestion: "Fazer uma pergunta",
        .tools: "Ferramentas",             .translateDoc: "Traduzir",
        .safeProfile: "Perfil Seguro",     .caseSummary: "Resumo do Caso",
        .askAnything: "Pergunte qualquer coisa sobre habitação…",
        .typingIndicator: "Pensando…",
        .phone: "Telefone",                .area: "Área Principal",
        .showingNearby: "Mostrando todos os recursos ordenados pela sua área",
        .findSupportGroup: "Encontrar Grupo de Apoio",
        .supportGroupSub: "Navegue por organizações reais e aprenda como participar.",
        .addDocument: "Adicionar Documento",.noDocuments: "Nenhum documento ainda",
        .noDocumentsHint: "Toque em + para adicionar seu primeiro documento.",
        .aiRoadmap: "Roteiro IA",          .generateRoadmap: "Gerar Meu Roteiro",
        .regenerate: "Regenerar",
        .housingGoalPlaceholder: "ex. Conseguir moradia em 60 dias",
        .stepsComplete: "etapas concluídas",.reachedStableHousing: "Você alcançou moradia estável!",
        .askAIGuidance: "Pedir orientação à IA",
        .howToJoin: "Como Solicitar / Participar",.visitWebsite: "Visitar Site",
        .national: "Nacional"
    ]

    static let table: [HavenUser.Language: [Key: String]] = [
        .english: en, .spanish: es, .chinese: zh,
        .hindi: hi, .arabic: ar, .french: fr, .portuguese: pt
    ]
}
