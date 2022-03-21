// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

import "ds-test/test.sol";

import "../GenericVectorABI.sol";

library VectorUIntImpl {
	function push(GenericVector memory vector, uint elem) internal pure {
		GenericVectorPushAtImpl.push(vector, abi.encode(elem));
	}

	function at(GenericVector memory vector, uint idx) internal pure returns (uint) {
		return abi.decode(GenericVectorPushAtImpl.at(vector, idx), (uint));
	}
}

uint constant SIZE_UINT = 32;

contract GenericVectorABITest is DSTest {
	using GenericVectorImpl for GenericVector;
	using VectorUIntImpl for GenericVector;

	function test_generic_vector_abi() public {
		GenericVector memory v = GenericVectorImpl.alloc(SIZE_UINT, 3);
		assertEq(v.len(), 0);
		assertEq(v.reserved, 3);
		v.push(0);
		assertEq(v.len(), 1);
		v.push(1);
		v.push(2);
		assertEq(v.at(0), 0);
		assertEq(v.at(1), 1);
		assertEq(v.at(2), 2);

		v.pop();
		assertEq(v.len(), 2);

		assertEq(v.at(0), 0);
		assertEq(v.at(1), 1);

		v.push(2);
		assertEq(v.len(), 3);
		// needs to expand
		v.push(3);
		assertEq(v.len(), 4);
		v.push(4);
		v.push(5);

		assertEq(v.len(), 6);

		for (uint i = 0; i < v.len(); ++i)
			assertEq(v.at(i), i);
	}
}
