# Política de Uso de IA no Desenvolvimento

**Estamos identificando bugs, aumento da complexidade cognitiva e degradação da qualidade em trechos de código recentes.**

A causa está no uso inadequado de ferramentas de IA (GitHub Copilot, ChatGPT, Claude, etc.) para gerar código sem compreensão adequada do que está sendo implementado.

Este documento estabelece diretrizes claras para o uso responsável de IA no desenvolvimento.

---

## O Problema

Temos encontrado nos commits recentes:

- Bugs relativamente simples de corrigir, mas difíceis de entender e analisar
- Código com complexidade cognitiva elevada sem justificativa
- Soluções over-engineered para problemas simples
- Código incompreensível para a equipe
- Dificuldade de manutenção e evolução

**Exemplo real**: Um bug simples tornou-se difícil de analisar devido à forma como o código gerado por IA foi incorporado, sem que o desenvolvedor compreendesse plenamente a solução.

---

## A Regra Fundamental

**NÃO use IA se você não sabe como resolver o problema.**

Se você não sabe fazer algo manualmente, não use IA para fazer por você.

- Você deve ser capaz de explicar cada linha do código para um colega
- Você deve entender por que aquela solução resolve o problema
- Você deve conhecer as alternativas e seus trade-offs
- Você deve conseguir manter e evoluir esse código no futuro

**Se não consegue explicar em code review, não faça commit.**

---

## Princípios

### IA é Assistente, Não Professor

Ferramentas de IA podem auxiliar a acelerar o que você JÁ SABE FAZER.

IA NÃO deve ser usada para aprender ou implementar algo que você não domina.

Você é o autor e responsável por todo código que commita, independente de quem ou o que o gerou.

### Aprenda Primeiro, Use IA Depois

Antes de usar IA para qualquer tarefa:

1. Você deve SABER como fazer manualmente
2. Você deve ENTENDER os conceitos envolvidos
3. Você deve CONHECER as alternativas de solução

Só então use IA para acelerar algo que você já domina.

### Qualidade Acima de Velocidade

Código legível, simples e manutenível é mais valioso que código gerado rapidamente.

Prefira demorar mais tempo e entregar código de qualidade do que ser rápido e criar débito técnico.

---

## Quando Usar IA

### Boilerplate e Código Repetitivo

Estruturas padrão que você conhece e usa frequentemente.

```csharp
// C#: Estrutura de testes que você JÁ conhece
[Fact]
public void DeveCalcularDescontoCorretamente()
{
    var servico = new DescontoService();
    var resultado = servico.Calcular(100, TipoCliente.Premium);
    Assert.Equal(15, resultado);
}
```

```python
# Python: Estrutura de testes que você JÁ usa
def test_calcular_desconto_corretamente():
    servico = DescontoService()
    resultado = servico.calcular(100, TipoCliente.PREMIUM)
    assert resultado == 15
```

### Refatoração de Código Conhecido

**IMPORTANTE**: Você deve instruir explicitamente a IA sobre o que fazer.

**Processo obrigatório para refatoração com IA**:

1. Informe o design pattern ou técnica a ser aplicada
2. Peça para a IA EXPLICAR o que vai fazer ANTES de fazer
3. Revise a explicação
4. Só então peça para executar
5. Revise o código gerado linha por linha

**Exemplo correto**:

```
VOCÊ: "Quero aplicar Extract Method no bloco de cálculo de total.
Primeiro, explique quais métodos você vai extrair e por quê."

IA: [Explicação detalhada]

VOCÊ: "Ok, agora execute a refatoração conforme explicado."
```

```csharp
// C#: Refatoração com design pattern que VOCÊ escolheu
public decimal CalcularTotal(Pedido pedido)
{
    var subtotal = CalcularSubtotal(pedido.Itens);
    var desconto = CalcularDesconto(pedido.Cliente, subtotal);
    var frete = CalcularFrete(pedido.Endereco);
    return subtotal - desconto + frete;
}
```

**NÃO faça**: "IA, refatore esse código" (muito vago)

**FAÇA**: "Aplicar pattern Strategy para o cálculo de desconto. Explique primeiro como vai fazer."

### Documentação de Código Existente

Gerar documentação para código que você criou e entende.

```python
def calcular_desconto(tipo_cliente: str, valor_pedido: float) -> float:
    """
    Calcula o desconto aplicável baseado no tipo de cliente.
    
    Args:
        tipo_cliente: Tipo do cliente (premium, regular, basic)
        valor_pedido: Valor total do pedido em reais
        
    Returns:
        Valor do desconto em reais
    """
    pass
```

### Testes Unitários

Gerar casos de teste para lógica que VOCÊ implementou e entende.

```python
def test_desconto_cliente_premium():
    resultado = calcular_desconto("premium", 1000)
    assert resultado == 150

def test_desconto_cliente_regular():
    resultado = calcular_desconto("regular", 1000)
    assert resultado == 50
```

---

## Quando NÃO Usar IA

### NUNCA Use IA Para Debugar ou Corrigir Bugs

**PROIBIDO**: Pedir para IA encontrar ou corrigir bugs.

```python
# ERRADO - NÃO FAÇA ISSO
# "IA, esse código tem um bug, conserte"
# "IA, por que essa função não está funcionando?"
# "IA, debug esse código"
```

**Por quê?**
- Você não entenderá a causa raiz do problema
- O bug pode voltar em outra forma
- Você não aprende com o erro
- Gera código que você não compreende

**CORRETO**: Debug manual
1. Use debugger
2. Adicione logs
3. Analise o stack trace
4. Entenda a causa raiz
5. Implemente a correção VOCÊ MESMO

### NUNCA Use IA Para Corrigir Código

Se o código está errado, você deve:

1. Entender por que está errado
2. Diagnosticar o problema
3. Conhecer a solução correta
4. Implementar a correção manualmente

**Só então**, se quiser, use IA para acelerar a digitação de código boilerplate relacionado.

### Lógica de Negócio Complexa

NUNCA gere lógica de negócio sem compreensão total das regras.

```csharp
// C#: NÃO faça isso
public decimal CalcularImpostos(Pedido pedido)
{
    var imposto = pedido.Itens.Sum(item => 
        item.Categoria == "alimento" ? item.Valor * 0.08m :
        item.Categoria == "eletronico" ? item.Valor * 0.15m :
        item.Importado ? item.Valor * 0.20m : item.Valor * 0.12m
    );
    return imposto;
}
// Você entende TODAS essas regras? De onde vieram esses percentuais?
// Quem definiu essas categorias? Está documentado onde?
```

### Algoritmos ou Padrões Desconhecidos

**Se você não conhece, NÃO USE IA.**

```csharp
// NÃO: "IA, implemente Factory Pattern com Dependency Injection"
// se você não sabe o que são esses padrões

// CORRETO:
// 1. Estude Factory Pattern
// 2. Estude Dependency Injection
// 3. Implemente manualmente primeiro
// 4. Depois use IA para acelerar tarefas repetitivas
```

**Regra**: Se você não consegue implementar na mão, não peça para IA fazer.

### Código de Segurança

NUNCA gere código relacionado a segurança sem expertise completa.

```python
# NÃO faça isso
def encriptar_senha(senha):
    # Código gerado por IA sem compreensão
    pass

# Faça isso - use bibliotecas estabelecidas que você ENTENDE
from werkzeug.security import generate_password_hash
hash = generate_password_hash(senha)
```

### Integrações Críticas

Pagamentos, integrações bancárias, APIs críticas: você deve dominar completamente.

```csharp
// NÃO gere código de integração crítica sem domínio completo
public async Task ProcessarPagamento(Pagamento pagamento)
{
    // Você deve SABER implementar isso sem IA
    // Você deve ENTENDER fluxo, erros, rollback, idempotência
}
```

---

## Checklist Antes do Commit

Responda honestamente antes de commitar código assistido por IA:

1. Eu sei fazer isso SEM IA?
2. Eu entendo completamente cada linha deste código?
3. Eu consigo explicar essa solução para um colega?
4. Eu sei por que essa é a melhor abordagem?
5. Eu conheço as alternativas e seus trade-offs?
6. O código está simples e legível?
7. Eu consigo debugar e manter este código?
8. O código segue nossos padrões de qualidade?

**Se você respondeu NÃO para a pergunta 1, você NÃO deveria ter usado IA.**

**Se você respondeu NÃO para qualquer outra pergunta, não faça commit.**

---

## Boas Práticas

### Instrua Explicitamente a IA

Sempre diga à IA:
- Qual técnica ou pattern aplicar
- O que você espera como resultado
- Peça explicação antes da implementação

```
ERRADO: "IA, melhore esse código"
ERRADO: "IA, refatore esse método"
ERRADO: "IA, otimize essa função"

CERTO: "Aplicar Extract Method para separar validação de processamento. Explique primeiro."
CERTO: "Usar Strategy Pattern para os cálculos. Descreva a estrutura antes."
CERTO: "Implementar Repository Pattern. Mostre a hierarquia de classes primeiro."
```

### Peça Explicação Primeiro

Antes de aceitar código da IA:

1. Peça para explicar o que vai fazer
2. Revise a explicação
3. Confirme se está correto
4. Só então peça a implementação
5. Revise linha por linha

### Revise e Simplifique

IA frequentemente gera código over-engineered. Sempre simplifique.

```python
# Código gerado por IA (complexo)
def processar(pedido):
    return (lambda p: {**p, 'total': sum([i['preco'] * i['qtd'] 
            for i in p['itens']]) * (1 - p.get('desconto', 0))})(pedido)

# Sua versão (simples)
def processar(pedido):
    subtotal = sum(item['preco'] * item['qtd'] for item in pedido['itens'])
    desconto = pedido.get('desconto', 0)
    return subtotal * (1 - desconto)
```

### Adicione Contexto

Explique decisões e regras de negócio.

```csharp
public decimal CalcularDesconto(TipoCliente tipo, decimal valor)
{
    // Regra de negócio definida em REQ-DESC-001:
    // Clientes premium recebem 15% de desconto em todos os produtos
    if (tipo == TipoCliente.Premium)
        return valor * 0.15m;
    
    return 0;
}
```

---

## Responsabilidade

**Você é o autor do código, não a IA.**

- Bugs em código gerado por IA são SUA responsabilidade
- Problemas de qualidade são SUA responsabilidade
- Problemas de segurança são SUA responsabilidade
- Débito técnico gerado é SUA responsabilidade

**Não existe desculpa** do tipo:
- "Mas a IA gerou assim"
- "Mas a IA disse que estava certo"
- "Mas eu não sabia fazer, então usei IA"

Se você não sabe fazer, NÃO USE IA. Aprenda primeiro.

---

## Em Caso de Dúvida

Se você não tem certeza se deve usar IA em determinada situação:

1. Pergunte ao Tech Lead
2. Discuta em code review
3. Na dúvida, NÃO use

**Regra simples**: Se você não sabe fazer sem IA, não use IA.

**É melhor demorar mais e fazer certo do que rápido e errado.**

A velocidade de desenvolvimento não vale a pena se o resultado for código de baixa qualidade que gera bugs e débito técnico.

---

## Resumo

**Use IA SOMENTE para:**
- Acelerar tarefas que você JÁ DOMINA
- Gerar boilerplate de estruturas que você JÁ CONHECE
- Documentar código que VOCÊ escreveu
- Testes de código que VOCÊ implementou

**NUNCA use IA para:**
- Debugar ou corrigir bugs
- Corrigir código com erro
- Implementar algo que você não sabe fazer
- Resolver problemas que você não compreende
- Algoritmos ou padrões que você não conhece
- Código crítico de segurança ou integrações
- Substituir seu aprendizado

**Regra de ouro**: Se você não consegue fazer sem IA, você não pode usar IA.

---

**Versão:** 1.0  
**Status:** Ativo  
**Vigência:** Imediata

Contamos com a colaboração de todos para mantermos o padrão de qualidade do código.
