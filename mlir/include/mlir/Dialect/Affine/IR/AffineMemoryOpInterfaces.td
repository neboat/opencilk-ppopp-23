//===- AffineMemoryOpInterfaces.td -------------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a set of interfaces for affine memory ops.
//
//===----------------------------------------------------------------------===//

#ifndef AFFINEMEMORYOPINTERFACES
#define AFFINEMEMORYOPINTERFACES

include "mlir/IR/OpBase.td"

def AffineReadOpInterface : OpInterface<"AffineReadOpInterface"> {
  let description = [{
      Interface to query characteristics of read-like ops with affine
      restrictions.
  }];

  let methods = [
    InterfaceMethod<
      /*desc=*/"Returns the memref operand to read from.",
      /*retTy=*/"Value",
      /*methodName=*/"getMemRef",
      /*args=*/(ins),
      /*methodBody*/[{}],
      /*defaultImplementation=*/ [{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getOperand(op.getMemRefOperandIndex());
      }]
    >,
    InterfaceMethod<
      /*desc=*/"Returns the type of the memref operand.",
      /*retTy=*/"MemRefType",
      /*methodName=*/"getMemRefType",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getMemRef().getType().template cast<MemRefType>();
      }]
    >,
    InterfaceMethod<
      /*desc=*/"Returns affine map operands.",
      /*retTy=*/"Operation::operand_range",
      /*methodName=*/"getMapOperands",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return llvm::drop_begin(op.getOperands(), 1);
      }]
    >,
    InterfaceMethod<
      /*desc=*/[{
        Returns the affine map used to index the memref for this operation.
      }],
      /*retTy=*/"AffineMap",
      /*methodName=*/"getAffineMap",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getAffineMapAttr().getValue();
      }]
    >,
    InterfaceMethod<
      /*desc=*/"Returns the value read by this operation.",
      /*retTy=*/"Value",
      /*methodName=*/"getValue",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        return cast<ConcreteOp>(this->getOperation());
      }]
    >,
  ];
}

def AffineWriteOpInterface : OpInterface<"AffineWriteOpInterface"> {
  let description = [{
      Interface to query characteristics of write-like ops with affine
      restrictions.
  }];

  let methods = [
    InterfaceMethod<
      /*desc=*/"Returns the memref operand to write to.",
      /*retTy=*/"Value",
      /*methodName=*/"getMemRef",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getOperand(op.getMemRefOperandIndex());
      }]
    >,
    InterfaceMethod<
      /*desc=*/"Returns the type of the memref operand.",
      /*retTy=*/"MemRefType",
      /*methodName=*/"getMemRefType",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getMemRef().getType().template cast<MemRefType>();
      }]
    >,
    InterfaceMethod<
      /*desc=*/"Returns affine map operands.",
      /*retTy=*/"Operation::operand_range",
      /*methodName=*/"getMapOperands",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return llvm::drop_begin(op.getOperands(), 2);
      }]
    >,
    InterfaceMethod<
      /*desc=*/[{
        Returns the affine map used to index the memref for this operation.
      }],
      /*retTy=*/"AffineMap",
      /*methodName=*/"getAffineMap",
      /*args=*/(ins),
      /*methodName=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getAffineMapAttr().getValue();
      }]
    >,
    InterfaceMethod<
      /*desc=*/"Returns the value to store.",
      /*retTy=*/"Value",
      /*methodName=*/"getValueToStore",
      /*args=*/(ins),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        return op.getOperand(op.getStoredValOperandIndex());
      }]
    >,
  ];
}

def AffineMapAccessInterface : OpInterface<"AffineMapAccessInterface"> {
  let description = [{
      Interface to query the AffineMap used to dereference and access a given
      memref. Implementers of this interface must operate on at least one
      memref operand.  The memref argument given to this interface much match
      one of those memref operands.
  }];

  let methods = [
    InterfaceMethod<
      /*desc=*/"Returns the AffineMapAttr associated with 'memref'.",
      /*retTy=*/"NamedAttribute",
      /*methodName=*/"getAffineMapAttrForMemRef",
      /*args=*/(ins "Value":$memref),
      /*methodBody=*/[{}],
      /*defaultImplementation=*/[{
        ConcreteOp op = cast<ConcreteOp>(this->getOperation());
        assert(memref == op.getMemRef() &&
               "Expected memref argument to match memref operand");
        return {StringAttr::get(op.getContext(), op.getMapAttrName()),
                op.getAffineMapAttr()};
      }]
    >,
  ];
}

#endif // AFFINEMEMORYOPINTERFACES
