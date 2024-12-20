; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple lanai | FileCheck %s -check-prefixes=CHECK

declare dso_local void @main()

define dso_local void @naked() naked "frame-pointer"="all" {
; CHECK-LABEL: naked:
; CHECK:       .Lnaked$local:
; CHECK-NEXT:    .type .Lnaked$local,@function
; CHECK-NEXT:    .cfi_startproc
; CHECK-NEXT:  ! %bb.0:
; CHECK-NEXT:    add %pc, 0x10, %rca
; CHECK-NEXT:    st %rca, [--%sp]
; CHECK-NEXT:    bt main
; CHECK-NEXT:    nop
  call void @main()
  unreachable
}

define dso_local void @normal() "frame-pointer"="all" {
; CHECK-LABEL: normal:
; CHECK:       .Lnormal$local:
; CHECK-NEXT:    .type .Lnormal$local,@function
; CHECK-NEXT:    .cfi_startproc
; CHECK-NEXT:  ! %bb.0:
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    sub %sp, 0x8, %sp
; CHECK-NEXT:    add %pc, 0x10, %rca
; CHECK-NEXT:    st %rca, [--%sp]
; CHECK-NEXT:    bt main
; CHECK-NEXT:    nop
  call void @main()
  unreachable
}
