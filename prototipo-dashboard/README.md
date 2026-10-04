# Protótipo da dashboard DataBus

Referência visual e de código para o site do DataBus: a tela em que as empresas de transporte acompanham a lotação da frota. Usa só HTML, CSS e JavaScript (o gráfico usa Chart.js) e roda com **dados simulados** no navegador, no mesmo formato que a API vai devolver.

## Como abrir

Abra o `index.html` no navegador. A fonte e o Chart.js vêm da internet; sem conexão, a página continua funcionando e mostra o histórico em tabela.

## O que a tela mostra

| Área | O que responde |
|---|---|
| Indicadores | Quantos ônibus estão lotados, quantos passageiros estão a bordo, a ocupação média e quantos ônibus estão transmitindo |
| Frota agora | A situação de cada ônibus, com os lotados primeiro |
| Alertas | Quando um ônibus ficou lotado, saiu da lotação ou parou de transmitir |
| Detalhe do ônibus | Lotação agora, a regra principal em forma de conta (entradas − saídas = lotação), o gráfico do dia e os últimos eventos dos sensores |

Situações: **normal** abaixo de 70% da capacidade, **atenção** de 70% a 89%, **lotado** a partir de 90% e **sem sinal** quando o ônibus passa mais de 2 minutos sem mandar dados. Os limites ficam no início do `script.js`.

## Arquivos

| Arquivo | Conteúdo |
|---|---|
| `index.html` | Estrutura da página |
| `style.css` | Visual: cores em variáveis CSS, tema claro e escuro, layout para celular |
| `script.js` | Busca dos dados, regras de exibição, gráfico e, no fim do arquivo, a simulação |

## Como ligar na API real

1. No `script.js`, seção 3, cada função já tem o `fetch` em comentário. Descomente o `fetch` e apague a linha `return simulacao...`:

   ```js
   async function buscarLotacao() {
     const resposta = await fetch('/api/lotacao');
     return await resposta.json();
   }
   ```

2. Em `horaAtual()`, use `return new Date();`.
3. Apague a seção de simulação no fim do arquivo e a linha `const simulacao = criarSimulacao();` no início.

Formato que a dashboard espera de cada endpoint:

```text
GET /api/lotacao
[{ "idOnibus": 1021, "linha": "101", "trajeto": "Centro ↔ Bairro Norte", "capacidade": 80,
   "entradas": 418, "saidas": 356, "lotacao": 62, "ocupacao": 77.5,
   "ultimaLeitura": "2026-10-04T10:42:15.000Z" }]

GET /api/onibus/1021/historico         → [{ "dataHora": "…", "lotacao": 58 }]  (um ponto a cada 5 min)
GET /api/onibus/1021/eventos?limite=8  → [{ "dataHora": "…", "tipo": "entrada", "porta": "dianteira" }]
GET /api/alertas?limite=20             → [{ "dataHora": "…", "idOnibus": 2042, "linha": "202",
                                            "tipo": "lotado", "ocupacao": 96 }]
```

Só o `GET /api/lotacao` está no diagrama de arquitetura; os outros três são sugestões para o detalhe e os alertas. Os tipos de alerta são `lotado` e `normalizado` (com `ocupacao`) e `sem-sinal` (com `ultimaLeitura`).

## Pontos de atenção para a versão real

- **Sinal de vida:** o Arduino só manda dados quando alguém passa pela porta. Sem um envio periódico (por exemplo, a cada 30 s), um ônibus andando sem parar aparece como "sem sinal".
- **Cada empresa vê só os seus ônibus:** com login, a API deve devolver apenas a frota da empresa do usuário.
- **Alertas sem repetição:** a simulação usa uma folga. O ônibus entra em "lotado" com 90% e só sai abaixo de 85%, para não gerar um alerta a cada passageiro perto do limite.
