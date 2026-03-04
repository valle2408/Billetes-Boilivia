import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../componentes/advertencias.dart';
import '../componentes/banner_resultado.dart';
import '../datos_bd/repositorio_rangos.dart';
import '../informacion/pantalla_acerca.dart';
import '../logica_validacion/resultado_validacion.dart';
import '../logica_validacion/validador_billete.dart';

class PantallaEscaneo extends StatefulWidget {
  const PantallaEscaneo({super.key});

  @override
  State<PantallaEscaneo> createState() => _PantallaEscaneoState();
}

class _PantallaEscaneoState extends State<PantallaEscaneo>
    with WidgetsBindingObserver {
  // =========================
  // ✅ AQUÍ REGULAS LO "HORIZONTAL"
  // - 1.00 = proporción real de cámara
  // - 0.95 = un poquito menos horizontal (más alto)
  // - 0.90 = todavía menos horizontal (más alto)
  // - 1.05 = un poquito más horizontal (más bajito)
  //
  // RECOMENDACIÓN: empieza con 0.95 o 1.00.
  // =========================
  static const double factorAspectoPreview = 0.70;

  CameraController? _camara;
  bool _camaraLista = false;

  bool _linternaOn = false; // estado UI (solo usuario la cambia)
  bool _yaEscaneo = false;

  final _reconocedor = TextRecognizer(script: TextRecognitionScript.latin);
  final _validador = ValidadorBillete(RepositorioRangos());

  ResultadoValidacion _resultado = const ResultadoValidacion(
    estado: EstadoValidacion.noLeido,
    mensaje: 'Presione "Escanee ahora" para iniciar.',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Cámara puede iniciar automático (como dijiste).
    _iniciarCamara();
  }

  // ===== CICLO DE VIDA =====
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // ✅ Apagar linterna SIEMPRE al salir / pausar
      await _forzarLinternaOffSilencioso();
      await _liberarCamara();
    }

    if (state == AppLifecycleState.resumed) {
      // ✅ Al volver, reiniciamos cámara y forzamos linterna apagada
      if (!_camaraLista) {
        await _iniciarCamara();
      } else {
        await _forzarLinternaOffSilencioso();
      }
    }
  }

  Future<void> _liberarCamara() async {
    try {
      await _camara?.dispose();
    } catch (_) {
      // silencioso
    } finally {
      _camara = null;
      if (mounted) {
        setState(() {
          _camaraLista = false;
          _linternaOn = false; // ✅ nunca queda como prendida
        });
      }
    }
  }

  Future<void> _forzarLinternaOffSilencioso() async {
    // ✅ Apaga físicamente el flash y sincroniza el estado
    try {
      _linternaOn = false;
      if (_camara != null) {
        await _camara!.setFlashMode(FlashMode.off);
      }
    } catch (_) {
      // algunos equipos no soportan flash o fallan -> no crashear
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _iniciarCamara() async {
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      // ✅ CLAVE: forzar OFF al iniciar SIEMPRE (evita que se prenda sola)
      _linternaOn = false;
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _camara = controller;
        _camaraLista = true;
        _linternaOn = false; // doble seguro
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultado = ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'Error al iniciar cámara: $e',
        );
      });
    }
  }

  Future<void> _toggleLinterna() async {
    if (_camara == null || !_camaraLista) return;

    try {
      _linternaOn = !_linternaOn;
      await _camara!.setFlashMode(
        _linternaOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _resultado = ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'No se pudo controlar la linterna: $e',
        );
      });
    }
  }

  Future<void> _escanear() async {
    if (_camara == null || !_camaraLista) {
      setState(() {
        _resultado = const ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'Cámara no disponible. Reintente.',
        );
      });
      return;
    }

    try {
      final foto = await _camara!.takePicture();
      final input = InputImage.fromFilePath(foto.path);
      final texto = await _reconocedor.processImage(input);

      final res = await _validador.validar(texto.text);

      setState(() {
        _resultado = res;
        _yaEscaneo = true;
      });
    } catch (e) {
      setState(() {
        _resultado = ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'Error al escanear: $e',
        );
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reconocedor.close();
    _camara?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textoBoton = _yaEscaneo ? 'Escanee nuevamente' : 'Escanee ahora';

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billetes Bolivia'),
            SizedBox(height: 2),
            Text(
              'Solo cortes de 10, 20 y 50 Bs.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _linternaOn ? 'Apagar linterna' : 'Encender linterna',
            onPressed: _toggleLinterna,
            icon: Icon(_linternaOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.black12,
                  child: _camaraLista && _camara != null
                      ? Center(
                          child: AspectRatio(
                            // ✅ Aquí se aplica el factor horizontal
                            aspectRatio:
                                _camara!.value.aspectRatio *
                                factorAspectoPreview,
                            child: CameraPreview(_camara!),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(height: 10),
            BannerResultado(resultado: _resultado),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _escanear,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(textoBoton),
              ),
            ),
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerLeft, child: Advertencias()),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaAcerca()),
                ),
                child: const Text(
                  'Acerca de nosotros',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
