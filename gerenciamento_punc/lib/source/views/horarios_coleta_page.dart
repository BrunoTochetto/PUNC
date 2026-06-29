import 'package:flutter/material.dart';

import '../../nucleo/erros/falha_api.dart';
import '../data/modelos/gerente.dart';
import '../data/modelos/horario_coleta.dart';
import '../data/modelos/tipo_lixo.dart';
import '../viewmodel/horarios_coleta_view_model.dart';
import '../widgets/estado_pagina.dart';

class HorariosColetaPage extends StatefulWidget {
  const HorariosColetaPage({super.key, required this.idGerente});

  final int idGerente;

  @override
  State<HorariosColetaPage> createState() => _HorariosColetaPageState();
}

class _HorariosColetaPageState extends State<HorariosColetaPage> {
  final _viewModel = HorariosColetaViewModel();

  late Future<List<HorarioColetaGrupo>> _horariosFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _horariosFuture = _viewModel.listarAgrupados(idGerente: widget.idGerente);
    });
  }

  Future<void> _abrirCadastro() async {
    final areas = await _viewModel.listarAreas(idGerente: widget.idGerente);
    if (!mounted) return;

    if (areas.isEmpty) {
      _mostrarSnackBar('Cadastre uma área de atuação antes de criar horários.');
      return;
    }

    final cadastrou = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogoCadastroHorario(
        idGerente: widget.idGerente,
        areas: areas,
        viewModel: _viewModel,
      ),
    );

    if (cadastrou == true) _carregar();
  }

  Future<void> _excluir(HorarioColetaGrupo grupo) async {
    if (grupo.idsHorario.isEmpty) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir horário?'),
        content: Text(
          'Deseja excluir ${grupo.diasFormatados} às ${grupo.horarioEstimado}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await _viewModel.excluirGrupo(
        idGerente: widget.idGerente,
        grupo: grupo,
      );
      _carregar();
      if (!mounted) return;
      _mostrarSnackBar('Horário excluído.');
    } on FalhaApi catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.mensagem);
    }
  }

  Future<void> _editar(HorarioColetaGrupo grupo) async {
    if (grupo.idsHorario.isEmpty) return;

    final areas = await _viewModel.listarAreas(idGerente: widget.idGerente);
    if (!mounted) return;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _DialogoEditarHorario(
        grupo: grupo,
        areas: areas,
      ),
    );

    if (resultado == null) return;

    final comentarios = (resultado['comentarios'] as String?)?.trim();

    try {
      await _viewModel.editarGrupo(
        idGerente: widget.idGerente,
        grupo: grupo,
        idAreaAtuacao: resultado['idArea'] as int?,
        horarioEstimado: resultado['horario'] as String,
        diasSemana: (resultado['dias'] as List).cast<String>(),
        tipoLixo: resultado['tipo'] as String,
        comentarios: comentarios == null || comentarios.isEmpty
            ? null
            : comentarios,
        ativo: resultado['ativo'] as bool?,
      );
      _carregar();
      if (!mounted) return;
      _mostrarSnackBar('Horário atualizado.');
    } on FalhaApi catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.mensagem);
    }
  }

  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Horários de coleta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Visualize e gerencie os horários cadastrados.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<HorarioColetaGrupo>>(
                future: _horariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const EstadoCarregando();
                  }

                  if (snapshot.hasError) {
                    return EstadoErro(
                      mensagem: 'Não foi possível carregar os horários.',
                      onTentarNovamente: _carregar,
                    );
                  }

                  final grupos = snapshot.data ?? [];
                  if (grupos.isEmpty) {
                    return const EstadoVazio(
                      mensagem:
                          'Nenhum horário cadastrado. Use o botão + para adicionar.',
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Dias')),
                          DataColumn(label: Text('Horário')),
                          DataColumn(label: Text('Tipo')),
                          DataColumn(label: Text('CEP')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: grupos
                            .map(
                              (grupo) => DataRow(
                                cells: [
                                  DataCell(Text(grupo.diasFormatados)),
                                  DataCell(Text(grupo.horarioEstimado)),
                                  DataCell(
                                    Text(TipoLixo.rotulo(grupo.tipoLixo)),
                                  ),
                                  DataCell(Text(grupo.cep ?? '—')),
                                  DataCell(
                                    Text(
                                      grupo.ativo == false
                                          ? 'Inativo'
                                          : 'Ativo',
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Editar',
                                          icon:
                                              const Icon(Icons.edit_outlined),
                                          onPressed: () => _editar(grupo),
                                        ),
                                        IconButton(
                                          tooltip: 'Excluir',
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () => _excluir(grupo),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        tooltip: 'Adicionar horário',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DialogoCadastroHorario extends StatefulWidget {
  const _DialogoCadastroHorario({
    required this.idGerente,
    required this.areas,
    required this.viewModel,
  });

  final int idGerente;
  final List<AreaAtuacao> areas;
  final HorariosColetaViewModel viewModel;

  @override
  State<_DialogoCadastroHorario> createState() =>
      _DialogoCadastroHorarioState();
}

class _DialogoCadastroHorarioState extends State<_DialogoCadastroHorario> {
  final _horarioController = TextEditingController();
  final _comentariosController = TextEditingController();

  int? _areaSelecionada;
  final _diasSelecionados = <String>{};
  String _tipoSelecionado = TipoLixo.organico;
  bool _salvando = false;

  @override
  void dispose() {
    _horarioController.dispose();
    _comentariosController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_areaSelecionada == null) {
      _mostrarErro('Selecione uma área de atuação.');
      return;
    }

    if (_diasSelecionados.isEmpty) {
      _mostrarErro('Selecione ao menos um dia da semana.');
      return;
    }

    final horario = _horarioController.text.trim();
    if (horario.isEmpty) {
      _mostrarErro('Informe o horário estimado.');
      return;
    }

    setState(() => _salvando = true);
    try {
      await widget.viewModel.cadastrarVarios(
        idGerente: widget.idGerente,
        idAreaAtuacao: _areaSelecionada!,
        horarioEstimado: horario,
        diasSemana: _diasSelecionados.toList(),
        tipoLixo: _tipoSelecionado,
        comentarios: _comentariosController.text.trim().isEmpty
            ? null
            : _comentariosController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on FalhaApi catch (e) {
      if (!mounted) return;
      _mostrarErro(e.mensagem);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar horário'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _areaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Área de atuação',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: widget.areas
                    .map(
                      (area) => DropdownMenuItem(
                        value: area.id,
                        child: Text('CEP ${area.cep}'),
                      ),
                    )
                    .toList(),
                onChanged: _salvando
                    ? null
                    : (valor) => setState(() => _areaSelecionada = valor),
              ),
              const SizedBox(height: 16),
              Text(
                'Dias da semana',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: TipoLixo.diasSemana.map((dia) {
                  final selecionado = _diasSelecionados.contains(dia);
                  return FilterChip(
                    label: Text(dia),
                    selected: selecionado,
                    onSelected: _salvando
                        ? null
                        : (valor) {
                            setState(() {
                              if (valor) {
                                _diasSelecionados.add(dia);
                              } else {
                                _diasSelecionados.remove(dia);
                              }
                            });
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _horarioController,
                enabled: !_salvando,
                decoration: const InputDecoration(
                  labelText: 'Horário estimado',
                  hintText: '08:00',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de lixo',
                  prefixIcon: Icon(Icons.delete_outline),
                ),
                items: TipoLixo.valores
                    .map(
                      (tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(TipoLixo.rotulo(tipo)),
                      ),
                    )
                    .toList(),
                onChanged: _salvando
                    ? null
                    : (valor) {
                        if (valor != null) {
                          setState(() => _tipoSelecionado = valor);
                        }
                      },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _comentariosController,
                enabled: !_salvando,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Comentários (opcional)',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

class _DialogoEditarHorario extends StatefulWidget {
  const _DialogoEditarHorario({
    required this.grupo,
    required this.areas,
  });

  final HorarioColetaGrupo grupo;
  final List<AreaAtuacao> areas;

  @override
  State<_DialogoEditarHorario> createState() => _DialogoEditarHorarioState();
}

class _DialogoEditarHorarioState extends State<_DialogoEditarHorario> {
  late final TextEditingController _horarioController;
  late final TextEditingController _comentariosController;
  late int? _areaSelecionada;
  late final Set<String> _diasSelecionados;
  late String _tipoSelecionado;
  late bool _ativo;

  @override
  void initState() {
    super.initState();
    final grupo = widget.grupo;
    _horarioController = TextEditingController(text: grupo.horarioEstimado);
    _comentariosController =
        TextEditingController(text: grupo.comentarios ?? '');
    _areaSelecionada = grupo.idAreaAtuacao;
    _diasSelecionados = grupo.diasSemana.toSet();
    _tipoSelecionado =
        TipoLixo.normalizar(grupo.tipoLixo) ?? TipoLixo.organico;
    _ativo = grupo.ativo ?? true;
  }

  @override
  void dispose() {
    _horarioController.dispose();
    _comentariosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar horário'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _areaSelecionada,
                decoration: const InputDecoration(labelText: 'Área'),
                items: widget.areas
                    .map(
                      (area) => DropdownMenuItem(
                        value: area.id,
                        child: Text('CEP ${area.cep}'),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => _areaSelecionada = valor),
              ),
              const SizedBox(height: 12),
              Text(
                'Dias da semana',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: TipoLixo.diasSemana.map((dia) {
                  final selecionado = _diasSelecionados.contains(dia);
                  return FilterChip(
                    label: Text(dia),
                    selected: selecionado,
                    onSelected: (valor) {
                      setState(() {
                        if (valor) {
                          _diasSelecionados.add(dia);
                        } else {
                          _diasSelecionados.remove(dia);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _horarioController,
                decoration: const InputDecoration(labelText: 'Horário'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipoSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo de lixo'),
                items: TipoLixo.valores
                    .map(
                      (tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(TipoLixo.rotulo(tipo)),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) setState(() => _tipoSelecionado = valor);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _comentariosController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Comentários'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ativo'),
                value: _ativo,
                onChanged: (valor) => setState(() => _ativo = valor),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_diasSelecionados.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecione ao menos um dia da semana.'),
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'idArea': _areaSelecionada,
              'horario': _horarioController.text.trim(),
              'dias': _diasSelecionados.toList(),
              'tipo': _tipoSelecionado,
              'comentarios': _comentariosController.text.trim(),
              'ativo': _ativo,
            });
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
