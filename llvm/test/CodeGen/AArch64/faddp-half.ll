; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --mtriple=aarch64 -mattr=+fullfp16 < %s | FileCheck %s
; RUN: llc --mtriple=aarch64 < %s | FileCheck %s --check-prefix=CHECKNOFP16

define half @faddp_2xhalf(<2 x half> %a) {
; CHECK-LABEL: faddp_2xhalf:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    faddp h0, v0.2h
; CHECK-NEXT:    ret
;
; CHECKNOFP16-LABEL: faddp_2xhalf:
; CHECKNOFP16:       // %bb.0: // %entry
; CHECKNOFP16-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECKNOFP16-NEXT:    dup v1.4h, v0.h[1]
; CHECKNOFP16-NEXT:    fcvtl v0.4s, v0.4h
; CHECKNOFP16-NEXT:    fcvtl v1.4s, v1.4h
; CHECKNOFP16-NEXT:    fadd v0.4s, v0.4s, v1.4s
; CHECKNOFP16-NEXT:    fcvtn v0.4h, v0.4s
; CHECKNOFP16-NEXT:    // kill: def $h0 killed $h0 killed $q0
; CHECKNOFP16-NEXT:    ret
entry:
  %shift = shufflevector <2 x half> %a, <2 x half> undef, <2 x i32> <i32 1, i32 undef>
  %0 = fadd <2 x half> %a, %shift
  %1 = extractelement <2 x half> %0, i32 0
  ret half %1
}

define half @faddp_2xhalf_commute(<2 x half> %a) {
; CHECK-LABEL: faddp_2xhalf_commute:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    faddp h0, v0.2h
; CHECK-NEXT:    ret
;
; CHECKNOFP16-LABEL: faddp_2xhalf_commute:
; CHECKNOFP16:       // %bb.0: // %entry
; CHECKNOFP16-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECKNOFP16-NEXT:    dup v1.4h, v0.h[1]
; CHECKNOFP16-NEXT:    fcvtl v0.4s, v0.4h
; CHECKNOFP16-NEXT:    fcvtl v1.4s, v1.4h
; CHECKNOFP16-NEXT:    fadd v0.4s, v1.4s, v0.4s
; CHECKNOFP16-NEXT:    fcvtn v0.4h, v0.4s
; CHECKNOFP16-NEXT:    // kill: def $h0 killed $h0 killed $q0
; CHECKNOFP16-NEXT:    ret
entry:
  %shift = shufflevector <2 x half> %a, <2 x half> undef, <2 x i32> <i32 1, i32 undef>
  %0 = fadd <2 x half> %shift, %a
  %1 = extractelement <2 x half> %0, i32 0
  ret half %1
}

define half @faddp_4xhalf(<4 x half> %a) {
; CHECK-LABEL: faddp_4xhalf:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    faddp h0, v0.2h
; CHECK-NEXT:    ret
;
; CHECKNOFP16-LABEL: faddp_4xhalf:
; CHECKNOFP16:       // %bb.0: // %entry
; CHECKNOFP16-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECKNOFP16-NEXT:    dup v1.4h, v0.h[1]
; CHECKNOFP16-NEXT:    fcvtl v0.4s, v0.4h
; CHECKNOFP16-NEXT:    fcvtl v1.4s, v1.4h
; CHECKNOFP16-NEXT:    fadd v0.4s, v0.4s, v1.4s
; CHECKNOFP16-NEXT:    fcvtn v0.4h, v0.4s
; CHECKNOFP16-NEXT:    // kill: def $h0 killed $h0 killed $q0
; CHECKNOFP16-NEXT:    ret
entry:
  %shift = shufflevector <4 x half> %a, <4 x half> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %0 = fadd <4 x half> %a, %shift
  %1 = extractelement <4 x half> %0, i32 0
  ret half %1
}

define half @faddp_4xhalf_commute(<4 x half> %a) {
; CHECK-LABEL: faddp_4xhalf_commute:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    faddp h0, v0.2h
; CHECK-NEXT:    ret
;
; CHECKNOFP16-LABEL: faddp_4xhalf_commute:
; CHECKNOFP16:       // %bb.0: // %entry
; CHECKNOFP16-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECKNOFP16-NEXT:    dup v1.4h, v0.h[1]
; CHECKNOFP16-NEXT:    fcvtl v0.4s, v0.4h
; CHECKNOFP16-NEXT:    fcvtl v1.4s, v1.4h
; CHECKNOFP16-NEXT:    fadd v0.4s, v1.4s, v0.4s
; CHECKNOFP16-NEXT:    fcvtn v0.4h, v0.4s
; CHECKNOFP16-NEXT:    // kill: def $h0 killed $h0 killed $q0
; CHECKNOFP16-NEXT:    ret
entry:
  %shift = shufflevector <4 x half> %a, <4 x half> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %0 = fadd <4 x half> %shift, %a
  %1 = extractelement <4 x half> %0, i32 0
  ret half %1
}

define half @faddp_8xhalf(<8 x half> %a) {
; CHECK-LABEL: faddp_8xhalf:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    faddp h0, v0.2h
; CHECK-NEXT:    ret
;
; CHECKNOFP16-LABEL: faddp_8xhalf:
; CHECKNOFP16:       // %bb.0: // %entry
; CHECKNOFP16-NEXT:    dup v1.8h, v0.h[1]
; CHECKNOFP16-NEXT:    fcvt s0, h0
; CHECKNOFP16-NEXT:    fcvt s1, h1
; CHECKNOFP16-NEXT:    fadd s0, s0, s1
; CHECKNOFP16-NEXT:    fcvt h0, s0
; CHECKNOFP16-NEXT:    ret
entry:
  %shift = shufflevector <8 x half> %a, <8 x half> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %0 = fadd <8 x half> %a, %shift
  %1 = extractelement <8 x half> %0, i32 0
  ret half %1
}

define half @faddp_8xhalf_commute(<8 x half> %a) {
; CHECK-LABEL: faddp_8xhalf_commute:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    faddp h0, v0.2h
; CHECK-NEXT:    ret
;
; CHECKNOFP16-LABEL: faddp_8xhalf_commute:
; CHECKNOFP16:       // %bb.0: // %entry
; CHECKNOFP16-NEXT:    dup v1.8h, v0.h[1]
; CHECKNOFP16-NEXT:    fcvt s0, h0
; CHECKNOFP16-NEXT:    fcvt s1, h1
; CHECKNOFP16-NEXT:    fadd s0, s1, s0
; CHECKNOFP16-NEXT:    fcvt h0, s0
; CHECKNOFP16-NEXT:    ret
entry:
  %shift = shufflevector <8 x half> %a, <8 x half> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %0 = fadd <8 x half> %shift, %a
  %1 = extractelement <8 x half> %0, i32 0
  ret half %1
}