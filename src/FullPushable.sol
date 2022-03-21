// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

// From:
// https://gist.github.com/brockelmore/2904cf497a4af63d403ae1666805f42d

type PushArrayPtr is bytes32;

library PushArray {
    function newArray(uint8 len) internal pure returns (PushArrayPtr s) {
        assembly {
            // grab free mem ptr, accounting for annoying return adjustment 
            s := mload(0x40)
            // update free mem ptr to 32*(len+2)+curr_free_memptr
            mstore(0x40, add(s, mul(add(0x02, len), 0x20)))
            mstore(add(0x20, s), len)
        }
    }

    function push(PushArrayPtr self, uint256 elem) internal view returns (PushArrayPtr) {
        PushArrayPtr ret;
        assembly {
            ret := self
            switch eq(mload(self), mload(add(0x20, self))) 
            case 1 {
                switch eq(mload(0x40), add(self, mul(add(0x02, mload(self)), 0x20))) 
                case 1 {
                    // free mem ptr hasnt been updated since we initialized the ptr, we can just update it with more space
                    // update length
                    mstore(add(0x20, self), add(0x01, mload(add(0x20, self))))
                    mstore(0x40, add(0x20, mload(0x40)))

                    mstore(
                        add(
                            self, // self + (2+curr_len)*32
                            mul(
                                add(0x02, mload(self)), // 2 + curr len * 32
                                0x20
                            )
                        ), elem
                    )
                    mstore(self, add(0x01, mload(self)))
                }
                default {
                    let s := mload(0x40)
                    // move the array to the free mem ptr
                    pop(staticcall(gas(), 0x04, self, mul(add(0x02, mload(self)), 0x20), s, mul(add(0x02, mload(self)), 0x20)))
                    mstore(
                        add(
                            s, // s + (2+curr_len)*32
                            mul(
                                add(0x02, mload(s)), // 2 + curr len * 32
                                0x20
                            )
                        ), elem
                    )
                    // add to the length
                    mstore(add(0x20, s), add(0x01, mload(add(0x20, s))))
                    mstore(s, add(0x01, mload(s)))
                    mstore(0x40, add(mul(add(0x02, mload(s)), 0x20), mload(0x40)))
                    ret := s
                }
            }
            default {
                mstore(
                    add(
                        self, // self + (2+curr_len)*32
                        mul(
                            add(0x02, mload(self)), // 2 + curr len * 32
                            0x20
                        )
                    ), elem
                )
                mstore(self, add(0x01, mload(self)))
            }
        }
        return ret;
    }

    function push_unsafe(PushArrayPtr self, uint256 elem) internal pure {
        assembly {
            mstore(add(self, mul(add(0x02, mload(self)), 0x20)), elem)
            mstore(self, add(0x01, mload(self)))
        }
    }

    function get(PushArrayPtr self, uint8 i) internal pure returns (uint256 s) {
        assembly {
            s := mload(add(self, mul(0x20, add(0x02, i))))
        }
    } 
}

/*
contract Contract {
    using PushArray for PushArrayPtr;
    function run() public {
        PushArrayPtr pa = PushArray.newArray(5);
        // safe pushes
        pa.push(125);
        pa.push(126);
        pa.push(127);
        pa.push(128);
        pa.push(129);

        PushArrayPtr pa2 = PushArray.newArray(5);
        pa2.push(1337);
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
        assert(last == 129);
    }
}
*/
