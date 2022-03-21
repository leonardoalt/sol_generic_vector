// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

import "ds-test/test.sol";

import "../VectorUInt.sol";

contract VectorTest is DSTest {
	using VectorImpl for Vector;

	function test_vector_uint() public {
		Vector memory v = VectorImpl.alloc(3);
		assertEq(v.len(), 0);
		assertEq(v.data.length, 3);
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
