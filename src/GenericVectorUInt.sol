// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

import "ds-test/test.sol";

import "./GenericVector.sol";

uint constant SIZE_UINT = 32;

struct ElemWrapper {
	uint elem;
}

library VectorUIntImpl {
	using VectorImpl for Vector;

	// `push` and `at` need to be specific to the desired type

	function push(Vector memory vector, uint elem) internal pure {
		ElemWrapper memory e = ElemWrapper(elem);
		bytes memory elemData;
		assembly { elemData := e }
		vector.push(elemData);
	}

	function at(Vector memory vector, uint idx) internal pure returns (uint) {
		bytes memory encodedElem = vector.at(idx);
		ElemWrapper memory e;
		assembly { e := encodedElem }
		return e.elem;
	}

	// The other functions just relay to the generic impl.
	// We need to re-list these here because the compiler
	// complains about `at` having the same signature
	// (only the return type differs),
	// so we cannot define
	// `using VectorImpl for Vector;`
	// when using our vector.

	function alloc(uint baseSize) internal pure returns (Vector memory) { return VectorImpl.alloc(baseSize); }

	function alloc(uint baseSize, uint amt) internal pure returns (Vector memory) { return VectorImpl.alloc(baseSize, amt); }

	function reserve(Vector memory vector, uint amt) internal pure { return vector.reserve(amt); }

	function pop(Vector memory vector) internal pure { return vector.pop(); }

	function len(Vector memory vector) internal pure returns (uint) { return vector.len(); }
}


