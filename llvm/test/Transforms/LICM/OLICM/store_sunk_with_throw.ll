; NOTE: Tests that store through borrowed gep ptr is sunk outside the loop into exit block.
; NOTE: This is even in the presence of external call "cond" that may unwind.
; RUN: opt -S -passes=licm --licm-uses-ownsem --licm-ownsem-safeset-ignores-throw < %s | FileCheck %s
; Function Attrs: noinline nounwind nonlazybind uwtable
define hidden fastcc void @cond_inc(ptr noalias nocapture noundef align 4 dereferenceable(8) %b) unnamed_addr #0 !dbg !8 {
; CHECK-LABEL: @cond_inc(
; CHECK-NEXT: start:
; CHECK-NEXT:   [[BORROW_GEP:%.*]] = getelementptr inbounds i8, ptr %b, i64 4
; CHECK-NEXT:   [[LOAD_VAL:.*]] = load i32, ptr [[BORROW_GEP]], align 4
; CHECK-NEXT:   br label %[[LOOP_BLOCK:.*]]
; CHECK:      [[EXIT_BLOCK:.*]]:{{.*}}
; CHECK-NEXT:   [[STORE_VAL:%.*]] = phi i32 [ [[VAL_FROM_LOOP:%.*]], [[LOOP_MAIN:%.*]] ]
; CHECK-NEXT:   store i32 [[STORE_VAL]], ptr [[BORROW_GEP]]
; CHECK-LABEL:  ret void{{.*}}
; CHECK:      [[LOOP_BLOCK]]:{{.*}}
; CHECK:        br i1 %exitcond.not, label %[[EXIT_BLOCK]], label %[[LOOP_BLOCK]]{{.*}}
start:
  %0 = getelementptr inbounds i8, ptr %b, i64 4, !ownsem !13
  %.promoted = load i32, ptr %0, align 4
  br label %loop 

exit.block:                                          
  ret void, !dbg !28

loop:                                              ; preds = %bb3, %start
  %1 = phi i32 [ %.promoted, %start ], [ %2, %loop ], !dbg !29
  %iter.sroa.0.02 = phi i32 [ 0, %start ], [ %_11.0.i, %loop ]
  %_11.0.i = add nuw nsw i32 %iter.sroa.0.02, 1, !dbg !29
  %_6 = tail call noundef zeroext i1 @cond() #2, !dbg !47
  %2 = add i32 %1, 1, !dbg !49
  store i32 %2, ptr %0, align 4, !dbg !49
  %exitcond.not = icmp eq i32 %_11.0.i, 100, !dbg !50
  br i1 %exitcond.not, label %exit.block, label %loop, !dbg !14
}

; Function Attrs: nounwind nonlazybind uwtable
declare noundef zeroext i1 @cond() unnamed_addr #1

attributes #0 = { noinline nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #1 = { nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}
!llvm.dbg.cu = !{!6}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"PIE Level", i32 2}
!2 = !{i32 2, !"RtLibUseGOT", i32 1}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{!"rustc version 1.81.0-dev"}
!6 = distinct !DICompileUnit(language: DW_LANG_Rust, file: !7, producer: "clang LLVM (rustc version 1.81.0-dev)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!7 = !DIFile(filename: "mutborrow-test3.rs/@/mutborrow_test3.e40d5def4ead7b15-cgu.0", directory: "/home/siddharth/rust-examples")
!8 = distinct !DISubprogram(name: "cond_inc", linkageName: "_ZN15mutborrow_test38cond_inc17ha016c95b5781229eE", scope: !10, file: !9, line: 11, type: !11, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!9 = !DIFile(filename: "mutborrow-test3.rs", directory: "/home/siddharth/rust-examples", checksumkind: CSK_MD5, checksum: "451c134edaf9d6106eb72197d5b208a3")
!10 = !DINamespace(name: "mutborrow_test3", scope: null)
!11 = !DISubroutineType(types: !12)
!12 = !{}
!13 = !{!"mutbor"}
!14 = !DILocation(line: 753, column: 12, scope: !15, inlinedAt: !22)
!15 = distinct !DILexicalBlock(scope: !17, file: !16, line: 752, column: 5)
!16 = !DIFile(filename: "/home/siddharth/rust/library/core/src/iter/range.rs", directory: "", checksumkind: CSK_MD5, checksum: "b8d3f14c43d9898ef8d305366b66f557")
!17 = distinct !DISubprogram(name: "spec_next<i32>", linkageName: "_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h1596796f349b5580E", scope: !18, file: !16, line: 752, type: !11, scopeLine: 752, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!18 = !DINamespace(name: "{impl#5}", scope: !19)
!19 = !DINamespace(name: "range", scope: !20)
!20 = !DINamespace(name: "iter", scope: !21)
!21 = !DINamespace(name: "core", scope: null)
!22 = !DILocation(line: 844, column: 14, scope: !23, inlinedAt: !26)
!23 = distinct !DILexicalBlock(scope: !24, file: !16, line: 843, column: 5)
!24 = distinct !DISubprogram(name: "next<i32>", linkageName: "_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h4002284d7590d7aaE", scope: !25, file: !16, line: 843, type: !11, scopeLine: 843, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!25 = !DINamespace(name: "{impl#6}", scope: !19)
!26 = !DILocation(line: 12, column: 13, scope: !27)
!27 = distinct !DILexicalBlock(scope: !8, file: !9, line: 12, column: 3)
!28 = !DILocation(line: 16, column: 2, scope: !8)
!29 = !DILocation(line: 2218, column: 26, scope: !30, inlinedAt: !35)
!30 = distinct !DILexicalBlock(scope: !32, file: !31, line: 2217, column: 9)
!31 = !DIFile(filename: "/home/siddharth/rust/library/core/src/num/int_macros.rs", directory: "", checksumkind: CSK_MD5, checksum: "b3d3cd63027e7cafce5264d183e5bb52")
!32 = distinct !DISubprogram(name: "overflowing_add", linkageName: "_ZN4core3num21_$LT$impl$u20$i32$GT$15overflowing_add17h612d9a5f1bd6c544E", scope: !33, file: !31, line: 2217, type: !11, scopeLine: 2217, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!33 = !DINamespace(name: "{impl#2}", scope: !34)
!34 = !DINamespace(name: "num", scope: !21)
!35 = distinct !DILocation(line: 2302, column: 42, scope: !36, inlinedAt: !39)
!36 = distinct !DILexicalBlock(scope: !37, file: !31, line: 2301, column: 13)
!37 = distinct !DILexicalBlock(scope: !38, file: !31, line: 2300, column: 9)
!38 = distinct !DISubprogram(name: "overflowing_add_unsigned", linkageName: "_ZN4core3num21_$LT$impl$u20$i32$GT$24overflowing_add_unsigned17h1415036934c95a55E", scope: !33, file: !31, line: 2300, type: !11, scopeLine: 2300, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!39 = distinct !DILocation(line: 547, column: 31, scope: !40, inlinedAt: !42)
!40 = distinct !DILexicalBlock(scope: !41, file: !31, line: 546, column: 9)
!41 = distinct !DISubprogram(name: "checked_add_unsigned", linkageName: "_ZN4core3num21_$LT$impl$u20$i32$GT$20checked_add_unsigned17hc571a9b24a45bc87E", scope: !33, file: !31, line: 546, type: !11, scopeLine: 546, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!42 = distinct !DILocation(line: 192, column: 28, scope: !43, inlinedAt: !45)
!43 = distinct !DISubprogram(name: "forward_unchecked", linkageName: "_ZN47_$LT$i32$u20$as$u20$core..iter..range..Step$GT$17forward_unchecked17hcf0137a8acd3acc4E", scope: !44, file: !16, line: 190, type: !11, scopeLine: 190, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!44 = !DINamespace(name: "{impl#40}", scope: !19)
!45 = distinct !DILocation(line: 756, column: 35, scope: !46, inlinedAt: !22)
!46 = distinct !DILexicalBlock(scope: !15, file: !16, line: 754, column: 13)
!47 = !DILocation(line: 13, column: 15, scope: !48)
!48 = distinct !DILexicalBlock(scope: !27, file: !9, line: 12, column: 20)
!49 = !DILocation(line: 14, column: 7, scope: !48)
!50 = !DILocation(line: 1563, column: 52, scope: !51, inlinedAt: !14)
!51 = distinct !DILexicalBlock(scope: !53, file: !52, line: 1563, column: 17)
!52 = !DIFile(filename: "/home/siddharth/rust/library/core/src/cmp.rs", directory: "", checksumkind: CSK_MD5, checksum: "3920494dc5159b92e6f225b608268915")
!53 = distinct !DISubprogram(name: "lt", linkageName: "_ZN4core3cmp5impls55_$LT$impl$u20$core..cmp..PartialOrd$u20$for$u20$i32$GT$2lt17hd7afd838f3d15ca1E", scope: !54, file: !52, line: 1563, type: !11, scopeLine: 1563, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !6, templateParams: !12)
!54 = !DINamespace(name: "{impl#76}", scope: !55)
!55 = !DINamespace(name: "impls", scope: !56)
!56 = !DINamespace(name: "cmp", scope: !21)
