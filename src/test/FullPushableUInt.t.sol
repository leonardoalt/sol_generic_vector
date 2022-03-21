// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

import "ds-test/test.sol";

import "../FullPushable.sol";
import "../VectorUInt.sol";

contract FullPushableTest is DSTest {
	using PushArray for PushArrayPtr;
	using VectorImpl for Vector;

	// The two tests below do the same thing using
	// the two different uint Vector libraries for
	// gas comparison.

	function test_full_pushable_vs_vector_uint() public {
		PushArrayPtr pa = PushArray.newArray(5);
		// safe pushes
		pa.push(125);
		pa.push(126);
		pa.push(127);
		pa.push(128);
		pa.push(129);

		// one more push would revert if we didnt expand dynamically
		// this one will be expensive because we have to move the list in memory
		pa = pa.push(130);
		// the rest are relatively cheap tho
		pa = pa.push(130);
		pa = pa.push(130);
		pa = pa.push(130);
		pa = pa.push(130);
		pa = pa.push(130);
		uint256 last = pa.get(4);
		//assert(last == 129);
		assertEq(last, 129);
	}

	function test_vector_uint_vs_full_pushable() public {
		Vector memory v = VectorImpl.alloc(5);
		// safe pushes
		v.push(125);
		v.push(126);
		v.push(127);
		v.push(128);
		v.push(129);

		// one more push would revert if we didnt expand dynamically
		// this one will be expensive because we have to move the list in memory
		v.push(130);
		// the rest are relatively cheap tho
		v.push(130);
		v.push(130);
		v.push(130);
		v.push(130);
		v.push(130);
		uint256 last = v.at(4);
		//assert(last == 129);
		assertEq(last, 129);
	}
}
