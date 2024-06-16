// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {OpcodesBitmap} from "../src/OpcodesBitmap.sol";

contract CounterTest is Test {
    // forgefmt: disable-next-item
    uint8[] initialOpcodes = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,
        0x0A, 0x0B, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x20, 0x30, 0x31, 0x32,
        0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C,
        0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
        0x47, 0x48, 0x49, 0x4A, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55,
        0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
        0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,
        0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73,
        0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D,
        0x7E, 0x7F, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
        0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F, 0x90, 0x91,
        0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B,
        0x9C, 0x9D, 0x9E, 0x9F, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xF0,
        0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xFA, 0xFD, 0xFE, 0xFF
    ];

    OpcodesBitmap public opcodesBitmap;

    function setUp() public {
        opcodesBitmap = new OpcodesBitmap(initialOpcodes);
        assertEq(
            opcodesBitmap.opcodesBitmap(),
            103238640842065774761881656312677524192904604960857204817777740543577286447103,
            "not inited properly"
        );

        console2.log("Opcodes Bitmap Base 10: %s", opcodesBitmap.opcodesBitmap());
        console2.log("Opcodes Bitmap Base 2: %s", opcodesBitmap.opcodesBitString());
    }

    function test_supportOpcode() external {
        // can add opcode
        uint8 CALLF_opcode = 0xe3;

        // should be unsupported
        assertFalse(opcodesBitmap.isSupportedOpcode(CALLF_opcode), "opcode should be unsupported");

        // should support opcode successfully
        opcodesBitmap.supportOpcode(CALLF_opcode);
        assertTrue(opcodesBitmap.isSupportedOpcode(CALLF_opcode), "support opcode failed");

        // should not add already supported opcode
        vm.expectRevert(OpcodesBitmap.AlreadySupported.selector);
        opcodesBitmap.supportOpcode(CALLF_opcode);
    }

    function test_deprecateOpcode() external {
        // can deprecate opcode
        uint8 CALLF_opcode = 0xe3;
        opcodesBitmap.supportOpcode(CALLF_opcode);
        assertTrue(opcodesBitmap.isSupportedOpcode(CALLF_opcode), "opcode should be supported");

        // should deprecate opcode successfully
        opcodesBitmap.deprecateOpcode(CALLF_opcode);
        assertFalse(opcodesBitmap.isSupportedOpcode(CALLF_opcode), "opcode should be unsupported");

        // should not deprecate unsupported opcode
        vm.expectRevert(OpcodesBitmap.NotSupported.selector);
        opcodesBitmap.deprecateOpcode(CALLF_opcode);
    }
}
