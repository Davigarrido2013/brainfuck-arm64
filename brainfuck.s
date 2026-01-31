// Implementação de uma linguagem Turing-completa
// usando outra linguagem Turing-completa pior ainda

.section .rodata
    titulo: .ascii "Brainfuck Interpreter\n\nDigite \"A\" para escolher um arquivo.\n\n"
    tam= .-titulo
    input: .ascii "\033[H\033[2JDigite o nome do arquivo: "
    tinput= .-input
    res: .ascii "\033[H\033[2JOutput:\n\n"
    tres= .-res
    inv: .ascii "'[' e ']' não fechados corretamente!\n"
    tinv= .-inv
    erro_msg: .ascii "Caractere inválido: "
    terro= .-erro_msg
    error: .ascii "Erro ao abrir arquivo!\n\n"
    terror= .-error
    quebra: .byte 10

.section .bss
    memoria: .skip 30000
    entrada: .skip 32768
    file: .skip 64

.section .text
.global _start

_start:
    mov x8, 64
    mov x0, 1
    adr x1, titulo
    mov x2, tam
    svc 0

    mov x8, 63
    mov x0, 0
    adr x1, entrada
    mov x2, 32768
    svc 0

    ldrb w10, [x1]
    bl arquivo

    mov x8, 64
    mov x0, 1
    adr x1, res
    mov x2, tres
    svc 0

    adr x1, memoria
    mov x9, 0
    mov x5, sp

    b leitura

arquivo:
    sub sp, sp, 16
    str x30, [sp]

    cmp w10, 'A'
    bne return

    mov x8, 64
    mov x0, 1
    adr x1, input
    mov x2, tinput
    svc 0

    mov x8, 63
    mov x0, 0
    adr x1, file
    mov x2, 64
    svc 0

    bl removerNl

    mov x8, 56
    mov x0, -100
    adr x1, file
    mov x2, 0
    mov x3, 0
    svc 0

    cmp x0, 0
    blt erro2
    mov x9, x0

    mov x8, 63
    mov x0, x9
    adr x1, entrada
    mov x2, 32768
    svc 0

    mov x8, 57
    mov x0, x9
    svc 0

    ldr x30, [sp]
    add sp, sp, 16

return:
    ret

leitura:
    adr x3, entrada
    ldrb w6, [x3,x9]

    cmp w6, '\n'
    beq fim
    cmp w6, '+'
    beq sum
    cmp w6, '-'
    beq subt
    cmp w6, '>'
    beq front
    cmp w6, '<'
    beq back
    cmp w6, '['
    beq loop_1
    cmp w6, ']'
    beq loop_2
    cmp w6, '.'
    beq imprime
    cmp w6, ','
    beq ler
    b erro

sum:
    ldrb w6, [x1]
    add w6, w6, 1
    strb w6, [x1]

    add x9, x9, 1
    b leitura

subt:
    ldrb w6, [x1]
    sub w6, w6, 1
    strb w6, [x1]

    add x9, x9, 1
    b leitura

front:
    add x1, x1, 1

    add x9, x9, 1
    b leitura

back:
    sub x1, x1, 1

    add x9, x9, 1
    b leitura

loop_1:
    ldrb w6, [x1]
    cbz w6, pula_loop

    sub sp, sp, 16
    add x9, x9, 1
    str x9, [sp]

    b leitura

pula_loop:
    mov w10, 1

skip_loop:
    ldrb w6, [x3,x9]
    add x9, x9, 1

    cmp w6, '\n'
    beq invalido

    cmp w6, '['
    beq inc_depth

    cmp w6, ']'
    beq dec_depth

    b skip_loop

inc_depth:
    add w10, w10, 1
    b skip_loop

dec_depth:
    sub w10, w10, 1
    cbnz w10, skip_loop
    b leitura

loop_2:
    mov x7, sp
    cmp x5, x7
    beq invalido

    ldrb w6, [x1]
    cbz w6, sai_loop

    ldr x9, [sp]
    b leitura

sai_loop:
    add sp, sp, 16
    add x9, x9, 1
    b leitura

invalido:
    mov x8, 64
    mov x0, 1
    adr x1, inv
    mov x2, tinv
    svc 0

    mov x8, 93
    mov x0, 1
    svc 0

erro:
    add x7, x3, x9

    mov x8, 64
    mov x0, 1
    adr x1, erro_msg
    mov x2, terro
    svc 0

    mov x8, 64
    mov x0, 1
    mov x1, x7
    mov x2, 1
    svc 0

    mov x8, 64
    mov x0, 1
    adr x1, quebra
    mov x2, 1
    svc 0

    mov x8, 93
    mov x0, 1
    svc 0

erro2:
    mov x8, 64
    mov x0, 1
    adr x1, error
    mov x2, terror
    svc 0

    mov x8, 93
    mov x0, 1
    svc 0

removerNl:
    mov x5, 0

loop_remove:
    ldrb w6, [x1,x5]

    cmp w6, 10
    beq remover

    add x5, x5, 1
    b loop_remove

remover:
    strb wzr, [x1,x5]
    ret

imprime:
    mov x8, 64
    mov x0, 1
    mov x2, 1
    svc 0

    add x9, x9, 1
    b leitura

ler:
    mov x8, 63
    mov x0, 0
    mov x2, 1
    svc 0

    add x9, x9, 1
    b leitura

fim:
    mov x8, 93
    mov x0, 0
    svc 0
