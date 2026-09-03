<a id="readme-top"></a>

[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<br />
<div align="center">
  <h3 align="center">🧠 ISA 24-bit — Definição e Implementação</h3>

  <p align="center">
    Definição de uma ISA personalizada de 24 bits e sua microarquitetura monociclo, implementada no Logisim-Evolution — trabalho da disciplina Projetos Digitais e Microprocessadores (CI1210) na UFPR.
    <br />
    <a href="https://github.com/GiuTP/ISA-Monociclo/issues/new?labels=bug">Reportar Bug</a>
    &middot;
    <a href="https://github.com/GiuTP/ISA-Monociclo/issues/new?labels=enhancement">Sugerir Melhoria</a>
  </p>
</div>

---

<!-- SUMÁRIO -->
<details>
  <summary>Sumário</summary>
  <ol>
    <li><a href="#-sobre-o-projeto">Sobre o Projeto</a>
      <ul>
        <li><a href="#-construído-com">Construído com</a></li>
      </ul>
    </li>
    <li><a href="#-arquitetura-da-isa">Arquitetura da ISA</a></li>
    <li><a href="#-conjunto-de-instruções">Conjunto de Instruções</a></li>
    <li><a href="#-registradores">Registradores</a></li>
    <li><a href="#-microarquitetura--componentes">Microarquitetura / Componentes</a></li>
    <li><a href="#-fluxo-de-dados">Fluxo de Dados</a></li>
    <li><a href="#-estrutura-do-projeto">Estrutura do Projeto</a></li>
    <li><a href="#-como-simular">Como Simular</a></li>
    <li><a href="#-dificuldades-e-aprendizados">Dificuldades e Aprendizados</a></li>
    <li><a href="#-licença">Licença</a></li>
    <li><a href="#-contato">Contato</a></li>
    <li><a href="#-agradecimentos">Agradecimentos</a></li>
  </ol>
</details>

---

## 📖 Sobre o Projeto

**ISA 24-bit** é uma arquitetura de conjunto de instruções (*Instruction Set Architecture*) completamente original, desenvolvida para a disciplina **Projetos Digitais e Microprocessadores (CI1210)** da **Universidade Federal do Paraná (UFPR)**.

O projeto foi dividido em três partes: **definição da ISA** (formatos, instruções e convenção de registradores), **implementação da microarquitetura monociclo** no simulador Logisim-Evolution, e **tradução de um programa em assembly** para linguagem de máquina — testando todas as instruções criadas. A ISA foi inspirada no RISC-V (RV32I/RV32C), mas com formato de instrução único de 24 bits e palavra de 32 bits, constituindo uma arquitetura *load/store* original.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

### 🛠 Construído com

* [![Logisim][Logisim-badge]][Logisim-url]

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## ⏱ Arquitetura da ISA

A instrução possui **24 bits** com **formato único** (ao contrário do RISC-V, não há funct3 nem múltiplos formatos), dividida assim do bit menos significativo ao mais significativo:

```
 23      16  15     12  11      8  7       4  3       0
+----------+---------+---------+---------+-----------+
|  IMM[7:0]|  RD[3:0]| RS2[3:0]| RS1[3:0]| Opcode[3:0]|
+----------+---------+---------+---------+-----------+
```

| Campo | Bits | Descrição |
|-------|------|-----------|
| `Opcode` | [3:0] | Código da operação (16 instruções possíveis) |
| `RS1` | [7:4] | Endereço do registrador fonte 1 |
| `RS2` | [11:8] | Endereço do registrador fonte 2 |
| `RD` | [15:12] | Endereço do registrador destino |
| `IMM` | [23:16] | Imediato de 8 bits com sinal (complemento de 2, intervalo [-128, 127]) |

> **Palavra:** 32 bits — o imediato é estendido de 8 para 32 bits pela unidade de extensão de bits antes de chegar à ULA.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 📋 Conjunto de Instruções

### Aritméticas

| Opcode | Mnemônico | Operação | Descrição |
|--------|-----------|----------|-----------|
| `0000` | **ADD** | `RD ← RS1 + RS2` | Soma dois registradores |
| `0001` | **SUB** | `RD ← RS1 - RS2` | Subtrai RS2 de RS1 |
| `0010` | **ADDI** | `RD ← RS1 + IMM` | Soma registrador com imediato |
| `0011` | **SLLI** | `RD ← RS1 << IMM` | Shift left lógico (equivale a × 2ⁿ) |
| `0100` | **SRLI** | `RD ← RS1 >> IMM` | Shift right lógico (equivale a ÷ 2ⁿ) |

### Lógicas

| Opcode | Mnemônico | Operação | Descrição |
|--------|-----------|----------|-----------|
| `0101` | **AND** | `RD ← RS1 && RS2` | E lógico bit a bit |
| `0110` | **OR** | `RD ← RS1 \|\| RS2` | OU lógico bit a bit |
| `0111` | **XOR** | `RD ← RS1 XOR RS2` | OU-exclusivo bit a bit |
| `1000` | **NOT** | `RD ← ~RS1 + 1` | Complemento de dois de RS1 |
| `1001` | **SLT** | `RD ← RS1 < RS2 ? 1 : 0` | Compara e seta 1 se menor |

### Desvio Condicional

| Opcode | Mnemônico | Operação | Descrição |
|--------|-----------|----------|-----------|
| `1010` | **BEQ** | `PC ← RS1==RS2 ? PC+IMM : PC+1` | Salta se RS1 == RS2 |

### Memória (Load/Store)

| Opcode | Mnemônico | Operação | Descrição |
|--------|-----------|----------|-----------|
| `1011` | **LW** | `RD ← MD[RS1 + IMM]` | Carrega palavra da memória |
| `1100` | **SW** | `MD[RS1 + IMM] ← RS2` | Armazena palavra na memória |

### Saltos Incondicionais

| Opcode | Mnemônico | Operação | Descrição |
|--------|-----------|----------|-----------|
| `1101` | **JAL** | `RD ← PC+1; PC ← PC+IMM` | Salto com link — chamada de função e loops |
| `1110` | **JALR** | `RD ← PC+1; PC ← RS1+IMM` | Salto indireto — retorno de função |

### Controle

| Opcode | Mnemônico | Operação | Descrição |
|--------|-----------|----------|-----------|
| `1111` | **EBREAK** | `PC ← PC` | Para a execução do programa |

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 🗂 Registradores

O banco de registradores possui **16 registradores de 32 bits**, endereçados por 4 bits:

| Endereço | Nome genérico | Nome ABI | Função | Salvo? |
|----------|--------------|----------|--------|--------|
| `0000` | x0 | **r0** | Constante 0 (hardwired) | N.A. |
| `0001` | x1 | **a0** | Argumento / Retorno de função | Temporário |
| `0010` | x2 | **a1** | Argumento / Retorno de função | Temporário |
| `0011` | x3 | **a2** | Argumento de função | Temporário |
| `0100` | x4 | **a3** | Argumento de função | Temporário |
| `0101` | x5 | **ra** | Return address | Temporário |
| `0110` | x6 | **sp** | Stack pointer | Temporário |
| `0111` | x7 | **r1** | Uso geral | Temporário |
| `1000` | x8 | **r2** | Uso geral | Temporário |
| `1001` | x9 | **r3** | Uso geral | Temporário |
| `1010` | x10 | **r4** | Uso geral | Temporário |
| `1011` | x11 | **r5** | Uso geral | Temporário |
| `1100` | x12 | **s0** | Uso geral salvo | Salvo |
| `1101` | x13 | **s1** | Uso geral salvo | Salvo |
| `1110` | x14 | **s2** | Uso geral salvo | Salvo |
| `1111` | x15 | **s3** | Uso geral salvo | Salvo |

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 🔧 Microarquitetura

A implementação é **monociclo**: cada instrução completa em um único ciclo de clock.

| Componente | Especificação | Função |
|------------|--------------|--------|
| **PC** | Registrador de 32 bits | Aponta para a instrução atual na ROM |
| **PC Adder** | Somador dedicado | Calcula `PC+1` ou `PC+IMM` sem usar a ULA |
| **ROM** | Memória de instruções (24-bit/posição) | Armazena o programa codificado |
| **RAM** | Memória de dados (32-bit/posição) | Dados para LW/SW |
| **Banco de Registradores** | 16 registradores × 32 bits | Armazena operandos e resultados |
| **ULA** | Opera em 32 bits | Executa ADD, SUB, AND, OR, XOR, SLLI, SRLI, NOT |
| **Unidade de Controle** | Tabela-verdade por opcode | Gera sinais: WE, WM, Op_ULA, MUX_PC, MUX_Reg, Branch, FreezePC |
| **Bit Extender** | 8→32 bits (imediato), 32→24 (PC→ROM), 1→32 (flag de sinal) | Compatibilidade de largura entre módulos |
| **Multiplexadores** | Vários (2:1 e 4:1) | Roteiam PC next, entrada da ULA, write-data do banco |

```
         ROM (instrução 24b)
              |
     +--------+--------+
     | Unidade de      |
     | Controle        |---> sinais de controle (WE, WM, Branch…)
     +--------+--------+
              |
  PC ──> PC Adder ──> MUX_PC ──> PC (próximo)
              |
  RS1 ─────> ULA <───── MUX (RS2 | IMM)
              |
           MUX_Reg ──> Banco de Registradores (WD)
              |
            RAM (LW/SW)
```

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 🔄 Fluxo de Dados

| Instrução | Caminho de dados ativo |
|-----------|----------------------|
| **Tipo R** (ADD, SUB, AND…) | ROM → UC → ULA(RS1, RS2) → RD |
| **Tipo I** (ADDI, SLLI, LW…) | ROM → UC → ULA(RS1, IMM_ext) → RD |
| **SW** | ROM → UC → ULA(RS1, IMM_ext) → endereço RAM; RS2 → dado RAM |
| **BEQ** | ROM → UC → ULA compara RS1==RS2; se true → PC+IMM, senão → PC+1 |
| **JAL** | ROM → UC → RD ← PC+1; PC ← PC+IMM |
| **JALR** | ROM → UC → RD ← PC+1; PC ← RS1+IMM |
| **EBREAK** | UC → FreezePC=1 → PC congela |

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 📁 Estrutura do Projeto

```
trabalho-isa-24-bits-GiuTP/
├── ISA.circ                          circuito completo da microarquitetura (Logisim)
├── Docs/
│   ├── Greencard.pdf                 tabela completa de instruções (opcode, operação, descrição)
│   ├── Informações da ISA.pdf        formato de instrução, grupos de operações e decisões de projeto
│   ├── Convenção dos registradores.pdf  tabela ABI dos 16 registradores
│   ├── Componentes usados na ISA.pdf   documentação de cada unidade funcional e tabela-verdade da UC
│   ├── test.asm                      código assembly de teste cobrindo todas as instruções
│   ├── Teste completo.txt            código de máquina (hex) pronto para carregar na ROM do Logisim
│   └── cm.txt                        arquivo auxiliar de código de máquina
└── README.md
```

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 🚀 Como Simular

### 📦 Pré-requisitos

É necessário o simulador **Logisim-Evolution** (Java):

1. Baixe o [logisim-evolution](https://github.com/logisim-evolution/logisim-evolution/releases/latest) (arquivo `.jar`).
2. Tenha o **Java 11+** instalado:
   ```sh
   sudo apt install default-jre -y
   ```

### ▶️ Executando

1. Clone o repositório:
   ```sh
   git clone https://github.com/GiuTP/ISA-Monociclo.git
   cd ISA-Monociclo
   ```
2. Abra o simulador:
   ```sh
   java -jar /caminho/para/logisim-evolution.jar
   ```
3. Abra o arquivo `ISA.circ` pelo menu **File → Open**.
4. Carregue o programa de teste na ROM:
   - Clique com o botão direito na **ROM** dentro do circuito.
   - Selecione **Load image...** e escolha `Docs/Teste completo.txt`.
5. Clique em **▶ Simulate → Ticks Enabled** para iniciar a execução passo a passo.

### 🧪 Testando com o emulador EGG

O código assembly em `Docs/test.asm` também pode ser validado com o emulador **EGG** antes de carregar no Logisim:

```sh
# Repositório do autor: https://github.com/gboncoffee
egg test.asm
```

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 📚 Dificuldades e Aprendizados

- **Entender o fluxo de dados em um processador "real"** — Compreender como cada instrução percorre os blocos (ROM → UC → ULA → Banco de Registradores → RAM) e como os sinais de controle orquestram esse fluxo foi o principal aprendizado do projeto. Ver isso funcionando no Logisim tornou o conceito concreto de uma forma que a teoria sozinha não consegue.
- **Construir tudo do zero** — Diferente de adaptar uma ISA existente, definir formatos, escolher quantos registradores, dimensionar o imediato e implementar cada componente funcional sem referência pronta exigiu muitas decisões de projeto e revisões.
- **Depurar código assembly** — Traduzir manualmente o assembly para linguagem de máquina e identificar erros bit a bit foi extremamente trabalhoso. O emulador **EGG** (de [@gboncoffee](https://github.com/gboncoffee)) foi essencial para validar o comportamento esperado antes de testar no circuito, economizando muito tempo de debug no Logisim.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 📄 Licença

O código-fonte deste projeto está distribuído sob a licença **MIT**. Consulte o arquivo `LICENSE` para mais informações.

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 📬 Contato

GiuTP — [github.com/GiuTP](https://github.com/GiuTP)

E-mail — giulianotpt@gmail.com

Link do projeto: [https://github.com/GiuTP/ISA-Monociclo](https://github.com/GiuTP/ISA-Monociclo)

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

## 🙏 Agradecimentos

* [@gboncoffee](https://github.com/gboncoffee) — autor do emulador EGG, fundamental para depuração do assembly
* [logisim-evolution](https://github.com/logisim-evolution/logisim-evolution) — simulador de circuitos digitais utilizado
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template) — template base deste README

<p align="right">(<a href="#readme-top">voltar ao topo</a>)</p>

---

<!-- MARKDOWN LINKS & IMAGES -->
[stars-shield]: https://img.shields.io/github/stars/UFPR-Daniel-Oliveira/trabalho-isa-24-bits-GiuTP.svg?style=for-the-badge
[stars-url]: https://github.com/GiuTP/ISA-Monociclo/stargazers
[issues-shield]: https://img.shields.io/github/issues/UFPR-Daniel-Oliveira/trabalho-isa-24-bits-GiuTP.svg?style=for-the-badge
[issues-url]: https://github.com/GiuTP/ISA-Monociclo/issues
[license-shield]: https://img.shields.io/github/license/UFPR-Daniel-Oliveira/trabalho-isa-24-bits-GiuTP.svg?style=for-the-badge
[license-url]: https://github.com/GiuTP/ISA-Monociclo/blob/main/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/GiuTP/
[Logisim-badge]: https://img.shields.io/badge/Logisim--Evolution-Simulator-orange?style=for-the-badge&logo=electron&logoColor=white
[Logisim-url]: https://github.com/logisim-evolution/logisim-evolution
