import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../datos_bd/repositorio_rangos.dart';
import '../logica_validacion/resultado_validacion.dart';
import '../logica_validacion/validador_billete.dart';
import 'layout_escaneo_responsive.dart';

class PantallaEscaneo extends StatefulWidget {
  const PantallaEscaneo({super.key});

  @override
  State<PantallaEscaneo> createState() => _PantallaEscaneoState();
}

class _PantallaEscaneoState extends State<PantallaEscaneo>
    with WidgetsBindingObserver {
  // ✅ Regulación del preview (mismo que ya tenías)
  static const double factorAspectoPreview = 0.70;

  CameraController? _camara;
  bool _camaraLista = false;

  bool _linternaOn = false;
  bool _yaEscaneo = false;

  // ✅ Evita doble captura
  bool _escaneando = false;

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
    _iniciarCamara();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await _forzarLinternaOffSilencioso();
      await _liberarCamara();
    }

    if (state == AppLifecycleState.resumed) {
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
          _linternaOn = false;
          _escaneando = false;
        });
      }
    }
  }

  Future<void> _forzarLinternaOffSilencioso() async {
    try {
      _linternaOn = false;
      if (_camara != null) {
        await _camara!.setFlashMode(FlashMode.off);
      }
    } catch (_) {
      // silencioso
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

      // ✅ Linterna SIEMPRE apagada al iniciar
      _linternaOn = false;
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _camara = controller;
        _camaraLista = true;
        _linternaOn = false;
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
    if (_escaneando) return;

    if (_camara == null || !_camaraLista) {
      setState(() {
        _resultado = const ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'Cámara no disponible. Reintente.',
        );
      });
      return;
    }

    setState(() {
      _escaneando = true;
    });

    try {
      final foto = await _camara!.takePicture();
      final input = InputImage.fromFilePath(foto.path);
      final texto = await _reconocedor.processImage(input);

      final res = await _validador.validar(texto.text);

      if (!mounted) return;
      setState(() {
        _resultado = res;
        _yaEscaneo = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resultado = const ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'No se pudo leer. Intente nuevamente.',
        );
        _yaEscaneo = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _escaneando = false;
        });
      } else {
        _escaneando = false;
      }
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

    return LayoutEscaneoResponsive(
      camaraLista: _camaraLista,
      camara: _camara,
      factorAspectoPreview: factorAspectoPreview,
      linternaOn: _linternaOn,
      escaneando: _escaneando,
      yaEscaneo: _yaEscaneo,
      textoBoton: textoBoton,
      resultado: _resultado,
      onToggleLinterna: _toggleLinterna,
      onEscanear: _escanear,
    );
  }
}