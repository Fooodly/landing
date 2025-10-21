import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isDarkMode = true; // ✅ 1. Dark mode di default

  @override
  void initState() {
    super.initState();
    // Assicurati che 'assets/images/logo.png' sia nel pubspec.yaml
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci un\'email valida', style: GoogleFonts.lato()),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ SOLUZIONE: Usa l'email come ID del documento.
      // Questo previene duplicati e richiede solo 'create'.
      // Se l'email (documento) esiste già, 'set' la aggiorna.
      // Se non esiste, la crea.
      await FirebaseFirestore.instance
          .collection('waitlist_b2c')
          .doc(email) // <-- Usa l'email come ID
          .set({      // <-- Usa 'set' invece di 'add'
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => _isSuccess = true);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisco i colori in base alla modalità
    final scaffoldBgColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final containerBgColor = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = _isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08);

    return Scaffold(
      // Rimosso il colore di sfondo da qui per animarlo nel container sottostante
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // ✅ 2. Animazione colore di sfondo
        color: scaffoldBgColor,
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                bool isMobile = screenWidth < 900; // Breakpoint

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300), // ✅ 2. Animazione colore del riquadro
                  constraints: const BoxConstraints(maxWidth: 1400), // Max width
                  margin: const EdgeInsets.all(24),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 60,
                    vertical: isMobile ? 40 : 60,
                  ),
                  decoration: BoxDecoration(
                    color: containerBgColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNavbar(),
                      SizedBox(height: isMobile ? 60 : 80),
                      _buildResponsiveContent(isMobile),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildNavIcon(FontAwesomeIcons.tiktok, () => _launchURL('https://www.tiktok.com/@ilpasco')),
        const SizedBox(width: 24),
        _buildNavIcon(FontAwesomeIcons.linkedin, () => _launchURL('https://www.linkedin.com/in/nicolo-pacucci-4426062b3/')),
        const SizedBox(width: 24),
        _buildThemeToggleButton(), // ✅ 3. Uso il nuovo bottone animato
      ],
    );
  }

  // ✅ 3. Nuovo widget per il bottone del tema con animazione
  Widget _buildThemeToggleButton() {
    final iconColor = _isDarkMode ? Colors.white70 : Colors.black87;
    return InkWell(
      onTap: () => setState(() => _isDarkMode = !_isDarkMode),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: FaIcon(
            _isDarkMode ? FontAwesomeIcons.solidSun : FontAwesomeIcons.solidMoon, // ✅ Corretta icona
            key: ValueKey<bool>(_isDarkMode),
            size: 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, VoidCallback onTap) {
    final iconColor = _isDarkMode ? Colors.white70 : Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FaIcon(
          icon,
          size: 24,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(bool isMobile) {
    if (isMobile) {
      return Column( // ✅ Mobile: Blocco testo e telefono impilati
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTextAndFormBlock(isMobile),
          const SizedBox(height: 60),
          _buildPhoneMockup(),
        ],
      );
    } else {
      return Row( // ✅ Desktop: Blocco testo e telefono affiancati
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center, // Centra verticalmente gli elementi della Row
        children: [
          Flexible(
            flex: 6,
            child: _buildTextAndFormBlock(isMobile),
          ),
          const SizedBox(width: 80),
          Flexible(
            flex: 5,
            child: _buildPhoneMockup(),
          ),
        ],
      );
    }
  }

  // ✅ ===================================================================
  // ✅ REWORK UI: Sezione sinistra completamente rifatta con logo in risalto e allineamento migliorato
  // ✅ ===================================================================
  Widget _buildTextAndFormBlock(bool isMobile) {
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final subtextColor = _isDarkMode ? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.75);
    return Container(
      constraints: const BoxConstraints(maxWidth: 550), // Mantiene la leggibilità
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente i contenuti all'interno di questo blocco
        children: [
          // 1. Logo (MAGGIORE RISALTO)
          Image.asset(
            'assets/images/logo.png', // Logo rosso originale
            height: 100, // Dimensione maggiore per dare risalto
          ),
          SizedBox(height: isMobile ? 32 : 40),

          // 2. Titolo (Headline)
          Text(
            'IL SOCIAL NETWORK DEL GUSTO.', // ✅ Nuovo testo
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 44 : 56, // Font size re-bilanciato
              fontWeight: FontWeight.w900,
              color: textColor,
              height: 1.15,
              letterSpacing: -1,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            textScaler: MediaQuery.textScalerOf(context),
          ),
          SizedBox(height: isMobile ? 20 : 24),

          // 3. Descrizione
          Text(
            'Entra nella waitlist di Fooodly per essere tra i primi a scoprire i piatti migliori della tua città, consigliati da persone come te.', // ✅ Nuovo testo
            style: GoogleFonts.lato(
              fontSize: 18,
              color: subtextColor, // Colore più morbido
              height: 1.6,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 40),

          // 4. Form (o Messaggio di Successo)
          if (_isSuccess)
            _buildSuccessMessage()
          else
            _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final textFieldFillColor = _isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
    final textFieldTextColor = _isDarkMode ? Colors.white : Colors.black;
    final textFieldHintColor = _isDarkMode ? Colors.white38 : Colors.black38;
    final buttonBgColor = _isDarkMode ? Colors.white : Colors.black;
    final buttonFgColor = _isDarkMode ? Colors.black : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.lato(fontSize: 16, color: textFieldTextColor),
          decoration: InputDecoration(
            hintText: 'La tua email',
            hintStyle: GoogleFonts.lato(color: textFieldHintColor),
            filled: true,
            fillColor: textFieldFillColor, // Leggero grigio per il campo
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Bordo pulito
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFBC02D), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBgColor,
              foregroundColor: buttonFgColor,
              disabledBackgroundColor: Colors.grey[400],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Entra in Waitlist',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    final successTextColor = _isDarkMode ? Colors.white : Colors.black87;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBC02D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBC02D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFFBC02D), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Sei in lista! Ti faremo sapere quando saremo pronti.',
              style: GoogleFonts.lato(
                fontSize: 15,
                color: successTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 640),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDA292A), // Sfondo rosso del mockup
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Notch
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 100,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    // ✅ FIX: Rimosso 'color: Colors.white' per usare i colori originali
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: LinearProgressIndicator(
                      value: 0.2,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
