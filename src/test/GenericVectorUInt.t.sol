// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

import "ds-test/test.sol";

import "../GenericVectorUInt.sol";

contract GenericVectorUIntTest is DSTest {
	using VectorUIntImpl for Vector;

	function test_generic_vector_uint() public {
		Vector memory v = VectorImpl.alloc(SIZE_UINT, 3);
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
