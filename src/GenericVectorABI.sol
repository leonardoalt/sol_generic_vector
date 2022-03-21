// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

struct GenericVector {
	uint baseSize; // size of one element in bytes
	bytes data;
	uint reserved; // amount of allocated elements
	uint length; // amount of used elements
}

error VectorOutOfBounds(uint);

uint constant INIT_RESERVE = 10;

library GenericVectorImpl {
	using GenericVectorImpl for GenericVector;

	function alloc(uint baseSize) internal pure returns (GenericVector memory) {
		return alloc(baseSize, INIT_RESERVE);
	}

	function alloc(uint baseSize, uint amt) internal pure returns (GenericVector memory) {
		GenericVector memory vector;
		vector.baseSize = baseSize;
		vector.reserve(amt);
		return vector;
	}

	function reserve(GenericVector memory vector, uint amt) internal pure {
		if (vector.reserved >= amt)
			return;

		bytes memory oldData = vector.data;
		vector.data = new bytes(vector.baseSize * amt);
		vector.reserved = amt;
		for (uint i = 0; i < vector.baseSize * vector.length; ++i)
			vector.data[i] = oldData[i];
	}

	function pop(GenericVector memory vector) internal pure{
		--vector.length;
	}

	/*
	function insert(Vector memory vector, uint idx, bytes memory elem) internal pure {
		if (idx >= vector.length)
			revert VectorOutOfBounds(idx);

		vector.data[idx] = elem;
	}
	*/

	function len(GenericVector memory vector) internal pure returns (uint) {
		return vector.length;
	}
}

library GenericVectorPushAtImpl {
	using GenericVectorImpl for GenericVector;

	function push(GenericVector memory vector, bytes memory elem) internal pure {
		require(elem.length == vector.baseSize);
		if (vector.length >= vector.reserved)
			vector.reserve(vector.reserved * 2);

		uint newElemPtr = vector.baseSize * vector.length;
		for (uint i = newElemPtr; i < newElemPtr + vector.baseSize; ++i)
			vector.data[i] = elem[i - newElemPtr];

		++vector.length;
	}

	function at(GenericVector memory vector, uint idx) internal pure returns (bytes memory) {
		if (idx >= vector.length)
			revert VectorOutOfBounds(idx);

		bytes memory elem = new bytes(vector.baseSize);
		uint elemPtr = idx * vector.baseSize;
		for (uint i = 0; i < vector.baseSize; ++i)
			elem[i] = vector.data[elemPtr + i];
		return elem;
	}
}
