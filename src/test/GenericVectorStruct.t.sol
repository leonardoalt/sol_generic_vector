// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

import "ds-test/test.sol";

import "../GenericVectorStruct.sol";

contract GenericVectorStructTest is DSTest {
	using VectorStructImpl for Vector;

	function test_generic_vector_struct() public {
		Vector memory v = VectorImpl.alloc(SIZE_PAIR, 3);
		assertEq(v.len(), 0);
		assertEq(v.reserved, 3);
		v.push(Pair(0, 0));
		assertEq(v.len(), 1);
		v.push(Pair(1, 1));
		v.push(Pair(2, 2));
		assertEq(v.at(0).first, 0);
		assertEq(v.at(1).second, 1);
		assertEq(v.at(2).first, 2);

		v.pop();
		assertEq(v.len(), 2);

		assertEq(v.at(0).second, 0);
		assertEq(v.at(1).first, 1);

		v.push(Pair(2, 2));
		assertEq(v.len(), 3);
		// needs to expand
		v.push(Pair(3, 3));
		assertEq(v.len(), 4);
		v.push(Pair(4, 4));
		v.push(Pair(5, 5));

		assertEq(v.len(), 6);

		for (uint i = 0; i < v.len(); ++i) {
			Pair memory p = v.at(i);
			assertEq(p.first, i);
			assertEq(p.second, i);
		}
	}
}
