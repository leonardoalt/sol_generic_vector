// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.13;

struct Vector {
	uint baseSize;	// size of one element in bytes
	bytes data;		// raw data
	uint reserved;	// amount of allocated elements
	uint length;	// amount of used elements
}

error VectorOutOfBounds(uint);
error BaseSizeNotMultiple32(uint);

uint constant WORD_SIZE = 32;
uint constant INIT_RESERVE = 10;

library VectorImpl {
	using VectorImpl for Vector;

	function alloc(uint baseSize) internal pure returns (Vector memory) {
		return alloc(baseSize, INIT_RESERVE);
	}

	function alloc(uint baseSize, uint amt) internal pure returns (Vector memory) {
		if (baseSize % WORD_SIZE != 0)
			revert BaseSizeNotMultiple32(baseSize);

		Vector memory vector;
		vector.baseSize = baseSize;
		vector.reserve(amt);
		return vector;
	}

	function reserve(Vector memory vector, uint amt) internal pure {
		if (vector.reserved >= amt)
			return;

		bytes memory oldData = vector.data;
		bytes memory oldStart;
		assembly { oldStart := add(oldData, 0x20) }

		vector.data = new bytes(vector.baseSize * amt);
		vector.reserved = amt;

		bytes memory newStart = vector.data;
		assembly { newStart := add(newStart, 0x20) }

		for (uint offset = 0; offset < oldData.length; offset += WORD_SIZE)
			assembly {
				mstore(
					add(newStart, offset),
					mload(add(oldStart, offset))
				)
			}
	}

	function push(Vector memory vector, bytes memory elem) internal pure {
		if (vector.length >= vector.reserved)
			vector.reserve(vector.reserved * 2);

		uint newElemIdx = vector.baseSize * vector.length;

		bytes memory data = vector.data;
		assembly { data := add(add(data, 0x20), newElemIdx) }

		for (uint offset = 0; offset < vector.baseSize; offset += WORD_SIZE)
			assembly {
				mstore(add(data, offset), mload(add(elem, offset)))
			}

		++vector.length;
	}

	function at(Vector memory vector, uint idx) internal pure returns (bytes memory) {
		if (idx >= vector.length)
			revert VectorOutOfBounds(idx);

		bytes memory data = vector.data;
		uint elemIdx = idx * vector.baseSize;
		assembly { data := add(elemIdx, add(data, 0x20)) }
		return data;
	}

	function pop(Vector memory vector) internal pure {
		--vector.length;
	}

	/*
	function insert(Vector memory vector, uint idx, bytes memory elem) internal pure {
	}
	*/

	function len(Vector memory vector) internal pure returns (uint) {
		return vector.length;
	}
}
