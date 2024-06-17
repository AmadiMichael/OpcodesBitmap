// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract OpcodesBitmap {
    error AlreadySupported();
    error NotSupported();

    uint256 public opcodesBitmap;

    constructor(uint8[] memory initialOpcodes) {
        assembly {
            let currentOpcodesBitmap

            let currentOffset := add(initialOpcodes, 0x20)
            let end := add(currentOffset, shl(5, mload(initialOpcodes)))
            for {} 1 {} {
                // get the opcode
                let opcode := and(mload(currentOffset), 0xff)

                // get the mask to use
                let mask := shl(opcode, 0x01)

                // if already added, revert
                if and(currentOpcodesBitmap, mask) {
                    mstore(0x00, 0x3706ba49)
                    revert(0x1c, 0x04)
                }

                // update currentOpcodesBitmap
                currentOpcodesBitmap := or(currentOpcodesBitmap, mask)

                // increment currentOffset
                currentOffset := add(currentOffset, 0x20)

                // end loop if currentOffset is >= end
                if iszero(lt(currentOffset, end)) { break }
            }

            // sstore currentOpcodesBitmap in storage
            sstore(opcodesBitmap.slot, currentOpcodesBitmap)
        }
    }

    function opcodesBitString() external view returns (string memory base2) {
        uint256 value = opcodesBitmap;
        if (value == 0) base2 = "0";

        while (value != 0) {
            uint256 v = value % 2;
            value = value / 2;

            base2 = string.concat(v == 0 ? "0" : "1", base2);
        }
    }

    function supportOpcode(uint8 opcode) external {
        assembly {
            let mask := shl(and(opcode, 0xff), 0x01)
            let currentOpcodesBitmap := sload(opcodesBitmap.slot)

            // if already added, revert
            if and(currentOpcodesBitmap, mask) {
                mstore(0x00, 0x3706ba49)
                revert(0x1c, 0x04)
            }

            // sstore it in storage
            sstore(opcodesBitmap.slot, or(currentOpcodesBitmap, mask))
        }
    }

    function deprecateOpcode(uint8 opcode) external {
        assembly {
            let mask := shl(and(opcode, 0xff), 0x01)
            let currentOpcodesBitmap := sload(opcodesBitmap.slot)

            // if not added, revert
            if iszero(and(currentOpcodesBitmap, mask)) {
                mstore(0x00, 0xa0387940)
                revert(0x1c, 0x04)
            }

            // sstore it in storage
            sstore(opcodesBitmap.slot, sub(currentOpcodesBitmap, mask))
        }
    }

    function isSupportedOpcode(uint8 opcode) external view returns (bool isSupported) {
        assembly {
            let mask := shl(and(opcode, 0xff), 0x01)
            let currentOpcodesBitmap := sload(opcodesBitmap.slot)
            isSupported := and(currentOpcodesBitmap, mask)
        }
    }
}
