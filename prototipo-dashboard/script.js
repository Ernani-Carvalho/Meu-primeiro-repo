/* ============================================================
   DataBus · protótipo da dashboard de lotação
   ------------------------------------------------------------
   Os dados desta página são SIMULADOS no próprio navegador.
   Quando a API existir, troque as funções da seção 3 pelo
   fetch() que está comentado em cada uma e apague a seção de
   simulação no fim do arquivo. O resto continua igual.
   ============================================================ */

/* ---------- 1. Configuração ---------- */
const INTERVALO_ATUALIZACAO_MS = 5000; // a dashboard consulta a API a cada 5 s
const LIMITE_ATENCAO = 70;             // % da capacidade
const LIMITE_LOTADO = 90;              // % da capacidade
const SEM_SINAL_APOS_SEGUNDOS = 120;   // sem mensagem do ônibus há mais de 2 min

/* ---------- 2. Simulação (só existe no protótipo) ---------- */
const simulacao = criarSimulacao();

/* ---------- 3. Acesso aos dados ---------- */

// GET /api/lotacao → lotação atual de cada ônibus da empresa
async function buscarLotacao() {
  // const resposta = await fetch('/api/lotacao');
  // return await resposta.json();
  return simulacao.lotacao();
}

// GET /api/onibus/:id/historico → lotação do dia, um ponto a cada 5 minutos
async function buscarHistorico(idOnibus) {
  // const resposta = await fetch(`/api/onibus/${idOnibus}/historico`);
  // return await resposta.json();
  return simulacao.historico(idOnibus);
}

// GET /api/onibus/:id/eventos?limite=8 → últimas passagens lidas pelos sensores
async function buscarEventos(idOnibus) {
  // const resposta = await fetch(`/api/onibus/${idOnibus}/eventos?limite=8`);
  // return await resposta.json();
  return simulacao.eventos(idOnibus, 8);
}

// GET /api/alertas?limite=20 → alertas mais recentes (lotação e perda de sinal)
async function buscarAlertas() {
  // const resposta = await fetch('/api/alertas?limite=20');
  // return await resposta.json();
  return simulacao.alertas(20);
}

// Hora usada para calcular "há X s". Na versão real: return new Date();
function horaAtual() {
  return simulacao.agora();
}

/* ---------- 4. Regras de exibição ---------- */
const SITUACOES = {
  lotado: { rotulo: 'Lotado', ordem: 0 },
  atencao: { rotulo: 'Atenção', ordem: 1 },
  normal: { rotulo: 'Normal', ordem: 2 },
  'sem-sinal': { rotulo: 'Sem sinal', ordem: 3 },
};

function calcularSituacao(onibus, agora) {
  const segundosSemSinal = (agora - new Date(onibus.ultimaLeitura)) / 1000;
  if (segundosSemSinal > SEM_SINAL_APOS_SEGUNDOS) return 'sem-sinal';
  if (onibus.ocupacao >= LIMITE_LOTADO) return 'lotado';
  if (onibus.ocupacao >= LIMITE_ATENCAO) return 'atencao';
  return 'normal';
}

function situacaoDaOcupacao(ocupacao) {
  if (ocupacao >= LIMITE_LOTADO) return 'lotado';
  if (ocupacao >= LIMITE_ATENCAO) return 'atencao';
  return 'normal';
}

// Ícones desenhados em SVG: a cor vem do CSS (classes is-lotado, is-atencao...)
const ICONES = {
  lotado: '<svg viewBox="0 0 16 16" aria-hidden="true"><circle cx="8" cy="8" r="8" fill="currentColor"/><rect x="7" y="3.5" width="2" height="6" rx="1" fill="#fff"/><circle cx="8" cy="12" r="1.2" fill="#fff"/></svg>',
  atencao: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M8 .8 15.6 14.6H.4Z" fill="currentColor"/><rect x="7.1" y="5.3" width="1.8" height="4.8" rx=".9" fill="#1d1503"/><circle cx="8" cy="12.2" r="1.05" fill="#1d1503"/></svg>',
  normal: '<svg viewBox="0 0 16 16" aria-hidden="true"><circle cx="8" cy="8" r="8" fill="currentColor"/><path d="m4.6 8.3 2.3 2.3 4.6-4.9" fill="none" stroke="#fff" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  'sem-sinal': '<svg viewBox="0 0 16 16" aria-hidden="true"><circle cx="8" cy="8" r="8" fill="currentColor"/><rect x="4" y="7" width="8" height="2" rx="1" fill="#fff"/></svg>',
  entrada: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M2.5 8h8.5M8 4.5 11.5 8 8 11.5M13.5 3v10" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  saida: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M13.5 8H5M8 4.5 4.5 8 8 11.5M2.5 3v10" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>',
};

/* ---------- 5. Estado da tela e funções de apoio ---------- */
const estado = {
  frota: [],          // última resposta de /api/lotacao, com a situação calculada
  alertas: [],
  linha: 'todas',     // filtro escolhido
  selecionado: null,  // ônibus mostrado no detalhe
  ultimaAtualizacao: null,
};

const $ = (seletor) => document.querySelector(seletor);
const numero = new Intl.NumberFormat('pt-BR');

// Textos que vêm da API passam por aqui antes de entrar no HTML
function escaparHtml(texto) {
  const trocas = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
  return String(texto).replace(/[&<>"']/g, (c) => trocas[c]);
}

function formatarHora(dataHora, comSegundos = false) {
  const opcoes = { hour: '2-digit', minute: '2-digit' };
  if (comSegundos) opcoes.second = '2-digit';
  return new Date(dataHora).toLocaleTimeString('pt-BR', opcoes);
}

function tempoDesde(dataHora, agora) {
  const segundos = Math.max(0, Math.round((agora - new Date(dataHora)) / 1000));
  if (segundos < 60) return `há ${segundos} s`;
  const minutos = Math.floor(segundos / 60);
  if (minutos < 60) return `há ${minutos} min`;
  return `às ${formatarHora(dataHora)}`;
}

function frotaFiltrada() {
  if (estado.linha === 'todas') return estado.frota;
  return estado.frota.filter((onibus) => onibus.linha === estado.linha);
}

function ordenarPorSituacao(frota) {
  return [...frota].sort((a, b) =>
    SITUACOES[a.situacao].ordem - SITUACOES[b.situacao].ordem || b.ocupacao - a.ocupacao);
}

function chipSituacao(situacao) {
  return `<span class="chip is-${situacao}"><span class="icone">${ICONES[situacao]}</span>${SITUACOES[situacao].rotulo}</span>`;
}

function preencherMedidor(elemento, ocupacao, situacao) {
  elemento.classList.remove('is-normal', 'is-atencao', 'is-lotado', 'is-sem-sinal');
  elemento.classList.add(`is-${situacao}`);
  elemento.style.setProperty('--pct', `${Math.min(ocupacao, 100)}%`);
}

/* ---------- 6. Renderização ---------- */

function renderizarIndicadores(frota) {
  const emOperacao = frota.filter((onibus) => onibus.situacao !== 'sem-sinal');
  const lotados = emOperacao.filter((onibus) => onibus.situacao === 'lotado').length;
  const passageiros = emOperacao.reduce((soma, onibus) => soma + onibus.lotacao, 0);
  const lugares = emOperacao.reduce((soma, onibus) => soma + onibus.capacidade, 0);
  const ocupacaoMedia = lugares ? Math.round((passageiros / lugares) * 100) : 0;
  const semSinal = frota.length - emOperacao.length;

  $('#kpi-lotados').textContent = lotados;
  $('#kpi-lotados-contexto').textContent = `de ${emOperacao.length} em operação · 90% ou mais`;

  $('#kpi-passageiros').textContent = numero.format(passageiros);
  $('#kpi-passageiros-contexto').textContent = `em ${numero.format(lugares)} lugares disponíveis`;

  $('#kpi-ocupacao').textContent = `${ocupacaoMedia}%`;
  preencherMedidor($('#kpi-ocupacao-medidor'), ocupacaoMedia, situacaoDaOcupacao(ocupacaoMedia));

  $('#kpi-operacao').innerHTML = `${emOperacao.length}<small> de ${frota.length}</small>`;
  $('#kpi-operacao-contexto').innerHTML = semSinal
    ? `<span class="icone is-sem-sinal">${ICONES['sem-sinal']}</span>${semSinal} sem sinal`
    : `<span class="icone is-normal">${ICONES.normal}</span>todos transmitindo`;
}

// Recria a lista sem perder o foco de quem navega pelo teclado
function manterFoco(container, seletorChave, recriar) {
  const ativo = container.contains(document.activeElement) ? document.activeElement.closest(seletorChave) : null;
  const chave = ativo ? ativo.dataset.chave : null;
  recriar();
  if (chave) {
    const alvo = container.querySelector(`[data-chave="${chave}"]`);
    const botao = alvo && (alvo.matches('button') ? alvo : alvo.querySelector('button'));
    if (botao) botao.focus();
  }
}

function renderizarFrota(frota, agora) {
  manterFoco($('#frota-corpo'), 'tr', () => desenharFrota(frota, agora));
}

function desenharFrota(frota, agora) {
  $('#frota-corpo').innerHTML = ordenarPorSituacao(frota).map((onibus) => {
    const selecionado = onibus.idOnibus === estado.selecionado;
    return `
      <tr class="is-${onibus.situacao}${selecionado ? ' selecionado' : ''}" data-id="${onibus.idOnibus}" data-chave="${onibus.idOnibus}">
        <td class="c-onibus"><button type="button" class="onibus-botao" aria-current="${selecionado}">${escaparHtml(onibus.idOnibus)}</button></td>
        <td class="c-linha">
          <span class="linha-celula">
            <span class="linha-badge">${escaparHtml(onibus.linha)}</span>
            <span class="trajeto">${escaparHtml(onibus.trajeto)}</span>
          </span>
        </td>
        <td class="c-lotacao">
          <span class="lotacao-celula">
            <span class="medidor" style="--pct: ${Math.min(onibus.ocupacao, 100)}%"><span></span></span>
            <span class="lotacao-numero">${onibus.lotacao}/${onibus.capacidade}</span>
          </span>
        </td>
        <td class="num c-ocupacao">${Math.round(onibus.ocupacao)}%</td>
        <td class="c-situacao">${chipSituacao(onibus.situacao)}</td>
        <td class="leitura c-leitura">${tempoDesde(onibus.ultimaLeitura, agora)}</td>
      </tr>`;
  }).join('');
}

function textoDoAlerta(alerta) {
  const onibus = `Ônibus ${escaparHtml(alerta.idOnibus)}`;
  const linha = `linha ${escaparHtml(alerta.linha)}`;
  if (alerta.tipo === 'lotado') {
    return { classe: 'is-lotado', icone: ICONES.lotado, titulo: `${onibus} lotado`, detalhe: `${alerta.ocupacao}% da capacidade · ${linha}` };
  }
  if (alerta.tipo === 'normalizado') {
    return { classe: 'is-normal', icone: ICONES.normal, titulo: `${onibus} saiu da lotação`, detalhe: `agora com ${alerta.ocupacao}% · ${linha}` };
  }
  return { classe: 'is-sem-sinal', icone: ICONES['sem-sinal'], titulo: `${onibus} sem sinal`, detalhe: `última leitura às ${formatarHora(alerta.ultimaLeitura)} · ${linha}` };
}

function renderizarAlertas() {
  const alertas = estado.alertas
    .filter((alerta) => estado.linha === 'todas' || alerta.linha === estado.linha)
    .slice(0, 7);

  if (!alertas.length) {
    $('#lista-alertas').innerHTML = '<li class="lista-vazia">Nenhum alerta para esta linha hoje.</li>';
    return;
  }
  manterFoco($('#lista-alertas'), 'button', () => {
    $('#lista-alertas').innerHTML = alertas.map((alerta) => {
      const texto = textoDoAlerta(alerta);
      const chave = `${alerta.tipo}-${alerta.idOnibus}-${new Date(alerta.dataHora).getTime()}`;
      return `
      <li>
        <button type="button" class="alerta ${texto.classe}" data-id="${alerta.idOnibus}" data-chave="${chave}">
          <span class="icone">${texto.icone}</span>
          <span class="alerta__titulo">${texto.titulo}</span>
          <span class="alerta__hora">${formatarHora(alerta.dataHora)}</span>
          <span class="alerta__detalhe">${texto.detalhe}</span>
        </button>
      </li>`;
    }).join('');
  });
}

async function renderizarDetalhe(agora) {
  const id = estado.selecionado;
  const onibus = estado.frota.find((item) => item.idOnibus === id);
  if (!onibus) return;

  const [historico, eventos] = await Promise.all([buscarHistorico(id), buscarEventos(id)]);
  if (id !== estado.selecionado) return; // o usuário trocou de ônibus enquanto os dados chegavam

  $('#detalhe-titulo').textContent = `Ônibus ${onibus.idOnibus}`;
  $('#detalhe-subtitulo').textContent = `Linha ${onibus.linha} · ${onibus.trajeto} · ${onibus.capacidade} lugares`;
  $('#det-lotacao').textContent = onibus.lotacao;
  $('#det-capacidade').textContent = onibus.capacidade;
  preencherMedidor($('#det-medidor'), onibus.ocupacao, onibus.situacao);
  $('#det-situacao').innerHTML = `${chipSituacao(onibus.situacao)}<span>${Math.round(onibus.ocupacao)}% da capacidade</span>`;
  $('#det-leitura').textContent = onibus.situacao === 'sem-sinal'
    ? `Sem sinal desde ${formatarHora(onibus.ultimaLeitura)}. Mostrando o último valor recebido.`
    : `Última leitura ${tempoDesde(onibus.ultimaLeitura, agora)}`;

  // A regra principal do DataBus, mostrada como conta
  $('#det-entradas').textContent = numero.format(onibus.entradas);
  $('#det-saidas').textContent = numero.format(onibus.saidas);
  $('#det-resultado').textContent = numero.format(onibus.lotacao);

  renderizarGrafico(onibus, historico);
  renderizarTabelaDia(onibus, historico);
  renderizarEventos(eventos);
}

function rotulosDoHistorico(onibus, historico) {
  return historico.map((ponto, i) => {
    const ultimo = i === historico.length - 1;
    return ultimo && onibus.situacao !== 'sem-sinal' ? 'agora' : formatarHora(ponto.dataHora);
  });
}

function renderizarTabelaDia(onibus, historico) {
  const rotulos = rotulosDoHistorico(onibus, historico);
  const linhas = historico.map((ponto, i) => `
      <tr>
        <td>${rotulos[i]}</td>
        <td>${ponto.lotacao}</td>
        <td>${Math.round((ponto.lotacao / onibus.capacidade) * 100)}%</td>
      </tr>`).reverse().join('');
  $('#tabela-dia').innerHTML = `
    <table>
      <caption class="visualmente-oculto">Lotação do ônibus ${escaparHtml(onibus.idOnibus)} hoje</caption>
      <thead><tr><th scope="col">Horário</th><th scope="col">Passageiros</th><th scope="col">Ocupação</th></tr></thead>
      <tbody>${linhas}</tbody>
    </table>`;
}

function renderizarEventos(eventos) {
  if (!eventos.length) {
    $('#lista-eventos').innerHTML = '<li class="lista-vazia">Nenhum evento recebido hoje.</li>';
    return;
  }
  $('#lista-eventos').innerHTML = eventos.map((evento) => `
      <li class="evento">
        <span class="evento__hora">${formatarHora(evento.dataHora, true)}</span>
        <span class="evento__tipo">${evento.tipo === 'entrada' ? ICONES.entrada + 'Entrada' : ICONES.saida + 'Saída'}</span>
        <span class="evento__porta">porta ${escaparHtml(evento.porta)}</span>
      </li>`).join('');
}

/* ---------- 7. Gráfico (Chart.js) ---------- */
let grafico = null;
let capacidadeNoGrafico = 0;

function lerToken(nome) {
  return getComputedStyle(document.documentElement).getPropertyValue(nome).trim();
}

function comTransparencia(hex, alfa) {
  const n = parseInt(hex.replace('#', ''), 16);
  return `rgba(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}, ${alfa})`;
}

// Linha vertical que acompanha o mouse, para facilitar a leitura do horário
const linhaVertical = {
  id: 'linhaVertical',
  afterDatasetsDraw(chart) {
    const ativos = chart.tooltip ? chart.tooltip.getActiveElements() : [];
    if (!ativos.length) return;
    const { ctx, chartArea } = chart;
    const x = ativos[0].element.x;
    ctx.save();
    ctx.beginPath();
    ctx.moveTo(x, chartArea.top);
    ctx.lineTo(x, chartArea.bottom);
    ctx.lineWidth = 1;
    ctx.strokeStyle = lerToken('--tinta-3');
    ctx.stroke();
    ctx.restore();
  },
};

function criarGrafico() {
  if (!window.Chart) return null; // sem internet o Chart.js não carrega: a página mostra a tabela

  Chart.defaults.font.family = lerToken('--fonte');
  Chart.defaults.font.size = 12;

  return new Chart($('#grafico-dia'), {
    type: 'line',
    data: {
      labels: [],
      datasets: [
        { label: 'Passageiros', data: [], borderWidth: 2, tension: 0.3, fill: 'origin',
          pointRadius: 0, pointHoverRadius: 5, pointHoverBorderWidth: 2 },
        { label: 'Capacidade', data: [], borderWidth: 1.5, borderDash: [6, 5], fill: false,
          pointRadius: 0, pointHoverRadius: 0 },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      animation: false,
      interaction: { mode: 'index', intersect: false },
      plugins: {
        legend: { display: false },
        tooltip: {
          usePointStyle: true,
          callbacks: {
            labelPointStyle: () => ({ pointStyle: 'line', rotation: 0 }),
            label: (item) => (item.datasetIndex === 0
              ? `${item.parsed.y} passageiros (${Math.round((item.parsed.y / capacidadeNoGrafico) * 100)}%)`
              : `capacidade: ${item.parsed.y} lugares`),
          },
        },
      },
      scales: {
        x: {
          grid: { display: false },
          border: {},
          ticks: {
            maxRotation: 0,
            autoSkip: false,
            // mostra só as horas cheias e o ponto "agora"
            callback(valor) {
              const rotulo = this.getLabelForValue(valor);
              return rotulo.endsWith(':00') || rotulo === 'agora' ? rotulo : null;
            },
          },
        },
        y: { beginAtZero: true, grid: {}, border: { display: false }, ticks: { precision: 0, maxTicksLimit: 6 } },
      },
    },
    plugins: [linhaVertical],
  });
}

// Lê as cores do CSS: assim o gráfico acompanha o tema claro ou escuro
function aplicarCoresNoGrafico() {
  if (!grafico) return;
  const serie = lerToken('--serie-1');
  const [passageiros, capacidade] = grafico.data.datasets;
  passageiros.borderColor = serie;
  passageiros.backgroundColor = comTransparencia(serie, 0.1);
  passageiros.pointHoverBackgroundColor = serie;
  passageiros.pointHoverBorderColor = lerToken('--superficie');
  capacidade.borderColor = lerToken('--tinta-3');

  const { x, y } = grafico.options.scales;
  x.ticks.color = lerToken('--tinta-3');
  y.ticks.color = lerToken('--tinta-3');
  y.grid.color = lerToken('--linha');
  x.border.color = lerToken('--linha');

  const tooltip = grafico.options.plugins.tooltip;
  tooltip.backgroundColor = lerToken('--tinta');
  tooltip.titleColor = lerToken('--superficie');
  tooltip.bodyColor = lerToken('--superficie');
  grafico.update('none');
}

function renderizarGrafico(onibus, historico) {
  const valores = historico.map((ponto) => ponto.lotacao);
  $('#grafico-dia').setAttribute('aria-label',
    `Lotação do ônibus ${onibus.idOnibus} hoje: começou com ${valores[0]} e está com ${valores[valores.length - 1]} passageiros, de ${onibus.capacidade} lugares.`);
  if (!grafico) return;

  capacidadeNoGrafico = onibus.capacidade;
  grafico.data.labels = rotulosDoHistorico(onibus, historico);
  grafico.data.datasets[0].data = valores;
  grafico.data.datasets[1].data = historico.map(() => onibus.capacidade);
  grafico.options.scales.y.suggestedMax = Math.ceil(onibus.capacidade * 1.1);
  grafico.update('none');
}

function alternarVista() {
  const mostrarTabela = $('#tabela-dia').hidden;
  $('#tabela-dia').hidden = !mostrarTabela;
  $('#grafico-caixa').hidden = mostrarTabela;
  $('#alternar-vista').setAttribute('aria-pressed', String(mostrarTabela));
  $('#alternar-vista').textContent = mostrarTabela ? 'Ver gráfico' : 'Ver tabela';
}

/* ---------- 8. Ciclo de atualização ---------- */

function preencherFiltroDeLinhas() {
  const select = $('#filtro-linha');
  if (select.options.length > 1) return;
  const linhas = [...new Set(estado.frota.map((onibus) => onibus.linha))].sort();
  for (const linha of linhas) {
    const trajeto = estado.frota.find((onibus) => onibus.linha === linha).trajeto;
    select.add(new Option(`${linha} · ${trajeto}`, linha));
  }
}

function garantirSelecao() {
  const visiveis = ordenarPorSituacao(frotaFiltrada());
  if (!visiveis.some((onibus) => onibus.idOnibus === estado.selecionado)) {
    estado.selecionado = visiveis.length ? visiveis[0].idOnibus : null;
  }
}

function renderizarResumo(agora) {
  const frota = frotaFiltrada();
  renderizarIndicadores(frota);
  renderizarFrota(frota, agora);
  renderizarAlertas();
}

function atualizarRelogio() {
  if (!estado.ultimaAtualizacao) return;
  const segundos = Math.round((Date.now() - estado.ultimaAtualizacao) / 1000);
  $('#atualizado').textContent = segundos < 2 ? 'atualizado agora' : `atualizado há ${segundos} s`;
}

async function atualizar() {
  try {
    const [lotacao, alertas] = await Promise.all([buscarLotacao(), buscarAlertas()]);
    const agora = horaAtual();
    estado.frota = lotacao.map((onibus) => ({ ...onibus, situacao: calcularSituacao(onibus, agora) }));
    estado.alertas = alertas;
    estado.ultimaAtualizacao = Date.now();
    preencherFiltroDeLinhas();
    garantirSelecao();
    renderizarResumo(agora);
    await renderizarDetalhe(agora);
    $('#erro').hidden = true;
  } catch (erro) {
    console.error('Falha ao atualizar a dashboard:', erro);
    $('#erro').hidden = false;
  }
  atualizarRelogio();
}

function selecionar(idOnibus) {
  estado.selecionado = idOnibus;
  const agora = horaAtual();
  renderizarFrota(frotaFiltrada(), agora);
  renderizarDetalhe(agora);
  // Em telas estreitas o detalhe fica lá embaixo: rola até ele
  if (window.matchMedia('(max-width: 1040px)').matches) {
    const suave = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    $('#detalhe').scrollIntoView({ behavior: suave ? 'smooth' : 'auto', block: 'start' });
  }
}

// Eventos da página
$('#frota-corpo').addEventListener('click', (evento) => {
  const linha = evento.target.closest('tr[data-id]');
  if (linha) selecionar(Number(linha.dataset.id));
});

$('#lista-alertas').addEventListener('click', (evento) => {
  const alerta = evento.target.closest('[data-id]');
  if (alerta && estado.frota.some((onibus) => onibus.idOnibus === Number(alerta.dataset.id))) {
    selecionar(Number(alerta.dataset.id));
  }
});

$('#filtro-linha').addEventListener('change', (evento) => {
  estado.linha = evento.target.value;
  garantirSelecao();
  const agora = horaAtual();
  renderizarResumo(agora);
  renderizarDetalhe(agora);
});

$('#alternar-vista').addEventListener('click', alternarVista);

// O gráfico troca de cor quando o tema do sistema (ou da página) muda
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', aplicarCoresNoGrafico);
new MutationObserver(aplicarCoresNoGrafico)
  .observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });

// Início
document.documentElement.lang = 'pt-BR';
document.querySelectorAll('[data-icone]').forEach((elemento) => {
  elemento.innerHTML = ICONES[elemento.dataset.icone];
});
grafico = criarGrafico();
if (grafico) {
  aplicarCoresNoGrafico();
} else {
  alternarVista();
  $('#alternar-vista').hidden = true;
}
if (document.fonts) document.fonts.ready.then(() => grafico && grafico.update('none'));

atualizar();
setInterval(atualizar, INTERVALO_ATUALIZACAO_MS);
setInterval(atualizarRelogio, 1000);

/* ============================================================
   SIMULAÇÃO: gera dados no mesmo formato da API real.
   Apague esta seção quando a dashboard estiver ligada na API.
   ============================================================ */
function criarSimulacao() {
  // Relógio simulado: começa às 07:40 (pico da manhã) e anda junto com o relógio real
  const inicioReal = Date.now();
  const inicio = new Date();
  inicio.setHours(7, 40, 0, 0);
  const agora = () => new Date(inicio.getTime() + (Date.now() - inicioReal));

  const MINUTO = 60 * 1000;
  const PASSO = 5000; // a simulação anda de 5 em 5 segundos
  const aleatorio = (min, max) => min + Math.random() * (max - min);
  const inteiro = (min, max) => Math.floor(aleatorio(min, max + 1));
  const horaDoDia = (texto) => {
    const [h, m, s] = texto.split(':').map(Number);
    const data = new Date(inicio);
    data.setHours(h, m, s, 0);
    return data;
  };

  // Frota fictícia. "base" é a ocupação típica neste horário (0 a 1).
  const frota = [
    { idOnibus: 1021, linha: '101', trajeto: 'Centro ↔ Bairro Norte', capacidade: 80, base: 0.78, ciclo: 7 },
    { idOnibus: 1022, linha: '101', trajeto: 'Centro ↔ Bairro Norte', capacidade: 80, base: 0.84, ciclo: 6 },
    { idOnibus: 1023, linha: '101', trajeto: 'Centro ↔ Bairro Norte', capacidade: 80, base: 0.41, ciclo: 9 },
    { idOnibus: 1024, linha: '101', trajeto: 'Centro ↔ Bairro Norte', capacidade: 80, base: 0.6, ciclo: 8, semSinalDesde: '07:35:40' },
    { idOnibus: 2041, linha: '202', trajeto: 'Terminal Leste ↔ Universidade', capacidade: 120, base: 0.64, ciclo: 8 },
    { idOnibus: 2042, linha: '202', trajeto: 'Terminal Leste ↔ Universidade', capacidade: 120, base: 0.95, ciclo: 7 },
    { idOnibus: 3011, linha: '303', trajeto: 'Rodoviária ↔ Distrito Industrial', capacidade: 80, base: 0.9, ciclo: 5 },
    { idOnibus: 3012, linha: '303', trajeto: 'Rodoviária ↔ Distrito Industrial', capacidade: 80, base: 0.57, ciclo: 9 },
    { idOnibus: 4005, linha: '404', trajeto: 'Circular do Hospital', capacidade: 45, base: 0.33, ciclo: 6 },
    { idOnibus: 4006, linha: '404', trajeto: 'Circular do Hospital', capacidade: 45, base: 0.72, ciclo: 7 },
  ];

  // Alertas que "já aconteceram" antes de a página abrir
  const alertas = [
    { dataHora: horaDoDia('07:38:12'), idOnibus: 2042, linha: '202', tipo: 'lotado', ocupacao: 96 },
    { dataHora: horaDoDia('07:37:40'), idOnibus: 1024, linha: '101', tipo: 'sem-sinal', ultimaLeitura: horaDoDia('07:35:40') },
    { dataHora: horaDoDia('07:31:05'), idOnibus: 3011, linha: '303', tipo: 'lotado', ocupacao: 92 },
    { dataHora: horaDoDia('07:20:02'), idOnibus: 1022, linha: '101', tipo: 'normalizado', ocupacao: 83 },
    { dataHora: horaDoDia('07:12:30'), idOnibus: 1022, linha: '101', tipo: 'lotado', ocupacao: 91 },
  ];

  // Ocupação desejada no instante t: oscila em torno da base para os números mudarem
  const alvo = (onibus, t) => {
    const onda = Math.sin((2 * Math.PI * (t - inicio)) / (onibus.ciclo * MINUTO));
    return Math.min(1.08, Math.max(0.05, onibus.base + 0.07 * onda));
  };

  function registrarPassagens(onibus, entram, saem, instante) {
    for (let i = 0; i < entram; i++) {
      onibus.eventos.push({ dataHora: new Date(instante - inteiro(0, PASSO - 1)), tipo: 'entrada', porta: 'dianteira' });
    }
    for (let i = 0; i < saem; i++) {
      onibus.eventos.push({ dataHora: new Date(instante - inteiro(0, PASSO - 1)), tipo: 'saida', porta: 'traseira' });
    }
    onibus.eventos.sort((a, b) => b.dataHora - a.dataHora);
    onibus.eventos.length = Math.min(onibus.eventos.length, 30);
    onibus.entradas += entram;
    onibus.saidas += saem;
    onibus.lotacao = onibus.entradas - onibus.saidas; // a regra principal do DataBus
  }

  function atualizarHistorico(onibus, instante) {
    onibus.historico.pop(); // tira o ponto "agora"
    let ultimo = onibus.historico[onibus.historico.length - 1].dataHora.getTime();
    while (ultimo + 5 * MINUTO <= instante.getTime()) {
      ultimo += 5 * MINUTO;
      onibus.historico.push({ dataHora: new Date(ultimo), lotacao: onibus.lotacao });
    }
    onibus.historico.push({ dataHora: instante, lotacao: onibus.lotacao });
  }

  // Alerta com folga: entra em "lotado" com 90% e só sai abaixo de 85%,
  // para não gerar um alerta a cada passageiro perto do limite
  function verificarAlertas(onibus, instante) {
    const ocupacao = Math.round((onibus.lotacao / onibus.capacidade) * 100);
    if (!onibus.emLotacao && ocupacao >= LIMITE_LOTADO) {
      onibus.emLotacao = true;
      alertas.unshift({ dataHora: instante, idOnibus: onibus.idOnibus, linha: onibus.linha, tipo: 'lotado', ocupacao });
    } else if (onibus.emLotacao && ocupacao < LIMITE_LOTADO - 5) {
      onibus.emLotacao = false;
      alertas.unshift({ dataHora: instante, idOnibus: onibus.idOnibus, linha: onibus.linha, tipo: 'normalizado', ocupacao });
    }
  }

  // Estado inicial: histórico do dia desde 05:00 e totais coerentes com a lotação
  const abertura = horaDoDia('05:00:00');
  const t0 = agora();
  for (const onibus of frota) {
    const fim = onibus.semSinalDesde ? horaDoDia(onibus.semSinalDesde) : t0;
    onibus.lotacao = Math.round(onibus.base * onibus.capacidade);
    onibus.saidas = Math.round(onibus.capacidade * aleatorio(3.2, 5.2));
    onibus.entradas = onibus.saidas + onibus.lotacao;
    onibus.ultimaLeitura = onibus.semSinalDesde ? fim : new Date(t0 - inteiro(1, 4) * 1000);
    onibus.emLotacao = onibus.lotacao / onibus.capacidade >= LIMITE_LOTADO / 100;

    onibus.historico = [];
    for (let t = abertura.getTime(); t < fim.getTime(); t += 5 * MINUTO) {
      const progresso = (t - abertura) / (fim - abertura);
      const valor = onibus.base * (0.18 + 0.82 * progresso ** 1.6) * (1 + aleatorio(-0.08, 0.08));
      onibus.historico.push({ dataHora: new Date(t), lotacao: Math.round(Math.min(1.1, valor) * onibus.capacidade) });
    }
    onibus.historico.push({ dataHora: fim, lotacao: onibus.lotacao });

    onibus.eventos = [];
    for (let i = 0; i < 12; i++) {
      const tipo = Math.random() < 0.55 ? 'entrada' : 'saida';
      onibus.eventos.push({
        dataHora: new Date(fim - inteiro(2, 180) * 1000),
        tipo,
        porta: tipo === 'entrada' ? 'dianteira' : 'traseira',
      });
    }
    onibus.eventos.sort((a, b) => b.dataHora - a.dataHora);
  }

  let ultimoPasso = t0;
  function avancar() {
    const passos = Math.floor((agora() - ultimoPasso) / PASSO);
    for (let p = 1; p <= passos; p++) {
      const instante = new Date(ultimoPasso.getTime() + p * PASSO);
      for (const onibus of frota) {
        if (onibus.semSinalDesde) continue; // este ônibus parou de transmitir
        if (Math.random() < 0.5) {          // metade do tempo o ônibus está numa parada
          const diferenca = alvo(onibus, instante) * onibus.capacidade - onibus.lotacao;
          const entram = Math.max(0, Math.round(diferenca * 0.4 + aleatorio(0, 3)));
          const saem = Math.min(onibus.lotacao + entram, Math.max(0, Math.round(-diferenca * 0.4 + aleatorio(0, 3))));
          registrarPassagens(onibus, entram, saem, instante);
        }
        onibus.ultimaLeitura = new Date(instante - inteiro(0, 2) * 1000);
        atualizarHistorico(onibus, instante);
        verificarAlertas(onibus, instante);
      }
    }
    if (passos > 0) ultimoPasso = new Date(ultimoPasso.getTime() + passos * PASSO);
  }

  const porId = (id) => frota.find((onibus) => onibus.idOnibus === id);
  const iso = (data) => data.toISOString();

  return {
    agora,
    lotacao() {
      avancar();
      return frota.map((onibus) => ({
        idOnibus: onibus.idOnibus,
        linha: onibus.linha,
        trajeto: onibus.trajeto,
        capacidade: onibus.capacidade,
        entradas: onibus.entradas,
        saidas: onibus.saidas,
        lotacao: onibus.lotacao,
        ocupacao: Math.round((onibus.lotacao / onibus.capacidade) * 1000) / 10,
        ultimaLeitura: iso(onibus.ultimaLeitura),
      }));
    },
    historico(id) {
      return porId(id).historico.map((ponto) => ({ dataHora: iso(ponto.dataHora), lotacao: ponto.lotacao }));
    },
    eventos(id, limite) {
      return porId(id).eventos.slice(0, limite).map((evento) => ({ ...evento, dataHora: iso(evento.dataHora) }));
    },
    alertas(limite) {
      return alertas.slice(0, limite).map((alerta) => ({
        ...alerta,
        dataHora: iso(alerta.dataHora),
        ...(alerta.ultimaLeitura && { ultimaLeitura: iso(alerta.ultimaLeitura) }),
      }));
    },
  };
}
