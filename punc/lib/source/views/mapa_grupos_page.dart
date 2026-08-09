import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/motorista_view_model.dart';
import '../widgets/painel_controle_motorista.dart';
import '../widgets/punc_app_shell.dart';

class MapaGruposPage extends StatelessWidget {
  const MapaGruposPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ehMotorista = context.watch<MotoristaViewModel>().ehMotorista;

    return PuncAppShell(
      selectedRoute: ehMotorista ? '/mapa' : '/cronograma',
      body: ehMotorista
          ? const _TelaOperacionalMotorista()
          : const _AcessoRestritoMapa(),
    );
  }
}

class _AcessoRestritoMapa extends StatelessWidget {
  const _AcessoRestritoMapa();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Acompanhe sua coleta pelo cronograma',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A tela de percurso fica disponivel apenas para dispositivos de motorista.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/cronograma'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Abrir cronograma'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelaOperacionalMotorista extends StatelessWidget {
  const _TelaOperacionalMotorista();

  @override
  Widget build(BuildContext context) {
    return Consumer<MotoristaViewModel>(
      builder: (context, motorista, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CabecalhoOperacao(motorista: motorista),
              const SizedBox(height: 16),
              _CartaoStatusMotorista(motorista: motorista),
              const SizedBox(height: 16),
              const PainelControleMotorista(),
              const SizedBox(height: 16),
              _ResumoEnvioLocalizacao(motorista: motorista),
            ],
          ),
        );
      },
    );
  }
}

class _CabecalhoOperacao extends StatelessWidget {
  const _CabecalhoOperacao({required this.motorista});

  final MotoristaViewModel motorista;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final emPercurso = motorista.estaEmPercurso;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      (emPercurso ? colorScheme.secondary : colorScheme.primary)
                          .withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: emPercurso
                      ? colorScheme.secondary
                      : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operacao do motorista',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      motorista.nomeDispositivo ?? 'Dispositivo autorizado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _TrilhaDecorativa(),
        ],
      ),
    );
  }
}

class _CartaoStatusMotorista extends StatelessWidget {
  const _CartaoStatusMotorista({required this.motorista});

  final MotoristaViewModel motorista;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final emPercurso = motorista.estaEmPercurso;
    final corStatus = emPercurso ? colorScheme.secondary : colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined, color: corStatus),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  emPercurso ? 'Percurso ativo' : 'Percurso desligado',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: corStatus,
                  ),
                ),
              ),
              if (motorista.estaSincronizando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const Divider(height: 24),
          _LinhaStatus(
            label: 'Caminhao',
            value: motorista.identificacaoCaminhaoExibicao ?? 'Nao informado',
          ),
          _LinhaStatus(
            label: 'Tipo de coleta',
            value: motorista.tipoLixoExibicao ?? 'Nao selecionado',
          ),
          _LinhaStatus(
            label: 'Envio de localizacao',
            value: emPercurso ? 'Ativo em segundo plano' : 'Aguardando inicio',
          ),
        ],
      ),
    );
  }
}

class _ResumoEnvioLocalizacao extends StatelessWidget {
  const _ResumoEnvioLocalizacao({required this.motorista});

  final MotoristaViewModel motorista;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            motorista.estaEmPercurso
                ? Icons.gps_fixed_outlined
                : Icons.gps_not_fixed_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              motorista.estaEmPercurso
                  ? 'Sua localizacao esta sendo enviada enquanto o percurso estiver ativo.'
                  : 'Preencha os dados do caminhao e ligue o percurso para iniciar o envio.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaStatus extends StatelessWidget {
  const _LinhaStatus({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.64),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrilhaDecorativa extends StatelessWidget {
  const _TrilhaDecorativa();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 132,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TrilhaOperacionalPainter(
                corLinha: colorScheme.primary.withValues(alpha: 0.28),
                corPonto: colorScheme.secondary,
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 18,
            child: _MarcadorTrilha(
              icon: Icons.home_work_outlined,
              color: colorScheme.primary,
            ),
          ),
          Positioned(
            right: 8,
            top: 12,
            child: _MarcadorTrilha(
              icon: Icons.recycling_outlined,
              color: colorScheme.secondary,
            ),
          ),
          Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Icon(
                Icons.local_shipping,
                color: colorScheme.primary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarcadorTrilha extends StatelessWidget {
  const _MarcadorTrilha({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _TrilhaOperacionalPainter extends CustomPainter {
  const _TrilhaOperacionalPainter({
    required this.corLinha,
    required this.corPonto,
  });

  final Color corLinha;
  final Color corPonto;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(30, size.height - 34)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.24,
        size.width * 0.66,
        size.height * 0.84,
        size.width - 32,
        34,
      );

    final linePaint = Paint()
      ..color = corLinha
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()..color = corPonto;
    canvas.drawCircle(Offset(30, size.height - 34), 5, pointPaint);
    canvas.drawCircle(Offset(size.width - 32, 34), 5, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _TrilhaOperacionalPainter oldDelegate) {
    return oldDelegate.corLinha != corLinha || oldDelegate.corPonto != corPonto;
  }
}
