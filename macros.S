    .macro declare_global_v syms:vararg
        .irp sym, \syms
            .global \sym
        .endr
    .endm

    .macro push_v regs:vararg
        .irp reg, \regs
            push \reg
        .endr
    .endm

    .macro pop_v regs:vararg
        .irp reg, \regs
            pop \reg
        .endr
    .endm
