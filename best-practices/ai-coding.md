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

**Se você não entende completamente o código gerado pela IA, NÃO o utilize.**

Não há exceções a esta regra.

- Você deve ser capaz de explicar cada linha do código para um colega
- Você deve entender por que aquela solução resolve o problema
- Você deve conhecer as alternativas e seus trade-offs
- Você deve conseguir manter e evoluir esse código no futuro

**Se não consegue explicar em code review, não faça commit.**

---

## Princípios

### IA é Assistente, Não Autor

Ferramentas de IA podem auxiliar, mas não devem ser usadas quando não houver entendimento claro do que está sendo implementado.

Você é o autor e responsável por todo código que commita, independente de quem ou o que o gerou.

### Compreensão é Obrigatória

Código que você não entende:
- Gera bugs difíceis de rastrear
- Aumenta a complexidade cognitiva
- Dificulta manutenção
- Compromete a qualidade do produto

### Qualidade Acima de Velocidade

Código legível, simples e manutenível é mais valioso que código gerado rapidamente.

Prefira demorar mais tempo e entregar código de qualidade do que ser rápido e criar débito técnico.

---

## Quando Usar IA

### Boilerplate e Código Repetitivo

Estruturas padrão que você conhece e usa frequentemente.

```csharp
// C#: Estrutura de testes
[Fact]
public void DeveCalcularDescontoCorretamente()
{
    var servico = new DescontoService();
    var resultado = servico.Calcular(100, TipoCliente.Premium);
    Assert.Equal(15, resultado);
}
```

```python
# Python: Estrutura de testes
def test_calcular_desconto_corretamente():
    servico = DescontoService()
    resultado = servico.calcular(100, TipoCliente.PREMIUM)
    assert resultado == 15
```

### Refatoração de Código Conhecido

Quando você escreveu o código e entende completamente, IA pode ajudar a reorganizá-lo.

```csharp
// C#: Extrair métodos de um bloco longo
public decimal CalcularTotal(Pedido pedido)
{
    var subtotal = CalcularSubtotal(pedido.Itens);
    var desconto = CalcularDesconto(pedido.Cliente, subtotal);
    var frete = CalcularFrete(pedido.Endereco);
    return subtotal - desconto + frete;
}
```

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

Gerar casos de teste para lógica que você implementou.

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

### Lógica de Negócio Complexa

Nunca gere lógica de negócio sem compreensão total das regras.

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

### Correção de Bugs

Nunca peça para IA "consertar" um bug sem diagnosticar e entender a causa raiz.

```python
# NÃO faça: "IA, conserte esse bug de autenticação"
# FAÇA: Entenda o bug, diagnostique, então implemente a correção
```

### Algoritmos ou Padrões Desconhecidos

Se você não conhece o padrão ou algoritmo, aprenda primeiro. Não deixe IA implementar algo que você não domina.

```csharp
// NÃO: Pedir IA para gerar "Factory Pattern com Dependency Injection"
// se você não sabe o que são esses padrões

// SIM: Estude os padrões, entenda-os, então use IA para acelerar
```

### Código de Segurança

Nunca gere código relacionado a segurança, autenticação, autorização ou criptografia sem expertise completa.

```python
# NÃO faça isso
def encriptar_senha(senha):
    # Código gerado por IA sem compreensão
    pass

# Faça isso - use bibliotecas estabelecidas
from werkzeug.security import generate_password_hash
hash = generate_password_hash(senha)
```

### Integrações Críticas

Pagamentos, integrações bancárias, APIs críticas exigem compreensão total do fluxo e tratamento de erros.

```csharp
// NÃO gere código de integração crítica sem domínio completo
public async Task ProcessarPagamento(Pagamento pagamento)
{
    // Você deve entender completamente o fluxo de pagamento
    // tratamento de erros, rollback, idempotência, etc.
}
```

---

## Checklist Antes do Commit

Responda honestamente antes de commitar código assistido por IA:

1. Eu entendo completamente cada linha deste código?
2. Eu consigo explicar essa solução para um colega em code review?
3. Eu sei por que essa é a melhor abordagem para o problema?
4. Eu conheço as alternativas e seus trade-offs?
5. O código está simples e legível?
6. Eu consigo manter e debugar este código no futuro?
7. O código segue nossos padrões de qualidade?
8. Eu testei adequadamente?

**Se você respondeu NÃO para qualquer pergunta, não faça commit.**

---

## Boas Práticas

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

### Use Como Ponto de Partida

1. Peça sugestão para a IA
2. Estude a sugestão
3. Adapte para seu contexto
4. Simplifique se necessário
5. Teste completamente
6. Documente decisões não óbvias

### Adicione Contexto

Explique decisões e regras de negócio, mesmo que óbvias para você.

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

Não existe desculpa do tipo "mas a IA gerou assim". Você escolheu usar e commitar aquele código.

---

## Em Caso de Dúvida

Se você não tem certeza se deve usar IA em determinada situação:

1. Pergunte ao Tech Lead
2. Discuta em code review
3. Na dúvida, NÃO use

**É melhor demorar mais e fazer certo do que rápido e errado.**

A velocidade de desenvolvimento não vale a pena se o resultado for código de baixa qualidade que gera bugs e débito técnico.

---

## Resumo

**Use IA para:**
- Acelerar tarefas que você já domina
- Gerar boilerplate e código repetitivo
- Explorar alternativas de solução
- Documentar código que você escreveu

**NÃO use IA para:**
- Gerar código que você não entende
- Resolver problemas que você não compreende
- Substituir seu aprendizado e conhecimento técnico
- Código crítico de segurança ou integrações

---

**Versão:** 1.0  
**Status:** Ativo  
**Vigência:** Imediata

Contamos com a colaboração de todos para mantermos o padrão de qualidade do código.