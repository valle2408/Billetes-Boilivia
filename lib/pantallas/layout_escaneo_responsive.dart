import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../componentes/advertencias.dart';
import '../componentes/banner_resultado.dart';
import '../informacion/pantalla_acerca.dart';
import '../logica_validacion/resultado_validacion.dart';

class LayoutEscaneoResponsive extends StatelessWidget {
  final bool camaraLista;
  final CameraController? camara;

  // Preview
  final double factorAspectoPreview;

  // Estado UI
  final bool linternaOn;
  final bool escaneando;
  final bool yaEscaneo;
  final String textoBoton;

  // Resultado
  final ResultadoValidacion resultado;

  // Acciones
  final VoidCallback onToggleLinterna;
  final VoidCallback onEscanear;

  const LayoutEscaneoResponsive({
    super.key,
    required this.camaraLista,
    required this.camara,
    required this.factorAspectoPreview,
    required this.linternaOn,
    required this.escaneando,
    required this.yaEscaneo,
    required this.textoBoton,
    required this.resultado,
    required this.onToggleLinterna,
    required this.onEscanear,
  });

  @override
  Widget build(BuildContext context) {
    final esHorizontal = MediaQuery.of(context).orientation == Orientation.landscape;

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
            tooltip: linternaOn ? 'Apagar linterna' : 'Encender linterna',
            onPressed: onToggleLinterna,
            icon: Icon(linternaOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: esHorizontal ? _layoutHorizontal(context) : _layoutVertical(context),
      ),
    );
  }

  Widget _previewCamara() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.black12,
        child: camaraLista && camara != null
            ? Center(
                child: AspectRatio(
                  aspectRatio: camara!.value.aspectRatio * factorAspectoPreview,
                  child: CameraPreview(camara!),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _panelDerecho(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BannerResultado(resultado: resultado),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: escaneando ? null : onEscanear,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EC4B6),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF2EC4B6).withValues(alpha: 120),
              disabledForegroundColor: Colors.white.withValues(alpha: 180),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(escaneando ? 'Escaneando...' : textoBoton),
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
    );
  }

  Widget _layoutVertical(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _previewCamara()),
        const SizedBox(height: 10),
        _panelDerecho(context),
      ],
    );
  }

  Widget _layoutHorizontal(BuildContext context) {
    // En horizontal: cámara a la izquierda, panel a la derecha.
    // Usamos scroll para evitar overflow en pantallas bajas.
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _previewCamara(),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _panelDerecho(context),
          ),
        ),
      ],
    );
  }
}