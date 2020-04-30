        .text
        .globl  addsb
        .type   addsb, @function

addsb:
        #Na podstawie zadania 4. z listy 2.

        # 0x7F7F7F7F -> 01111111011111110111111101111111
        # 0x80808080 -> 10000000100000001000000010000000
        # s = (x & 0x7F7F7F7F) + (y & 0x7F7F7F7F)
        # s = ((x ^ y) & 0x80808080) ^ s
        # wyifować [over|under]flow

        # %r8 <- 0x7F7F7F7F = 0b01111111011111110111111101111111
        # %r9 <- 0x80808080 = 0b10000000100000001000000010000000
        movq $0x7F7F7F7F7F7F7F7F, %r8
        movq $0x8080808080808080, %r9
        
        # %rdi <- x_original
        # %rsi <- y_original


        # s = (x & 0x7F7F7F7F) + (y & 0x7F7F7F7F)

        # Kopiowanie x i y na potrzeby obliczeń.
        movq %rdi, %rax # %rax <- x1
        movq %rsi, %rdx # %rdx <- y1

        # x1 <- x1 ^ r8
        # y1 <- y1 ^ r8
        # res <- x1 + y1
        and %r8, %rax
        and %r8, %rdx
        add %rdx, %rax

        # Konstruujemy odpowiedź bez nasycania.
        # s = ((x ^ y) & 0x80808080) ^ s
        movq %rdi, %r12
        xor %rsi, %r12
        and %r9, %r12
        xor %r12, %rax

        # Do tego miejsca implementowaliśmy zadanie z listy.

        # Pomysł jest taki, że znajdujemy wszystkie miejsca, gdzie jest flow. Strzelamy, że jest to overflow.
        # Następnie wśród tych miejsc znajdujemy, gdzie tak naprawdę są underflow'y.
        # Odpowiednia kolejność wpisywania 7F i 80 nadpisze nam nieprawidłlowe flow'y (if'y na końcu).


        # Czy jest [under|over]flow.
        # x[7]==y[7] && x[7]!=res[7]
        # %r11 <- [under|over]flow
        movq %rdi, %r11
        xor %rsi, %r11# r11 <- xnor x, y
        not %r11
        movq %rax, %r13# r13 <- xor x, res       # Why no xnor? Przecież jest w dokumentacji.
        xor %rdi, %r13
        and %r13, %r11# r11 <- and r11, r13
        and %r9, %r11

        # Czy jest konkretnie underflow.
        # Żeby był flow potrzebujemy jednakowych najstarszych bitów w operandach i różnego od nich najstarszego bitu w wyniku.
        # Skoro to już mamy znalezione, to wystarczy sprawdzić gdzie jest 1 na najstarszym bicie x.
        # Wykorzystujemy ponownie %rdi. Od tego miejsca już nie ma w nim parametru.
        # %rdi <- underflow
        and %r11, %rdi

        # Rozpropagować bity [under|over]flow po ich całych bajtach.
        movq %rdi, %r13
        shr $1, %r13
        or %r13, %rdi
        movq %rdi, %r13
        shr $2, %r13
        or %r13, %rdi
        movq %rdi, %r13
        shr $4, %r13
        or %r13, %rdi
        
        # Rozpropagować bity underflow po ich całych bajtach.
        movq %r11, %r13#tmp
        shr $1, %r13
        or %r13, %r11
        movq %r11, %r13
        shr $2, %r13
        or %r13, %r11
        movq %r11, %r13
        shr $4, %r13
        or %r13, %r11

        # If dla [under|over]flow'u
        # Działa na zasadzie b&x + ~b&y (z listy zadań). Bitowo działa, jak powinno, jeśli b ma wszystkie swoje bity takie same.
        not %r11
        and %r11, %rax
        not %r11
        and %r8, %r11
        add %r11, %rax

        # If dla underflow'u
        # Nadpisujemy nieprawidłowe flow'y z poprzedniego if'a
        not %rdi
        and %rdi, %rax
        not %rdi
        and %r9, %rdi
        add %rdi, %rax

        ret

        .size   addsb, .-addsb
