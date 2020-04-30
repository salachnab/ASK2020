	.text
	.globl	bitrev
	.type	bitrev, @function

bitrev:
		movq %rdi, %rax

		# Pomysł jest bardzo podobny do zliczania bitów, które było na którejś z pierwszych list.
		# Najpierw zamieniamy sąsiednie bity, następnie sąsiednie pary, czwórki, itd.

		# Wyciągamy bity parzyste.
		movq $0x5555555555555555, %rcx#010101...
		and %rcx, %rax
		# Wyciągamy bity nieparzyste.
		movq $0xAAAAAAAAAAAAAAAA, %rcx#101010...
		and %rcx, %rdi
		# Parzyste o 1 w lewo, nieparzyste o 1 w prawo - zamieniamy sąsiadów miejscami.
		salq $1, %rax
		shrq $1, %rdi
		# Łączymy w jeden ciąg bitów - z zamienionymi sąsiadującumi bitami.
		or %rdi, %rax

		# Następne kroki analogicznie, tylko zamiast na bitach operujemy na  parach, czwórkach, itd.

		movq %rax, %rdi
		movq $0x3333333333333333, %rcx#00110011...
		and %rcx, %rax
		movq $0xCCCCCCCCCCCCCCCC, %rcx#11001100...
		and %rcx, %rdi
		salq $2, %rax
		shrq $2, %rdi
		or %rdi, %rax

		movq %rax, %rdi
		movq $0x0F0F0F0F0F0F0F0F, %rcx
		and %rcx, %rax
		movq $0xF0F0F0F0F0F0F0F0, %rcx
		and %rcx, %rdi
		salq $4, %rax
		shrq $4, %rdi
		or %rdi, %rax

		movq %rax, %rdi
		movq $0x00FF00FF00FF00FF, %rcx
		and %rcx, %rax
		movq $0xFF00FF00FF00FF00, %rcx
		and %rcx, %rdi
		salq $8, %rax
		shrq $8, %rdi
		or %rdi, %rax

		movq %rax, %rdi
		movq $0x0000FFFF0000FFFF, %rcx
		and %rcx, %rax
		movq $0xFFFF0000FFFF0000, %rcx
		and %rcx, %rdi
		salq $16, %rax
		shrq $16, %rdi
		or %rdi, %rax

		movq %rax, %rdi
		movq $0x00000000FFFFFFFF, %rcx
		and %rcx, %rax
		shrq $32, %rdi
#		movq $0xFFFFFFFF00000000, %rcx
#		and %rcx, %rdi
		salq $32, %rax
#		shrq $32, %rdi
		or %rdi, %rax
		#This little maneuver is gonna cost us 47 instructions
	ret

	.size	bitrev, .-bitrev
