// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

struct Vector {
	// invariant: data.length > length
	// data.length == reserved amount
	uint[] data;
	// used amount
	uint length;
}

error VectorOutOfBounds(uint);

uint constant INIT_RESERVE = 10;

library VectorImpl {
	using VectorImpl for Vector;

	function alloc() internal pure returns (Vector memory) {
		return alloc(INIT_RESERVE);
	}

	function alloc(uint amt) internal pure returns (Vector memory) {
		Vector memory vector;
		vector.reserve(amt);
		return vector;
	}

	function reserve(Vector memory vector, uint amt) internal pure{
		if (vector.data.length >= amt)
			return;

		uint[] memory oldData = vector.data;
		vector.data = new uint[](amt);
		for (uint i = 0; i < vector.length; ++i)
			vector.data[i] = oldData[i];
	}

	function push(Vector memory vector, uint elem) internal pure{
		if (vector.length >= vector.data.length)
			vector.reserve(vector.data.length * 2);

		vector.data[vector.length++] = elem;
	}

	function pop(Vector memory vector) internal pure{
		--vector.length;
	}

	function insert(Vector memory vector, uint idx, uint elem) internal pure {
		if (idx >= vector.length)
			revert VectorOutOfBounds(idx);

		vector.data[idx] = elem;
	}

	function at(Vector memory vector, uint idx) internal pure returns (uint) {
		if (idx >= vector.length)
			revert VectorOutOfBounds(idx);

		return vector.data[idx];
	}

	function len(Vector memory vector) internal pure returns (uint) {
		return vector.length;
	}
}
