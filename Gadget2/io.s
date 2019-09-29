	.file	"io.c"
	.local	n_type
	.comm	n_type,24,16
	.local	ntot_type_all
	.comm	ntot_type_all,48,32
	.section	.rodata
.LC0:
	.string	"\nwriting snapshot file... "
	.align 8
.LC1:
	.string	"Fatal error.\nNumber of processors must be larger or equal than All.NumFilesPerSnapshot."
.LC2:
	.string	"Unsupported File-Format"
	.align 8
.LC3:
	.string	"Code wasn't compiled with HDF5 support enabled!"
.LC4:
	.string	"%s%s_%03d.%d"
.LC5:
	.string	"%s%s_%03d"
.LC6:
	.string	"done with snapshot."
	.text
	.globl	savepositions
	.type	savepositions, @function
savepositions:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$592, %rsp
	movl	%edi, -580(%rbp)
	call	second
	movq	%xmm0, %rax
	movq	%rax, -32(%rbp)
	movl	ThisTask(%rip), %eax
	testl	%eax, %eax
	jne	.L2
	movl	$.LC0, %edi
	call	puts
.L2:
	movl	All+40(%rip), %edx
	movl	NTask(%rip), %eax
	cmpl	%eax, %edx
	jle	.L3
	movl	ThisTask(%rip), %eax
	testl	%eax, %eax
	jne	.L4
	movl	$.LC1, %edi
	call	puts
.L4:
	movl	$0, %edi
	call	endrun
.L3:
	movl	All+36(%rip), %eax
	testl	%eax, %eax
	jle	.L5
	movl	All+36(%rip), %eax
	cmpl	$3, %eax
	jle	.L6
.L5:
	movl	ThisTask(%rip), %eax
	testl	%eax, %eax
	jne	.L7
	movl	$.LC2, %edi
	call	puts
.L7:
	movl	$0, %edi
	call	endrun
.L6:
	movl	All+36(%rip), %eax
	cmpl	$3, %eax
	jne	.L8
	movl	ThisTask(%rip), %eax
	testl	%eax, %eax
	jne	.L9
	movl	$.LC3, %edi
	call	puts
.L9:
	movl	$0, %edi
	call	endrun
.L8:
	movl	$0, -12(%rbp)
	jmp	.L10
.L11:
	movl	-12(%rbp), %eax
	cltq
	movl	$0, n_type(,%rax,4)
	addl	$1, -12(%rbp)
.L10:
	cmpl	$5, -12(%rbp)
	jle	.L11
	movl	$0, -12(%rbp)
	jmp	.L12
.L13:
	movq	P(%rip), %rcx
	movl	-12(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	movslq	%eax, %rdx
	movl	n_type(,%rdx,4), %edx
	addl	$1, %edx
	cltq
	movl	%edx, n_type(,%rax,4)
	addl	$1, -12(%rbp)
.L12:
	movl	NumPart(%rip), %eax
	cmpl	%eax, -12(%rbp)
	jl	.L13
	movl	NTask(%rip), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, -40(%rbp)
	movq	-40(%rbp), %rax
	subq	$8, %rsp
	pushq	$1140850688
	movl	$1275069445, %r9d
	movl	$6, %r8d
	movq	%rax, %rcx
	movl	$1275069445, %edx
	movl	$6, %esi
	movl	$n_type, %edi
	call	MPI_Allgather
	addq	$16, %rsp
	movl	$0, -4(%rbp)
	jmp	.L14
.L17:
	movl	-4(%rbp), %eax
	cltq
	movq	$0, ntot_type_all(,%rax,8)
	movl	$0, -8(%rbp)
	jmp	.L15
.L16:
	movl	-4(%rbp), %eax
	cltq
	movq	ntot_type_all(,%rax,8), %rcx
	movl	-8(%rbp), %edx
	movl	%edx, %eax
	addl	%eax, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	%eax, %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-40(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	cltq
	leaq	(%rcx,%rax), %rdx
	movl	-4(%rbp), %eax
	cltq
	movq	%rdx, ntot_type_all(,%rax,8)
	addl	$1, -8(%rbp)
.L15:
	movl	NTask(%rip), %eax
	cmpl	%eax, -8(%rbp)
	jl	.L16
	addl	$1, -4(%rbp)
.L14:
	cmpl	$5, -4(%rbp)
	jle	.L17
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	free
	movl	NTask(%rip), %eax
	leal	-1(%rax), %ecx
	movl	All+40(%rip), %eax
	leaq	-568(%rbp), %rdi
	leaq	-564(%rbp), %rsi
	subq	$8, %rsp
	leaq	-572(%rbp), %rdx
	pushq	%rdx
	movq	%rdi, %r9
	movq	%rsi, %r8
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	distribute_file
	addq	$16, %rsp
	call	fill_Tab_IO_Labels
	movl	All+40(%rip), %eax
	cmpl	$1, %eax
	jle	.L18
	movl	-564(%rbp), %ecx
	movl	-580(%rbp), %edx
	leaq	-560(%rbp), %rax
	movl	%ecx, %r9d
	movl	%edx, %r8d
	movl	$All+1088, %ecx
	movl	$All+988, %edx
	movl	$.LC4, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf
	jmp	.L19
.L18:
	movl	-580(%rbp), %edx
	leaq	-560(%rbp), %rax
	movl	%edx, %r8d
	movl	$All+1088, %ecx
	movl	$All+988, %edx
	movl	$.LC5, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf
.L19:
	movl	All+40(%rip), %eax
	movl	All+44(%rip), %esi
	cltd
	idivl	%esi
	movl	%eax, -20(%rbp)
	movl	All+40(%rip), %eax
	movl	All+44(%rip), %ecx
	cltd
	idivl	%ecx
	movl	%edx, %eax
	testl	%eax, %eax
	je	.L20
	addl	$1, -20(%rbp)
.L20:
	movl	$0, -16(%rbp)
	jmp	.L21
.L23:
	movl	-564(%rbp), %eax
	movl	All+44(%rip), %esi
	cltd
	idivl	%esi
	cmpl	-16(%rbp), %eax
	jne	.L22
	movl	-572(%rbp), %edx
	movl	-568(%rbp), %ecx
	leaq	-560(%rbp), %rax
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	write_file
.L22:
	movl	$1140850688, %edi
	call	MPI_Barrier
	addl	$1, -16(%rbp)
.L21:
	movl	-16(%rbp), %eax
	cmpl	-20(%rbp), %eax
	jl	.L23
	movl	ThisTask(%rip), %eax
	testl	%eax, %eax
	jne	.L24
	movl	$.LC6, %edi
	call	puts
.L24:
	call	second
	movq	%xmm0, %rax
	movq	%rax, -48(%rbp)
	movsd	-48(%rbp), %xmm0
	movq	-32(%rbp), %rax
	movapd	%xmm0, %xmm1
	movq	%rax, -592(%rbp)
	movsd	-592(%rbp), %xmm0
	call	timediff
	movapd	%xmm0, %xmm1
	movsd	All+464(%rip), %xmm0
	addsd	%xmm1, %xmm0
	movsd	%xmm0, All+464(%rip)
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	savepositions, .-savepositions
	.globl	fill_write_buffer
	.type	fill_write_buffer, @function
fill_write_buffer:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$120, %rsp
	.cfi_offset 3, -24
	movl	%edi, -100(%rbp)
	movq	%rsi, -112(%rbp)
	movl	%edx, -104(%rbp)
	movl	%ecx, -116(%rbp)
	movsd	.LC7(%rip), %xmm0
	movsd	%xmm0, -72(%rbp)
	movl	All+280(%rip), %eax
	testl	%eax, %eax
	je	.L26
	movsd	All+368(%rip), %xmm1
	movsd	All+368(%rip), %xmm0
	mulsd	%xmm1, %xmm0
	movsd	All+368(%rip), %xmm1
	mulsd	%xmm1, %xmm0
	movsd	.LC7(%rip), %xmm1
	divsd	%xmm0, %xmm1
	movapd	%xmm1, %xmm0
	movsd	%xmm0, -72(%rbp)
	movsd	All+368(%rip), %xmm1
	movsd	All+368(%rip), %xmm0
	mulsd	%xmm1, %xmm0
	movsd	.LC7(%rip), %xmm1
	divsd	%xmm0, %xmm1
	movapd	%xmm1, %xmm0
	movsd	%xmm0, -80(%rbp)
	movq	All+368(%rip), %rax
	movsd	.LC8(%rip), %xmm0
	movapd	%xmm0, %xmm1
	movq	%rax, -128(%rbp)
	movsd	-128(%rbp), %xmm0
	call	pow
	movapd	%xmm0, %xmm1
	movsd	.LC7(%rip), %xmm0
	divsd	%xmm1, %xmm0
	movsd	%xmm0, -88(%rbp)
	jmp	.L27
.L26:
	movsd	.LC7(%rip), %xmm0
	movsd	%xmm0, -88(%rbp)
	movsd	-88(%rbp), %xmm0
	movsd	%xmm0, -80(%rbp)
	movsd	-80(%rbp), %xmm0
	movsd	%xmm0, -72(%rbp)
.L27:
	movq	CommBuffer(%rip), %rax
	movq	%rax, -40(%rbp)
	movq	CommBuffer(%rip), %rax
	movq	%rax, -48(%rbp)
	movq	-112(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -28(%rbp)
	cmpl	$10, -100(%rbp)
	ja	.L28
	movl	-100(%rbp), %eax
	movq	.L30(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L30:
	.quad	.L29
	.quad	.L31
	.quad	.L32
	.quad	.L33
	.quad	.L34
	.quad	.L35
	.quad	.L36
	.quad	.L71
	.quad	.L71
	.quad	.L71
	.quad	.L71
	.text
.L29:
	movl	$0, -20(%rbp)
	jmp	.L41
.L45:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L42
	movl	$0, -24(%rbp)
	jmp	.L43
.L44:
	movl	-24(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-40(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	leaq	(%rsi,%rax), %rdx
	movl	-24(%rbp), %eax
	cltq
	movss	(%rdx,%rax,4), %xmm0
	movss	%xmm0, (%rcx)
	addl	$1, -24(%rbp)
.L43:
	cmpl	$2, -24(%rbp)
	jle	.L44
	addl	$1, -20(%rbp)
	addq	$12, -40(%rbp)
.L42:
	addl	$1, -28(%rbp)
.L41:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L45
	jmp	.L28
.L31:
	movl	$0, -20(%rbp)
	jmp	.L46
.L55:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L47
	movl	All+280(%rip), %eax
	testl	%eax, %eax
	je	.L48
	movl	All+408(%rip), %ecx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	60(%rax), %eax
	movl	%ecx, %esi
	movl	%eax, %edi
	call	get_gravkick_factor
	movsd	%xmm0, -128(%rbp)
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	60(%rax), %ecx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	56(%rax), %eax
	addl	%ecx, %eax
	movl	%eax, %edx
	shrl	$31, %edx
	addl	%edx, %eax
	sarl	%eax
	movl	%eax, %esi
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	60(%rax), %eax
	movl	%eax, %edi
	call	get_gravkick_factor
	movsd	-128(%rbp), %xmm2
	subsd	%xmm0, %xmm2
	movapd	%xmm2, %xmm0
	movsd	%xmm0, -56(%rbp)
	movl	All+408(%rip), %ecx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	60(%rax), %eax
	movl	%ecx, %esi
	movl	%eax, %edi
	call	get_hydrokick_factor
	movsd	%xmm0, -128(%rbp)
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	60(%rax), %ecx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	56(%rax), %eax
	addl	%ecx, %eax
	movl	%eax, %edx
	shrl	$31, %edx
	addl	%edx, %eax
	sarl	%eax
	movl	%eax, %esi
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	60(%rax), %eax
	movl	%eax, %edi
	call	get_hydrokick_factor
	movsd	-128(%rbp), %xmm3
	subsd	%xmm0, %xmm3
	movapd	%xmm3, %xmm0
	movsd	%xmm0, -64(%rbp)
	jmp	.L49
.L48:
	movl	All+408(%rip), %ecx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	60(%rax), %esi
	movq	P(%rip), %rdi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdi, %rax
	movl	56(%rax), %eax
	addl	%esi, %eax
	movl	%eax, %edx
	shrl	$31, %edx
	addl	%edx, %eax
	sarl	%eax
	negl	%eax
	addl	%ecx, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sd	%eax, %xmm0
	movsd	All+400(%rip), %xmm1
	mulsd	%xmm1, %xmm0
	movsd	%xmm0, -64(%rbp)
	movsd	-64(%rbp), %xmm0
	movsd	%xmm0, -56(%rbp)
.L49:
	movl	$0, -24(%rbp)
	jmp	.L50
.L52:
	movl	-24(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-40(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	addq	$4, %rdx
	movss	(%rax,%rdx,4), %xmm0
	cvtss2sd	%xmm0, %xmm1
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	addq	$4, %rdx
	movss	12(%rax,%rdx,4), %xmm0
	cvtss2sd	%xmm0, %xmm0
	mulsd	-56(%rbp), %xmm0
	addsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%rcx)
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	testl	%eax, %eax
	jne	.L51
	movl	-24(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-40(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movl	-24(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-40(%rbp), %rax
	addq	%rdx, %rax
	movss	(%rax), %xmm0
	cvtss2sd	%xmm0, %xmm1
	movq	SphP(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	addq	$8, %rdx
	movss	(%rax,%rdx,4), %xmm0
	cvtss2sd	%xmm0, %xmm0
	mulsd	-64(%rbp), %xmm0
	addsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%rcx)
.L51:
	addl	$1, -24(%rbp)
.L50:
	cmpl	$2, -24(%rbp)
	jle	.L52
	movl	$0, -24(%rbp)
	jmp	.L53
.L54:
	movq	-72(%rbp), %rax
	movq	%rax, -128(%rbp)
	movsd	-128(%rbp), %xmm0
	call	sqrt
	movapd	%xmm0, %xmm1
	movl	-24(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-40(%rbp), %rax
	addq	%rdx, %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	leaq	0(,%rdx,4), %rcx
	movq	-40(%rbp), %rdx
	addq	%rcx, %rdx
	movss	(%rdx), %xmm0
	cvtss2sd	%xmm0, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%rax)
	addl	$1, -24(%rbp)
.L53:
	cmpl	$2, -24(%rbp)
	jle	.L54
	addl	$1, -20(%rbp)
	addq	$12, -40(%rbp)
.L47:
	addl	$1, -28(%rbp)
.L46:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L55
	jmp	.L28
.L32:
	movl	$0, -20(%rbp)
	jmp	.L56
.L58:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L57
	movq	-48(%rbp), %rdx
	leaq	4(%rdx), %rax
	movq	%rax, -48(%rbp)
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rcx
	movq	%rcx, %rax
	salq	$4, %rax
	addq	%rcx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movl	48(%rax), %eax
	movl	%eax, (%rdx)
	addl	$1, -20(%rbp)
.L57:
	addl	$1, -28(%rbp)
.L56:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L58
	jmp	.L28
.L33:
	movl	$0, -20(%rbp)
	jmp	.L59
.L61:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L60
	movq	-40(%rbp), %rdx
	leaq	4(%rdx), %rax
	movq	%rax, -40(%rbp)
	movq	P(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rcx
	movq	%rcx, %rax
	salq	$4, %rax
	addq	%rcx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movss	12(%rax), %xmm0
	movss	%xmm0, (%rdx)
	addl	$1, -20(%rbp)
.L60:
	addl	$1, -28(%rbp)
.L59:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L61
	jmp	.L28
.L34:
	movl	$0, -20(%rbp)
	jmp	.L62
.L64:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L63
	movq	-40(%rbp), %rbx
	leaq	4(%rbx), %rax
	movq	%rax, -40(%rbp)
	movq	SphP(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movss	(%rax), %xmm0
	cvtss2sd	%xmm0, %xmm0
	movsd	.LC9(%rip), %xmm1
	divsd	%xmm1, %xmm0
	movsd	%xmm0, -128(%rbp)
	movq	SphP(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movss	4(%rax), %xmm0
	cvtss2sd	%xmm0, %xmm0
	mulsd	-72(%rbp), %xmm0
	movsd	.LC9(%rip), %xmm1
	call	pow
	mulsd	-128(%rbp), %xmm0
	movq	All+128(%rip), %rax
	movapd	%xmm0, %xmm1
	movq	%rax, -128(%rbp)
	movsd	-128(%rbp), %xmm0
	call	dmax
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%rbx)
	addl	$1, -20(%rbp)
.L63:
	addl	$1, -28(%rbp)
.L62:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L64
	jmp	.L28
.L35:
	movl	$0, -20(%rbp)
	jmp	.L65
.L67:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L66
	movq	-40(%rbp), %rcx
	leaq	4(%rcx), %rax
	movq	%rax, -40(%rbp)
	movq	SphP(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movss	4(%rax), %xmm0
	movss	%xmm0, (%rcx)
	addl	$1, -20(%rbp)
.L66:
	addl	$1, -28(%rbp)
.L65:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L67
	jmp	.L28
.L36:
	movl	$0, -20(%rbp)
	jmp	.L68
.L70:
	movq	P(%rip), %rcx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$4, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rcx, %rax
	movl	52(%rax), %eax
	cmpl	-116(%rbp), %eax
	jne	.L69
	movq	-40(%rbp), %rcx
	leaq	4(%rcx), %rax
	movq	%rax, -40(%rbp)
	movq	SphP(%rip), %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rsi, %rax
	movss	8(%rax), %xmm0
	movss	%xmm0, (%rcx)
	addl	$1, -20(%rbp)
.L69:
	addl	$1, -28(%rbp)
.L68:
	movl	-20(%rbp), %eax
	cmpl	-104(%rbp), %eax
	jl	.L70
	jmp	.L28
.L71:
	nop
.L28:
	movq	-112(%rbp), %rax
	movl	-28(%rbp), %edx
	movl	%edx, (%rax)
	nop
	addq	$120, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	fill_write_buffer, .-fill_write_buffer
	.globl	get_bytes_per_blockelement
	.type	get_bytes_per_blockelement, @function
get_bytes_per_blockelement:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)
	movl	$0, -4(%rbp)
	cmpl	$10, -20(%rbp)
	ja	.L73
	movl	-20(%rbp), %eax
	movq	.L75(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L75:
	.quad	.L74
	.quad	.L74
	.quad	.L76
	.quad	.L77
	.quad	.L77
	.quad	.L77
	.quad	.L77
	.quad	.L77
	.quad	.L74
	.quad	.L77
	.quad	.L77
	.text
.L74:
	movl	$12, -4(%rbp)
	jmp	.L73
.L76:
	movl	$4, -4(%rbp)
	jmp	.L73
.L77:
	movl	$4, -4(%rbp)
	nop
.L73:
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	get_bytes_per_blockelement, .-get_bytes_per_blockelement
	.globl	get_datatype_in_block
	.type	get_datatype_in_block, @function
get_datatype_in_block:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)
	movl	-20(%rbp), %eax
	cmpl	$2, %eax
	jne	.L84
	movl	$0, -4(%rbp)
	jmp	.L82
.L84:
	movl	$1, -4(%rbp)
	nop
.L82:
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	get_datatype_in_block, .-get_datatype_in_block
	.globl	get_values_per_blockelement
	.type	get_values_per_blockelement, @function
get_values_per_blockelement:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)
	movl	$0, -4(%rbp)
	cmpl	$10, -20(%rbp)
	ja	.L86
	movl	-20(%rbp), %eax
	movq	.L88(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L88:
	.quad	.L87
	.quad	.L87
	.quad	.L89
	.quad	.L89
	.quad	.L89
	.quad	.L89
	.quad	.L89
	.quad	.L89
	.quad	.L87
	.quad	.L89
	.quad	.L89
	.text
.L87:
	movl	$3, -4(%rbp)
	jmp	.L86
.L89:
	movl	$1, -4(%rbp)
	nop
.L86:
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	get_values_per_blockelement, .-get_values_per_blockelement
	.globl	get_particles_in_block
	.type	get_particles_in_block, @function
get_particles_in_block:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	movl	$0, -8(%rbp)
	movl	$0, -12(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L92
.L96:
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movl	$0, (%rax)
	movl	-4(%rbp), %eax
	cltq
	movl	header(,%rax,4), %eax
	testl	%eax, %eax
	jle	.L93
	movl	-4(%rbp), %eax
	cltq
	movl	header(,%rax,4), %eax
	addl	%eax, -8(%rbp)
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movl	$1, (%rax)
.L93:
	movl	-4(%rbp), %eax
	cltq
	addq	$104, %rax
	movsd	All+8(,%rax,8), %xmm0
	pxor	%xmm1, %xmm1
	ucomisd	%xmm1, %xmm0
	jp	.L94
	pxor	%xmm1, %xmm1
	ucomisd	%xmm1, %xmm0
	jne	.L94
	movl	-4(%rbp), %eax
	cltq
	movl	header(,%rax,4), %eax
	addl	%eax, -12(%rbp)
.L94:
	addl	$1, -4(%rbp)
.L92:
	cmpl	$5, -4(%rbp)
	jle	.L96
	movl	header(%rip), %eax
	movl	%eax, -16(%rbp)
	movl	header+16(%rip), %eax
	movl	%eax, -20(%rbp)
	cmpl	$10, -36(%rbp)
	ja	.L97
	movl	-36(%rbp), %eax
	movq	.L99(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L99:
	.quad	.L98
	.quad	.L98
	.quad	.L98
	.quad	.L100
	.quad	.L101
	.quad	.L101
	.quad	.L101
	.quad	.L98
	.quad	.L98
	.quad	.L101
	.quad	.L98
	.text
.L98:
	movl	-8(%rbp), %eax
	jmp	.L102
.L100:
	movl	$0, -4(%rbp)
	jmp	.L103
.L106:
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movl	$0, (%rax)
	movl	-4(%rbp), %eax
	cltq
	addq	$104, %rax
	movsd	All+8(,%rax,8), %xmm0
	pxor	%xmm1, %xmm1
	ucomisd	%xmm1, %xmm0
	jp	.L104
	pxor	%xmm1, %xmm1
	ucomisd	%xmm1, %xmm0
	jne	.L104
	movl	-4(%rbp), %eax
	cltq
	movl	header(,%rax,4), %eax
	testl	%eax, %eax
	jle	.L104
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movl	$1, (%rax)
.L104:
	addl	$1, -4(%rbp)
.L103:
	cmpl	$5, -4(%rbp)
	jle	.L106
	movl	-12(%rbp), %eax
	jmp	.L102
.L101:
	movl	$1, -4(%rbp)
	jmp	.L107
.L108:
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movl	$0, (%rax)
	addl	$1, -4(%rbp)
.L107:
	cmpl	$5, -4(%rbp)
	jle	.L108
	movl	-16(%rbp), %eax
	jmp	.L102
.L97:
	movl	$212, %edi
	call	endrun
	movl	$0, %eax
.L102:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	get_particles_in_block, .-get_particles_in_block
	.globl	blockpresent
	.type	blockpresent, @function
blockpresent:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	cmpl	$7, -4(%rbp)
	jne	.L112
	movl	$0, %eax
	jmp	.L113
.L112:
	cmpl	$8, -4(%rbp)
	jne	.L114
	movl	$0, %eax
	jmp	.L113
.L114:
	cmpl	$9, -4(%rbp)
	jne	.L115
	movl	$0, %eax
	jmp	.L113
.L115:
	cmpl	$10, -4(%rbp)
	jne	.L116
	movl	$0, %eax
	jmp	.L113
.L116:
	movl	$1, %eax
.L113:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	blockpresent, .-blockpresent
	.globl	fill_Tab_IO_Labels
	.type	fill_Tab_IO_Labels, @function
fill_Tab_IO_Labels:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, -4(%rbp)
	jmp	.L118
.L132:
	cmpl	$10, -4(%rbp)
	ja	.L119
	movl	-4(%rbp), %eax
	movq	.L121(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L121:
	.quad	.L120
	.quad	.L122
	.quad	.L123
	.quad	.L124
	.quad	.L125
	.quad	.L126
	.quad	.L127
	.quad	.L128
	.quad	.L129
	.quad	.L130
	.quad	.L131
	.text
.L120:
	movl	$542330704, Tab_IO_Labels(%rip)
	jmp	.L119
.L122:
	movl	$541869398, Tab_IO_Labels+4(%rip)
	jmp	.L119
.L123:
	movl	$538985545, Tab_IO_Labels+8(%rip)
	jmp	.L119
.L124:
	movl	$1397965133, Tab_IO_Labels+12(%rip)
	jmp	.L119
.L125:
	movl	$538976341, Tab_IO_Labels+16(%rip)
	jmp	.L119
.L126:
	movl	$542066770, Tab_IO_Labels+20(%rip)
	jmp	.L119
.L127:
	movl	$1280136008, Tab_IO_Labels+24(%rip)
	jmp	.L119
.L128:
	movl	$542396240, Tab_IO_Labels+28(%rip)
	jmp	.L119
.L129:
	movl	$1162036033, Tab_IO_Labels+32(%rip)
	jmp	.L119
.L130:
	movl	$1413762629, Tab_IO_Labels+36(%rip)
	jmp	.L119
.L131:
	movl	$1347703636, Tab_IO_Labels+40(%rip)
	nop
.L119:
	addl	$1, -4(%rbp)
.L118:
	cmpl	$10, -4(%rbp)
	jbe	.L132
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	fill_Tab_IO_Labels, .-fill_Tab_IO_Labels
	.globl	get_dataset_name
	.type	get_dataset_name, @function
get_dataset_name:
.LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	movabsq	$32770348699510116, %rdx
	movq	%rdx, (%rax)
	cmpl	$10, -4(%rbp)
	ja	.L147
	movl	-4(%rbp), %eax
	movq	.L136(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L136:
	.quad	.L135
	.quad	.L137
	.quad	.L138
	.quad	.L139
	.quad	.L140
	.quad	.L141
	.quad	.L142
	.quad	.L143
	.quad	.L144
	.quad	.L145
	.quad	.L146
	.text
.L135:
	movq	-16(%rbp), %rax
	movabsq	$7020664749254733635, %rcx
	movq	%rcx, (%rax)
	movl	$7562612, 8(%rax)
	jmp	.L134
.L137:
	movq	-16(%rbp), %rax
	movabsq	$7598814347072922966, %rsi
	movq	%rsi, (%rax)
	movw	$29541, 8(%rax)
	movb	$0, 10(%rax)
	jmp	.L134
.L138:
	movq	-16(%rbp), %rax
	movabsq	$7308325599891841360, %rdi
	movq	%rdi, (%rax)
	movl	$7554121, 8(%rax)
	jmp	.L134
.L139:
	movq	-16(%rbp), %rax
	movl	$1936941389, (%rax)
	movw	$29541, 4(%rax)
	movb	$0, 6(%rax)
	jmp	.L134
.L140:
	movq	-16(%rbp), %rax
	movabsq	$7809644666444607049, %rdx
	movq	%rdx, (%rax)
	movl	$1919249989, 8(%rax)
	movw	$31079, 12(%rax)
	movb	$0, 14(%rax)
	jmp	.L134
.L141:
	movq	-16(%rbp), %rax
	movabsq	$34186468438992196, %rcx
	movq	%rcx, (%rax)
	jmp	.L134
.L142:
	movq	-16(%rbp), %rax
	movabsq	$7956005066021760339, %rsi
	movq	%rsi, (%rax)
	movabsq	$29401385160494183, %rdi
	movq	%rdi, 8(%rax)
	jmp	.L134
.L143:
	movq	-16(%rbp), %rax
	movabsq	$7019269511730982736, %rdx
	movq	%rdx, (%rax)
	movw	$108, 8(%rax)
	jmp	.L134
.L144:
	movq	-16(%rbp), %rax
	movabsq	$7021786285255910209, %rcx
	movq	%rcx, (%rax)
	movl	$1852795252, 8(%rax)
	movb	$0, 12(%rax)
	jmp	.L134
.L145:
	movq	-16(%rbp), %rax
	movabsq	$7512961094574694738, %rsi
	movq	%rsi, (%rax)
	movabsq	$7945869608754835041, %rdi
	movq	%rdi, 8(%rax)
	movl	$1886351988, 16(%rax)
	movw	$121, 20(%rax)
	jmp	.L134
.L146:
	movq	-16(%rbp), %rax
	movabsq	$8099007406428481876, %rdx
	movq	%rdx, (%rax)
	movb	$0, 8(%rax)
	nop
.L134:
.L147:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	get_dataset_name, .-get_dataset_name
	.section	.rodata
.LC11:
	.string	"w"
	.align 8
.LC12:
	.string	"can't open file `%s' for writing snapshot.\n"
.LC13:
	.string	"HEAD"
	.text
	.globl	write_file
	.type	write_file, @function
write_file:
.LFB9:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$192, %rsp
	movq	%rdi, -184(%rbp)
	movl	%esi, -188(%rbp)
	movl	%edx, -192(%rbp)
	movl	$0, -88(%rbp)
	movq	$0, -32(%rbp)
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L149
	movl	$0, -8(%rbp)
	jmp	.L150
.L151:
	movl	-8(%rbp), %eax
	cltq
	movl	n_type(,%rax,4), %edx
	movl	-8(%rbp), %eax
	cltq
	movl	%edx, -112(%rbp,%rax,4)
	addl	$1, -8(%rbp)
.L150:
	cmpl	$5, -8(%rbp)
	jle	.L151
	movl	-188(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -20(%rbp)
	jmp	.L152
.L155:
	movl	-20(%rbp), %edx
	leaq	-144(%rbp), %rax
	subq	$8, %rsp
	leaq	-176(%rbp), %rcx
	pushq	%rcx
	movl	$1140850688, %r9d
	movl	$37, %r8d
	movl	%edx, %ecx
	movl	$1275069445, %edx
	movl	$6, %esi
	movq	%rax, %rdi
	call	MPI_Recv
	addq	$16, %rsp
	movl	$0, -8(%rbp)
	jmp	.L153
.L154:
	movl	-8(%rbp), %eax
	cltq
	movl	-112(%rbp,%rax,4), %edx
	movl	-8(%rbp), %eax
	cltq
	movl	-144(%rbp,%rax,4), %eax
	addl	%eax, %edx
	movl	-8(%rbp), %eax
	cltq
	movl	%edx, -112(%rbp,%rax,4)
	addl	$1, -8(%rbp)
.L153:
	cmpl	$5, -8(%rbp)
	jle	.L154
	addl	$1, -20(%rbp)
.L152:
	movl	-20(%rbp), %eax
	cmpl	-192(%rbp), %eax
	jle	.L155
	movl	-188(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -20(%rbp)
	jmp	.L156
.L157:
	movl	-20(%rbp), %edx
	leaq	-112(%rbp), %rax
	movl	$1140850688, %r9d
	movl	$10, %r8d
	movl	%edx, %ecx
	movl	$1275069445, %edx
	movl	$6, %esi
	movq	%rax, %rdi
	call	MPI_Send
	addl	$1, -20(%rbp)
.L156:
	movl	-20(%rbp), %eax
	cmpl	-192(%rbp), %eax
	jle	.L157
	jmp	.L158
.L149:
	movl	-188(%rbp), %eax
	movl	$1140850688, %r9d
	movl	$37, %r8d
	movl	%eax, %ecx
	movl	$1275069445, %edx
	movl	$6, %esi
	movl	$n_type, %edi
	call	MPI_Send
	movl	-188(%rbp), %edx
	leaq	-112(%rbp), %rax
	subq	$8, %rsp
	leaq	-176(%rbp), %rcx
	pushq	%rcx
	movl	$1140850688, %r9d
	movl	$10, %r8d
	movl	%edx, %ecx
	movl	$1275069445, %edx
	movl	$6, %esi
	movq	%rax, %rdi
	call	MPI_Recv
	addq	$16, %rsp
.L158:
	movl	$0, -8(%rbp)
	jmp	.L159
.L160:
	movl	-8(%rbp), %eax
	cltq
	movl	-112(%rbp,%rax,4), %edx
	movl	-8(%rbp), %eax
	cltq
	movl	%edx, header(,%rax,4)
	movl	-8(%rbp), %eax
	cltq
	movq	ntot_type_all(,%rax,8), %rax
	movl	%eax, %edx
	movl	-8(%rbp), %eax
	cltq
	addq	$24, %rax
	movl	%edx, header(,%rax,4)
	movl	-8(%rbp), %eax
	cltq
	movq	ntot_type_all(,%rax,8), %rax
	sarq	$32, %rax
	movl	%eax, %edx
	movl	-8(%rbp), %eax
	cltq
	addq	$40, %rax
	movl	%edx, header+8(,%rax,4)
	addl	$1, -8(%rbp)
.L159:
	cmpl	$5, -8(%rbp)
	jle	.L160
	movl	$0, -8(%rbp)
	jmp	.L161
.L162:
	movl	-8(%rbp), %eax
	cltq
	addq	$104, %rax
	movsd	All+8(,%rax,8), %xmm0
	movl	-8(%rbp), %eax
	cltq
	addq	$2, %rax
	movsd	%xmm0, header+8(,%rax,8)
	addl	$1, -8(%rbp)
.L161:
	cmpl	$5, -8(%rbp)
	jle	.L162
	movsd	All+368(%rip), %xmm0
	movsd	%xmm0, header+72(%rip)
	movl	All+280(%rip), %eax
	testl	%eax, %eax
	je	.L163
	movsd	All+368(%rip), %xmm1
	movsd	.LC7(%rip), %xmm0
	divsd	%xmm1, %xmm0
	movsd	.LC7(%rip), %xmm1
	subsd	%xmm1, %xmm0
	movsd	%xmm0, header+80(%rip)
	jmp	.L164
.L163:
	pxor	%xmm0, %xmm0
	movsd	%xmm0, header+80(%rip)
.L164:
	movl	$0, header+88(%rip)
	movl	$0, header+92(%rip)
	movl	$0, header+120(%rip)
	movl	$0, header+160(%rip)
	movl	$0, header+164(%rip)
	movl	All+40(%rip), %eax
	movl	%eax, header+124(%rip)
	movsd	All+24(%rip), %xmm0
	movsd	%xmm0, header+128(%rip)
	movsd	All+248(%rip), %xmm0
	movsd	%xmm0, header+136(%rip)
	movsd	All+256(%rip), %xmm0
	movsd	%xmm0, header+144(%rip)
	movsd	All+272(%rip), %xmm0
	movsd	%xmm0, header+152(%rip)
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L165
	movl	All+36(%rip), %eax
	cmpl	$3, %eax
	je	.L165
	movq	-184(%rbp), %rax
	movl	$.LC11, %esi
	movq	%rax, %rdi
	call	fopen
	movq	%rax, -32(%rbp)
	cmpq	$0, -32(%rbp)
	jne	.L166
	movq	-184(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC12, %edi
	movl	$0, %eax
	call	printf
	movl	$123, %edi
	call	endrun
.L166:
	movl	All+36(%rip), %eax
	cmpl	$2, %eax
	jne	.L167
	movl	$8, -148(%rbp)
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
	movq	-32(%rbp), %rax
	movq	%rax, %rcx
	movl	$4, %edx
	movl	$1, %esi
	movl	$.LC13, %edi
	call	my_fwrite
	movl	$264, -52(%rbp)
	movq	-32(%rbp), %rdx
	leaq	-52(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
.L167:
	movl	$256, -148(%rbp)
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
	movq	-32(%rbp), %rax
	movq	%rax, %rcx
	movl	$1, %edx
	movl	$256, %esi
	movl	$header, %edi
	call	my_fwrite
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
.L165:
	movl	-192(%rbp), %eax
	subl	-188(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -36(%rbp)
	movl	$0, -24(%rbp)
	jmp	.L168
.L191:
	movl	-24(%rbp), %eax
	movl	%eax, %edi
	call	blockpresent
	testl	%eax, %eax
	je	.L169
	movl	-24(%rbp), %eax
	movl	%eax, %edi
	call	get_bytes_per_blockelement
	movl	%eax, -40(%rbp)
	movl	All+48(%rip), %eax
	sall	$20, %eax
	cltd
	idivl	-40(%rbp)
	movl	%eax, -44(%rbp)
	leaq	-80(%rbp), %rdx
	movl	-24(%rbp), %eax
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	get_particles_in_block
	movl	%eax, -48(%rbp)
	cmpl	$0, -48(%rbp)
	jle	.L169
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L170
	movl	All+36(%rip), %eax
	cmpl	$1, %eax
	je	.L171
	movl	All+36(%rip), %eax
	cmpl	$2, %eax
	jne	.L170
.L171:
	movl	All+36(%rip), %eax
	cmpl	$2, %eax
	jne	.L172
	movl	$8, -148(%rbp)
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
	movl	-24(%rbp), %eax
	salq	$2, %rax
	leaq	Tab_IO_Labels(%rax), %rdi
	movq	-32(%rbp), %rax
	movq	%rax, %rcx
	movl	$4, %edx
	movl	$1, %esi
	call	my_fwrite
	movl	-48(%rbp), %eax
	imull	-40(%rbp), %eax
	addl	$8, %eax
	movl	%eax, -52(%rbp)
	movq	-32(%rbp), %rdx
	leaq	-52(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
.L172:
	movl	-48(%rbp), %eax
	imull	-40(%rbp), %eax
	movl	%eax, -148(%rbp)
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
.L170:
	movl	$0, -4(%rbp)
	jmp	.L173
.L189:
	movl	-4(%rbp), %eax
	cltq
	movl	-80(%rbp,%rax,4), %eax
	testl	%eax, %eax
	je	.L174
	movl	-188(%rbp), %eax
	movl	%eax, -20(%rbp)
	movl	$0, -88(%rbp)
	jmp	.L175
.L188:
	movl	ThisTask(%rip), %eax
	cmpl	%eax, -20(%rbp)
	jne	.L176
	movl	-4(%rbp), %eax
	cltq
	movl	n_type(,%rax,4), %eax
	movl	%eax, -84(%rbp)
	movl	-188(%rbp), %eax
	movl	%eax, -12(%rbp)
	jmp	.L177
.L179:
	movl	ThisTask(%rip), %eax
	cmpl	%eax, -12(%rbp)
	je	.L178
	movl	-12(%rbp), %edx
	leaq	-84(%rbp), %rax
	movl	$1140850688, %r9d
	movl	$24, %r8d
	movl	%edx, %ecx
	movl	$1275069445, %edx
	movl	$1, %esi
	movq	%rax, %rdi
	call	MPI_Send
.L178:
	addl	$1, -12(%rbp)
.L177:
	movl	-12(%rbp), %eax
	cmpl	-192(%rbp), %eax
	jle	.L179
	jmp	.L181
.L176:
	movl	-20(%rbp), %edx
	leaq	-84(%rbp), %rax
	subq	$8, %rsp
	leaq	-176(%rbp), %rcx
	pushq	%rcx
	movl	$1140850688, %r9d
	movl	$24, %r8d
	movl	%edx, %ecx
	movl	$1275069445, %edx
	movl	$1, %esi
	movq	%rax, %rdi
	call	MPI_Recv
	addq	$16, %rsp
	jmp	.L181
.L187:
	movl	-84(%rbp), %eax
	movl	%eax, -16(%rbp)
	movl	-16(%rbp), %eax
	cmpl	-44(%rbp), %eax
	jle	.L182
	movl	-44(%rbp), %eax
	movl	%eax, -16(%rbp)
.L182:
	movl	ThisTask(%rip), %eax
	cmpl	-20(%rbp), %eax
	jne	.L183
	movl	-4(%rbp), %ecx
	movl	-16(%rbp), %edx
	leaq	-88(%rbp), %rsi
	movl	-24(%rbp), %eax
	movl	%eax, %edi
	call	fill_write_buffer
.L183:
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L184
	movl	-20(%rbp), %eax
	cmpl	-188(%rbp), %eax
	je	.L184
	movl	-40(%rbp), %eax
	imull	-16(%rbp), %eax
	movl	%eax, %esi
	movq	CommBuffer(%rip), %rax
	movl	-20(%rbp), %edx
	subq	$8, %rsp
	leaq	-176(%rbp), %rcx
	pushq	%rcx
	movl	$1140850688, %r9d
	movl	$12, %r8d
	movl	%edx, %ecx
	movl	$1275068685, %edx
	movq	%rax, %rdi
	call	MPI_Recv
	addq	$16, %rsp
.L184:
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	je	.L185
	movl	ThisTask(%rip), %eax
	cmpl	%eax, -20(%rbp)
	jne	.L185
	movl	-40(%rbp), %eax
	imull	-16(%rbp), %eax
	movl	%eax, %esi
	movq	CommBuffer(%rip), %rax
	movl	-188(%rbp), %edx
	movl	$1140850688, %r9d
	movl	$12, %r8d
	movl	%edx, %ecx
	movl	$1275068685, %edx
	movq	%rax, %rdi
	call	MPI_Ssend
.L185:
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L186
	movl	All+36(%rip), %eax
	cmpl	$3, %eax
	je	.L186
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movl	-40(%rbp), %eax
	movslq	%eax, %rsi
	movq	CommBuffer(%rip), %rax
	movq	-32(%rbp), %rcx
	movq	%rax, %rdi
	call	my_fwrite
.L186:
	movl	-84(%rbp), %eax
	subl	-16(%rbp), %eax
	movl	%eax, -84(%rbp)
.L181:
	movl	-84(%rbp), %eax
	testl	%eax, %eax
	jg	.L187
	addl	$1, -20(%rbp)
.L175:
	movl	-20(%rbp), %eax
	cmpl	-192(%rbp), %eax
	jle	.L188
.L174:
	addl	$1, -4(%rbp)
.L173:
	cmpl	$5, -4(%rbp)
	jle	.L189
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L169
	movl	All+36(%rip), %eax
	cmpl	$1, %eax
	je	.L190
	movl	All+36(%rip), %eax
	cmpl	$2, %eax
	jne	.L169
.L190:
	movq	-32(%rbp), %rdx
	leaq	-148(%rbp), %rax
	movq	%rdx, %rcx
	movl	$1, %edx
	movl	$4, %esi
	movq	%rax, %rdi
	call	my_fwrite
.L169:
	addl	$1, -24(%rbp)
.L168:
	cmpl	$10, -24(%rbp)
	jbe	.L191
	movl	ThisTask(%rip), %eax
	cmpl	-188(%rbp), %eax
	jne	.L193
	movl	All+36(%rip), %eax
	cmpl	$3, %eax
	je	.L193
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	fclose
.L193:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	write_file, .-write_file
	.section	.rodata
	.align 8
.LC14:
	.string	"I/O error (fwrite) on task=%d has occured: %s\n"
	.text
	.globl	my_fwrite
	.type	my_fwrite, @function
my_fwrite:
.LFB10:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movq	%rcx, -48(%rbp)
	movq	-48(%rbp), %rcx
	movq	-40(%rbp), %rdx
	movq	-32(%rbp), %rsi
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	fwrite
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	cmpq	-40(%rbp), %rax
	je	.L195
	call	__errno_location
	movl	(%rax), %eax
	movl	%eax, %edi
	call	strerror
	movq	%rax, %rdx
	movl	ThisTask(%rip), %eax
	movl	%eax, %esi
	movl	$.LC14, %edi
	movl	$0, %eax
	call	printf
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush
	movl	$777, %edi
	call	endrun
.L195:
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	my_fwrite, .-my_fwrite
	.section	.rodata
	.align 8
.LC15:
	.string	"I/O error (fread) on task=%d has occured: %s\n"
	.text
	.globl	my_fread
	.type	my_fread, @function
my_fread:
.LFB11:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movq	%rcx, -48(%rbp)
	movq	-48(%rbp), %rcx
	movq	-40(%rbp), %rdx
	movq	-32(%rbp), %rsi
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	fread
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	cmpq	-40(%rbp), %rax
	je	.L198
	call	__errno_location
	movl	(%rax), %eax
	movl	%eax, %edi
	call	strerror
	movq	%rax, %rdx
	movl	ThisTask(%rip), %eax
	movl	%eax, %esi
	movl	$.LC15, %edi
	movl	$0, %eax
	call	printf
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush
	movl	$778, %edi
	call	endrun
.L198:
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	my_fread, .-my_fread
	.section	.rodata
	.align 8
.LC7:
	.long	0
	.long	1072693248
	.align 8
.LC8:
	.long	0
	.long	1074266112
	.align 8
.LC9:
	.long	1431655766
	.long	1071994197
	.ident	"GCC: (GNU) 6.5.0"
	.section	.note.GNU-stack,"",@progbits
