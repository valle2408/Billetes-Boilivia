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

class _PantallaEscaneoState extends State<PantallaEscaneo> {
  CameraController? _camara;
  bool _camaraLista = false;
  bool _linternaOn = false;

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
    _iniciarCamara();
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

      setState(() {
        _camara = controller;
        _camaraLista = true;
      });
    } catch (e) {
      setState(() {
        _resultado = ResultadoValidacion(
          estado: EstadoValidacion.noLeido,
          mensaje: 'Error al iniciar cámara: $e',
        );
      });
    }
  }

  Future<void> _toggleLinterna() async {
    if (_camara == null) return;

    // Linterna SOLO si el usuario quiere (no automática)
    try {
      _linternaOn = !_linternaOn;
      await _camara!.setFlashMode(_linternaOn ? FlashMode.torch : FlashMode.off);
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
    if (_camara == null || !_camaraLista) return;

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
                      ? CameraPreview(_camara!)
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
                child: const Text('Acerca de nosotros', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}