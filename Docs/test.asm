; Testes aritméticos e lógicos
addi r1, r0, 5; r1 = 5 (esperado: r1 = 5)
addi r2, r0, 10; r2 = 10 (esperado: r2 = 10)
add r3, r1, r2; r3 = 5 + 10 (esperado: r3 = 5)
sub r4, r1, r2; r4 = 5 - 10 (esperado: r4 = -5)
slli r5, r1, 1; r5 = r1 << 1 (esperado: r5 = 10)
srli s0, r2, 2; s0 = r2 >> 2 (esperado: s0 = 2)
and s1, r1, r2; s1 = r1 and r2 (esperado: s1 = 0)
or s2, r1, r2; s2 = r1 or r2 (esperado: s2 = 15)
xor s3, r1, r2; s3 = r1 xor r2 (esperado: s3 = 15)
not r3, r1; r3 = not r1 + 1 (esperado: r3 = 11111011)
; testes de comparacao
slt r3, r1, r2; 5 < 10 ? 1 : 0 (esperado: r3 = 1) 
slt r4, r2, r1; 10 < 5 ? 1 : 0 (esperado: r4 = 0)
; testes de desvios
beq r1, r2, 2; dont jump (5 != 10)
addi r5, r0, 11; (executa a operacao)
beq r1, r1, 2; jump (5 == 5)
addi r5, r0, 2; (nao executa)
; esperado que r5 = 11
; testes de load e store 
addi sp, sp, -4; aloca espaco na stack
sw sp, r1, 4; salva o conteudo de r1 na stack
lw r3, sp, 0; carrega o conteudo da stack no endereco 0 apontado
addi sp, sp 4; (esperado: r3 = 5) e desaloca da stack
; saltos e chamadas de funções
; função para calcular os termos de fibonacci
addi a0, r0, 4 ; a0 = 4 (quarto termo da sequência)
jal ra, 3(fib); chama a função
add a0, a0, a0; a0 += a0 (esperado: a0 = 4)
ebreak ; fim :)
fib:
addi r1, r0, 0; penul = 0
addi r2, r0, 0; ult = 1
addi r3, r0, 2; i = 2
beq a0, r0, 10(fim); Se n = 0, acabou a funcao
slt r4, a0, r3; a0 < i (4 < 2) ? r4 = 1
loop:
beq r4, r0, 7(fim); r4 == r0 ? (Inicio do loop)
add r5, r1, r2; atual = penul + ult
add r1, r0, r2; penul = ult
add r2, r0, r5; ult = atual
addi r3, r3, 1; i++
slt r4, r3, a0; a0 < i (usado no beq novamente ate ser 0)
jal r0, -6(loop)
add a0, r0, r5; a0 = r5 - transfere o valor para a0
jalr r0, ra, 0; return
